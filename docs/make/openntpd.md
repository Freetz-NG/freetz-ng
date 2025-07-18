# Openntpd 3.9p1 - DEPRECATED
  - Package: [master/make/pkgs/openntpd/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/openntpd/)
  - Maintainer: -

*"OpenNTPD ist eine FREIE und einfach zu benutzende Implementierung des
Network Time Protocol. OpenNTPD kann die lokale Uhr mit NTP-Servern
abgleichen und selbst als NTP-Server fungieren, also die lokale Uhrzeit
anderen Systemen zur Verfügung stellen."*
[http://www.openntpd.org/de/](http://www.openntpd.org/de/)

Mit **OpenNTPD** lässt sich die Zeit per Internet synchronisieren.
Natürlich kann man das von jedem PC aus auch, und die Fritzbox (multid
daemon) selbst holt sich die Zeit ja auch aus dem Netz - wozu also
dieses Paket?

Das OpenNTPD Paket stellt nicht nur einen Client, sondern auch einen
Server zur Verfügung. Somit kann sich die FritzBox die Zeit aus dem
Internet "downloaden" - und stellt sie dann im lokalen Netz bereit.

### Vorteile:

-   Nur die FritzBox muss die Zeit "Remote" abgleichen
-   Da die FritzBox sicher rund um die Uhr läuft, kann dies jederzeit
    passieren - und dennoch steht die aktuelle Zeit zur Verfügung,
    sollte das Internet mal "kaputt" sein (Probleme beim Provider
    o.ä.).
-   Alle Rechner im lokalen Netz synchronisieren mit der FritzBox, und
    haben somit identische Zeitstempel - sehr von Vorteil, wenn man z.B.
    Logfiles abgleichen will.
-   Auch Rechner, die nicht ins Internet dürfen, haben die Chance auf
    einen Zeitabgleich.

### Ubuntu client setup

-   Install: *sudo apt-get install ntp*
-   Configure: *add server fritz.box* as first server to */etc/ntp.conf*
-   Apply configuration: *sudo service ntp restart*
-   Check if it works: *sudo ntpq -np*
-   More info:
    [here](https://help.ubuntu.com/community/UbuntuTime)

### Multid NTP client deaktivieren

Durch diese Option wird AVM's multid durch einen zusätzlichen Parameter
angewiesen die Zeit nicht zu synchronisieren (erfordert Restarts von
multid).

Wenn chronyd in der Firmware vorhanden ist wird multid in rc.net ohne
SNTP-Funktion gestartet. Zusätzlich deaktiviert multid diese Funktion
auch automatisch wenn /var/run/chronyd.pid existiert
([source](http://www.wehavemorefun.de/fritzbox/index.php/Multid#Aufruf)).

SNTP = Simple Network Time Protocol

openntpd automatically selects Remove chronyd.

### Fehlerbehebung

-   `dispatch_imsg in main: pipe closed`: In der `openntpd.conf` wird
    `listen on` falsch benutzt.

### Alternative

Man kann auch den in [inetd](inetd.html#user) integrierten
["time"
Service](http://en.wikipedia.org/wiki/Time_Protocol)
aktivieren. Diese kann z.B. mit "rdate" genutzt werden, welches
bereits in Freetz enthalten ist oder auch auf der Dbox2

### Weiterführende Links

-   [http://www.openntpd.org/](http://www.openntpd.org/)
-   [Artikel zu
    OpenNtpd](http://www.zdnet.de/builder/program/0,39023551,39191851,00.htm)

