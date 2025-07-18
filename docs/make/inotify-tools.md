# inotify-tools 3.14 (binary only) - DEPRECATED
  - Homepage: [https://github.com/inotify-tools/inotify-tools](https://github.com/inotify-tools/inotify-tools)
  - Manpage: [https://github.com/inotify-tools/inotify-tools/wiki](https://github.com/inotify-tools/inotify-tools/wiki)
  - Changelog: [https://github.com/inotify-tools/inotify-tools/releases](https://github.com/inotify-tools/inotify-tools/releases)
  - Repository: [https://github.com/inotify-tools/inotify-tools/commits/master](https://github.com/inotify-tools/inotify-tools/commits/master)
  - Package: [master/make/pkgs/inotify-tools/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/inotify-tools/)
  - Maintainer: -

**Inotify** ist eine Kernel-Schnittstelle zur Überwachung von
Dateizugriffen, verbunden mit einem Event-Mechanismus, von dem man sich
über bestimmte Ereignisse benachrichtigen lassen kann. Siehe dazu den
[deutschen
(kurz)](http://de.wikipedia.org/wiki/Linux_%28Kernel%29#Inotify)
und [englischen
(ausführlich)](http://en.wikipedia.org/wiki/Inotify)
Wikipedia-Artikel.

### Inotify und Inotify-Tools allgemein

Die
**[Inotify-Tools](http://inotify-tools.sourceforge.net)**
sind eine kleine Sammlung von Werkzeugen bzw. Programmierschnittstellen,
um bequemer diesen mächtigen Mechanismus nutzen zu können. Wir stellen
als Freetz-Paket zwei ausführbare Werkzeuge und eine Bibliothek zur
Verfügung, und zwar

-   inotifywait,
-   inotifywatch und
-   libinotifytools

Verwendungsbeispiele gibt es ebenfalls auf der
[Sourceforge-Projektseite](http://inotify-tools.sourceforge.net/#info).
**Inotifywait** wartet auf ein Ereignis, für das man sich vorher
registriert hat und kehrt dann zurück, wenn es eintritt. Das Ganze geht
auch im Hintergrundbetrieb, wenn man Ereignisse nicht nur einmalig,
sondern dauerhaft beobachten möchte. **Inotifywatch** hingegen sammelt
und summiert statistische Daten zu Dateisystem-Ereignissen und stellt
sie in tabellarischer Textdarstellung zur Verfügung.

### Dateizugriffe der FritzBox ab dem Start beobachten

Eine besondere Anwendung, für die das Startskript `rc.S` durch einen
speziellen, immer eingebauten Patch vorbereitet wird, ist das
Protokollieren sämtlicher Dateisystemzugriffe beim Starten der Box.
`rc.S` ist das erste Skript, welches von `init` ausgeführt wird, d.h.
die Protokollierung beginnt wirklich sehr früh (direkt nach dem Start
des Watchdogs), man verpaßt nichts Wichtiges. Da es keinen Sinn macht,
diese Protokollierung immer durchzuführen, kann man sie ein- und
ausschalten. Dafür verwendet man das [kernel_args-API?]. Vor dem zu protokollierenden Startvorgang, also vor dem Reboot,
aktiviert man die Protokollierung:

```
# API laden
. /usr/bin/kernel_args
# Aktivieren (Achtung, kein "=", zwei Parameter!)
ka_setValue InotifyBootAnalysis y
# Prüfen, ob Variable gesetzt
ka_getArgs
# Ergebnis z.B. idle=4 foo=bar InotifyBootAnalysis=y
```

Anstatt den Wert "y" kann man auch einen positiven Ganzzahlwert
zuordnen, der automatisch bei jedem Start um 1 vermindert wird, bis er
schließlich 0 werden würden, was zum Folgewert "n" und zur
automatischen Deaktivierung der Funktion führt. So kann man erstens das
Deaktivieren nicht auf Dauer vergessen und zweitens mögliche Probleme
beim Hochfahren der Box durch das Logging eliminieren, indem man sie
einfach oft genug neu startet, bis die Funktion wieder inaktiv ist.

Deaktivieren kann man die Funktion auch manuell, indem man in obiger
Code-Sequenz eine Zeile austauscht:

```
# Deaktivieren
ka_setValue InotifyBootAnalysis n
```

Auch ganz löschen kann man die Variable aus dem Bootloader Environment:

```
# Variable ganz löschen
ka_removeVariable InotifyBootAnalysis
```

Wenn das Logging erst einmal gestartet wurde, läuft es immer weiter, bis
man es manuell stoppt, nachdem der Startvorgang abgeschlossen ist bzw.
auch danach noch man so viel protokolliert hat, wie man möchte. Es
könnte ja sein, daß man außer dem Startvorgang noch einige Stunden oder
Tage die Box weiter beobachten möchte, um festzustellen, welche Dateien
überhaupt benutzt werden oder nicht, um sie dann in Verbindung mit dem
[Downloader-CGI](downloader.md) auszulagern und nachzuladen
oder ganz aus der Firmware zu entfernen, um Platz zu schaffen für mehr
oder größere Pakete, was gerade bei Boxen mit nur 4 MB Flash-Größe eine
Kunst für sich ist. Die 8-MB-Boxen sind da weniger eingeengt, aber auch
dort kann es interessant sein, falls man unter "Featuritis" leidet.

Wie also stoppt man die Protokollierung, bevor einem der Speicher
volläuft?

```
# Protokollierung anhalten
/etc/init.d/rc.inotify_tools stop
```

Ob die Protokollierung gerade läuft, kann man so feststellen:

```
# Status prüfen ("running" oder "stopped")
/etc/init.d/rc.inotify_tools status
```

Es ist auch jederzeit im laufenden Betrieb möglich, die Protokollierung
einzuschalten, um bei Bedarf zur Laufzeit alle Dateizugriffe zu
beobachten:

```
# Protokollierung (neu) starten
/etc/init.d/rc.inotify_tools start
```

Achtung, ein kleiner Ausflug ins noch Technischere: Man sollte wissen,
daß `rc.inotify_tools start` eine evtl. bereits laufende Protokollierung
kurzzeitig stoppt und sie dann sofort neu startet. Das ist etwas
ungewohnt, kann aber nützlich sein in Situationen, wo Init von einem
Skript aufgrund z.B. `kill -1 1`, wie `rc.mini_fo` es verwendet, um in
mehreren Durchgängen sein Overlay-Dateisystem aufzuziehen, beendet wird,
um dann neu gestartet zu werden und nochmals die Startskripten
aufzurufen. Dazwischen kann die Protokollierung entweder noch laufen
oder abgebrochen worden sein. Jedenfalls startet Inotify-Tools in diesem
Fall neu, ggf. jetzt mit Ausgabe auf das frisch gemountete *mini_fo*
(vorher auf das nun überdeckte, darunter liegende Dateisystem).

### Was wird von rc.inotify_tools protokolliert?

Wir könnten alles protokollieren, aber das wäre eine große Datenmenge,
weil bestimmte Zugriffe, z.B. auf häufig verwendete Dateien wie
`busybox`, `uClibc` oder `libcrypt` das Log zumüllen. Daß sie verwendet
werden, sollte sowieso selbstverständlich sein, und wir werden sie auch
ganz bestimmt nicht aus der Firmware auslagern. Also werden sie bei der
Protokollierung nicht berücksichtigt. So sieht in `rc.S` die Passage
aus, wo die Protokollierung gestartet wird:

```
echo "starting inotifywait"
inotifywait -c -r -m / 
@/dev @/proc @/var @/rom @/sto 
--exclude 'busybox|uClibc|libcrypt-0' 
>> /var/iw.log 2> /dev/null &
sleep 3
```

Es wird also kontinuierlich geloggt, und zwar rekursiv alles ab dem
Wurzel-Verzeichnis ("/" als Parameter am Ende der ersten
Aufruf-Zeile). Ausgeschlossen sind die virtuellen oder für interne
*Mini_fo*-Zwecke verwandten Verzeichnisse `/dev`, `/proc`, `/rom`,
`/sto` sowie die RAM-Disk `/var`, desweiteren Dateien, welche die
Zeichenketten "busybox", "uClibc" oder "libcrypt-0" enthalten -
die "-0" am Ende grenzt übrigens `libcrypt` von `libcrypto` ab.

Das Log wird geschrieben in die RAM-Disk nach `/var/iw.log` - "iw" wie
"inotifywait".

### Ausgabeformat

Was steht nun drin in `/var/iw.log` bzw. wie sieht es aus? Ein kleiner
Ausschnitt:

```
/etc/,"CLOSE_NOWRITE,CLOSE",.subversion
/lib/,"CLOSE_NOWRITE,CLOSE",libgcc_s.so.1
/lib/,"CLOSE_NOWRITE,CLOSE",libgcc_s.so.1
/lib/,OPEN,libgcc_s.so.1
/lib/,ACCESS,libgcc_s.so.1
/lib/modules/2.6.13.1-ohio/modules/,DELETE_SELF,
/lib/modules/2.6.13.1-ohio/modules/,IGNORED,
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avm_event/,DELETE_SELF,
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avm_event/,IGNORED,
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avalanche_led/,DELETE_SELF,
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avalanche_led/,IGNORED,
/lib/,"CLOSE_NOWRITE,CLOSE",libgcc_s.so.1
/usr/share/images/,OPEN,edge_lt.png
/usr/share/images/,ACCESS,edge_lt.png
/usr/share/images/,"CLOSE_NOWRITE,CLOSE",edge_lt.png
```

Mit dem Aufruf aus `rc.S` heraus wurde dafür gesorgt, daß in einem
leicht woanders (Tabellenkalkulation, Datenbank) importierbaren,
kommagetrennten CSV-Format protokolliert wird. Wie die einzelnen Daten
zu interpretieren sind, entnimmt man der Dokumentation der
Inotify-Tools, das ist nicht Freetz-spezifisch.

Falls man andere Daten sammeln möchte, z.B. Zugriffe auf die RAM-Disk
mit protokolliert haben möchte, nur ein bestimmtes Verzeichnis
beobachten möchte, nur Schreibvorgänge beobachten möchte usw., kann man
`inotifywait` immer noch manuell starten oder für vorgefertigte
Statistiken auch mal `inotifywatch` bemühen.

### Log-Datei regelmäßig konsolidieren, um Platz zu sparen

Zum Zweck des Platzsparens in Firmware-Images interessiert uns
vermutlich weniger, auf welche Dateien in welcher Reihenfolge, wie oft,
auf welche Weise (lesen, schreiben, anlegen, löschen etc.) zugegriffen
wurde, sondern lediglich, auf welche Dateien *überhaupt* zugegriffen
wurde - bzw. auf welche nicht, denn die würden dann im Log fehlen. Dafür
wäre eine kumulierte Ausgabe praktisch, welche

-   das Log bei Überschreiten einer bestimmten Größe kondensiert auf
    eine Liste reiner Pfad- und Dateinamen, alphabetisch nach Pfad
    sortiert,
-   diese kondensierte Liste mit einer evtl. vorhandenen vorherigen
    Version vereinigt und Dubletten entfernt,
-   das große Log löscht und zu diesem Zweck kurz zwischendurch die
    Protokollierung anhält,
-   die Protokollierung ins große Log neu startet, bis die Maximalgröße
    wieder erreicht wird

usw. immer im Kreis. Folgendes Skript habe ich in meiner
`/var/tmp/flash/rc.custom`, sie wird also nach dem Ende des
Freetz-Startvorgangs ausgeführt:

```
# Create script for continuous file access logging and log file consolidation
cat << 'EOF' > /var/tmp/iw_continuous
#!/bin/sh

# If inotify logging is inactive, start it
if [ "$(/etc/init.d/rc.inotify_tools status)" != "running" ]; then
/etc/init.d/rc.inotify_tools start
fi

MAX_LOG_SIZE=$(( 10 * 1024 ))
while true; do
sleep 60
if [[ $(( $MAX_LOG_SIZE - $(cat /var/iw.log | wc -c) )) -gt 0 ]]; then
    #echo "current size of iw.log < $MAX_LOG_SIZE - continue logging"
    continue;
fi
#echo "current size of iw.log >= $MAX_LOG_SIZE - consolidate file list and restart logging"
cat /var/iw.log | grep '^/' | sed 's/,.*,//' | sort | uniq | sed 's//////' > /var/iw-unique.tmp
touch /var/iw-unique.log
cat /var/iw-unique.log >> /var/iw-unique.tmp
cat /var/iw-unique.tmp | sort | uniq > /var/iw-unique.log
rm -f /var/iw-unique.tmp /var/iw.log
/etc/init.d/rc.inotify_tools start
done
EOF

chmod +x /var/tmp/iw_continuous

# If inotifywait is already running, start continuous logging script
if [ "$(/etc/init.d/rc.inotify_tools status)" == "running" ]; then
/var/tmp/iw_continuous > /dev/null 2>&1 &
fi
```

Das Skript erzeugt ein weiteres, ausführbares Skript, welches im
Hintergrund gestartet wird und die eigentliche kontinuierliche
Konsolidierung des großen Logs übernimmt. Die konsolidierte Liste der
Dateien wird regelmäßig aktualisiert in `/var/iw-unique.log`, wo man sie
jederzeit einsehen kann. Sie sieht in etwa so aus (Ausschnitt):

```
/
/etc/.subversion
/etc/default.callmonitor/system.cfg
/etc/init.d/rc.bftpd
/etc/init.d/rc.cifsmount
/etc/init.d/rc.crond
/etc/init.d/rc.dropbear
/etc/init.d/rc.inotify_tools
/etc/init.d/rc.mini_fo
/etc/init.d/rc.nfsroot
/etc/init.d/rc.samba
/etc/init.d/rc.swap
/etc/init.d/rc.syslogd
/etc/init.d/rc.telnetd
/etc/init.d/rc.webcfg
/etc/init.d/rc.wol
/etc/static.pkg
/lib/libgcc_s.so.1
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avalanche_led/
/lib/modules/2.6.13.1-ohio/kernel/drivers/char/avm_event/
/lib/modules/2.6.13.1-ohio/modules/
/usr
/usr/
/usr/lib/callmonitor/applets/rc.callmonitor.sh
```

### Schlußwort

Damit steht ein mächtiges und nun im nachhinein auch dokumentiertes
Analyse-Werkzeug zur Verfügung, mit dem die Möglichkeiten der
"Platzspar-Jünger" sich hoffentlich etwas erweitern werden. Viel Spaß
beim Ausprobieren. Geduld, Ihr kommt dahinter, bei mir hat es auch
gedauert - leider hatte ich diese Doku aus naheliegenden Gründen nicht.
;-)

Im Forum war der Ursprung dieses Pakets meine Idee und Anfrage
[dort](http://www.ip-phone-forum.de/showthread.php?t=134151),
aktuell kann über das Paket und diesen Artikel diskutiert werden im
neuen Thema [Paket Inotify-Tools +
Anwendungen](http://www.ip-phone-forum.de/showthread.php?t=150597)

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)

