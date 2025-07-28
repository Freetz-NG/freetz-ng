#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

virthost_conf() {
#$1 string of input-tag name-attribute
#$2 variable containing current value to display in input field
#$3 name to display
if [ "$LIGHTTPD_VIRTHOST" = "yes" ]; then
cat << EOF
<p style="font-size:10px;">$(lang de:"In folgender Box werden die virtuellen Hostnamen angegeben, f&uuml;r welche die Konfiguration bez&uuml;glich $3 gilt. Es k&ouml;nnen entweder der vollst&auml;ndige Hostname oder ein regul&auml;rer Ausdruck f&uuml;r mehrere Hostnamen verwendet werden. Mehrere Werte k&ouml;nnen angegeben werden, in dem diese mit Leerzeichen getrennt werden. Wenn die Konfiguration generell f&uuml;r alle virtuellen Hosts gelten soll, ist die Box leer zu lassen." en:"Please specify the virtual hosts the configuration of $3 applies to in the following box. You can either provide a full qualified domain name or a regular expression to match multiple host names. When supplying multiple values, please separate them using a space character. In case the configuration applies to all virtual hosts, leave the box empty.")</p>
<p> $(lang de:"Virtuelle Hosts" en:"Virtual hosts"): <input type="text" name="$1" size="30" maxlength="255" value="$(html "$2")"></p>
EOF
fi
}

check "$LIGHTTPD_CHROOT" yes:chrooten "*":chrootdi
check "$LIGHTTPD_DIRLISTING" enable:dirlista "*":dirlistd
check "$LIGHTTPD_SSLENABLE" enable:sslenaba "*":sslenabd
check "$LIGHTTPD_SSLADDITIONAL" yes:ssladdly no:ssladdln
check "$LIGHTTPD_SSLREDIRECT" yes:sslredirect
check "$LIGHTTPD_LOGGING" yes:log
check "$LIGHTTPD_MODCGI" yes:modcgi
check "$LIGHTTPD_MODFASTCGIPHP" yes:modfastcgiphp
check "$LIGHTTPD_MODFASTCGIRUBY" yes:modfastcgiruby
check "$LIGHTTPD_MODDEFLATE" yes:moddeflate
check "$LIGHTTPD_ERROR" yes:error
check "$LIGHTTPD_AUTH" yes:auth
check "$LIGHTTPD_MODSTATUS" yes:modstatus
check "$LIGHTTPD_MODSTATUSSORT" enable:modstatussort
check "$LIGHTTPD_AUTHMETH" basic:authbasic digest:authdigest
check "$LIGHTTPD_LOGGING_ACCESS_FILE" yes:accesslog_file "*":accesslog_syslog
check "$LIGHTTPD_LOGGING_ERROR_FILE" yes:errorlog_file "*":errorlog_syslog
check "$LIGHTTPD_VIRTHOST" yes:virthost

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$LIGHTTPD_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Web Server" en:"Web server")"
cat << EOF
<p> $(lang de:"Server binden an Port" en:"Listen on port"): <input type="text" name="port" size="5" maxlength="5" value="$(html "$LIGHTTPD_PORT")"></p>
EOF

if [ -d /proc/sys/net/ipv6 ] || find /lib/modules/*-*/kernel/net/ipv6 -maxdepth 1 -name ipv6.ko >/dev/null 2>&1; then
	cgi_print_checkbox_p "ipv6_support" "$LIGHTTPD_IPV6_SUPPORT" \
	  "$(lang de:"Aktiviere IPv6 Unterst&uuml;tzung" en:"Enable IPv6 support")"
fi

dirs=$LIGHTTPD_DOCROOT
[ "$LIGHTTPD_CHROOT" = "yes" ] && dirs="$dirs/websites"
[ "$LIGHTTPD_VIRTHOST" = "yes" ] && dirs="$dirs/default</li><li>$dirs/$LIGHTTPD_VIRTHOSTTYPE"
dirs="<ul><li>$dirs</li></ul>"

