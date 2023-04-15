isFreetzType 7362_7490 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi

echo1 "adapt firmware for 7362"

export FREETZ_REMOVE_WLAN=y

export FREETZ_REMOVE_PIGLET_POTS=y
export FREETZ_REMOVE_PIGLET_ISDN=y
export FREETZ_REMOVE_PIGLET_V1=y
export FREETZ_REMOVE_PIGLET_V2=y

echo2 "copying 7362 dect files"
file="lib/modules/dectfw_secondlevel_441.hex"
cp -a "${FILESYSTEM_TK_DIR}/$file" "${FILESYSTEM_MOD_DIR}/$file"

echo2 "removing reference to the bitfile_pots.bit file"
file="etc/init.d/S11-piglet"
modsed 's/piglet_potsbitfile=.*}/"/g' "${FILESYSTEM_MOD_DIR}/$file"

echo2 "removing remove unnecessary files"
modules=" kernel/drivers/usb/host/xhci-hcd.ko kernel/drivers/isdn/isdn_fon5/isdn_fbox_fon5.ko"
for i in $modules; do
	rm_files "${FILESYSTEM_MOD_DIR}/lib/modules/${FREETZ_KERNEL_VERSION_MODULES_SUBDIR}/$i"
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
