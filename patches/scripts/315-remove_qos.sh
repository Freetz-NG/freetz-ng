[ "$FREETZ_REMOVE_QOS" == "y" ] || return 0
echo1 "removing qos files"

[ -e "${HTML_LANG_MOD_DIR}/internet/trafapp.lua" ] && traf="trafapp" || traf="trafficappl"
rm_files \
  "${MODULES_DIR}/kernel/net/sched/" \
  "${FILESYSTEM_MOD_DIR}/sbin/qos" \
  "${FILESYSTEM_MOD_DIR}/sbin/tc" \
  "${HTML_SPEC_MOD_DIR}/internet/trafficappl*" \
  "${HTML_SPEC_MOD_DIR}/internet/trafficprio*" \
  "${HTML_SPEC_MOD_DIR}/internet/trafficprotocol*" \
  "${HTML_LANG_MOD_DIR}/internet/traf*.lua"

# entfernet Internet > Filter (von 'Kindersicherung' mitgenutzt)
if [ "$FREETZ_REMOVE_KIDS" == "y" ]; then
	modsed 's/\(setvariable var:showKids \)./\10/g' "${HTML_SPEC_MOD_DIR}/menus/menu2_internet.html"
fi

# patcht Internet > Priorisierung
sedfile="${HTML_SPEC_MOD_DIR}/menus/menu2_internet.html"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed "/.*('internet','qos_meter').*/d" $sedfile
fi

if [ "$FREETZ_TYPE_EXTENDER" != "y" ]; then
	# patcht Internet > Filter > Priorisierung
	menulua_remove "trafficprio" "/filter/priority"
	# patcht Internet > Filter > Listen
	menulua_remove "$traf" "/filter/lists"
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_NQOS=y/CONFIG_NQOS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
modsed "s/CONFIG_QOS_METER=y/CONFIG_QOS_METER=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"