cat << EOF
<p style="font-size:10px;">$(lang de:"Das im Folgenden angegebene Datenverzeichnis muss existieren, da lighttpd sonst nicht startet." en:"The document root directory must exist as otherwise lighttpd will not start.")</p>
<p> $(lang de:"Verzeichnis der Daten" en:"Document Root"): <input type="text" name="docroot" size="30" maxlength="255" value="$(html "$LIGHTTPD_DOCROOT")"></p>
<p>$(lang de:"Soll das angegebe Datenverzeichnis auch als chroot-Verzeichnis genutzt werden?" en:"Shall the document root directory used as chroot directory?")</p>
<p>
<input id="c1" type="radio" name="chroot" value="yes"$chrooten_chk><label for="c1"> $(lang de:"Chroot nutzen" en:"Use chroot")</label>
<input id="c2" type="radio" name="chroot" value="no"$chrootdi_chk><label for="c2"> $(lang de:"Ohne chroot" en:"No chroot")</label>
</p>
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass bei einem aktivierten chroot, folgende Eigenschaften gelten relativ zum oben angegebenen Datenverzeichnis, welches das chroot-Verzeichnis ist: Datenverzeichnisse werden im Verzeichnis /websites/default und virtuelle Hosts im Verzeichnis /websites/&lt;extension&gt; gesucht, alle sonstigen Pfadkonfigurationen m&uuml;ssen unterhalb des chroots liegen. Falls FastCGI konfiguriert wird, m&uuml;ssen alle FastCGI Programme und all ihre Bibliotheken innerhalb des chroots liegen - falls das Programm ldd vorhanden ist, wird dies automatisch durchgef&uuml;hrt." en:"Please note that with an activated chroot, the following properties apply relative to the above supplied docroot directory which becomes the chroot directory: the docroot will be searched in /websites/default and virtual hosts in /websites/&lt;extension&gt;, all other path configurations are to be supplied relative to the chroot directory. If FastCGI is configured, all FastCGI programs and their libraries must be found within the chroot - if the ldd program exists, this will be done automatically.")</p>
<p style="font-size:10px;">$(lang de:"Entsprechend der Konfiguration sucht lighttpd deine HTML und andere Dateien in folgenden Verzeichnis(sen) - Anzeige wird nach jeder Speicherung aktualisiert:$dirs" en:"Based on the configuration lighttpd is looking for your HTML and other files in the following directories - the listing is updated after each save:$dirs")</p>
EOF
sec_end

sec_begin "$(lang de:"Virtuelle Hosts" en:"Virtual Hosts")"
cat << EOF
<p><input type="hidden" name="virthost" value="no">
<input id="b9" type="checkbox" name="virthost" value="yes"$virthost_chk><label for="b9"> $(lang de:"Virtuelle Hosts aktivieren" en:"Activate virtual hosts")</label></p>
<p style="font-size:10px;">$(lang de:"Das Verzeichnis der Daten (Document Root) der virtuellen Hosts setzt sich zusammen aus dem Verzeichnis der Daten (Document Root) welches oben angegeben wurde plus der Erweiterung welche im Folgenden gew&auml;hlt wird (&lt;docroot&gt;/&lt;extension&gt;). Falls das Datenverzeichnis mit der gew&auml;hlten Extension existiert, wird dieses Verzeichnis als Datenverzeichnis des virtuellen Hosts verwendet. Falls dieses Verzeichnis nicht existiert, wird das oben gew&auml;hlte Datenverzeichnis plus \"/default/\" als Datenverzeichnis verwendet. Dies bedeutet, dass bei aktivieren virtuellen Hosts das oben gew&auml;hlte Datenverzeichnis nicht mehr direkt verwendet wird.<br />lighttpd wird nur starten, wenn bei aktivierten virtuellen Hosts das default/ Datenverzeichnis existiert.<br />ACHTUNG: &Uuml;berlege genau, welche Option die richtige ist, vor allem im Zusammenspiel mit Zugriffskontrolle oder SSL (zum Beispiel kann die Zugriffskontrolle, welche nur f&uuml;r einen virtuellen Host konfiguriert wurde, einfach ausgehebelt werden, wenn du die Option \"%3\" w&auml;hlst und einen DNS Namen domain.topleveldomain auf deine Box zeigen l&auml;sst)! Meist ist die Option \"%3.%0\" f&uuml;r den gesamten Hostnamen die richtige.<br />F&uuml;r Informationen bez&uuml;glich der erlauben Konfigurationsoptionen siehe <a href=https://wiki.lighttpd.net/Docs:ModEVhost>hier</a>." en:"The document root of the virtual host is defined by combining the above configured document root plus the extension selected as follows (&lt;docroot&gt;/&lt;extension&gt;). If the directory for the virtual host does not exist, the above configured document root extended with \"/default/\" is used as document root. This also means that with activated virtual host support, the above configured document root will not be used directly any more.<br />lighttpd will only start if the the default/ document root exists.<br />ATTENTION: be careful to select the right option (e.g. configuration of virtual hosts where one host is access-protected, the access check is easily circumvented when selecting only \"%3\" and having an DNS entry of domainname.topleveldomain)! In most cases, you want to select the option \"%3.%0\".<br />For details on the allowed configuration, please see <a href=https://wiki.lighttpd.net/Docs:ModEVhost>here</a>.")</p>
<p> $(lang de:"Datenverzeichnis-Erweiterung" en:"Document root directory extension"): <input type="text" name="virthosttype" size="10" maxlength="20" value="$(html "$LIGHTTPD_VIRTHOSTTYPE")"></p>
EOF
sec_end

