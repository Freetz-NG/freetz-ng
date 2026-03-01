#!/bin/sh

VALS="$(echo ar7cfg.internet_forwardrules | ar7cfgctl -s | grep -v '^ar7cfg$' | sed 's/ 0 mark 1//g;s/, /\n/g' | sed -rn 's/^\"([ut][dc]p) 0.0.0.0:([^ ]*) [^:]*:([^\"]*).*/\2_\1:\3/p' | sort -n)"
AVM_PORTFW_TCP="$(for x in $(echo "$VALS" | sed -rn 's/_tcp//p'); do [ "$(echo $x | sed 's/[+:_].*//')" == "${x#*:}" ] && x="${x%:*}"; echo -n "$x "; done | sed 's/ $//')"
AVM_PORTFW_UDP="$(for x in $(echo "$VALS" | sed -rn 's/_udp//p'); do [ "$(echo $x | sed 's/[+:_].*//')" == "${x#*:}" ] && x="${x%:*}"; echo -n "$x "; done | sed 's/ $//')"
echo -e "export AVM_PORTFW_TCP='$AVM_PORTFW_TCP'\nexport AVM_PORTFW_UDP='$AVM_PORTFW_UDP'" > /mod/etc/conf/avm-portfw.cfg

. /usr/lib/libmodcgi.sh


sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
$(lang de:"Freizugebende Ports, mehrere durch Leerzeichen getrennt" en:"Ports to open, multiple seperated by spaces").
EOF

cgi_print_textline_p "tcp" "$AVM_PORTFW_TCP" 55/255 "TCP $(lang de:"Ports" en:"ports"): "

cgi_print_textline_p "udp" "$AVM_PORTFW_UDP" 55/255 "UDP $(lang de:"Ports" en:"ports"): "

cat << EOF
<ul>
<li>$(lang de:"Portbl&ouml;cke so angeben: PORT+ANZAHL, zB 55500+3 f&uuml;r 55500-55502" en:"For a range of ports: PORT+COUNT, eg 55500+3 for 55500-55502").</li>
<li>$(lang de:"Umleitungen so angeben: EXTERN(+ANZAHL):INTERN, zB 443:8443 oder 80+2:8008" en:"To redirect ports: EXTERNAL(+COUNT):INTERNAL, eg 443:8443 or 80+2:8008").</li>
<li>$(lang de:"Die Eintr&auml;ge k&ouml;nnen im AVM-Webif unter Diagnose > Sicherheit &uuml;berpr&uuml;ft werden" en:"You could check the settings by AVM webif with Diagnose > Sicherheit").</li>
<li>$(lang de:"Bei Syntaxfehlern wird die komplette ar7.cfg von AVM zur&uuml;ckgesetzt" en:"On syntax errors, the whole ar7.cfg will be reset by AVM").</li>
</ul>
EOF

sec_end

