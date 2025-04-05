[ "$FREETZ_WEBIF_LINK" == "y" ] || return 0
echo1 "adding responsive webmenu link"

modsed \
  '/liveTv/{N;N;N;N;s/^ *\([^\[]*\).*\n.*\n.*\n *\["pos"\] = -65\n *} or nil\(.*\)/&\n\1\["freetz"\] = {\n\["txt"\] = "Freetz",\n\["lnk"\] = "\/cgi-bin\/freetz_status",\n\["pos"\] = -69,\n\["icon"\] = "fritzbox"\n} or nil\2/}' \
  "${MENU_DATA_LUA}" \
  "freetz_status"