sec_begin "$(lang de:"Erlaube Auflistung des Verzeichnisinhalts" en:"Allow listing of directory contents")"
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_DIRLISTING" = "y" ]; then
cat << EOF
<p>
<input id="d5" type="radio" name="dirlisting" value="enable"$dirlista_chk><label for="d5"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="d6" type="radio" name="dirlisting" value="disable"$dirlistd_chk><label for="d6"> $(lang de:"Deaktiviert" en:"Deactivate")</label>
</p>
<p> $(lang de:"Kodierung der Dateinamen" en:"File name encoding"): <input type="text" name="dirlistingenc" size="6" maxlength="10" value="$(html "$LIGHTTPD_DIRLISTINGENC")"></p>
EOF
virthost_conf "dirlistingvirt" "$LIGHTTPD_DIRLISTINGVIRT" "$(lang de:"Verzeichnisauflistung" en:"directory listing")"
else
cat << EOF
<p style="font-size:10px;">$(lang de:"Auflistung des Verzeichnisinhaltes nicht m&ouml;glich - mod_dirlisting.so nicht vorhanden." en:"Listing of directory contents not available - mod_dirlisting.so unavailable.")</p>
EOF
fi
sec_end

sec_begin "$(lang de:"SSL Unterst&uuml;tzung" en:"SSL support")"
if [ "$FREETZ_PACKAGE_LIGHTTPD_WITH_SSL" = "y" ]; then
cat << EOF
<p style="font-size:10px;">$(lang de:"Damit lighttpd mit SSL-Unterst&uuml;tzung gestartet werden kann, m&uuml;ssen Zertifikat &amp; Schl&uuml;ssel <a href=\"$(href file lighttpd crt)\">hier</a> eingetragen sein." en:"To start lighttpd with SSL-Support you have to setup Certifikat&amp;Key <a TARGET=\"_blank\" href=\"$(href file lighttpd crt)\">here</a>.")</p>
<p style="font-size:10px;">$(lang de:"Falls das Zertifikat mit einer CA signiert wurde, trage bitte das CA Zertifikat <a href=\"$(href file lighttpd ca)\">hier</a> ein." en:"In case the certificate was signed with a CA, please provide the CA certificate <a TARGET=\"_blank\" href=\"$(href file lighttpd ca)\">here</a>.")</p>
<p><input id="d1" type="radio" name="sslenable" value="enable"$sslenaba_chk><label for="d1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="d2" type="radio" name="sslenable" value="disable"$sslenabd_chk><label for="d2"> $(lang de:"Deaktiviert" en:"Deactivate")</label>
</p>

<p> $(lang de:"Verf&uuml;gbare Cipher festlegen" en:"Set available cipher"): <input type="text" name="sslcipher" size="55" maxlength="999" value="$(html "$LIGHTTPD_SSLCIPHER")"></p>
<font size=-2>
<ul>
<li>$(lang de:"Sichere Liste" en:"Secure list"): EECDH+AESGCM:EDH+AESGCM:AES128+EECDH:AES128+EDH</li>
<li>$(lang de:"Kompatible Liste" en:"Compaitble list"): EECDH+AESGCM:EDH+AESGCM:ECDHE-RSA-AES128-GCM-SHA256:AES256+EECDH:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4</li>
</ul>
</font>

