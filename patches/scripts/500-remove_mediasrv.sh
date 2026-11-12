remove_plugin() {
[ "$FREETZ_AVMPLUGINS_INTEGRATE" == "y" ] || return 1
[ "$FREETZ_AVM_HAS_PLUGIN_MEDIASRV" != "y" ] && return 1
[ "$FREETZ_AVMPLUGINS_MEDIASRV" == "y" ] && return 1
return 0  # remove plugin
}
remove_plugin || [ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0
echo1 "remove mediasrv"

# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)

sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
if [ -e "${HTML_LANG_MOD_DIR}/storage/media_settings.lua" ]; then
	# entfernt Heimnetz > Mediaserver (06.xx)
	menulua_remove "storage.media_settings" "/media-server"
	menulua_remove "dect.internetradio" "/media-server/internet-radio"
	menulua_remove "dect.podcast" "/media-server/podcast"
	# Heimnetz > Speicher (NAS) > Speicher an der FRITZ!Box > Speicher (NAS) aktiv > Datei-Index
	if [ -e $sedfile ]; then
		modsed 's!function get_scan_state.*!&\nif true then return "" end!g' $sedfile
		modsed 's/{?80:755?}//'  $sedfile
	fi
else
	if [ -e $sedfile ]; then
		echo1 "patching ${sedfile##*/}"
		if grep -q uiViewUseMusikBox $sedfile; then
			# patcht Heimnetz > Speicher (NAS) > Aktivierung > Musikbox aktiv (04.xx)
			mod_del_area \
			  'id="uiViewUseMusikBox"' \
			  -1 \
			  '{?80:1383?}' \
			  +2 \
			  $sedfile
		else
			# patcht Heimnetz > Speicher (NAS) > Speicher (NAS) > Mediaserver (05.xx)
			mod_del_area \
			  '<h4>{?80:609?}<.h4>' \
			  -2 \
			  '{?80:1383?}' \
			  +1 \
			  $sedfile
		fi
	fi
fi

# see #1391 for details
[ -e $sedfile ] && modsed "s/call_webusb.call_webusb_func(\"scan_info\".*)/\"\" -- &/g" "$sedfile"


echo1 "patching rc.conf"
modsed "s/CONFIG_MEDIASRV=.*$/CONFIG_MEDIASRV=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

[ "$FREETZ_REMOVE_MEDIASRV" == "y" ] || return 0

echo1 "remove mediasrv files"
for files in \
  lib/libpng.so* \
  lib/libmediasrv.so* \
  lib/libstationurl.so* \
  sbin/mediasrv \
  sbin/start_mediasrv \
  sbin/stop_mediasrv \
  etc/init.d/rc.media \
  etc/init.d/S76-media \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# don't remove libwebusb*.so, see Ticket #2020
modsed -r 's/(CONFIG_WEBUSB)=.*$/\1="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
# MEDIASRV & NAS are using this file
[ "$FREETZ_REMOVE_NAS" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmdb.so*"
# MEDIASRV & UPNP (started by NAS) are using this file
[ "$FREETZ_REMOVE_UPNP" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libsqlite3*.so*"
modsed -r 's/(CONFIG_SQLITE)=.*$/\1="n"/g'        "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed -r 's/(CONFIG_SQLITE_BILDER)=.*$/\1="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed -r 's/(CONFIG_SQLITE_VIDEO)=.*$/\1="n"/g'  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
# MEDIASRV & MINID are using this file
[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libavmid3*.so*"

if [ -e "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html" ]; then
	echo1 "patching Web UI"
	modsed "/^<p.*uiViewUseMusik.*<\/p>$/ {
	  N
	  s/\n//g
	  D }" "${HTML_SPEC_MOD_DIR}/nas/einstellungen.html"
fi

# patcht Heimnetz > Mediaserver
menulua_remove "dect.internetradio" "/media-server/internet-radio"
menulua_remove "dect.podcast" "/media-server/podcast"

# patcht Dect > Internetdienste
[ "$FREETZ_AVM_HAS_DECT" == "y" ] && menulua_remove "dect.radiopodcast" "/devices/radio"

# patcht USB-Geraete > USB-Speicher >  Musikbox aktivieren
mod_del_area \
  '"uiViewUseMusik"' \
  -1 \
  +2 \
  "${HTML_SPEC_MOD_DIR}/usb/usbdisk.html"

