#!/bin/sh


. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$ENDLESSH_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Endlessh Daemon" en:"Endlessh daemon")"
cgi_print_textline_p "port" "$ENDLESSH_PORT" 6/5 "$(lang de:"Port" en:"Port"): "

cgi_print_textline_p "max_clients"    "$ENDLESSH_MAX_CLIENTS"    6/5 "$(lang de:"Maximale Anzahl gleichzeitiger Verbindungen" en:"Maximum number of connections to accept at a time"): "
cgi_print_textline_p "delay"          "$ENDLESSH_DELAY"          7/5 "$(lang de:"Verz&ouml;gerung in Millisekunden zwischen den einzelnen Zeilen" en:"Delay in milliseconds between individual lines"): "
cgi_print_textline_p "max_linelength" "$ENDLESSH_MAX_LINELENGTH" 4/3 "$(lang de:"Maximale L&auml;nge der einzelnen Zeilen" en:"Maximum length of each line"): "

sec_end
