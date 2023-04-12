isFreetzType 7362_7490 || return 0


if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7362"

echo2 "deleting isdn files"
if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" ]; then
	rm_files \
	  $(find ${FILESYSTEM_MOD_DIR} ! -path '*/lib/*' -a -name '*isdn*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	  $(find ${FILESYSTEM_MOD_DIR}/lib/modules/2.6.*/ ${FILESYSTEM_MOD_DIR}/lib/modules/3.*.*/ -name '*isdn*' 2>/dev/null | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/') \
	[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
	  rm_files ${FILESYSTEM_MOD_DIR}/lib/modules/microvoip_isdn_top.bit
else
	rm_files $(find ${FILESYSTEM_MOD_DIR} -name '*isdn*' -o -name '*iglet*' | grep -Ev '^${FILESYSTEM_MOD_DIR}/(proc|dev|sys|oldroot|var)/')
fi
rm_files \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S17-isdn \
  ${FILESYSTEM_MOD_DIR}/etc/init.d/S11-piglet \
[ "$FREETZ_AVM_HAS_USB_HOST_AHCI" != "y" ] && \
  modsed '/microvoip_isdn_top.bit/d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"

echo2 "copying 7362 wlan files"
oems="1und1 avm"
for i in $oems; do
	cp -a ${FILESYSTEM_TK_DIR}/etc/default.Fritz_Box_HW203/$i/wlan* ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185/$i/
done
cp -a -r "${FILESYSTEM_TK_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/net" "${FILESYSTEM_MOD_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/"

echo2 "copying 7362 dect files"
file="lib/modules/dectfw_secondlevel_441.hex"
cp -a "${FILESYSTEM_TK_DIR}/$file" "${FILESYSTEM_MOD_DIR}/$file"

echo2 "copying 7362 led files"
modules=" kernel/drivers/char/led_module.ko"
for i in $modules; do
	cp -a "${FILESYSTEM_TK_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/$i" "${FILESYSTEM_MOD_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/$i"
done

echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185 ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW203

echo2 "patching rc.S and rc.conf"
modsed 's/CONFIG_USB_XHCI=.*$/CONFIG_USB_XHCI="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_128MB_vdsl_dect441_2eth_2geth_1ab_2usb_host_wlan11n_10101"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW203"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 7362 SL"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="131"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7490
echo2 "applying install patch"
modsed "s/mips34_512MB_xilinx_vdsl_dect446_4geth_2ab_isdn_nt_te_pots_2usb_host_wlan11n_27490/mips34_128MB_vdsl_dect441_2eth_2geth_1ab_2usb_host_wlan11n_10101/g" "${FIRMWARE_MOD_DIR}/var/install"
