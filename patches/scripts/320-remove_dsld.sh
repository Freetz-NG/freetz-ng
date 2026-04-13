[ "$FREETZ_REMOVE_DSLD" == "y" ] || return 0
echo1 "removing dsld files"

rm_files $(find ${FILESYSTEM_MOD_DIR}/sbin ${FILESYSTEM_MOD_DIR}/lib/modules -name dsld)
rm_files "${FILESYSTEM_MOD_DIR}/etc/modules-load.d/dsld.conf"

modsed 's/^ *eval.*dsld.*/echo -n/g' "$FILESYSTEM_MOD_DIR/etc/init.d/rc.net"

supervisor_delete_service "dsld"

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/DSL=y/DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_DSL=y/CONFIG_DSL=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

