#!/bin/sh

[ -z "$1" ] && [ -e /tmp/.mod.started ] && echo "Freetz-NG is yet started!" && exit 1

DAEMON=mod
. /etc/init.d/modlibrc
[ -r /etc/options.cfg ] && . /etc/options.cfg

log() {
	while read -r line; do
		[ -z "$line" ] && continue
		loglib_system "RCMOD" "$line"
		[ -n "$LOG2FILE" ] && echo "$line" >> /var/log/mod.log
	done
}


vulcheck_2014() {
	[ "$FREETZ_AVM_HAS_CVE_2014_9727" != "y" ] && return
	# 04.55 is the version of the first firmware with support for remote access (according to AVM)
	# 27349 is the revision of the first firmware remote access vulnerability has been fixed in
	# https://vuldb.com/de/?id.75594 CVSS Meta Temp Score 7.1
	echo "Firmware with remote access vulnerability detected."
	if [ ! -e /tmp/flash/mod/dont_touch_https ]; then
		echo "Remote access via https will be disabled. Create /tmp/flash/mod/dont_touch_https if you don't want this behavior."
		ctlmgr_ctl w remoteman settings/enabled 0 >/dev/null 2>&1
	fi
}

vulcheck_2023() {
	[ "$UPSI_2023_TR064CGI" != "y" ] && return
	# ZERO info by AVM about vulnerabilty, tr064cgi binary exists since FOS 05.2x. Up to FOS 6.0x (Sep 2015) it seems to be safe as 7270 v2+v3 and 7240 got no fixes.
	# Now 1 week later also extender get fixes, regardingless of existence of tr064cgi binary. Extender with FOS 7.56 (Jun 2023) have no longer the file.
	# As Extender without tr064cgi binary get the fixes too, the bug seems to be in arguments handling of avm's own developed closed-source webserver.
	# Seems there are multiple vulerabilities, as without tr064cgi binary (=Extender), only libwebsrv.so.2.0.0 is changed, libcmapi.so.1.0.0 not.
	# https://wid.cert-bund.de/portal/wid/securityadvisory?name=WID-SEC-2023-2262 CVSS Base Score first 7.1, now 7.3
	# rev38787-svn / rev107809-git is the revision of the first firmware found tr064cgi vulnerability has been fixed in.
	echo "Firmware with tr064cgi vulnerability detected."
	if [ ! -e /tmp/flash/mod/dont_touch_tr064cgi ]; then
		echo "Remote access via https will be disabled. Create /tmp/flash/mod/dont_touch_tr064cgi if you don't want this behavior."
		ctlmgr_ctl w remoteman settings/enabled 0 >/dev/null 2>&1
	fi
}

utmp_wtmp() {
	#utmp
	if [ "$FREETZ_BUSYBOX_FEATURE_UTMP" == "y" ]; then
		[ ! -e /var/run/utmp ] && touch /var/run/utmp
	fi
	#wtmp
	if [ "$FREETZ_BUSYBOX_FEATURE_WTMP" == "y" ]; then
		local WTMP="${MOD_PATH_WTMP}/"
		if [ "${WTMP#/var/log/}" != "$WTMP" ]; then
			# file, /var/log
			[ -L /var/log/wtmp ] && rm -rf /var/log/wtmp
			[ ! -e /var/log/wtmp ] && touch /var/log/wtmp
		else
			# link, other dir
			rm -rf /var/log/wtmp 2>/dev/null
			ln -s "${MOD_PATH_WTMP%/}/wtmp" /var/log/wtmp
			[ ! -e "${MOD_PATH_WTMP%/}/wtmp" ] && touch "${MOD_PATH_WTMP%/}/wtmp" 2>/dev/null
		fi
	fi
}

wlan_up() {
	[ "$FREETZ_PATCH_START_WLAN_IF_ON_BOOT" != "y" ] && return
	echo -n "Starting wlan interface ... "
	if [ ! -e /sys/class/net/wlan/operstate ]; then
		echo "unavailable."
	elif grep "^up$" /sys/class/net/wlan/operstate; then
		echo "skipped."
	else
		ifconfig wlan up && echo "done." || echo "failed."
	fi
}

