eval "$(modcgi oldpassword:password:replay mod_cgi)"

{
	echo "$MOD_CGI_OLDPASSWORD"
	echo "$MOD_CGI_PASSWORD"
	echo "$MOD_CGI_REPLAY"
} | modwebpw freetz > /dev/null 2>&1
result=$?

cgi_begin "$(lang de:"Passwort" en:"Password")"

if [ "$result" -ne 0 ]; then
	echo "<h1>$(lang de:"Das Passwort wurde nicht ge&auml;ndert." en:"The password was not changed.")</h1>"
	if [ "$result" -eq 2 ]; then
		echo "<p><b><font color=red>$(lang de:"Das alte Passwort war falsch!" en:"The old password was wrong!")</font></b></p>"
	fi
	echo "<input type='button' value='$(lang de:"Zur&uuml;ck" en:"Back")' onclick='window.location.href=\"/cgi-bin/conf/mod/webcfg\"'>"
else
	echo "<h1>$(lang de:"Passwort erfolgreich ge&auml;ndert." en:"New password set.")</h1>"
	echo -n "$MOD_CGI_PASSWORD" | md5sum | sed 's/ .*//' > /tmp/flash/mod/webmd5
	modsave flash >/dev/null
	rm /tmp/*.webcfg
	echo "<p>$(lang de:"Starte Weboberfl&auml;che neu ..." en:"Restarting webcfg ...")</p>"
	nohup /mod/etc/init.d/rc.webcfg restart >/dev/null 2>&1 &

	#XMail admin account
	if [ -x /usr/lib/MailRoot/bin/XMCrypt ]; then
		DAEMON="xmail"
		. /etc/init.d/modlibrc
		if [ -e $XMAIL_MAILLOCATION/ctrlaccounts.tab ]; then
			xmcryptpass=$(/usr/lib/MailRoot/bin/XMCrypt $MOD_CGI_PASSWORD)
			if [ -z "$xmcryptpass" ]; then
				echo 'ERROR: No encrypted Password received from XMCrypt,'
				echo '       Password for XMail control not changed !!!'
			else
				(
					sed -e "/\"$MOD_HTTPD_USER\"/d" $XMAIL_MAILLOCATION/ctrlaccounts.tab
					echo -e "\"$MOD_HTTPD_USER\"\t\"$xmcryptpass\""
				) > $XMAIL_MAILLOCATION/ctrlaccounts.tab

				#/mod/etc/init.d/rc.xmail restart

				#PHPXmail server.php
				[ -d /usr/mww/phpxmail ] && (
					[ -e /tmp/flash/phpxmail/servers.php ] && sed -e \
					"/^.*\t\(127\.0\.0\.1\|localhost\)\t.*\t$MOD_HTTPD_USER\t/d" /tmp/flash/phpxmail/servers.php
					echo -e "$(lang de:"Lokale" en:"Local") Fritz!Box\t127.0.0.1\t6017\t$MOD_HTTPD_USER\t$xmcryptpass\t0"
				) >/tmp/flash/phpxmail/servers.php && modsave flash > /dev/null
			fi
		fi
	fi

	back_button mod status
fi

cgi_end