<hr>
<p style="font-size:10px;">$(lang de:"Die SSL Unterst&uuml;tzung kann global als einzigstes konfiguriert werden (der oben konfigurierte Port wird verwendet) oder zus&auml;tzlich zur unverschl&uuml;sselten Verbindung konfiguriert werden. Falls die SSL Unterst&uuml;tzung zus&auml;tzlich gew&uuml;nscht ist, sind folgende Optionen zu setzen." en:"The SSL support can be configured globally as the exclusive access method (the above configured port will be used) or in addition to the unencrypted communication. In case the SSL support is intended to be in addition to the unencrypted communication, all of the following options must be set.")</p>
<p><input id="d3" type="radio" name="ssladditional" value="yes"$ssladdly_chk><label for="d3"> $(lang de:"SSL zus&auml;tzlich" en:"Additional SSL support")</label>
<input id="d4" type="radio" name="ssladditional" value="no"$ssladdln_chk><label for="d4"> $(lang de:"SSL exklusiv" en:"Exclusive SSL support")</label>
</p>
EOF

if [ "$LIGHTTPD_SSLADDITIONAL" == "yes" ]; then
cat << EOF
<p> $(lang de:"SSL Port" en:"SSL port"): <input type="text" name="sslport" size="5" maxlength="5" value="$(html "$LIGHTTPD_SSLPORT")"></p>
EOF

cat << EOF
<hr>
<p style="font-size:10px;">$(lang de:"Mit der folgenden Option wird eine Umleitung (HTTP redirect) vom unverschl&uuml;sselten Port zum SSL Port aktiviert. Diese Umleitung wird nur aktiv, wenn SSL zus&auml;tzlich zur unverschl&uuml;sselten Verbindung konfiguriert wurde. Bei der Benutzung von virtuellen Hosts werden nur die Hostnamen umgeleitet, f&uuml;r die eine SSL Unterst&uuml;tzung aktiv ist." en:"Using the following option, a HTTP redirect is activated redirecting traffic from the unencrypted port to the SSL port. This redirect is only active if SSL is configured as an additional service. When using virtual hosts, only the host names are redirected which are also configured for the SSL support.")</p>
<p>
<input type="hidden" name="sslredirect" value="no">
<input id="s1" type="checkbox" name="sslredirect" value="yes"$sslredirect_chk><label for="s1"> $(lang de:"Umleitung aktivieren" en:"Activate redirect")</label>
</p>
EOF

fi

virthost_conf "sslvirt" "$LIGHTTPD_SSLVIRT" "$(lang de:"Aktivierung der SSL-Unterst&uuml;tzung" en:"activation of SSL support")"

echo '<hr>'
cgi_print_checkbox_p "http2_enabled" "$LIGHTTPD_HTTP2_ENABLED" \
  "$(lang de:"Aktiviere HTTP/2 Unterst&uuml;tzung" en:"Enable HTTP/2 support")"

else
cat << EOF
<p style="font-size:10px;">$(lang de:"SSL Unterst&uuml;tzung in lighttpd nicht einkompiliert." en:"SSL support for lighttpd not compiled in.")</p>
EOF
fi
sec_end

sec_begin "$(lang de:"Zugriffskontrolle" en:"Access control")"
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_AUTH" = "y" ]; then
cat << EOF
<p style="font-size:10px;">$(lang de:"Damit lighttpd Benutzer authentisieren kann, m&uuml;ssen Benutzer <a href=\"$(href file lighttpd user)\">hier</a> eingetragen sein." en:"To allow lighttpd to authenticate users, you have to add users <a TARGET=\"_blank\" href=\"$(href file lighttpd user)\">here</a>.")</p>
<p style="font-size:10px;">$(lang de:"Zugriffsrechte k&ouml;nnen <a href=\"$(href file lighttpd rights)\">hier</a> eingetragen werden." en:"Access rights can be added <a href=\"$(href file lighttpd rights)\">here</a>.")</p>
<p><input type="hidden" name="auth" value="no">
<input id="z1" type="checkbox" name="auth" value="yes"$auth_chk><label for="z1"> $(lang de:"Zugriffskontrolle und Benutzerkonten aktivieren" en:"Activate access control and user accounts")</label></p>
<p>
<input id="z2" type="radio" name="authmeth" value="basic"$authbasic_chk><label for="z2"> $(lang de:"Basic Authentisierung" en:"Basic authentication")</label>
<input id="z3" type="radio" name="authmeth" value="digest"$authdigest_chk><label for="z3"> $(lang de:"Digest Authentisierung" en:"Digest Authentication")</label>
EOF
else
cat << EOF
<p style="font-size:10px;">$(lang de:"Zugriffskontrolle kann nicht konfiguriert werden - mod_auth.so nicht vorhanden." en:"Access control cannot be configured - mod_auth.so unavailable.")</p>
EOF
fi
sec_end

