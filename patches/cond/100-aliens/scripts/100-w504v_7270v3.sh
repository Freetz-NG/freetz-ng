# 7270v3 firmware on Macedonian W504V hardware, grown at:
# https://boxmatrix.info/wiki/FREETZ_TYPE_W504V_7270_V3

isFreetzType W504V_7270_V3 || return 0

if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
fi
echo1 "adapt firmware for Macedonian W504V"

echo2 "moving default config dir"
mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7270plus" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_504avm"

echo2 "patching rc.conf"

# model differences
modsed "s/CONFIG_PRODUKT_NAME=.*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Speedport W504V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_PRODUKT=.*$/CONFIG_PRODUKT=\"Fritz_Box_504avm\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_INSTALL_TYPE=.*$/CONFIG_INSTALL_TYPE=\"ur8_16MB_xilinx_4eth_2ab_isdn_pots_wlan_usb_host_dect_504avm_07585\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_VERSION_MAJOR=.*$/CONFIG_VERSION_MAJOR=\"92\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

# no FONS0 port
modsed "s/CONFIG_CAPI_NT=.*$/CONFIG_CAPI_NT=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

echo2 "changing bitfiles"
rm "${FILESYSTEM_MOD_DIR}/lib/modules/bitfile.bit"
cp "${FILESYSTEM_TK_DIR}/lib/modules/bitfile_isdn.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"
cp "${FILESYSTEM_TK_DIR}/lib/modules/bitfile_pots.bit" "${FILESYSTEM_MOD_DIR}/lib/modules"

echo2 "replacing S11-piglet"
cp -pf "${FILESYSTEM_TK_DIR}/etc/init.d/S11-piglet" "${FILESYSTEM_MOD_DIR}/etc/init.d"

# patch install script to accept firmware for w504v
echo2 "applying install patch"
modsed "s/ur8_16MB_xilinx_4eth_2ab_isdn_nt_te_pots_wlan_usb_host_dect_plus_55266/ur8_16MB_xilinx_4eth_2ab_isdn_pots_wlan_usb_host_dect_504avm_07585/g" "${FIRMWARE_MOD_DIR}/var/install"

# Check LEDs then remap if there is a need
# echo2 "replacing led_module"
# cp -f "${FILESYSTEM_TK_DIR}/lib/modules/2.6.32.21/kernel/drivers/char/led_module.ko" "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.32.41/kernel/drivers/char"
