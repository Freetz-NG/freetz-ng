#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=support_file
cgi_begin "$(lang de:"Supportdatei erstellen" en:"Create support file")"
cat << EOF

<p>$(lang \
  de:"Es wird eine Datei mit Konfigurations- und Logdateien zusammengepackt, die eine Fehlersuche erm&ouml;glicht. Es werden Callmonitor-Rufnummern, DSL-Serial, MAC-, IPv4- sowie IPv6-Adressen entfernt. Es gibt aber keine Garantie, dass dies fehlerfrei funktioniert. Deshalb bitte vor Ver&ouml;ffentlichung der Datei selbst pr&uuml;fen, ob irgendwelche pers&ouml;nlichen Daten enthalten sind!" \
  en:"A file with config and log files is created to find errors. Confidential details like Callmonitor phonenumbers, DSL-serial, MAC-, IPv4- and IPv6-addresses will be removed. But please check the file before publishing it!" \
)</p>

<form action="do_support.cgi" method="POST">
$(csrf_input)
<p><input type=submit value="$(lang de:"anfordern" en:"request")" style="width:150px"></p>
</form>

EOF
cgi_end