sec_begin "$(lang de:"Dynamische Webseiten" en:"Dynamic Web Pages")"
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_CGI" = "y" ]; then
cat << EOF
<p><input type="hidden" name="modcgi" value="no">
<input id="b1" type="checkbox" name="modcgi" value="yes"$modcgi_chk><label for="b1"> $(lang de:"mod_cgi aktivieren (Dateien *.cgi und in /cgi-bin ausf&uuml;hrbar)" en:"Activate mod_cgi (files *.cgi and in /cgi-bin executable")</label></p>
EOF
virthost_conf "modcgivirt" "$LIGHTTPD_MODCGIVIRT" "$(lang de:"Aktivierung von mod_cgi" en:"activation of mod_cgi")"
echo "<hr>"
else
cat << EOF
<p style="font-size:10px;">$(lang de:"CGI Unterst&uuml;tzung kann nicht konfiguriert werden - mod_cgi.so nicht vorhanden." en:"CGI support cannot be configured - mod_cgi.so unavailable.")</p>
EOF
fi

cat << EOF
<p><input type="hidden" name="modfastcgiphp" value="no">
<input id="b6" type="checkbox" name="modfastcgiphp" value="yes"$modfastcgiphp_chk><label for="b6"> $(lang de:"mod_fastcgi f&uuml;r PHP aktivieren (Dateien *.php ausf&uuml;hrbar)" en:"Activate mod_fastcgi for PHP (files *.php executable)")</label></p>
EOF
	foundphp=$(which php-cgi)
	if [ ! -x "$foundphp" ]; then
		foundphp=""
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm php-cgi wurde nicht gefunden. Bitte gib den vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program php-cgi was not found. Please provide complete path to this program.")</p>
EOF
	else
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm php-cgi wurde im Pfad $foundphp gefunden. Bitte gib diesen oder den entsprechenden vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program php-cgi was found at $foundphp. Please either provide this or the correct path to this program in following box.")</p>
EOF
	fi
	if [ "x$LIGHTTPD_MODFASTCGIPHPPATH" = "x" ]; then LIGHTTPD_MODFASTCGIPHPPATH=$foundphp; fi
cat << EOF
<p> $(lang de:"Pfad zu php-cgi" en:"Path to php-cgi"): <input type="text" name="modfastcgiphppath" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODFASTCGIPHPPATH")"></p>
<p> $(lang de:"Maximale Anzahl der PHP Prozesse" en:"Maximum number of PHP processes"): <input type="text" name="modfastcgiphpmaxproc" size="2" maxlength="2" value="$(html "$LIGHTTPD_MODFASTCGIPHPMAXPROC")"></p>
EOF
virthost_conf "modfastcgiphpvirt" "$LIGHTTPD_MODFASTCGIPHPVIRT" "$(lang de:"Aktivierung der PHP-FastCGI Unterst&uuml;tzung" en:"activation of PHP FastCGI support")"
echo "<hr>"
cat << EOF
<p><input type="hidden" name="modfastcgiruby" value="no">
<input id="b8" type="checkbox" name="modfastcgiruby" value="yes"$modfastcgiruby_chk><label for="b8"> $(lang de:"mod_fastcgi f&uuml;r RUBY aktivieren (Dateien *.rb ausf&uuml;hrbar)" en:"Activate mod_fastcgi for RUBY (files *.rb executable)")</label></p>
EOF
	foundruby=$(which ruby-cgi)
	if [ ! -x "$foundruby" ]; then
		foundruby=""
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm ruby-cgi wurde nicht gefunden. Bitte gib den vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program ruby-cgi was not found. Please provide complete path to this program.")</p>
EOF
	else
