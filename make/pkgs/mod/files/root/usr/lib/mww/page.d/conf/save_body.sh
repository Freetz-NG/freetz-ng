. /usr/lib/cgi-bin/mod/modlibcgi

start_stop() {
	local startORstop=$1
	local package=$2
	local oldstatus=$3
	local rc="/mod/etc/init.d/rc.${4-$2}"
	[ ! -x "$rc" ] && return
	case "$startORstop" in
		start)
			local newstatus=$(rc_status ${4-$2})
			[ "$oldstatus" == inetd -a "$newstatus" != inetd ] && /mod/etc/init.d/rc.inetd config "$package"

			# NB: This changes daemon's status when switching to inetd mode
			# and daemon was stopped before. Please review when dynamic
			# inetd is implemented.
			[ "$oldstatus" != stopped -o "$newstatus" == inetd ] && "$rc" start
			;;
		stop)
			[ "$oldstatus" != stopped ] && "$rc" stop
			;;
	esac
}

apply_changes() {
	local startORstop=$1
	local package=$2
	case "$package" in
		avm)
			start_stop $startORstop telnetd "$OLDSTATUS_telnetd"
			start_stop $startORstop multid "$OLDSTATUS_multid"
			start_stop $startORstop rextd "$OLDSTATUS_rextd"
			start_stop $startORstop websrv "$OLDSTATUS_websrv"
			;;
		mod)
			start_stop $startORstop swap "$OLDSTATUS_swap"
			# external
			if [ -x /mod/etc/init.d/rc.external ]; then
				if [ "$startORstop" == "stop" ]; then
					NEW_EXTERNAL_DIRECTORY="$(echo "$settings" | sed -ne "/MOD_EXTERNAL_DIRECTORY/s/MOD_EXTERNAL_DIRECTORY='\(.*\)'/\1/p")"
					[ "$MOD_EXTERNAL_DIRECTORY" != "$NEW_EXTERNAL_DIRECTORY" ] && RELOAD_external="true"
					NEW_EXTERNAL_BEHAVIOUR="$(echo "$settings" | sed -ne "/MOD_EXTERNAL_BEHAVIOUR/s/MOD_EXTERNAL_BEHAVIOUR='\(.*\)'/\1/p")"
					[ "$MOD_EXTERNAL_BEHAVIOUR" != "$NEW_EXTERNAL_BEHAVIOUR" ] && RELOAD_external="true"
				fi
				[ "$RELOAD_external" == "true" ] && start_stop $startORstop external "$OLDSTATUS_external"
			fi
			#webcfg
			if [ "$startORstop" == "start" -a "$OLDSTATUS_webcfg" != "stopped" ]; then
				echo "$(lang de:"Starte das Freetz-NG Webinterface in 9 Sekunden neu" en:"Restarting the Freetz-NG webinterface in 9 seconds")!"
				/mod/etc/init.d/rc.webcfg force-restart 9 >/dev/null 2>&1 &
			fi
			/usr/lib/mod/reg-status reload
			/usr/bin/modhosts load
			/mod/etc/init.d/rc.mod config
			;;
		*)
			start_stop $startORstop "$package" "$OLDSTATUS_PACKAGE"
			;;
	esac
}

rc_status() {
	local rc="/mod/etc/init.d/rc.$1"
	if [ -x "$rc" ]; then
		"$rc" status
	fi
}

default=false
case $QUERY_STRING in
	*default*) default=true ;;
	stop|start|restart) SERVICE_CMD=$QUERY_STRING ;;
esac

if [ -n "$SERVICE_CMD" ]; then
	eval "$(modcgi rc package)"
	SERVICE_PKG=/mod/etc/reg/pkg.reg
	description="$(sed -n "s/^$PACKAGE_RC|//p" "$SERVICE_PKG")"

	# redirect stderr to stdout so we see output in webif
	exec 2>&1

	case $SERVICE_CMD in
		start)   message="$(lang de:"Starte" en:"Starting")" ;;
		stop)    message="$(lang de:"Stoppe" en:"Stopping")" ;;
		restart) message="$(lang de:"Restarte" en:"Restarting")" ;;
	esac

	echo "<div id='result'>"
	echo -n "<p>$message ${description:-$PACKAGE_RC}:</p><pre class='log.small'>"
	"/mod/etc/init.d/rc.$PACKAGE_RC" "$SERVICE_CMD" | html | highlight
	echo '</pre>'
	echo "</div>"

	exit
fi

package=$PACKAGE

if $default; then
	echo "<p>$(lang de:"Konfiguration zur&uuml;cksetzen" en:"Restore default settings") ($PACKAGE_TITLE):</p>"
else
	echo "<p>$(lang de:"Konfiguration speichern" en:"Saving settings") ($PACKAGE_TITLE):</p>"
fi
echo -n "<pre class='log.small'>"

# redirect stderr to stdout so we see output in webif
exec 2>&1

back="mod status"
unset OLDSTATUS_telnetd OLDSTATUS_multid OLDSTATUS_rextd OLDSTATUS_websrv OLDSTATUS_swap OLDSTATUS_external RELOAD_external OLDSTATUS_webcfg

if $default; then
	hook=def
else
	hook=save
fi

# default functions for $package.save
#apply
pkg_pre_save() { :; }
pkg_apply_save() { :; }
pkg_post_save() { :; }
#default
pkg_pre_def() { :; }
pkg_apply_def() { :; }
pkg_post_def() { :; }
#both
pkg_pre() { pkg_pre_$1; }
pkg_apply() { pkg_apply_$1; }
pkg_post() { pkg_post_$1; }

# load package's implementation of these functions
if [ -r "/mod/etc/default.$package/$package.save" ]; then
	source "/mod/etc/default.$package/$package.save"
fi

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	case "$package" in
		avm)
			back="cgi $package"
			OLDSTATUS_telnetd=$(rc_status "telnetd")
			OLDSTATUS_multid=$(rc_status "multid")
			OLDSTATUS_rextd=$(rc_status "rextd")
			OLDSTATUS_websrv=$(rc_status "websrv")
			;;
		mod)
			back="mod conf"
			OLDSTATUS_swap=$(rc_status swap)
			OLDSTATUS_external=$(rc_status external)
			OLDSTATUS_webcfg=$(rc_status webcfg)
			;;
		*)
			back="cgi $package"
			OLDSTATUS_PACKAGE=$(rc_status "$package")
			;;
	esac
	if ! $default; then
		prefix="$(echo "$package" | tr 'a-z\-' 'A-Z_')_"

		unset vars
		for var in $(modconf vars "$package"); do
			vars="${vars:+$vars:}${var#$prefix}"
		done

		settings=$(modcgi "$vars" "$package")
	fi
fi

pkg_pre $hook | html | highlight

if [ -r "/mod/etc/default.$package/$package.cfg" ]; then
	apply_changes stop "$package"
	echo
	if ! $default; then
		echo -n 'Saving settings ... '
		echo "$settings" | modconf set "$package" -
		echo 'done.'
		echo -n "Saving $package.cfg ... "
		modconf save "$package"
		echo 'done.'
	else
		echo -n 'Restoring defaults ... '
		modconf default "$package"
		echo 'done.'
	fi
	echo
	{
		apply_changes start "$package"
		pkg_apply $hook
		echo
		modsave flash
	} | html
fi | while read line; do echo $line | highlight; done

pkg_post $hook | html | highlight

echo '</pre>'

