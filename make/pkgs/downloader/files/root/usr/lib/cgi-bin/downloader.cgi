#!/bin/sh


. /usr/lib/libmodcgi.sh

ftp_chk=''; http_chk=''

check "$DOWNLOADER_ENABLED" yes:auto "*":man
if [ "$DOWNLOADER_SRVPRFX" = "ftp://" ]; then ftp_chk=' selected'; else http_chk=' selected'; fi
check "$DOWNLOADER_DEBUG" yes:debug

sec_begin "$(lang de:"Aktivierung" en:"Activation")"

cat << EOF
<div style="float: right;">Version 0.2</div>
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> $(lang de:"Aktiv" en:"Active")</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> $(lang de:"Inaktiv" en:"Inactive")</label>
</p>
<p>
<input type="hidden" name="debug" value="no">
<input id="s1" type="checkbox" name="debug" value="yes"$debug_chk><label for="s1"> $(lang de:"mit Debug-Ausgaben" en:"with debug output")</label>
&nbsp;&nbsp; (in <a href="$(href extra downloader downlog)">/var/log/downloader.log</a>)
</p>
EOF

sec_end
sec_begin "$(lang de:"Serverparameter" en:"Server parameters")"

cat << EOF
<table>
<tr>
<td>$(lang de:"Servertyp" en:"Server type"):</td><td>&nbsp;&nbsp;&nbsp;&nbsp;URL:</td><td>&nbsp;&nbsp;$(lang de:"Entferntes Verzeichnis" en:"Remote dir"):</td>
</tr>
<tr>
<td>&nbsp;&nbsp;<i>http://</i></td><td><i>&nbsp;&nbsp;&nbsp;&nbsp;meinserver.de</i></td><td><i>&nbsp;&nbsp;/fritzbox/kernel26</i></td>
</tr>
<tr>
<td>
<select name="srvprfx" id="srvprfx">
<option title="FTP"
value="ftp://"$ftp_chk>ftp://</option>
<option title="HTTP"
value="http://"$http_chk>http://</option>
</select>
</td>
<td>
<input type="text" name="srvurl" size="30" maxlength="30" value="$(html "$DOWNLOADER_SRVURL")">
</td>
<td>
<input type="text" name="srvdir" size="30" maxlength="30" value="$(html "$DOWNLOADER_SRVDIR")">
</td>
</tr>
</table>
<h2>$(lang de:"Nur f&uuml;r FTP-Server" en:"Only for ftp server"):</h2>
<p>$(lang de:"Benutzer" en:"User"):
<input type="text" name="srvusr" size="20" maxlength="30" value="$(html "$DOWNLOADER_SRVUSR")">
&nbsp;&nbsp;&nbsp;&nbsp;Passwor$(lang de:"t" en:"d"):
<input type="password" name="srvpwd" size="20" maxlength="30" value="$(html "$DOWNLOADER_SRVPWD")">
</p>
EOF
sec_end
sec_begin "$(lang de:"Downloadparameter" en:"Download parameters")"

cat << EOF
<p>$(lang de:"Wartezeit" en:"Duration"):
<input type="text" name="twait" size="5" maxlength="5" value="$(html "$DOWNLOADER_TWAIT")">
&nbsp;Sek. &nbsp;&nbsp;&nbsp;$(lang de:"Wiederholversuche" en:"Number of repeats"):
<input type="text" name="nrep" size="5" maxlength="5" value="$(html "$DOWNLOADER_NREP")">
</p>
EOF

sec_end
sec_begin "$(lang de:"Dateien zum Downloaden" en:"Download files")"

cat << EOF
<table>
<tr>
<th>Syntax:</th><td>&lt;$(lang de:"Datei(ohne.gz)" en:"File(w/o.gz)")&gt;</td><td>&lt;$(lang de:"Attribute" en:"Permissions")&gt;</td><td>&lt;$(lang de:"Zielverzeichnis" en:"Destination dir")&gt;</td>
</tr>
<tr>
<th>$(lang de:"Beispiel" en:"Example"):</th><td>dropbear</td><td>755</td><td>/mod/bin</td>
</tr>
</table>
<p><textarea name="files" rows="4" cols="50">$(html "$DOWNLOADER_FILES")</textarea></p>
EOF

sec_end

sec_begin 'Extras'
cat << EOF
<ul>
<li>
<a href="$(href extra downloader downremover)">$(lang de:"Heruntergeladene Dateien l&ouml;schen" en:"Remove downloaded files")</a>
</li>
<li>
<a href="$(href extra downloader downlog)">$(lang de:"Protokoll ansehen" en:"View log file")</a>
</li>
</ul>
EOF
sec_end
