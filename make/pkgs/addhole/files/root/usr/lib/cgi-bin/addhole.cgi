#!/bin/sh

. /usr/lib/libmodcgi.sh


sec_begin "$(lang de:"Status" en:"Status")"

echo -n '<pre><FONT SIZE=-1>'
/mod/etc/init.d/rc.addhole status | html
echo '</FONT></pre>'

sec_end


sec_begin "$(lang de:"Wartung" en:"Maintenance")"

cat << EOF
<p>
<input type="button" value="$(lang de:"Hosts jetzt herunterladen" en:"Download hosts now")" onclick="if (confirm('$(lang de:"Fortfahren?" en:"Proceed?")')==true) window.open('$(href extra addhole download)','$(lang de:"Lade Hosts herunterladen" en:"Downloading hosts now")','menubar=no,width=$INIT_WINDOW_WIDTH,height=600,toolbar=no,resizable=yes,scrollbars=yes');" />
&nbsp;
<input type="button" value="$(lang de:"Hosts-Datei leeren" en:"Clear hosts file")" onclick="if (confirm('$(lang de:"Fortfahren?" en:"Proceed?")')==true) window.open('$(href extra addhole clear)','$(lang de:"Leere Hosts-Datei" en:"Clearing hosts file")','menubar=no,width=$INIT_WINDOW_WIDTH,height=600,toolbar=no,resizable=yes,scrollbars=yes');" />
</p>
EOF

sec_end


sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cgi_print_textline_p "file" "$ADDHOLE_FILE" 55/255 "$(lang de:"Datei mit blockierten Hosts" en:"File with blocked hosts"): "

cgi_print_textline_p "sink" "$ADDHOLE_SINK" 15/15 "$(lang de:"Ziel-IPv4 f&uuml;r blockierte Hosts" en:"Target IPv4 for blocked hosts"): "
cgi_print_textline_p "sink" "$ADDHOLE_SINK6" 15/39 "$(lang de:"Ziel-IPv6 f&uuml;r blockierte Hosts" en:"Target IPv6 for blocked hosts"): "

cgi_print_checkbox_p "keep" "$ADDHOLE_KEEP" "$(lang de:"Beim Updaten die vorherigen Hosts behalten" en:"On updating keep the previous hosts")."

cat << EOF
$(lang de:"Von diesen URLs herunterladen" en:"Download by this URLs"):
<textarea name="urls" rows="9" cols="75" maxlength="5120">$(html "$ADDHOLE_URLS")</textarea>
EOF

sec_end


sec_begin "$(lang de:"Cron" en:"Cron")"

cgi_print_checkbox_p "cron_enabled" "$ADDHOLE_CRON_ENABLED" "$(lang de:"Blockierte Hosts automatisch updaten" en:"Update blocked hosts automatically")."

cat << EOF
$(lang de:"Zeitpunkt des automatischen Updates (folgende Felder sind erforderlich)" en:"Point in time for automatic update (following values are required)").
EOF

cgi_print_textline_p "cron_weekd" "$ADDHOLE_CRON_WEEKD" 1/9 "$(lang de:"Wochentag" en:"Day of week") [0-6]: "
cgi_print_textline_p "cron_timeh" "$ADDHOLE_CRON_TIMEH" 2/9 "$(lang de:"Stunde" en:"Hour") [0-23]: "
cgi_print_textline_p "cron_timem" "$ADDHOLE_CRON_TIMEM" 2/9 "$(lang de:"Minute" en:"Minute") [0-59]: "

sec_end

