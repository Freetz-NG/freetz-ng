#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VLMCSD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cgi_print_textline_p "cmdline" "$VLMCSD_CMDLINE" 55/250 "$(lang de:"Optionale Parameter" en:"Optional parameters"): "
sec_end

