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
modsed "s/\(CONFIG_.*MEDIA.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" # Media
modsed "s/\(CONFIG_.*MTD.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # MTD
modsed "s/\(CONFIG_.*FAX.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"   # FAX
modsed "s/\(CONFIG_.*DECT.*=\).*/\1\"n\"/" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"  # DECT

# Other
modsed 's/CONFIG_CONFIGSPACE_ONNAND=.*$/CONFIG_CONFIGSPACE_ONNAND="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_ONLINEPB=.*$/CONFIG_ONLINEPB="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_XILINX=.*$/CONFIG_XILINX="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# Remote
modsed 's/CONFIG_T38=.*$/CONFIG_T38="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_TR369=.*$/CONFIG_TR369="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# Telephony
modsed 's/CONFIG_AB_COUNT=.*$/CONFIG_AB_COUNT="0"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_POTS=.*$/CONFIG_CAPI_POTS="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_CAPI_TE=.*$/CONFIG_CAPI_TE="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

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
  /lib/modules/bitfile_isdn.bit \
  /lib/modules/bitfile_pots.bit \
  /lib/modules/dectfw* \
  /etc/default.Fritz_Box_HW212/1und1 \
  /usr/www/1und1 \
  ; do
	rm_files "${FILESYSTEM_MOD_DIR}/$i"
done

# patch install script to accept firmware from 7490
echo2 "applying install patch"
modsed "s/mips34_512MB_xilinx_vdsl_dect446_4geth_2ab_isdn_nt_te_pots_2usb_host_wlan11n_27490/mips34_512MB_vdsl_4geth_2usb_host_offloadwlan11n_17525/g" "${FIRMWARE_MOD_DIR}/var/install"

