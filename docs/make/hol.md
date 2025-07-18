# Halt-On-Lan 1.0 - DEPRECATED
  - Package: [master/make/pkgs/hol/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/hol/)
  - Maintainer: -

Halt-on-Lan ist ein Paket zum Steuern vom Rechner im lokalen Netz von
der FritzBox heraus. Es basiert auf
[poweroff.exe](http://users.telenet.be/jbosman/poweroff/poweroff.htm)
einem Skript für Windows-Rechner, redet seine Sprache und ermöglicht den
Rechner herunterzufahren, neu zu starten und einige weitere Aktionen.
Seit
Changeset r5024
ist HOL-Paket im trunk.
Langfristig ist angedacht HOL mit WOL zu verbinden und HOL-Aktionen aus
dem erweiterten WOL-WebIF zu ermöglichen. Momentan ist es noch nicht
implementiert und man sollte sich mit der Kommandozeile befreunden:

```
/var/mod/root # hol
hol v1.0 Halt-On-Lan script
Author hermann72pb <http://www.ip-phone-forum.de/member.php?u=80424>

Usage: hol HOST [ACTION TIME MESSAGE]
HOST      Hostname or ip address: e.g. my.computer or 192.168.178.20
ACTION    Actions for poweroff: e.g. shutdown, reboot, logoff, lock, etc.
TIME      time in seconds for warning before the action:
          e.g. 10 or 0 for no warning
MESSAGE   Warning message: e.g. Please close all your files
/var/mod/root # hol 192.168.178.20
/var/mod/root # hol 192.168.178.20 lock
/var/mod/root # hol MeinPC monitor_off 15
/var/mod/root # hol DeinNotebook monitor_off 15 "Hey, dunschalte aus!"
```

Man kann aber schon jetzt die HOL-Aufrufe als callmonitor-Aktionen oder
als cron-Einträge benutzen. Zur Konfiguration der Default-Aktionen und
sonstiger Parameter gibt es eine Konfigurationsseite zum Paket HOL im
FREETZ-WebIF. Aus dieser Konfigurationseite ist es jedoch nicht möglich,
die Aktionen zu initiieren.

Weitere Informationen und Diskussion zum HOL-Paket können dem
entsprechenden
[Thread](http://www.ip-phone-forum.de/showthread.php?t=211366)
in IPPF entnommen werden.
Um den Rechner von der FritzBox ansteuern zu können, muss auf dem
Rechner eine poweroff.exe-kompatible Anwendung laufen. Das kann z.B.
[poweroff.exe](http://users.telenet.be/jbosman/poweroff/poweroff.htm)
selbst sein. Da
[poweroff.exe](http://users.telenet.be/jbosman/poweroff/poweroff.htm)
leider nicht richtig und nicht zuverlässig zu funktionieren scheint,
wurde vom Benutzer
[linuxkasten](http://www.ip-phone-forum.de/member.php?u=217599)
aus IPPF eine Alternative dafür
([remotehalt](http://www.nefkom.info/crats/software/remotehalt/))
für Windows geschrieben. Es wird empfohlen ab jetzt
[remotehalt](http://www.nefkom.info/crats/software/remotehalt/)
anstatt von
[poweroff.exe](http://users.telenet.be/jbosman/poweroff/poweroff.htm)
zu benutzen.
Auch für Linux-Anweder werden gerade passende Lösungen erarbeitet. Zum
einen existiert eine getarte
[Sammlung](http://www.ip-phone-forum.de/showpost.php?p=1501078&postcount=1)
zum entpacken und selbst installieren, zum anderen gibt es dafür auch
eine
[inetd-Variante](http://www.ip-phone-forum.de/showpost.php?p=1553804&postcount=39).
Sobald alle rechnerseitigen Anwendungen vollständig implementiert und
ausreichend getestet sind, werden hier die
[Download](../Download.html)-Informationen dafür überarbeitet.

