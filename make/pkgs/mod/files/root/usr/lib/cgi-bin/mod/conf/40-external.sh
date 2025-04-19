[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$MOD_EXTERNAL_WAIT_INFINITE" yes:external_wait_infinite_00 "*":external_wait_infinite_15
check "$MOD_EXTERNAL_BEHAVIOUR" copy:external_behaviour_copy "*":external_behaviour_link

sec_begin 'external'
_services=$(cat /mod/etc/external.pkg 2>/dev/null)
[ -z "$_services" ] && _services="$(lang de:"-keine-" en:"-none-")"

cgi_print_textline_p "external_directory" "$MOD_EXTERNAL_DIRECTORY" 55/255 "$(lang de:"Verzeichnis von external" en:"Directory for external"): "

if [ "$EXTERNAL_DYNAMIC" == "y" -a "$EXTERNAL_DYNAMIC_SCRIPTS" == "y" ]; then
cat << EOF
$(lang de:"Ausgelagerte Scripte so nutzen:" en:"Handle externalised scripts:")?
<blockquote>
<input id="s5" type="radio" name="external_behaviour" value="link"$external_behaviour_link_chk><label for="s5"> $(lang de:"Auf Ger&auml;t verweisen" en:"Link to USB").</label><br>
<input id="s6" type="radio" name="external_behaviour" value="copy"$external_behaviour_copy_chk><label for="s6"> $(lang de:"In den RAM kopieren" en:"Copy to RAM").</label><br>
</blockquote>
EOF
fi

cgi_print_checkbox_p "external_freetz_services" "$MOD_EXTERNAL_FREETZ_SERVICES" "$(lang de:"Folgende externalisierte Freetz-Dienste behandeln" en:"Manage these externalized services of Freetz")" ": $_services"

cat << EOF
$(lang de:"Folgende selbst definierte Dienste behandeln" en:"Manage these self defined services"):<p>
<textarea name="external_own_services" rows="5" cols="75" maxlength="255">$(html "$MOD_EXTERNAL_OWN_SERVICES")</textarea>
<FONT SIZE=-2><br><br>
$(lang de:"Hinweis: Namen der /mod/etc/init.d/rc.DAEMON Dateien ohne f&uuml;hrendes rc. und mit Leerzeichen getrennt angeben. " en:"Input the names of /mod/etc/init.d/rc.DAEMON files without rc., separated by space. ")
$(lang de:"Dies' kann dazu genutzt werden um nicht externalisierte Dienste, die ein USB-Ger&auml;t zum Speichern der Daten ben&ouml;tigen (wie RRDstats, Tor, bip, Xmail oder vnstat-cgi), zu starten und stoppen." en:"This would be helpful if a service is not externalized, but needs your USB-device for storing data-files (like RRDstats, Tor, bip, Xmail or vnstat-cgi).")
</FONT>
</p>

<h1>$(lang de:"Zeitsynchronisation" en:"Time-synchronisation")</h1>
<p>
EOF

cgi_print_checkbox "external_year_min" "$MOD_EXTERNAL_YEAR_MIN" "$(lang de:"Warte auf Zeitsynchronisation der Box (mindestens Jahr 2020)" en:"Wait for time synchronisation (year must be at least 2020)")"
cat << EOF
<blockquote>
<input id="s3" type="radio" name="external_wait_infinite" value="no"$external_wait_infinite_15_chk><label for="s3"> $(lang de:"Warte maximal 15 Minuten." en:"Wait maximum 15 minutes.")</label><br>
<input id="s4" type="radio" name="external_wait_infinite" value="yes"$external_wait_infinite_00_chk><label for="s4"> $(lang de:"Warte unbegrenzt." en:"Wait infinitely.")</label><br>
$(lang de:"Abbrechen, falls die Jahreszahl gr&ouml;&szlig;er als dieser Wert ist" en:"Abort if the year is higher than this value"): <input type="text" name="external_year_max" size="3" maxlength="4" value="$(html "$MOD_EXTERNAL_YEAR_MAX")">
</blockquote>
</p>
EOF

sec_end

