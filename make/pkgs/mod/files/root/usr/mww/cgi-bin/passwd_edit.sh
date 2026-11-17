cgi_begin "$(lang de:"Passwort &auml;ndern" en:"Change password")"

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	pw1=form.password;
	pw2=form.replay;
	if (pw1.value == "freetz") {
		alert("$(lang de:"Bitte nicht das Standardpasswort nutzen!" en:"Please don't use the default password!")");
		pw1.focus();
		return false;
	}
	if (pw1.value == "") {
		alert("$(lang de:"Das Passwort ist leer!" en:"The password is empty!")");
		pw1.focus();
		return false;
	}
	if (pw1.value != pw2.value) {
		alert("$(lang de:"Die Passw&ouml;rter stimmen nicht &uuml;berein!" en:"Passwords do not match!")");
		pw2.focus();
		return false;
	}
	return true;
}
</script>

<h1>$(lang de:"Passwort &auml;ndern" en:"Change password")</h1>

<form method=POST onsubmit="return CheckInput(this)">
$(csrf_input)
<table>
<tr><td><label for="oldpassword">$(lang de:"Altes Passwort" en:"Old password"):&nbsp;</label></td><td><input type="password" size=20 name="oldpassword" id="oldpassword"></td></tr>
<tr><td><label for="password">$(lang de:"Neues Passwort" en:"New password"):&nbsp;</label></td><td><input type="password" size=20 name="password" id="password"></td></tr>
<tr><td><label for="replay">$(lang de:"Wiederholung" en:"Retype password"):&nbsp;</label></td><td><input type="password" size=20 name="replay" id="replay"></td></tr>
<tr><td><input type="button" value="$(lang de:"Zur&uuml;ck" en:"Back")" onclick="history.back()"></td><td><input type="submit" value="$(lang de:"Speichern" en:"Save")"></td></tr>
</table>
</form>
EOF

cgi_end
