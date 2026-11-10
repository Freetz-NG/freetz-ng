#!/bin/sh

. /usr/lib/libmodcgi.sh

CHALLENGE="$( (date "+%s";echo "$$";cat /etc/.freetz-ng-version /proc/avm/calib/avmzertifikate /proc/sys/urlader/environment 2>/dev/null) | md5sum | sed 's/ *-//')"

cgi_begin "$(lang de:"Passwort &auml;ndern" en:"Change password")"
# Waren wir schonmal hier? Dann war was falsch!
[ "$(cat /tmp/flash/mod/webmd5)" == "465d0ff27bb239292778dc3a0c2f28d9" ] && \
  echo "<b>$(lang de:"Standard Passwort gesetzt. Bitte &auml;ndern!" en:"Default password set. Please change it!")</b><p>"

. /usr/mww/cgi-bin/md5hash.sh
echo "<script>challenge=\"$CHALLENGE\";</script>"

cat << EOF

<script>
function checkpw(pw1, pw2) {
	if (pw1 == "freetz") {
		alert("$(lang de:"Bitte nicht das Standardpasswort nutzen!" en:"Please don't use the default password!")");
		return false;
	}
	if (pw1 == "") {
		alert("$(lang de:"Das Passwort ist leer!" en:"The password is empty!")");
		return false;
	}
	if (pw1 != pw2) {
		alert("$(lang de:"Die Passw&ouml;rter stimmen nicht &uuml;berein!" en:"Passwords do not match!")");
		return false;
	}
	return true;
}</script>

<h1>$(lang de:"Passwort &auml;ndern" en:"Change password")</h1>

<table>
<tr><td><label for="old_pw">$(lang de:"Altes Passwort" en:"Old password"):&nbsp;</label></td><td><input type="password" size=20 name="old_pw" id="old_pw" maxlength="45"></td></tr>
<tr><td><label for="inp_pw">$(lang de:"Neues Passwort" en:"New password"):&nbsp;</label></td><td><input type="password" size=20 name="inp_pw" id="inp_pw" maxlength="45"></td></tr>
<tr><td><label for="inp_pw2">$(lang de:"Wiederholung" en:"Retype password"):&nbsp;</label></td><td><input type="password" size=20 name="inp_pw2" id="inp_pw2" maxlength="45"></td></tr>
EOF
[ "$WRONGPW" = 1 ] && echo "<tr><td colspan=2><p><b><font color=red>$(lang de:"Das alte Passwort war falsch!" en:"The old password was wrong!")</font></b></p></td></tr>"
cat << EOF
<tr><td><input type="button" value="$(lang de:"Zur&uuml;ck" en:"Back")" onclick="window.location.href='/cgi-bin/conf/mod/webcfg'"></td><td><input type="button" name="go" value="$(lang de:"Speichern" en:"Save")"
      onclick='if (checkpw (document.getElementById("inp_pw").value , document.getElementById("inp_pw2").value)) { location.href="/cgi-bin/pwchange.cgi?oldhash="+makemd5(document.getElementById("old_pw").value, challenge)+"&newhash="+md5(document.getElementById("inp_pw").value) ; }'></td></tr>
</table>

EOF

cgi_end

# Wir "merken" uns genau ein "Angebot" 
echo "$CHALLENGE#$REMOTE_ADDR" > /tmp/pwchangesid 

