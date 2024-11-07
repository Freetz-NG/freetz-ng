isFreetzType 3490_7490 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 3490"

echo2 "copying install script"
cp -p "${DIR}/.tk/original/firmware/var/install" "${DIR}/modified/firmware/var/install"
VERSION=`grep "newFWver=0" "${DIR}/original/firmware/var/install" | sed -n 's/newFWver=\(.*\)/\1/p'`
modsed "s/^newFWver=.*$/newFWver=${VERSION}/g" "${DIR}/modified/firmware/var/install"

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW212

echo2 "patching rc.S and rc.conf"
# Telephony
modsed 's/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT="0"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_T38=.*$/CONFIG_T38="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/\(CONFIG_.*FON.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # FON
modsed "s/\(CONFIG_.*CAPI.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  # CAPI
modsed "s/\(CONFIG_.*FAX.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # FAX

# ProductInfo
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW212"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 3490"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="140"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "copying missing files"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S11-piglet" "${FILESYSTEM_MOD_DIR}/etc/init.d"

echo2 "deleting obsolete files"
for i in \
  /bin/supportdata.dect \
  /etc/templates/fax_rcv_message* \
  /etc/templates/fax_send_message* \
  /lib/libfax*.so* \
  /lib/libfbpbook.so \
  /lib/libfoncclient.so \
  /lib/modules/3.10.107/kernel/drivers/char/Piglet_noemif* \
  /lib/modules/bitfile*.bit \
  /sbin/carddavd \
  /usr/bin/faxd \
  /usr/share/configd/dectmediadefault.xml \
  /usr/share/telefon/fax-test.pdf \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "deleting obsolete webui files"
for i in \
  /usr/www/all/assis/assi_fax_intern.lua \
  /usr/www/all/css/rd/arrow.css \
  /usr/www/all/css/rd/elements/elem_buttons_aus_blue.png \
  /usr/www/all/css/rd/elements/elem_buttons_ein_blue.png \
  /usr/www/all/css/rd/icons/ic_dect_* \
  /usr/www/all/css/rd/illustrations/illu_avmRepeater.png \
  /usr/www/all/css/rd/illustrations/illu_dect* \
  /usr/www/all/css/rd/images/img_dect_* \
  /usr/www/all/css/rd/selection_area.css \
  /usr/www/all/fon_devices* \
  /usr/www/all/html/moh_failed.html \
  /usr/www/all/html/moh_ok.html \
  /usr/www/all/html/phonebook_* \
  /usr/www/all/js/arrow.js \
  /usr/www/all/js/ha_sets.js \
  /usr/www/all/js/ha_switch_timer.js \
  /usr/www/all/js/selection_area.js \
  /usr/www/all/js/sffcoder.js \
  /usr/www/all/js/text2canvas.js \
  ; do	
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

# patch install script to accept firmware from 7490
echo2 "applying install patch"
modsed "s/mips34_512MB_xilinx_vdsl_dect446_4geth_2ab_isdn_nt_te_pots_2usb_host_wlan11n_27490/mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525/g" "${FIRMWARE_MOD_DIR}/var/install"

