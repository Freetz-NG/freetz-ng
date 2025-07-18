# mini_fo 0.3 - DEPRECATED
  - Package: [master/make/pkgs/mini_fo/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/mini_fo/)
  - Maintainer: -

[![Mini_fo Webinterface](../screenshots/205_md.png)](../screenshots/205.png)

**mini_fo** ist ein Overlay-Dateisystem vergleichbar mit
[UnionFS](http://de.wikipedia.org/wiki/UnionFS),
welches von diversen Live-Distributionen (z.B. Knoppix) bekannt ist.
Vereinfacht ausgedrückt, lässt sich damit ein schreibgeschütztes
Dateisystem beschreibbar machen. Natürlich kann man auf dem
schreibgeschützten Medium nicht wirklich (physisch) schreiben:
Änderungen werden an anderer Stelle gespeichert, was aber für den
Anwender derart transparent geschieht, dass er davon eigentlich nichts
merkt - sondern wirklich den Eindruck eines einzelnen, beschreibbaren
Mediums hat.

### Konfiguration (Webinterface)

Das Paket wird über das Webinterface konfiguriert. Hierbei kann der
Speicherort für die Änderungen ausgewählt werden. Entweder RAM
(flüchtig) oder JFFS2 (reboot resistent). Bei Auswahl der Option JFFS2
muss genügend freier Speicherplatz verfügbar sein (die Daten werden gzip
komprimiert abgespeichert):

```
root@fritz:/var/mod/root# df /dev/mtdblock5
Filesystem           1K-blocks      Used Available Use% Mounted on
/dev/mtdblock5            3200      2612       588  82% /sto
```

Das Paket kann nur durch einen Reboot de-/aktiviert werden.

### Konfiguration (per Hand)

**mini_fo** ist ein Kernel-Modul, das man entweder ohne Argumente mit
insmod lädt...

```
 insmod mini_fo
```

...oder in der Freetz-Oberfläche in Modules einträgt, damit es beim
Start geladen wird:

```
 mini_fo
```

Ist es aktiv steht der mount-type 'mini_fo' zur Verfügung. Um
/usr/www beschreibbar zu machen genügt diese Zeile in rc.custom:

```
mkdir -p /tmp/usrwww /tmp/usrwww-sto && 
 mount -o bind /usr/www /tmp/usrwww && 
 mount -t mini_fo -o base=/tmp/usrwww,sto=/tmp/usrwww-sto minifo /usr/www
```

Im Pfad /tmp/usrwww-sto befinden sich dann jegliche Änderungen.

### Mögliche Nebeneffekte

Ein Firmware-Update kann evtl. mit geladenem mini_fo Modul scheitern
(getestet mit 7170 4.8x). Es gibt dann keine Fehlermeldung aber die Box
hängt vor dem Herunterfahren und der Flash-Vorgang kommt nie zustande.
Wenn dies passiert sollte man vor einer Firmware-Aktualisierung ohne
mini_fo booten. Aktueller Trunk zeigt das Phenomen nicht.

Wird mini_fo auf einer Box ohne JFFS2-Partition betrieben fängt es auch
Schreibzugriffe auf /data ab, zumindest bis ein USB-Stick gemountet ist.
In /sto/mini_fo taucht dann data/tam/config und data/tam/rec/ mit dem
Datum 2000 (also vor Zeitsync) auf. Dieser Nebeneffekt ermöglicht es
Anrufbeantworter ohne JFFS2-Partition und ohne USB-Stick zu testen, z.B.
zur Weiterleitung per Email mit anschließender Löschung. Dabei sollte
man die Aufnahmelänge begrenzen damit der RAM-Speicher nicht
versehentlich aufgebraucht werden kann. Speichert mini_fo im RAM gehen
allerdings bei einem Neustart alle derart definierten Anrufbeantworter
verloren.

Bei Modellen der Generation 7170 zeigten sich Watchdog initiierte
Rebootschleifen (ca. 2-4min) bei aktiviertem WLAN mit Verschlüsselung im
DSL-Modem Modus (also Default nach Werksreset). Rebootgrund in crash.log
ist dann ein dsld Watchdog Timeout. Ohne WPA Verschlüsselung oder im
IP-Client Modus zeigt sich das Phenomen nicht. Offensichtlich werden
Semaphoren die dsld zur Verwaltung von Shared Memory in /var/tmp/csem
ablegt teilweise in /sto abgefragt und der Mechanismus empfindlich
gestört.

### Restore original file

The modified files are stored here (trunk version):

```
/sto/mini_fo/...
```

So for example a modified */usr/sbin/blkid* is stored as
*/sto/mini_fo/usr/sbin/blkid*.

If you remove the latter one, the original one will reappear in your
file system.

### Weiterführende Links

-   [diesen
    Thread](http://www.ip-phone-forum.de/showthread.php?t=111226)
    im Forum.
-   [mini_fo project
    page](http://www.denx.de/twiki/bin/view/Know/MiniFOHome).

