# Bftpd 6.2
  - Homepage: [https://bftpd.sourceforge.net/](https://bftpd.sourceforge.net/)
  - Manpage: [https://bftpd.sourceforge.net/documents.html](https://bftpd.sourceforge.net/documents.html)
  - Changelog: [https://bftpd.sourceforge.net/downloads/CHANGELOG](https://bftpd.sourceforge.net/downloads/CHANGELOG)
  - Repository: [https://sourceforge.net/projects/bftpd/](https://sourceforge.net/projects/bftpd/)
  - Package: [master/make/pkgs/bftpd/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/bftpd/)
  - Maintainer: [@fda77](https://github.com/fda77)

> "The bftpd program is a small, easy-to-configure FTP server. It
> strives to be fast, secure and quick to install/configure."
> [http://bftpd.sourceforge.net/](http://bftpd.sourceforge.net/)

Bftpd ist ein kleiner FTP Server. Um den Zugriff auf den FTP-Server mit
einem Passwort zu schützen, kann man wie folgt vorgehen:

-   Anonymer Zugriff auf der Freetz Konfigurations-Seite deaktivieren
-   In einer Shell (serielle Konsole, telnet oder dropbear) das Passwort
    für den Benutzer ftp ändern:

    ``` 
    passwd ftp
    modsave
    ```

Nun ist der Zugriff auf den FTP Server nur noch als Benutzer ftp mit dem
vergebenen Passwort möglich.

### Zusätzliche Benutzer einrichten

 * Achtung: Der
AVM-Dämon `ctlmgr` überschreibt die `/etc/passwd` bei Änderungen im
Webinterface und löscht die angelegten User. Außerdem ist das
Usermanagement von Freetz überarbeitet worden, so dass jetzt mit
`adduser username -h /var/media/ftp/uStor01` neue Benutzer angelegt
werden können. Diese Änderung muss anschließend mit
`modusers save; modsave flash` persistent gemacht werden.

Über eine kleine Änderung in der `debug.cfg` oder mit *crond* können
zusätzliche Benutzer mit frei wählbaren Homeverzeichnissen eingerichtet
werden.

Auf dieser Seite kann man sich die für die `/var/tmp/passwd` benötigten
Zeilen mit Benutzer und Passwort erzeugen lassen:

```
http://home.flash.net/cgi-bin/pw.pl
```

Alternativ geht das auch mit dem Unix/Linux Kommando `htpasswd`.

Die Syntax sieht dann wie folgt aus:

```
echo "user1:pass1:1000:1:ftp user:/var/media/ftp:/bin/sh" >> /var/tmp/passwd
echo "user2:pass2:1000:1:ftp user:/var/media/ftp:/bin/sh" >> /var/tmp/passwd
echo "user3:pass3:1000:1:ftp user:/var/media/ftp/uStor01/share:/bin/sh" >> /var/tmp/passwd
```

Wobei user und pass durch die zuvor zuvor erzeugten User und Passwörter
zu ersetzen sind. Wie auch die Pfadangaben sind das natürlich nur
Beispiele. Man beachte die Pfadangabe auf den USB-Stick im dritten
Beispiel. Der Pfad muss natürlich zum Zeitpunkt des Logins existieren,
sonst gibt es einen Fehler.

*Anmerkung:*

-   Das Passwort sollte nicht in der `/etc/passwd`, sondern in der
    `/etc/shadow` gespeichert werden. Das funktioniert auf der FritzBox,
    wie auf jeder üblichen Linux Distribution und ist im Internet an
    vielen Stellen dokumentiert.
-   Die einzelnen Benutzer erhhalten fortlaufende Benutzer-IDs und
    nicht, wie hier, alle Benutzer die selbe ID (hier: 1000). Als
    group-ID kann/sollte man die 1 (= Gruppe "users") nehmen, anstelle
    der 0 (= Gruppe "root").

Den AVM FTP benötigt ihr jetzt nicht mehr. Das Filesystem sollte auf
Lesen und Schreiben ohne Passwörter eingestellt sein. Der bftpd sollte
mit den Optionen "Automatisch starten lassen" und "nicht anonym"
gestartet werden.

### Bestehende (persistente) Benutzer modifizieren

Ergänzung von [Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)
vom 13.10.2007:

Wie man im DS-Mod bis Version ds26-15.2 persistent Benutzer anlegt und
löscht, erkläre ich in den
[How-Tos](../help/howtos/security/user_management.html). Damit
hat man also schon einmal automatisch angelegte Benutzer und Passwörter
nach dem Hochfahren der Box. Die Passworteingabe erfolgt direkt an der
Konsole, man braucht keine externe Seite, die das berechnet.

Jetzt geht es noch darum, dass das Heimverzeichnis eines Benutzers sowie
seine UID (eindeutige numerische Benutzer-ID) automatisch jedesmal nach
dem Neustart der Box vom DS-Mod vergeben werden, da sie bislang nicht
persistent gespeichert werden (auch das wird sich zu 15.3 ändern). Wie
man nun bestehende Benutzerdaten entsprechend automatisch umbiegt,
beschreibe ich
[dort](http://www.ip-phone-forum.de/showthread.php?p=958801#post958801)
im Forum.