motd() {
	( [ -e /tmp/flash/mod/motd ] && sh /tmp/flash/mod/motd || sh /mod/etc/default.mod/motd )> /etc/motd
}

ar7lite() {
	[ -z "$FREETZ_AVM_HAS_AR7_LITE" ] && return
	local fit="/var/media/ftp/fit-image/${CONFIG_VERSION//\./-}-$(/etc/version --project 2>/dev/null).fit"
	[ -e "$fit" ] && return
	echo "For the fiber module you need a unmodified fit-image. Extract this"
	echo "file from an AVM firmware and place it on the internal storage as:"
	echo "$fit"
}

update_lfs() {
	[ -x /usr/bin/bootmanager ] && return
	[ "$FREETZ_AVM_PROP_INNER_FILESYSTEM_TYPE_CPIO" == "y" ] && return
	[ ! -e /usr/mww/cgi-bin/system_lfs.cgi ] && return
	[ "$MOD_UPDATE_LFS" != "yes" ] && return
	echo -n "Updating lfs cache ... "
	nohup /usr/mww/cgi-bin/system_lfs.cgi startup 0</dev/null 1>/dev/null 2>&1 &
	echo "asynchronous."
}

start() {
	echo "Freetz-NG version $(sed 's/^freetz-//;s/^ng-//' /etc/.freetz-version)"

	# Basic Packages: links
	for pkg in crond telnetd webcfg stickymon dsld ftpd rextd multid swap external websrv smbd; do
		local pkg_default=/etc/default.$pkg
		[ -d "$pkg_default" -a ! -e "/mod${pkg_default}" ] && ln -s "$pkg_default" "/mod${pkg_default}"
		local rc="/etc/init.d/rc.$pkg"
		[ -e "$rc" -a ! -e "/mod$rc" ] && ln -s "$rc" "/mod$rc"
	done

	[ -d /tmp/flash ] || /usr/bin/modload

	# udev: reload rules after link targets are unpacked
	[ "$FREETZ_CUSTOM_UDEV_RULES" == "y" ] && udevadm control --reload-rules

	# avm watchdog
	if [ "$FREETZ_PATCH_DISABLE_AVM_WATCHDOG" == "y" ]; then
		echo -n "Disabling avm watchdog ... "
		if [ ! -c /dev/watchdog ]; then
			echo "unavailable."
		else
			echo init-done > /dev/watchdog && echo disable > /dev/watchdog && echo "done." || echo "failed."
		fi
	fi

	# set ipv6
	if [ "$FREETZ_TARGET_IPV6_SUPPORT" == "y" -a -d /proc/sys/net/ipv6 ]; then
		echo "$MOD_IPV6_ASSIGN" | grep -v "^ *#" | while read -r if6 ip6; do
			[ -n "$if6" -a -n "$ip6" ] && ifconfig $if6 $ip6
		done
		[ "$MOD_IPV6_FORWARD" == "yes" ] && echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
	fi

	# Basic Packages: load
	for pkg in crond telnetd webcfg stickymon dsld ftpd rextd multid swap external websrv; do
		local rc="/etc/init.d/rc.$pkg"
		[ -x "$rc" ] && "$rc"
	done

	# Static Packages
	if [ -x /mod/etc/init.d/rc.external ]; then
		[ "$MOD_EXTERNAL_FREETZ_SERVICES" == "yes" ] && EXTERNAL_SERVICES="$(cat /mod/etc/external.pkg 2>/dev/null)"
		EXTERNAL_SERVICES=" $EXTERNAL_SERVICES $(echo $MOD_EXTERNAL_OWN_SERVICES | tr '\n' ' ') "
	fi
	for pkg in $(cat /etc/static.pkg 2>/dev/null); do
		[ "$pkg" = mod ] && continue
		local rc="/etc/init.d/rc.$pkg"
		if [ -x "$rc" ]; then
			if echo "$EXTERNAL_SERVICES" | grep -q " $pkg "; then
				local long="$(sed -n "s/^DAEMON_LONG_NAME=[\"' ]*\([^\""\$"' ]*\).*/\1/p" "$rc")"
				echo "${long:-$pkg} will be started by external."
			else
				"$rc"
			fi
		fi
	done

	# AVM-Plugins
	plugins=$(ls /var/plugin-*/control 2>/dev/null)
	if [ -n "$plugins" ]; then
		echo -n "Starting AVM-Plugins"
		for plugin in $plugins; do
			echo -n " ... $(echo $plugin | sed 's/.*plugin-//;s/\/.*//')"
			$plugin start >/dev/null 2>&1
			[ $? -ne 0 ] && echo -n "(failed)"
		done
		echo " ... done."
	fi

	vulcheck_2014
	vulcheck_2023
	utmp_wtmp
	wlan_up
	motd
	ar7lite
	update_lfs

	if [ -s /tmp/flash/mod/rc.custom ]; then
		echo -n "Starting rc.custom ... "
		nohup sh /tmp/flash/mod/rc.custom 0</dev/null 1>/var/log/rc_custom.log 2>&1 &
		echo "asynchronous."
	fi

	# 7390: external hook for nand flash, if NAND exists it is mounted under /var/media/ftp
	if [ "$CONFIG_NAND" = 'y' -a -f "$MOD_EXTERNAL_DIRECTORY"/.external ] &&
	  df -P "$MOD_EXTERNAL_DIRECTORY" | tail -n1 | grep -q " /var/media/ftp$"; then
		echo "Detected external on ... internal storage."
		nohup /mod/etc/init.d/rc.external start 0</dev/null 1>/dev/null 2>&1 &
	fi

	/usr/lib/mod/menu-update
	echo "Startup finished."
	touch /tmp/.mod.started
}