cat << EOF
<p style="font-size:10px;">$(lang de:"Programm ruby-cgi wurde im Pfad $foundruby gefunden. Bitte gib diesen oder den entsprechenden vollst&auml;ndigen Pfad zu diesem Programm in folgender Box an." en:"Program ruby-cgi was found at $foundruby. Please either provide this or the correct path to this program in following box.")</p>
EOF
	fi
	if [ "x$LIGHTTPD_MODFASTCGIRUBYPATH" = "x" ]; then LIGHTTPD_MODFASTCGIRUBYPATH=$foundruby; fi
cat << EOF
<p> $(lang de:"Pfad zu ruby-cgi" en:"Path to ruby-cgi"): <input type="text" name="modfastcgirubypath" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODFASTCGIRUBYPATH")"></p>
<p> $(lang de:"Maximale Anzahl der RUBY Prozesse" en:"Maximum number of RUBY processes"): <input type="text" name="modfastcgirubymaxproc" size="2" maxlength="2" value="$(html "$LIGHTTPD_MODFASTCGIRUBYMAXPROC")"></p>
EOF
virthost_conf "modfastcgirubyvirt" "$LIGHTTPD_MODFASTCGIRUBYVIRT" "$(lang de:"Aktivierung der RUBY-FastCGI Unterst&uuml;tzung" en:"activation of RUBY FastCGI support")"

sec_end

