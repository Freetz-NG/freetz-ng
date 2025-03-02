#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$CHOPARP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration") (<a target=blank href=https://man.freebsd.org/cgi/man.cgi?query=choparp&manpath=FreeBSD+14.2-RELEASE+and+Ports>$(lang de:"Hilfe" en:"Help")</a>)"
cgi_print_textline_p "cmdline" "$CHOPARP_CMDLINE" 55/250 "$(lang de:"Parameter" en:"Parameters"): "
sec_end

