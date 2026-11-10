[ -r /etc/options.cfg ] && . /etc/options.cfg

skins="$(ls /usr/share/skin)"
for skin in $skins; do
	check "$MOD_SKIN" $skin:${skin}
done


sec_begin "$(lang de:"Weboberfl&auml;che" en:"Web interface")"

cgi_print_radiogroup_service_starttype \
	"httpd" "$MOD_HTTPD" "$(lang de:"Starttyp der Weboberfl&auml;che" en:"Web interface start type")" "" 1

cgi_print_textline_p "httpd_port" "$MOD_HTTPD_PORT" 5 "$(lang de:"Port" en:"Port"): "

if [ "$MOD_HTTPD_NEWLOGIN" != yes ]; then
	cgi_print_textline "httpd_user" "$MOD_HTTPD_USER" 15 "$(lang de:"Benutzername" en:"Username"): "
	echo "<p>$(lang de:"Passwort" en:"Password"): <input type='button' value='$(lang de:"&auml;ndern" en:"change")' onclick='window.open(\"/cgi-bin/passwd.cgi\",\"_self\")'></p>"
else
	echo "<p>$(lang de:"Passwort" en:"Password"): <input type='button' value='$(lang de:"&auml;ndern" en:"change")' onclick='window.open(\"/cgi-bin/pwchange.cgi\",\"_self\")'></p>"
fi

sec_end
sec_begin "$(lang de:"Authentifizierung" en:"Authentification")"

cgi_print_checkbox "httpd_newlogin" "$MOD_HTTPD_NEWLOGIN" "$(lang de:"Neue Loginversion mit Session-ID" en:"New login with session id")"
echo "<p>"
cgi_print_textline "httpd_sessiontimeout" "$MOD_HTTPD_SESSIONTIMEOUT" 5 "$(lang de:"Session-ID Timeout:" en:"Session id timeout:") " " $(lang de:"Sekunden" en:"seconds")"
echo "</p>"

cat << EOF
<script >
var conftext='$(lang de:"Standard PW ist \"freetz\".\\n\\nDas PW kann in Konsole so gesetzt werden:" en:"Default password is \"freetz\".\\n\\nYou can set the PW in console with this command:")\\necho -n \"freetz\" | md5sum | sed \"s/ .*//\" > /tmp/flash/mod/webmd5\\n'
var el=document.getElementById('httpd_newlogin_yes');
var eltime=document.getElementById('httpd_sessiontimeout');
$([ "$MOD_HTTPD_NEWLOGIN" = yes ] || echo "eltime.disabled = true;")
el.onchange=function(){eltime.disabled = this.checked ? false : true; if (this.checked){ this.checked = confirm(conftext) ? true : false;}; };
</script>
EOF

sec_end
sec_begin "$(lang de:"Erweiterte Einstellungen" en:"Advanced settings")"

cat << EOF
<p>
$(lang de:"Eingeh&auml;ngte Partitionen auf" en:"Mounted partitions on"):
EOF

cgi_print_checkbox "mounted_sub" "$MOD_MOUNTED_SUB" "$(lang de:"Untermen&uuml;" en:"Submenu")"
cgi_print_checkbox "mounted_main" "$MOD_MOUNTED_MAIN" "$(lang de:"Hauptseite" en:"Mainpage")"
cgi_print_checkbox "mounted_umount" "$MOD_MOUNTED_UMOUNT" "$(lang de:"mit Kn&ouml;pfen" en:"with buttons")"

cat << EOF
</p>
<p>
$(lang de:"Zus&auml;tzliche Partitionen" en:"Additional partitions"):
EOF

cgi_print_checkbox "mounted_tffs" "$MOD_MOUNTED_TFFS" "$(lang de:"TFFS" en:"TFFS")"
[ -d "/nvram" ] && \
  cgi_print_checkbox "mounted_nvram" "$MOD_MOUNTED_NVRAM" "$(lang de:"NVRAM" en:"NVRAM")"
df /var/flash/ 2>/dev/null | grep -q ' /var/flash$' && \
  cgi_print_checkbox "mounted_conf" "$MOD_MOUNTED_CONF" "$(lang de:"Konfiguration" en:"Configuartion")"
cgi_print_checkbox "mounted_temp" "$MOD_MOUNTED_TEMP" "$(lang de:"Tempor&auml;r" en:"Temporary")"

cat << EOF
</p>
EOF
if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" -o -r "/usr/lib/cgi-bin/mod/flash_info.cgi" -o -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
	echo "<p> $(lang de:"Zus&auml;tzliche Status-Seiten" en:"Additional status pages"):"

	if [ -r "/usr/lib/cgi-bin/mod/box_info.cgi" ]; then
		cgi_print_checkbox "show_box_info" "$MOD_SHOW_BOX_INFO" "$(lang de:"Box-Info" en:"Box info")"
	fi
	if [ -r "/usr/lib/cgi-bin/mod/flash_info.cgi" ]; then
		cgi_print_checkbox "show_flash_info" "$MOD_SHOW_FLASH_INFO" "$(lang de:"Flash-Info" en:"Flash info")"
	fi
	if [ -r "/usr/lib/cgi-bin/mod/info.cgi" ]; then
		cgi_print_checkbox "show_freetz_info" "$MOD_SHOW_FREETZ_INFO" "$(lang de:"Freetz-Info" en:"Freetz info")"
	fi

	echo "</p>"
fi

[ "$FREETZ_LANG_XX" == "y" ] && cgi_print_radiogroup \
  "lang" "$MOD_LANG" "" "$(lang de:"Sprachauswahl" en:"Language selection"):" \
  "de::deutsch" \
  "en::english"

cat << EOF
<p>$(lang de:"Skinauswahl" en:"Skin selection"):
EOF
for skin in $skins; do
	skin_nice_name="$(echo -n "${skin:0:1}" | tr '[:lower:]' '[:upper:]')${skin:1}"
	echo "<input id=\""$skin"\" type=\"radio\" name=\"skin\" value=\""$skin"\" "$(eval echo \$${skin}_chk)"><label for=\""$skin"\"> "$skin_nice_name"</label>"
done
echo '</p>'

cgi_print_textline_p "cgi_width" "$MOD_CGI_WIDTH" 4 "$(lang de:"Breite des Hauptinhalts" en:"Width of the main content area"):"
cgi_print_checkbox_p "show_memory_usage" "$MOD_SHOW_MEMORY_USAGE" "$(lang de:"Zeige Speicherverbrauch" en:"Show memory usage")"
[ ! -x /usr/bin/bootmanager ] && [ "$FREETZ_AVM_PROP_INNER_FILESYSTEM_TYPE_CPIO" != "y" ] && [ -e /usr/mww/cgi-bin/system_lfs.cgi ] && \
  cgi_print_checkbox_p "update_lfs" "$MOD_UPDATE_LFS" "$(lang de:"Ermittle inaktive Firmwareversion beim Booten" en:"Identify inactive firmware version at boot")"

sec_end

