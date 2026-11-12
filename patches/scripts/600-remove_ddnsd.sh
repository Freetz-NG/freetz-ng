[ "$FREETZ_REMOVE_DDNSD" == "y" ] || return 0
echo1 "removing ddnsd"

# patcht Internet > Freigaben > Dynamic DNS
modsed \
  's/^pageData\["dyndns"\] =/& nil ; dummy =/g' \
  "${MENU_DATA_LUA}"
menulua_remove "internet.dyn_dns" "/access/dyndns"
htmltab_remove "/js3/views/internet/access/access.html" "/access/dyndns"
js3tab_remove "/js3/views/internet/access/access.html" "dyndns"

modsed -r \
  's/(AVMDAEMONS.* )ddnsd /\1/g' \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"

supervisor_delete_service "ddnsd"

rm_files ${FILESYSTEM_MOD_DIR}/sbin/ddnsd

