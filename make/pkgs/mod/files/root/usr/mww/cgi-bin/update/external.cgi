#! /bin/sh


. /usr/lib/libmodcgi.sh

. /mod/etc/conf/mod.cfg

cgi --id=firmware_update
cgi_begin "$(lang de:"external-Datei Update" en:"external-file update")"

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	file_selector=document.getElementById('ex_file');
	target_text=document.getElementById('the_target');
	delete_chk=document.getElementById('delete');
	ex_start=document.getElementById('ex_start');
	if (file_selector.value=="") {
		alert("$(lang de:"Keine external-Datei angegeben!" en:"No external-file provided!")");
		return false;
	}
	file_selector.name=target_text.value;
	if (delete_chk.checked) {
		file_selector.name += ":delete_oldfiles";
	}
	if (ex_start.checked) {
		file_selector.name += ":external_start";
	}
	return true;
}
</script>

<h1>$(lang de:"external-Datei hochladen" en:"Upload external-file")</h1>

<p>
$(lang de:"Im ersten Schritt ist eine external-Datei zum Upload auszuw&auml;hlen. Diese Datei wird auf" en:"First choose an external-file for upload. This")
$(lang de:"die Box geladen und dort entpackt. Anschlie&szlig;end sollte die entsprechende Firmware" en:"file will be loaded to and extracted on the Box. You should")
$(lang de:"hochgeladen werden." en:"upload the appropriate firmware afterwards.")
</p>

<form action="do_external.cgi" method=POST enctype="multipart/form-data" onsubmit="return CheckInput(this);">
	<p>$(lang de:"external-Datei" en:"External-file") <input type=file size=50 id="ex_file"></p>
	<p>$(lang de:"Zielverzeichnis" en:"Target directory") <input type="textfield" size=50 id="the_target" name="the_target" value="$MOD_EXTERNAL_DIRECTORY"></p>
	<p><input type="checkbox" id="delete" name="delete" value="delete">$(lang de:"Alte External-Dateien l&ouml;schen" en:"Delete old external files")</p>
	<p><input type="checkbox" id="ex_start" name="ex_start" value="ex_start">$(lang de:"External Dienste nach Update starten" en:"Start external services after update")</p>
	<input type=submit value="$(lang de:"Datei hochladen" en:"Upload file")" style="width:200px">
</form>
EOF

cgi_end

