#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$AVM_RULES_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Informationen" en:"Informations")"
echo -n '<pre><FONT SIZE=-1>'
avm-rules stats 2>&1 | html
echo '</FONT></pre>'
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
$(lang de:"Freizugebende Ports, mehrere durch Leerzeichen getrennt" en:"Ports to open, multiple seperated by spaces").
EOF

cgi_print_textline_p "tcp" "$AVM_RULES_TCP" 55/255 "TCP $(lang de:"Ports" en:"ports"): "

cgi_print_textline_p "udp" "$AVM_RULES_UDP" 55/255 "UDP $(lang de:"Ports" en:"ports"): "

cgi_print_textline_p "seconds" "$AVM_RULES_SECONDS" 5/3 "$(lang de:"Timeout der offenen Ports, max 120 [Sekunden]" en:"Timeout of opened ports, max 120 [seconds]"): "

cgi_print_textline_p "initial" "$AVM_RULES_INITIAL" 5/3 "$(lang de:"Timeout ohne Internetverbindung [Sekunden]" en:"Timeout without internet connection [seconds]"): "

cgi_print_checkbox_p "logging" "$AVM_RULES_LOGGING" "$(lang de:"Debug-Log in Datei und Syslog" en:"Debug logging to file and syslog"). "

cat << EOF
<ul>
<li>$(lang de:"Die Ports werden f&uuml;r maximal 120 Sekunden ge&ouml;ffnet und m&uuml;ssen danach erneuert werden" en:"The ports will be opened for maximum 120 seconds and need to be refreshed afterwards").</li>
<li>$(lang de:"Neue Ports werden sofort beim Daemonstart ge&ouml;ffnet" en:"New ports get instantly opened on daemon start").</li>
<li>$(lang de:"Bei Konfigurations&auml;nderungen werden alte Ports erst nach dem ersten Intervall aktualisiert" en:"On configuration changes old ports are updated after the first intervall").</li>
<li>$(lang de:"Offene Ports k&ouml;nnen nicht geschlossen werden und es muss der Timeout abgewartet werden" en:"Open ports could not be closed and you have wait for the timeout").</li>
</ul>
EOF

sec_end

