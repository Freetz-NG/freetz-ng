#!/bin/sh

# keine Schleife, wenn wir schon libmodcgi.sh hatten ;-)
[ -z "$SENDSID" ] && . /usr/lib/libmodcgi.sh

# Nach 10 Minuten läuft der Login ab
find /tmp/ -maxdepth 1 -type f -name ".webcfg.${_CGI_CSRF_SCOPE:-default}.*.tmp" -mmin +9 -exec rm -f {} \;
echo "$SENDSID#$REMOTE_ADDR" > "/tmp/.webcfg.${_CGI_CSRF_SCOPE:-default}.$SENDSID.tmp"

# Schicken wir dem Browser eine SessionID, gueltig fuer alle Pfade. Dazu nicht
# via JS auslesbar und nicht mitsenden bei Anfragen anderer Websites ans Webif.
echo "Set-Cookie: SID=$SENDSID; Path=/; HttpOnly; SameSite=Strict"

cgi_begin "$(lang de:"Anmelden" en:"Login")"

if [ "$(cat /tmp/flash/mod/webmd5 2>/dev/null)" == "465d0ff27bb239292778dc3a0c2f28d9" ]; then
	WGPASS="$(sed -n 's/^webgui_pass[\t ]*//p' /proc/sys/urlader/environment)"
	[ -n "$WGPASS" ] && echo "<p>$(lang de:"Bitte das AVM-Ger&auml;tekennwort vom Typenschild verwenden." en:"Please use the AVM device password printed on the label.")</p>"
fi

. /usr/mww/cgi-bin/md5hash.sh

cat << EOF
<br><br>
<form id="login" action="/cgi-bin/login.cgi" method="POST" onsubmit="document.getElementById('login_hash').value=makemd5(document.getElementById('inp_pw').value,'$SENDSID')">
<input type="hidden" name="hash" id="login_hash">
$(lang de:"Passwort" en:"Password"): <input type="password" id="inp_pw" maxlength="45">
&nbsp;
<input type="submit" name="go" id="id_go" value="$(lang de:"Anmelden" en:"Login")">
EOF
subpage="$(echo "${REQUEST_URI}" | sed -n 's/.*\?subpage=//p' | sed 's/^\/*//;s/&.*//;s/[^-_a-zA-Z0-9\.\/]//g;s/\.\.//g')"
[ -z "$subpage" ] && subpage="${REQUEST_URI%%\?*}" || subpage="/$subpage"
echo "<input type='hidden' name='subpage' value='$(html "$subpage")'>"
echo '</form>'
echo "<script> document.getElementById(\"inp_pw\").focus(); </script>"
echo '<br><br>'

# Waren wir schonmal hier? Dann war was falsch!
if [ "$WRONGPW" == "1" ]; then
	echo "<p><b><font color=red>$(lang de:"Passwort falsch!" en:"Wrong password!")</font></b></p></b>"
	echo "<p><a href='https://freetz-ng.github.io/freetz-ng/make/mod/#passwort-zurucksetzen' target='_blank'>$(lang de:"Passwort vergessen?" en:"Forgot password?")</a></p>"
fi

cgi_end
