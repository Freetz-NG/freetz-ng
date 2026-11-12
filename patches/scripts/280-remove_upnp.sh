[ "$FREETZ_REMOVE_UPNP" == "y" ] || return 0
echo1 "removing AVM UPnP daemon (igdd or upnpd or upnpdevd)"

rm_files \
  $(find ${FILESYSTEM_MOD_DIR}/sbin -maxdepth 1 -type f -name upnpdevd -o -name upnpd -o -name igdd | xargs) \
  $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name 'any.xml' -o -name 'fbox*.xml') \
  $(find ${FILESYSTEM_MOD_DIR}/etc -maxdepth 1 -type d -name 'default.*' | xargs -I{} find {} -name '*igd*')
[ "$FREETZ_REMOVE_UPNP_LIBS" == "y" ] && rm_files $(ls -1 ${FILESYSTEM_MOD_DIR}/lib/libavmupnp*)

# html: Geraete und Benutzer
modsed "/.*javascript:doNetPage('upnp').*/d" "${HTML_SPEC_MOD_DIR}/home/clients.html"
# html: Netzwerkeinstellungen
modsed "/.*javascript:DoTabsUpnp().*/d" "${HTML_SPEC_MOD_DIR}/system/net.html"
# patcht Heimetz > Netzwerk > Programme (lua)
[ "$FREETZ_AVM_VERSION_07_2X_MAX" == "y" ] && menulua_remove "upnp"
# patcht Internet > Freigaben > Portfreigaben > Änderungen der Sicherheitseinstellungen über UPnP gestatten
sedfile="${HTML_LANG_MOD_DIR}/internet/port_fw.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	mod_del_area \
	  'id="ui_ShowUpnpControl"' \
	  -2 \
	  '{?4497:315?}' \
	  +5 \
	  $sedfile
fi	
# patcht Heimnetz > Netzwerk > Netzwerkeinstellungen > Heimnetzfreigaben > Statusinformationen über UPnP übertragen
sedfile="${HTML_LANG_MOD_DIR}/net/network_settings.lua"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	#<input type="checkbox" id="uiViewUpnpAktiv" name="upnp_activ" <?lua if g_var.upnp_activ then box.out('checked') end ?>>
	#<label for="uiViewUpnpAktiv">{?859:341?}</label>
	#<p class="form_checkbox_explain">
	#{?859:536?}
	#</p>
	mod_del_area \
	  'id="uiViewUpnpAktiv"' \
	  0 \
	  '{?859:536?}' \
	  1 \
	  $sedfile
	# remove_upnp removes the header if also selected
fi

_upnp_file="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
for _upnp_name in upnpdevdstart upnpdstart _upnp_name; do
	grep -q "^$_upnp_name *()" $_upnp_file || continue
	echo1 "patching rc.net: renaming $_upnp_name()"
	modsed "s/^\($_upnp_name *()\)/\1\n{ return; }\n_\1/" "$_upnp_file" "_$_upnp_name"
done

supervisor_delete_service "upnpd"

echo1 "patching rc.conf"
modsed "s/CONFIG_UPNP=.*$/CONFIG_UPNP=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"

#
#echo1 "patching rc.net: removing igdd"
#modsed "s/igdd websrv/multid/g" "$_upnp_file"
#modsed "s/igdd multid/multid/g" "$_upnp_file"
#
#echo1 "patching prepare_fwupgrade: removing igdd"
#modsed '/killall.*igdd/d' "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
#modsed '/.*igdd -s/d'     "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
#modsed 's/ igdd / /g'     "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"

