[ "$FREETZ_REMOVE_DECT" == "y" ] || return 0
echo1 "removing DECT files"

for files in \
  bin/supportdata.dect \
  sbin/start_dect_update.sh \
  usr/bin/dect_manager \
  usr/share/ctlmgr/libdect.so \
  etc/avm_firmware_public_key3 \
  $(find ${FILESYSTEM_MOD_DIR} -iwholename "*usr/www/*dect*" -a ! -path "*/js3/data/*" -printf "%P\n") \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done

# don't patch this in firmwares < 05.5x (see #2056)
if [ "$FREETZ_AVM_VERSION_05_5X_MIN" == "y" ]; then
for files in \
  lib/modules/dectfw_firstlevel.hex \
  lib/modules/dectfw_secondlevel.hex \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$files"
done
fi

[ "$FREETZ_REMOVE_TELEPHONY" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/dectfw_*"

if [ "$FREETZ_AVM_HAS_MODTEMP" != "y" -o "$FREETZ_AVM_VERSION_04_XX_MAX" == "y" ]; then
	rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name "*dect*.ko")
	for file in S17-isdn S17-capi E41-capi; do
		[ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/$file" ] && modsed '/dect_io/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/$file"
	done
fi

[ "$FREETZ_REMOVE_MINID" == "y" ] && rm_files "${FILESYSTEM_MOD_DIR}/lib/libfoncclient.so*"

echo1 "patching web UI"
modsed "s/document.write(Dect.\{1,10\}(.*))//g" "${HTML_SPEC_MOD_DIR}/home/home.html"
modsed "/jslGoTo('dect'/d;/^<?.*[dD]ect.*?>$/d" "${HTML_SPEC_MOD_DIR}/menus/menu2_konfig.html"
menu2html_remove dect

# patcht Heimnetz > Mediaserver
menulua_remove "dect.internetradio" "/media-server/internet-radio"
menulua_remove "dect.podcast" "/media-server/podcast"

# don't patch this in firmwares < 05.5x (see Ticket #2056)
if [ "$FREETZ_AVM_VERSION_05_5X_MIN" == "y" ]; then
	MODPROBEPIGLET=$(grep -l -i dect_firstlevelfile "${FILESYSTEM_MOD_DIR}/etc/init.d/"* 2>/dev/null)
	if [ -e "$MODPROBEPIGLET" ]; then
		echo1 "patching ${MODPROBEPIGLET##*/}"
		modsed '/^dect_[a-z]*levelfile=/ d; s!dect_[a-z]*levelfile=[^ ]*\level.hex!!g; s!.*dect_io.*!#&!' $MODPROBEPIGLET
	fi
fi

MODPROBEDECT=$(grep -l -i -e "^modprobe dect_io$" "${FILESYSTEM_MOD_DIR}/etc/init.d/"* 2>/dev/null)
if [ -e "$MODPROBEDECT" ]; then
	echo1 "patching ${MODPROBEDECT##*/}"
	if [ "$FREETZ_AVM_HAS_MODTEMP" == "y" -a "$FREETZ_AVM_VERSION_05_2X_MIN" != "y" ]; then
	modsed 's/^modprobe dect_io$/&\nrmmod dect_io/' $MODPROBEDECT
	else
	modsed '/^modprobe dect_io$/d' $MODPROBEDECT
	fi
fi

echo1 "patching rc.conf"
modsed "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

