#!/bin/sh

. /usr/lib/libmodcgi.sh

#
sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$MOSQUITTO_ENABLED" "" "" 0
sec_end

#
sec_begin "$(lang de:"Optionen" en:"Options")"
cgi_print_textline_p "port" "$MOSQUITTO_PORT" 6/5 "$(lang de:"Port" en:"Port"): "
cgi_print_checkbox "allow_anonymous" "$MOSQUITTO_ALLOW_ANONYMOUS" "$(lang de:"Ohne Authentifizierung" en:"Without authentication")"
cgi_print_textline_p "persistence_path" "$MOSQUITTO_PERSISTENCE_PATH" 45/255 "$(lang de:"Daten-Verzeichnis (leer f&uuml;r keines)" en:"Data directory (empty for none)"): "
cgi_print_checkbox "syslog" "$MOSQUITTO_SYSLOG" "$(lang de:"Syslog benutzen" en:"Use syslog")"

sec_end
