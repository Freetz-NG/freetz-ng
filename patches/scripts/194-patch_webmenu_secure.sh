[ "$FREETZ_PATCH_SECURE" == "y" ] || return 0
echo1 "applying webmenu secure patch"

[ "$FREETZ_PATCH_SECURE_2fa" == "y" ] && modsed 's/data[.]fritzos[.]twofactor_disabled/false/g'   ${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.js
[ "$FREETZ_PATCH_SECURE_sip" == "y" ] && modsed 's/data[.]fritzos[.]ipphone_from_outside/false/g' ${FILESYSTEM_MOD_DIR}/usr/www/all/home/home.js

