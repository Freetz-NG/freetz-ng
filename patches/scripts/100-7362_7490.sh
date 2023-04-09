
isFreetzType 7362_7490 || return 0
echo1 "adapt firmware for 7362"


echo2 "moving default config dir"
mv ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW185 \
   ${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_HW203

echo2 "patching rc.S and rc.conf"
modsed 's/CONFIG_USB_XHCI=.*$/CONFIG_USB_XHCI="n"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE="mips34_128MB_vdsl_dect441_2eth_2geth_1ab_2usb_host_wlan11n_10101"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT="Fritz_Box_HW203"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME="FRITZ!Box 7362 SL"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed 's/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR="131"/g' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# patch install script to accept firmware from 7490
echo2 "applying install patch"
modsed "s/mips34_512MB_xilinx_vdsl_dect446_4geth_2ab_isdn_nt_te_pots_2usb_host_wlan11n_27490/mips34_128MB_vdsl_dect441_2eth_2geth_1ab_2usb_host_wlan11n_10101/g" "${FIRMWARE_MOD_DIR}/var/install"
modsed "s/mips74_16MB_7490_wlan11ac_28854//g" "${FIRMWARE_MOD_DIR}/var/install"
