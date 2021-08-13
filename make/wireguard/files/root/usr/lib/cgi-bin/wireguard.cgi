#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")" sec_start
cgi_print_radiogroup_service_starttype "enabled" "$WIREGUARD_ENABLED" "" "" 0
sec_end

if [ "$(/mod/etc/init.d/rc.wireguard status)" == "running" ]; then
sec_begin "$(lang de:"Anzeigen" en:"Show")"
cat << EOF
<ul>
<li><a href="$(href status wireguard peers)">$(lang de:"Peers anzeigen" en:"Show peers")</a></li>
</ul>
EOF
sec_end
fi

sec_begin "$(lang de:"Einstellungen" en:"Configuration")"
cgi_print_textline_p "interface" "$WIREGUARD_INTERFACE" 5/10 "$(lang de:"Netzwierkschnittstelle" en:"Interface name"): "
cgi_print_textline_p "mtu" "$WIREGUARD_MTU" 5/10 "$(lang de:"MTU" en:"MTU"): "
cgi_print_textline_p "ip" "$WIREGUARD_IP" 20/255 "$(lang de:"IPv4-Adresse" en:"IPv4 address"): "
cgi_print_textline_p "ip6" "$WIREGUARD_IP6" 35/255 "$(lang de:"IPv6-Adresse" en:"IPv6 address"): "
cat << EOF
<p>$(lang de:"IPv6 leer lassen, wenn nicht vorhanden" en:"Leave IPv6 empty if not applicable")</p>
EOF

cgi_print_textline_p "pre_up" "$WIREGUARD_PRE_UP" 100/1024 "$(lang de:"PreUp Command" en:"PreUp Command"): "
cgi_print_textline_p "post_up" "$WIREGUARD_POST_UP" 100/1024 "$(lang de:"PostUp Command" en:"PostUp Command"): "
cgi_print_textline_p "pre_down" "$WIREGUARD_PRE_DOWN" 100/1024 "$(lang de:"PreDown Command" en:"PreDown Command"): "
cgi_print_textline_p "post_down" "$WIREGUARD_POST_DOWN" 100/1024 "$(lang de:"PostDown Command" en:"PostDown Command"): "
sec_end