sec_begin "$(lang de:"Erweiterte Einstellungen" en:"Advanced Options")"
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_DEFLATE" = "y" ]; then
cat << EOF
<p><input type="hidden" name="moddeflate" value="no">
<input id="b2" type="checkbox" name="moddeflate" value="yes"$moddeflate_chk><label for="b2"> $(lang de:"mod_deflate aktivieren (Cache Verzeichnis muss konfiguriert werden)" en:"Activate mod_deflate (Cache dir must be configured")</label></p>
<p> $(lang de:"Verzeichnis der Cache Daten" en:"Directory of Cache"): <input type="text" name="moddeflatedir" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODDEFLATEDIR")"></p>
EOF
virthost_conf "moddeflatevirt" "$LIGHTTPD_MODDEFLATEVIRT" "$(lang de:"Aktivierung von mod_deflate" en:"activation of mod_deflate support")"
echo "<hr>"
else
cat << EOF
<p style="font-size:10px;">$(lang de:"Dateicaching kann nicht konfiguriert werden - mod_deflate.so nicht vorhanden." en:"Caching of files cannot be configured - mod_deflate.so unavailable.")</p>
EOF
fi
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_STATUS" = "y" ]; then
cat << EOF
<p><input type="hidden" name="modstatus" value="no">
<input id="b3" type="checkbox" name="modstatus" value="yes"$modstatus_chk><label for="b3"> $(lang de:"Statusanzeige aktivieren (URLs m&uuml;ssen konfiguriert werden)" en:"Activate status display (URLs must be configured")</label></p>
<p><input type="hidden" name="modstatussort" value="disable">
<input id="b4" type="checkbox" name="modstatussort" value="enable"$modstatussort_chk><label for="b4"> $(lang de:"JavaScript zum Sortieren der Statusanzeige aktivieren" en:"Activate JavaScript for sorting of status display")</label></p>
<p style="font-size:10px;">$(lang de:"Ein leeres URL Feld deaktiviert die jeweilige Statusanzeige." en:"An empty URL field deactivates the corresponding status display.")</p>
<p style="font-size:10px;">$(lang de:"Falls der Webserver im Internet erreichbar ist, sollten diese URLs gesch&uuml;tzt werden (zum Beispiel mit Zugriffskontrolle - siehe oben)." en:"In case the web server is reachable in the Internet, please consider the protection of these URLs (for example by using the access control feature - see above).")</p>
<p> $(lang de:"URL f&uuml;r Konfiguration" en:"URL for configuration"): <input type="text" name="modstatusconfig" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSCONFIG")"></p>
<p> $(lang de:"URL f&uuml;r Statistiken" en:"URL for statistics"): <input type="text" name="modstatusstatistic" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSSTATISTIC")"></p>
<p> $(lang de:"URL f&uuml;r Status" en:"URL for status"): <input type="text" name="modstatusstatus" size="30" maxlength="255" value="$(html "$LIGHTTPD_MODSTATUSSTATUS")"></p>
EOF
virthost_conf "modstatusvirt" "$LIGHTTPD_MODSTATUSVIRT" "$(lang de:"Aktivierung von mod_status" en:"activation of mod_status support")"
echo "<hr>"
else
cat << EOF
<p style="font-size:10px;">$(lang de:"Statusinformationen k&ouml;nnen nicht angezeigt werden - mod_status.so nicht vorhanden." en:"Status information cannot be displayed - mod_status.so unavailable.")</p>
EOF
fi
cat << EOF
<p><input type="hidden" name="error" value="no">
<input id="b5" type="checkbox" name="error" value="yes"$error_chk><label for="b5"> $(lang de:"Eigene Fehlermeldungen anstelle der automatischen Fehlermeldung aktivieren (Dateiprefix angeben)" en:"Return own error message instead of the automated error messages (provide file prefix")</label></p>
<p style="font-size:10px;">$(lang de:"Der Server kann selbst-erstellte Fehlermeldungen zur&uuml;cksenden, inklusive eigene 404 Fehlerseiten. Generell k&ouml;nnen auch andere HTTP-Fehler (zum Beispiel 500) entsprechend behandelt werden. Es k&ouml;nnen ausschliesslich statische Seiten zur&uuml;ckgesendet werden. Das Format der Dateinamen lautet: &lt;Fehlerdatei-Prefix&gt;&lt;status-code&gt;.html. Der Prefix muss dabei der absolute Pfadname auf dem Hostsystem sein, nicht nur innerhalb des Datenverzeichnisses." en:"You can customize what page to send back based on a status code. This provides you with an alternative way to customize 404 pages. You may also customize other status-codes with their own custom page (500 pages, etc). Only static files are allowed to be sent back. Format: &lt;errorfile-prefix&gt;&lt;status-code&gt;.html. This path must be the absolute path name on the host system, not only starting with the docroot.")</p>
<p> $(lang de:"Datei-Prefix f&uuml;r Fehler" en:"File prefix for error"): <input type="text" name="errorfile" size="30" maxlength="255" value="$(html "$LIGHTTPD_ERRORFILE")"></p>
EOF
virthost_conf "errorvirt" "$LIGHTTPD_ERRORVIRT" "$(lang de:"Aktivierung der Fehlerseiten" en:"activation of error pages")"
cat << EOF
<hr>
<p style="font-size:10px;">$(lang de:"Die folgenden Boxen erlauben, die maximale Datentransferrate in kBytes/s festzulegen. Der Wert 0 bedeutet kein Limit. Bitte beachte, dass ein Wert von unter 32 kb/s effektiv den Verkehr auf 32 kb/s aufgrund der Gr&ouml;sse der TCP Sendepuffer drosselt." en:"The following boxes allw the specification of the maximum data transfer rate in kBytes/s. The value of 0 means no limit. Please note  that a limit below 32kb/s might actually limit the traffic to 32kb/s. This is caused by the size of the TCP send buffer.")</p>
<p> $(lang de:"Maximale Datenrate pro Verbindung" en:"Maximum throughput per connection"): <input type="text" name="limitconn" size="5" maxlength="5" value="$(html "$LIGHTTPD_LIMITCONN")"> kBytes/s</p>
<p> $(lang de:"Maximale Datenrate aller Verbindungen" en:"Maximum throughput for all connections"): <input type="text" name="limitsrv" size="5" maxlength="5" value="$(html "$LIGHTTPD_LIMITSRV")"> kBytes/s</p>
EOF
virthost_conf "limitvirt" "$LIGHTTPD_LIMITVIRT" "$(lang de:"Drosselung der Datentransferrate" en:"limitation of data transfer rate")"
sec_end

