#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$VNSTAT_DARK_MODE" yes:dark_mode
check "$VNSTAT_WEBENABLED" yes:webenabled
check "$VNSTAT_WEB_AUTH" yes:web_auth
check "$VNSTAT_WEB_INETD" yes:web_inetd

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VNSTAT_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Anzeigen" en:"Show statistics")"

cat << EOF
<ul>
<li><a href="$(href status vnstat stats)">$(lang de:"Statistiken anzeigen" en:"Show statistics")</a></li>
EOF

sec_end
sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
<p>
$(lang de:"Datenbankverzeichnis" en:"Database directory"):&nbsp;
<input type="text" name="dbdir" size="42" maxlength="255" value="$(html "$VNSTAT_DBDIR")">
</p>
<p>
$(lang de:"Zu &uuml;berwachende Interfaces (leer lassen f&uuml;r alle)" en:"Interfaces for monitoring (leave empty for all)"):&nbsp;
<input type="text" name="interfaces" size="55" maxlength="255" value="$(html "$VNSTAT_INTERFACES")">
<br>
<br>
<font size=-2>
$(lang de:"Verf&uuml;gbare Interfaces" en:"Available interfaces"):&nbsp;
$(vnstat --iflist | sed 's/.*: //;s/ ([^)]*)//g')
</font>
</p>
EOF
if [ "$FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON" != "y" ]; then
cat << EOF
<p>
<input type="hidden" name="dark_mode" value="no">
<input id="d0" type="checkbox" name="dark_mode" value="yes"$dark_mode_chk><label for="d0">$(lang de:"Grafiken im dunklen Modus anzeigen" en:"Display graphics in dark mode")</label>
</p>
EOF
fi

sec_end
sec_begin "$(lang de:"Webserver" en:"Webserver")"

cat << EOF
<p>
<input type="hidden" name="webenabled" value="no">
<input id="w1" type="checkbox" name="webenabled" value="yes"$webenabled_chk><label for="w1"></label>
$(lang de:"Zus&auml;tzlichen Webserver aktiveren auf Port" en:"Activate additional webserver on port")&nbsp;
<input type="text" name="web_port" size="4" maxlength="5" value="$(html "$VNSTAT_WEB_PORT")">
</p>
EOF

if [ "$VNSTAT_WEBENABLED" = "yes" ]; then
if [ -x /mod/etc/init.d/rc.inetd ]; then
cat << EOF
<p>
<input type="hidden" name="web_inetd" value="no">
<input id="a3" type="checkbox" name="web_inetd" value="yes"$web_inetd_chk><label for="a3">$(lang de:"Aktiviere inetd Nutzung" en:"Activate inetd support")</label>
</p>
EOF
fi
cat << EOF
<p>
<input type="hidden" name="web_auth" value="no">
<input id="a1" type="checkbox" name="web_auth" value="yes"$web_auth_chk><label for="a1">$(lang de:"Authentifizierung" en:"Authentication").</label>
$(lang de:"Benutzer" en:"User"):
<input type="text" name="web_user" size="15" maxlength="15" value="$(html "$VNSTAT_WEB_USER")">
$(lang de:"Passwort" en:"Password"):
<input type="password" name="web_pass" size="15" maxlength="15" value="$(html "$VNSTAT_WEB_PASS")">
</p>
EOF
fi

sec_end
