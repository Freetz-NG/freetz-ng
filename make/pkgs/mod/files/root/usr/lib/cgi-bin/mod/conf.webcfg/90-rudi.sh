sec_begin "$(lang de:"Rudi" en:"Rudi")"

cgi_print_radiogroup_service_starttype \
  "rudi_enabled" "$MOD_RUDI_ENABLED" "" \
  "$(lang de:"Zus&auml;tzlichen Webserver aktivieren" en:"Enable additional webserver")" 1

cgi_print_textline_p "rudi_port" "$MOD_RUDI_PORT" 5 "$(lang de:"Port" en:"Port"): "

cgi_print_checkbox_p "rudi_csrf_legacy" "$MOD_RUDI_CSRF_LEGACY" "$(lang de:"CSRF-Ausnahme f&uuml;r Legacy-Apps (via HTTP-GET)" en:"CSRF exception for legacy apps (via HTTP-GET)")"

cgi_print_checkbox_p "rudi_auth" "$MOD_RUDI_AUTH" "$(lang de:"Authentifizierung" en:"Authentication")"
cgi_print_textline_p "rudi_user" "$MOD_RUDI_USER" 15 "$(lang de:"Benutzername" en:"Username"): "
cgi_print_password_p "rudi_pass" "$MOD_RUDI_PASS" 15 "$(lang de:"Passwort" en:"Password"): "

sec_end

