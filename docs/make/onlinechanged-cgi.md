# Onlinechanged-CGI
  - Package: [master/make/pkgs/onlinechanged-cgi/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/onlinechanged-cgi/)
  - Maintainer: -
<br>

AVM-Firmwares beinhalten einen Mechanismus, welcher dafür sorgt, daß

 * beim Start der Box (Parameter $1 hat den Wert "start"),
 * bei der Trennung der Internet-Verbindung (Parameter $1 hat den Wert "offline") und auch
 * beim Neuaufbau der Internet-Verbindung (Parameter $1 hat den Wert "online") 

jeweils das Skript /bin/onlinechanged aufgerufen wird, welches wiederum weitere Skripten unterhalb der Verzeichnisse /etc/onlinechanged und
/var/tmp/onlinechanged, sofern vorhanden, aufruft. Diese Skripten (re-)initialisieren diverse Dienste, wie z.B. WebDAV (Online-Speicher).

Auch diverse Freetz-Pakete benötigen die Möglichkeit, beim Wechsel des Verbindungsstatus gewisse Aktionen durchzuführen, z.B. DynDNS-Hostnamen
mit neuer IP-Adresse zu registrieren, VPN-Verbindungen neu aufzubauen etc. Das Paket Onlinechanged-CGI ermöglicht es dem Benutzer darüber hinaus,
eigene Aktionen anzustoßen, bspw. eine E-Mail mit der aktuellen IP an den Benutzer zu senden.

 * Hinweis: AVM Onlinechanged funktioniert nur auf Geräten, die so konfiguriert sind, daß sie die Internet-Verbindung selbst herstellen (also
   i.d.R. via DSL oder via PPPoE), nicht auf Boxen hinter einem NAT (z.B. bei "Internetverbindung mitbenutzen"). Falls auf solchen Geräten auch
   Onlinechanged ausgeführt werden soll, geht das über den Patch "replace onlinechanged", der auch zur Anwendung kommt in Problemfällen bei Geräten,
   wo AVM Onlinechanged nicht zuverlässig funktioniert (siehe entsprechendes ​IPPF-Thema).


Dieses Feature ist ab r2850 (trunk) in Freetz und wurde implementiert weil AVM in der Firmware 54.04.67 das Verhalten von /bin/onlinechanged geändert hat.
Bisher handelte sich bei /bin/onlinechanged um ein Symlink auf das Skript /var/tmp/onlinechanged. Die Entstehung kann in Ticket #271 nachverfolgt werden.

Um das Verhalten zu vereinheitlichen gilt ab r2850 für /bin/onlinechanged:
Beim Wechsel des Online Status wird das Skript vom multid mit online bzw. offline als Parameter aufgerufen und ruft dann selbst folgende Skripte auf:

 * /var/tmp/onlinechanged 	Kompatibilität zum alten Verhalten
 * /etc/onlinechanged/* 	neues AVM Verhalten
 * /tmp/flash/onlinechanged/* 	Skripte im Freetz Flash

Ein Skript in /etc/onlinechanged könnte zum Beispiel folgendermaßen aussehen:
```
#!/bin/sh

case "$1" in
   online)
      /etc/init.d/rc.package online
      ;;

   offline)
      /etc/init.d/rc.package offline
      ;;
esac
```

An application: update external IP-address for dnsd:
```
EXTIP="`/usr/bin/get_ip -d`"
sed "s/#EXTIP#/$EXTIP/g"</tmp/flash/dnsd/dnsd_template.conf >/tmp/flash/dnsd/dnsd.conf
modsave
/etc/init.d/rc.dnsd restart
logger -t dnsd "IP set to $EXTIP"
```

You can send yourself an e-mail when your box comes online like this:

```
   online)
      mailer -s "Freetz online" -t <your e-mail address>
      ;;
```

For this to work, you should configure the ​AVM Push service, but it is not necessary to enable it. 

