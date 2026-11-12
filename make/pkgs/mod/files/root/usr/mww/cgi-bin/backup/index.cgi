#!/bin/sh

. /usr/lib/libmodcgi.sh

cgi --id=backup_restore
cgi_begin "$(lang de:"Konfiguration sichern/wiederherstellen" en:"Backup/restore configuration")"
[ -x "$(which fwupdate)"      ] && UPDATER_FOUND=y || UPDATER_FOUND=n
[ -x "$(which tr069fwupdate)" ] && TR069FU_FOUND=y || TR069FU_FOUND=n
[ -x "$(which openssl)"       ] && OPENSSL_FOUND=y || OPENSSL_FOUND=n
[ -x "$(which decoder)"       ] && DECODER_FOUND=y || DECODER_FOUND=n
#  wget "https://github.com/PeterPawn/decoder/raw/master/bin/decoder.$(uname -m)" -O /mod/usr/bin/decoder

cat << EOF
<form action="do_backup.cgi" method="GET">
	<h1>$(lang de:"Sicherung" en:"Backup")</h1>

	<p>
	$(lang \
	  de:"Sichern s&auml;mtlicher Einstellungen aus dem Flash-Speicher <i>/var/flash</i>. Dies umfa&szlig;t sowohl die Einstellungen von AVM als auch die von Freetz-NG sowie s&auml;mtlicher sonstiger installierten Erweiterungen." \
	  en:"Save all settings from flash memory <i>/var/flash</i>. This includes firmware settings of AVM as well as Freetz-NG and other installed extensions." \
	)
	</p>
EOF

if [ "$TR069FU_FOUND" == "y" -o "$UPDATER_FOUND" == "y" ]; then
cat << EOF
	<p>
	<input type=checkbox name="do_export" id="do_export" >
	<label for="do_export">
	$(lang de:"Zus&auml;tzlich ein Export der AVM Einstellungen hinzuf&uuml;gen" en:"Include additional an export of the AVM settings")
	<br>
	$(lang \
	  de:"Der Export kann &uuml;ber das AVM-Webinterface wiederhergestellt werden. Bei neuerem FritzOS muss ein Passwort eingegeben werden." \
	  en:"An export could be restored by the AVM web interface. With newer FritzOS a password needs to be entered." \
	)
	</label>
	</p>
EOF
fi

if [ "$OPENSSL_FOUND" == "y" ]; then
cat << EOF
	<p>
	<input type=checkbox name="do_encrypt" id="do_encrypt" checked>
	<label for="do_encrypt">
	$(lang de:"Das Backup mit OpenSSL verschl&uuml;sseln" en:"Encrypt the backup with OpenSSL")
	<br>
	$(lang \
	  de:"Ein verschl&uuml;sseltes Backup enth&auml;lt zus&auml;tzliche Daten um die Sicherung auch auf einem anderen Ger&auml;t wiederherzustellen zu k&ouml;nnen." \
	  en:"An encrypted backup contains additional data to restore the backup even on another device." \
	)
	</label>
	</p>
EOF
fi

if [ "$TR069FU_FOUND" == "y" -o "$OPENSSL_FOUND" == "y" ]; then
cat << EOF
	<p>
	<label for="password_backup">$(lang de:"Passwort f&uumlr Verschl&uumlsselung und Export" en:"Password for encryption and export"):</label>
	<br>
	<input type=text name="password_backup" id="password_backup" size="35" >
	</p>
EOF
fi

cat << EOF
	<p>
	<input type=submit value="$(lang de:"Sichern" en:"Save")" style="width:150px">
	</p>

</form>
<hr>
<form action="do_restore.cgi" method="POST" enctype="multipart/form-data">
	<h1>$(lang de:"Wiederherstellung" en:"Restore")</h1>

	<p>
	$(lang \
	  de:"Wiederherstellen eines zuvor gesicherten Archivs mit Einstellungen. Damit wird das Ger&auml;t wieder in den Zustand zum Zeitpunkt der entsprechenden Sicherung versetzt." \
	  en:"Restore previously saved configuration archive.  This way the device will be restored to the state it was in when you created the corresponding backup." \
	)
	</p>

	<p>
	<b>
	<i>$(lang \
	  de:"Nach der Wiederherstellung sollte das Ger&auml;t neu gestartet werden, um alle Einstellungen zu aktivieren. Bitte danach die Einstellungen &uuml;berpr&uuml;fen!" \
	  en:"After restore you should reboot the device in order to activate the configuration. Please remember to double-check all settings afterwards!" \
	)
	</i>
	</b>
	</p>

	<p>
	<input type=file name="uploadfile">
	</p>

	<p>
EOF

if [ "$DECODER_FOUND" == "y" ]; then
cat << EOF
	<input type=checkbox name="decode_avm" id="decode_avm" >
	<label for="decode_avm">$(lang de:"Die AVM-Einstellungen dekodieren" en:"Decode AVM settings")</label>
	<br>
EOF
fi

cat << EOF
	<input type=checkbox name="freetz_only" id="freetz_only">
	<label for="freetz_only">$(lang de:"Nur Freetz-NG Einstellungen wiederherstellen" en:"Restore Freetz-NG settings only")</label>
	<br>
	<input type=checkbox name="restart" id="restart" checked>
	<label for="restart">$(lang de:"Neustart nach Wiederherstellung" en:"Reboot after restore")</label>
	</p>
EOF

if [ "$OPENSSL_FOUND" == "y" ]; then
cat << EOF
	<p>
	<label for="password_restore">$(lang de:"Passwort (falls verschl&uuml;sselt)" en:"Password (if encrypted)"):</label>
	<br>
	<input type=password name="password_restore" id="password_restore" size="35" >
	</p>
EOF
fi

cat << EOF
	<p>
	<input type=submit value="$(lang de:"Wiederherstellen" en:"Restore")" style="width:150px">
	</p>
</form>
EOF

cgi_end

