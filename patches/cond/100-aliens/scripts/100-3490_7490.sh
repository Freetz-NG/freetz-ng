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

echo2 "creating missing oem symlinks"
if isFreetzType LANG_EN; then
	ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW212/avme"
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avm"
else
	ln -sf all "${FILESYSTEM_MOD_DIR}/usr/www/avme"
fi

echo2 "patching rc.S and rc.conf"
# Telephony
modsed 's/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT="0"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_T38=.*$/CONFIG_T38="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/\(CONFIG_.*FON.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # FON
modsed "s/\(CONFIG_.*CAPI.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  # CAPI
modsed "s/\(CONFIG_.*FAX.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # FAX
modsed "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  # DECT

# AHA
modsed 's/CONFIG_DECT_HOME=.*$/CONFIG_DECT_HOME="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_HOME_AUTO=.*$/CONFIG_HOME_AUTO="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_HOME_AUTO_NET=.*$/CONFIG_HOME_AUTO_NET="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# ProductInfo
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW212"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 3490"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="140"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "copying missing files"
cp -pd "${DIR}/.tk/original/filesystem/etc/init.d/S11-piglet" "${FILESYSTEM_MOD_DIR}/etc/init.d"

echo2 "deleting obsolete files"
for i in \
  /bin/supportdata.aha \
  /bin/supportdata.dect \
  /etc/avm_firmware_public_key3 \
  /etc/default.049/fx_lcr.1und1 \
  /etc/default.Fritz_Box_HW212/1und1 \
  /etc/init.d/S78-aha \
  /etc/templates/fax_rcv_message* \
  /etc/templates/fax_send_message* \
  /lib/libfax*.so* \
  /lib/libfbpbook.so \
  /lib/libfoncclient.so \
  /lib/modules/3.10.107/kernel/drivers/char/dect_io* \
  /lib/modules/3.10.107/kernel/drivers/char/Piglet_noemif* \
  /lib/modules/3.10.107/kernel/drivers/isdn/avm_dect* \
  /lib/modules/bitfile*.bit \
  /lib/modules/dectfw*.hex \
  /lib/systemd/system/aha.service \
  /sbin/carddavd \
  /sbin/start_dect_update.sh \
  /usr/bin/aha \
  /usr/bin/ahamailer \
  /usr/bin/dect_* \
  /usr/bin/faxd \
  /usr/share/aha* \
  /usr/share/configd/dectmediadefault.xml \
  /usr/share/ctlmgr/libdect.so \
  /usr/share/telefon/fax-test.pdf \
  /usr/www.myfritz/1und1 \
  /usr/www.nas/1und1 \
  /usr/www/1und1 \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

echo2 "deleting obsolete webui files"
for i in \
  /usr/www/avm/assis/assi_fax_intern.lua \
  /usr/www/avm/css/rd/arrow.css \
  /usr/www/avm/css/rd/elements/elem_buttons_aus_blue.png \
  /usr/www/avm/css/rd/elements/elem_buttons_ein_blue.png \
  /usr/www/avm/css/rd/icons/ic_dect_* \
  /usr/www/avm/css/rd/illustrations/illu_avmRepeater.png \
  /usr/www/avm/css/rd/illustrations/illu_dect* \
  /usr/www/avm/css/rd/images/img_dect_* \
  /usr/www/avm/css/rd/selection_area.css \
  /usr/www/avm/fon_devices* \
  /usr/www/avm/html/moh_failed.html \
  /usr/www/avm/html/moh_ok.html \
  /usr/www/avm/html/phonebook_* \
  /usr/www/avm/js/arrow.js \
  /usr/www/avm/js/ha_draw.js \
  /usr/www/avm/js/ha_sets.js \
  /usr/www/avm/js/ha_switch_timer.js \
  /usr/www/avm/js/selection_area.js \
  /usr/www/avm/js/sffcoder.js \
  /usr/www/avm/js/text2canvas.js \
  /usr/www/avm/meter* \
  /usr/www/avm/net/home_auto_* \
  /usr/www/avm/webservices* \
  /usr/www/avme/assis/assi_fax_intern.lua \
  /usr/www/avme/css/rd/arrow.css \
  /usr/www/avme/css/rd/elements/elem_buttons_aus_blue.png \
  /usr/www/avme/css/rd/elements/elem_buttons_ein_blue.png \
  /usr/www/avme/css/rd/icons/ic_dect_* \
  /usr/www/avme/css/rd/illustrations/illu_avmeRepeater.png \
  /usr/www/avme/css/rd/illustrations/illu_dect* \
  /usr/www/avme/css/rd/images/img_dect_* \
  /usr/www/avme/css/rd/selection_area.css \
  /usr/www/avme/fon_devices* \
  /usr/www/avme/html/moh_failed.html \
  /usr/www/avme/html/moh_ok.html \
  /usr/www/avme/html/phonebook_* \
  /usr/www/avme/js/arrow.js \
  /usr/www/avme/js/ha_draw.js \
  /usr/www/avme/js/ha_sets.js \
  /usr/www/avme/js/ha_switch_timer.js \
  /usr/www/avme/js/selection_area.js \
  /usr/www/avme/js/sffcoder.js \
  /usr/www/avme/js/text2canvas.js \
  /usr/www/avme/meter* \
  /usr/www/avme/net/home_auto_* \
  /usr/www/avme/webservices* \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

# patch install script to accept firmware from 7490
echo2 "applying install patch"
modsed "s/mips34_512MB_xilinx_vdsl_dect446_4geth_2ab_isdn_nt_te_pots_2usb_host_wlan11n_27490/mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525/g" "${FIRMWARE_MOD_DIR}/var/install"

