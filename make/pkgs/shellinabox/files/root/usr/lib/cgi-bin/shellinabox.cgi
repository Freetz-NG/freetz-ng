#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

eval "$(modcgi dogencert shellinabox_action)"
if [ "$REQUEST_METHOD" == "POST" ] && [ "$SHELLINABOX_ACTION_DOGENCERT" == "yes" ]; then
	sh /mod/etc/default.shellinabox/generate_cert.sh
	echo '<textarea id="certout">'
	cat /tmp/shellinabox_certificate.pem
	echo '</textarea>'
	echo '<script>parent.document.getElementById("id_cert").value=document.getElementById("certout").value</script>'
	rm /tmp/shellinabox_certificate.pem
	exit
fi

check "$SHELLINABOX_NOSSL" true:ssldis
if [ "$SHELLINABOX_NOSSL" = true  -o "$FREETZ_PACKAGE_SHELLINABOX_SSL" != "y" ]; then
	displayssl="none"
else
	displayssl="block"
fi
if [ "$FREETZ_PACKAGE_SHELLINABOX_BOXCERT" == y ]; then
	check "$SHELLINABOX_USEBOXCERT" yes:boxcert *:owncert
	if [ "$SHELLINABOX_USEBOXCERT" == yes ]; then
		displayowncert="none"
	else
		displayowncert="block"
	fi
fi

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$SHELLINABOX_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<table>
<tr>
<td><i>Port:</i></td>
<td><input type="text" name="port" size="10" maxlength="5" value="$(html "$SHELLINABOX_PORT")"></td>
EOF

if [ "$FREETZ_PACKAGE_SHELLINABOX_SSL" == "y" ]; then
cat << EOF
<td><i>$(lang de:"SSL deaktivieren" en:"Disable SSL"):</i> &nbsp; <input id="id_ssl" type="checkbox" name="nossl" value="true"$ssldis_chk onclick='(document.getElementById("div_cert").style.display=(this.checked)? "none" : "block")'></td>
EOF
fi

cat << EOF
</tr>
<tr>
<td><i>Service:</i></td>
<td colspan=3><input type="text" name="service" size="40" value="$(html "$SHELLINABOX_SERVICE")"></td>
</tr>
</table>
<div style="display:$displayssl" id="div_cert">
EOF

if [ "$FREETZ_PACKAGE_SHELLINABOX_BOXCERT" == y ]; then
cat << EOF
<p><input id="z1" type="radio" name="useboxcert" value="yes"$boxcert_chk><label for="z1" onclick='document.getElementById("div_owncert").style.display="none"'> $(lang de:"Zertifikat der FRITZ!Box verwenden" en:"use FRITZ!Box certificate from vendor's GUI")</label><br />
<input id="z2" type="radio" name="useboxcert" value="no"$owncert_chk onclick='document.getElementById("div_owncert").style.display="block"'><label for="z2"> $(lang de:"eigenes Zertifikat verwenden" en:"use certificate from below")</label>
<div style="display:$displayowncert" id="div_owncert">
EOF
fi

cat << EOF
<p>$(lang de:"Zertifikat" en:"Certificate")
<div align="center"><textarea id="id_cert" style="width: 500px;" name="cert" rows="15" cols="80" wrap="off">$SHELLINABOX_CERT</textarea></div></p>
EOF

if which openssl_req >/dev/null 2>&1; then
cat << EOF
$(lang de:"Die Box kann ein minimales, selbst signiertes Zertifikat erstellen. Das dauert etwas..." en:"This will build a self signed certificate on the box. Will take some time..")
<iframe name="dummy" id="id_iframe" style="display:none;" width=500 height=100 frameborder="0"> </iframe>
<input type="button" value="$(lang de:"Zertifikat erstellen" en:"Generate certificate")" onclick='csrfPost("/cgi-bin/conf/shellinabox?freetz_action=1",{dogencert:"yes"},"dummy")'>
EOF
fi

cat << EOF
</div>
<h2>$(lang de:"Andere Optionen" en:"Additional options"):</h2>
<p><input type="text" name="options" size="60" maxlength="255" value="$(html "$SHELLINABOX_OPTIONS")"></p>
EOF

sec_end
