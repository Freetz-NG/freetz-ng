[ "$FREETZ_REMOVE_MOVED" == "y" ] || return 0
echo1 "removing moved files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/usr/bin/moved" \
  "${FILESYSTEM_MOD_DIR}/lib/libmoved.so*" \
  "${FILESYSTEM_MOD_DIR}/usr/share/moved" \
  "${FILESYSTEM_MOD_DIR}/usr/lua/wizard_boxmove_*_data.lua"
# libmove_helper and libmovetrace are still needed by ctlmgr

for oem in $(supported_brandings) all; do
	www="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "$www" -a ! -L "$www" ] || continue

	rm_files \
	  "$www/wizards/boxmove*" \
	  "$www/wizards/wizard_box_move_*" \
	  "$www/css/rd/boxmove.css"
done

modsed 's/CONFIG_MOVED="y"/CONFIG_MOVED="n"/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

