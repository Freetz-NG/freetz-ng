#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

eval "$(modcgi genconfigname openvpn_action)"
if [ "$REQUEST_METHOD" == "POST" ] && [ -n "$OPENVPN_ACTION_GENCONFIGNAME" ]; then
	sh /mod/etc/default.openvpn/generate_virtual_pkg "$OPENVPN_ACTION_GENCONFIGNAME"
	sed -i "/$OPENVPN_ACTION_GENCONFIGNAME/ d" /tmp/flash/openvpn/configs
	echo "$OPENVPN_ACTION_GENCONFIGNAME" >> /tmp/flash/openvpn/configs
fi

cginame=${0##*/}
pkgname=${cginame%%.cgi}
if [ "openvpn" == ${pkgname} ]; then
	filepath=/tmp/flash/openvpn/
else
	filepath=/tmp/flash/openvpn/${pkgname}/
fi

sec_begin "$(lang de:"Starttyp" en:"Start type")" sec_start

[ "$FREETZ_PACKAGE_OPENVPN_WITH_INETDABLE" == "y" ] && INETDABLE='1' || INETDABLE='0'
cgi_print_radiogroup_service_starttype \
	"enabled" "$OPENVPN_ENABLED" "" "" $INETDABLE

sec_end

if [ -n "$(find /lib/modules/ -name tun.ko -o -name yf_patchkernel.ko)" ]; then
sec_begin "$(lang de:"Optionen" en:"Options")" sec_opts

cgi_print_checkbox_p "load_tun" "$OPENVPN_LOAD_TUN" \
	"$(lang de:"Lade das tun Modul (und falls vorhanden yf_patchkernel) automatisch" en:"Load the tun module (and if available yf_patchkernel) automatically")."

sec_end
fi

sec_begin "$(lang de:"Einstellungen" en:"Configuration")" sec_conf

cat << EOF
$(lang de:"Hinweis: Zertifikate und Keys liegen unter " en:"Certs and keys are located ") <i>${filepath}</i>
<p><div align="center">
<textarea id="id_conf" style="width: 500px;" name="conf" rows="15" cols="80"
 wrap="off" >$OPENVPN_CONF</textarea></div></p>

EOF

sec_end