sec_begin "$(lang de:"Server Logdateien" en:"Server log files")"
cat << EOF
<p style="font-size:10px;">$(lang de:"Bitte beachte, dass die Logdateien wertvollen RAM Speicher belegen falls das Standardverzeichnis f&uuml;r die Logdateien verwendet wird (siehe unten). Nutze das Logging nur f&uuml;r Fehlersuche und schalten es f&uuml;r den normalen Betrieb ab." en:"Please note that the log files use precious RAM memory if the standard directory for the log files is used (see below). Use logging only for debugging and disable it for regular operation.")</p>
EOF

if [ "$LIGHTTPD_LOGGING" = "yes" ]; then
if [ "$LIGHTTPD_LOGGING_ERROR_FILE" = "yes" ] || [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG" = "y" -a "$LIGHTTPD_LOGGING_ACCESS_FILE" = "yes" ]; then
cat << EOF
<p style="font-size:10px;"><a href="$(href status lighttpd lighttpd-log)">$(lang de:"Logdateien anzeigen" en:"Show logfiles")</a></p>
EOF
fi
fi

cat << EOF
<p>
<input type="hidden" name="logging" value="no">
<input id="a1" type="checkbox" name="logging" value="yes"$log_chk><label for="a1"> $(lang de:"Log aktivieren" en:"Activate logging")</label>
</p>
EOF
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG" = "y" ]; then
cat << EOF
<p>$(lang de:"Speicherart des Zugriffs-Logs (Access Log)" en:"Save type of access log")
<input id="e3" type="radio" name="logging_access_file" value="yes"$accesslog_file_chk><label for="e3"> $(lang de:"Datei" en:"File")</label>
<input id="e4" type="radio" name="logging_access_file" value="no"$accesslog_syslog_chk><label for="e4"> $(lang de:"Syslog" en:"Syslog")</label>
</p>
EOF
else
cat << EOF
<p style="font-size:10px;">$(lang de:"Zugriffs-Logs (Access Log) kann nicht konfiguriert werden - mod_accesslog.so nicht vorhanden." en:"Access logs cannot be configured - mod_accesslog.so unavailable.")</p>
EOF
fi
cat << EOF
<p>$(lang de:"Speicherart des Fehler-Logs (Error Log)" en:"Save type of error log")
<input id="e5" type="radio" name="logging_error_file" value="yes"$errorlog_file_chk><label for="e5"> $(lang de:"Datei" en:"File")</label>
<input id="e6" type="radio" name="logging_error_file" value="no"$errorlog_syslog_chk><label for="e6"> $(lang de:"Syslog" en:"Syslog")</label>
</p>
<p style="font-size:10px;">$(lang de:"In den folgenden Boxen k&ouml;nnen die absoluten Pfade zu den Logdateien ge&auml;ndert werden. Beachte, dass lighttpd mit der Benutzer ID wwwrun l&auml;uft und die Datei und das Verzeichnis f&uuml;r wwwrun schreibbar sein muss. Das Standardverzeichnis /var/log/lighttpd/ ist immer f&uuml;r den Benutzer wwwrun schreibbar. Falls ein anderes Verzeichnis als das Standardverzeichnis verwendet wird, erfolgt keine automatische L&ouml;schung der Logdateien, wenn logging deaktiviert wird. Wenn der Pfadname mit einem '|' beginnt, wird der im Anschluss folgende Pfadname als Prozess ausgef&uuml;hrt und erh&auml;lt die Logdaten als Eingabe via STDIN." en:"In the following boxes, you can alter the absolute path names to the log files. Please note, the lighttpd web server runs with the user ID of wwwrun. The provided file/path must be writeable for this user ID. The default directory /var/log/lighttpd/ is always writeable for wwwrun. If you use a different directory than the default directory, the log files will not be automatically removed in case you deactivate logging. If the path name starts with a '|' the rest of the name is taken as the name of a process which will be spawned and will get the output via STDIN.")</p>
EOF
if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG" = "y" ]; then
cat << EOF
<p> $(lang de:"Zugriffs-Log (Access log)" en:"Access log"): <input type="text" name="logging_access" size="25" maxlength="255" value="$(html "$LIGHTTPD_LOGGING_ACCESS")"></p>
EOF
fi
cat << EOF
<p> $(lang de:"Fehler-Log (Error log)" en:"Error log"): <input type="text" name="logging_error" size="25" maxlength="255" value="$(html "$LIGHTTPD_LOGGING_ERROR")"></p>
EOF
sec_end