stop_helper() {
	for pkg in $*; do
		[ "$pkg" = mod ] && continue
		local rc="/etc/init.d/rc.$pkg"
		[ -x "$rc" ] && "$rc" stop | sed "s,^,$pkg: ,g"
	done
}

stop() {
	echo "Stopping all packages:"

	[ -n "$MOD_SHUTDOWN_FIRST" ] && stop_helper $MOD_SHUTDOWN_FIRST

	local all_packages=""
	for pkg in $(cat /etc/static.pkg 2>/dev/null) crond telnetd webcfg stickymon dsld ftpd rextd multid; do
		if ! echo " $MOD_SHUTDOWN_FIRST $MOD_SHUTDOWN_IGNORE $MOD_SHUTDOWN_LAST " | grep -q " $pkg "; then
			all_packages="$all_packages $pkg"
		fi
	done
	stop_helper $all_packages

	[ -n "$MOD_SHUTDOWN_LAST" ] && stop_helper $MOD_SHUTDOWN_LAST

	echo "Stopping all packages finished."
}


modreg_file() {
	local file=$1 sec_level=$2
	local basename=${file//./_}
	modreg file mod "$basename" "$file" "$sec_level" "$basename"
}

register() {
	AUML="$(echo -ne '\344')"

	modreg cgi mod "Freetz-NG"
	modreg conf mod webcfg "$(lang de:"Weboberfl${AUML}che" en:"Web interface")"
	modreg cgi avm "$(lang de:"AVM-Dienste" en:"AVM services")"

	modreg_file  .profile    0
	modreg_file  hosts       1
	modreg_file  modules     0
	modreg_file  rc.custom   0
	modreg_file  shutdown    0
	[ -h /usr/bin/dtrace ] && modreg_file dtrace 0
	[ -h /etc/udev/rules.d/00-custom.rules ] && modreg_file udev_first 0
	[ -h /etc/udev/rules.d/99-custom.rules ] && modreg_file udev_final 0

	/usr/lib/mod/reg-status start
}


case $1 in
	"")
		register
		LOG2FILE="y"
		start 2>&1 | log
		;;
	start)
		start
		;;
	stop)
		stop
		;;
	halt)
		stop 2>&1 | log
		;;
	config)
		utmp_wtmp
		;;
	motd)
		echo -n "Updating motd ... "
		motd
		echo "done."
		;;
	*)
		echo "Usage: $0 [start|stop|motd]" 1>&2
		exit 1
		;;
esac
