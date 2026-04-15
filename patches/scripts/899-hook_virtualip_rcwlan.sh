[ "$FREETZ_PACKAGE_VIRTUALIP_CGI" == "y" ] || return 0

if [ -r "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf" ] && \
	grep -Eq '^CONFIG_WLAN="?n"?$' "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"; then
	echo2 "skipping virtualip wlan hook: device has no WLAN"
	return 0
fi

echo1 "hooking virtualip into rc.wlan"

found=0
for file in \
	"$FILESYSTEM_MOD_DIR/etc/init.d/rc.wlan" \
	"$VARTAR_MOD_DIR/etc/init.d/rc.wlan"; do
	[ -e "$file" ] || continue
	found=1
	echo2 "patching $file"

	# Add helper before start_wlan() if missing.
	modsed '/^start_wlan()/i\
virtualip_wlan_loadcfg() {\
	VIRTUALIP_ENABLED=no\
	if [ -r /mod/etc/conf/virtualip.cfg ]; then\
		. /mod/etc/conf/virtualip.cfg\
	fi\
}\
\
virtualip_wlan_dbglog() {\
	reason="$1"\
	virtualip_wlan_loadcfg\
	if [ -e /var/run/virtualip.online_ready ]; then\
		online_ready=yes\
	else\
		online_ready=no\
	fi\
	[ "$VIRTUALIP_DEBUG" = "yes" ] || return 0\
	printf "%s [   VIRTUALIP   ] rc.wlan hook fired: reason=%s enabled=%s online_ready=%s\\n" "$(date "+%F %T")" "$reason" "$VIRTUALIP_ENABLED" "$online_ready" >>/var/log/freetz.log 2>/dev/null\
}\
\
virtualip_wlan_reapply() {\
	virtualip_wlan_loadcfg\
	[ "$VIRTUALIP_ENABLED" = "yes" ] || return 0\
\tif [ -x /mod/etc/init.d/rc.virtualip ]; then\
		BOOT_START=1 /mod/etc/init.d/rc.virtualip start >/dev/null 2>&1\
\telif [ -x /etc/init.d/rc.virtualip ]; then\
		BOOT_START=1 /etc/init.d/rc.virtualip start >/dev/null 2>&1\
\tfi\
}\
' \
		"$file" \
		"virtualip_wlan_reapply()"

	# Trigger after normal wlan daemon start.
	modsed '/^[ \t]*wland$/a\
\t# virtualip-wlan-start-hook\
	( sleep ${VIRTUALIP_WLAN_DELAY_SECS:-8}; virtualip_wlan_dbglog start; virtualip_wlan_reapply; sleep ${VIRTUALIP_WLAN_RETRY_SECS:-20}; virtualip_wlan_dbglog start-retry; virtualip_wlan_reapply ) \&\
' \
		"$file" \
		"virtualip-wlan-start-hook"

	# Trigger after wlan daemon reconfig (HUP).
	modsed '/killall -HUP wland/a\
\t# virtualip-wlan-reconfig-hook\
	( sleep ${VIRTUALIP_WLAN_DELAY_SECS:-8}; virtualip_wlan_dbglog reconfig; virtualip_wlan_reapply; sleep ${VIRTUALIP_WLAN_RETRY_SECS:-20}; virtualip_wlan_dbglog reconfig-retry; virtualip_wlan_reapply ) \&\
' \
		"$file" \
		"virtualip-wlan-reconfig-hook"
done

[ "$found" -eq 1 ] || echo2 "no rc.wlan found, skipping"
