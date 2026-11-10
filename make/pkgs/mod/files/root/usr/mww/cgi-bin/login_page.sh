#!/bin/sh

# keine Schleife, wenn wir schon libmodcgi.sh hatten ;-)
[ -z "$SENDSID" ] && . /usr/lib/libmodcgi.sh

# Schicken wir dem Browser eine SessionID, gueltig fuer alle Pfade. Dazu nicht
# via JS auslesbar und nicht mitsenden bei Anfragen anderer Websites ans Webif.
echo "Set-Cookie: SID=$SENDSID; Path=/; HttpOnly; SameSite=Strict"

cgi_begin "$(lang de:"Anmelden" en:"Login")"

. /usr/mww/cgi-bin/md5hash.sh

cat << EOF
<br><br>
$(lang de:"Passwort" en:"Password"): <input  type="password" id="inp_pw" maxlength="45" onkeydown="if (event.keyCode == 13) document.getElementById('id_go').click()">
&nbsp;
<input type="button" name="go" id="id_go" value="$(lang de:"Anmelden" en:"Login")"
EOF
subpage="$(echo "${REQUEST_URI}" | sed -n 's/.*\?subpage=//p' | sed 's/^\/*//;s/&.*//;s/[^-_a-zA-Z0-9\.\/]//g;s/\.\.//g')"
[ -z "$subpage" ] && subpage="${REQUEST_URI%%\?*}" || subpage="/$subpage"
echo "onclick='location.href=\"/cgi-bin/login.cgi?subpage=$subpage&hash=\"+makemd5(document.getElementById(\"inp_pw\").value, \"$SENDSID\")'>"
echo "<script> document.getElementById(\"inp_pw\").focus(); </script>"
echo '<br><br>'

# Waren wir schonmal hier? Dann war was falsch!
[ "$WRONGPW" = 1 ] && echo "<p><b><font color=red>$(lang de:"Passwort falsch!" en:"Wrong password!")</font></b></p></b>"

cgi_end

# Wir "merken" uns genau ein SID-"Angebot" 
echo "$SENDSID#$REMOTE_ADDR" > /tmp/loginsid

