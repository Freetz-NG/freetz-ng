# Cifsmount 7.0 - DEPRECATED
  - Homepage: [https://wiki.samba.org/index.php/LinuxCIFS_utils](https://wiki.samba.org/index.php/LinuxCIFS_utils)
  - Changelog: [https://wiki.samba.org/index.php/LinuxCIFS_utils#News](https://wiki.samba.org/index.php/LinuxCIFS_utils#News)
  - Repository: [https://git.samba.org/?p=cifs-utils.git;a=summary](https://git.samba.org/?p=cifs-utils.git;a=summary)
  - Package: [master/make/pkgs/cifsmount/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/cifsmount/)
  - Maintainer: -

[![](../screenshots/146_md.jpg)](../screenshots/146.jpg)

In diesem Paket kommen die Helferlein für das Einbinden von CIFS
Netzwerkfreigaben - inklusive eines Web-Interfaces für die einfache
Konfiguration von bis zu drei "Mounts", optional mit automatischen
start/stop Events.

CIFS (**C**ommon **I**nternet **F**ile **S**ystem) ist eine erweiterte
Version von
[SMB](http://de.wikipedia.org/wiki/Server_Message_Block)
- dem Protokoll, welches bei MS Windows und auch
[Samba](samba.md) zum Einsatz kommt, um sowohl Ordner und
Dateien als auch Drucker im Netz bereitzustellen. Somit kann cifsmount
einen Samba-Client ersetzen - mit einem weiteren großen Vorteil, wenn
wir an unsere FritzBox denken: cifsmount benötigt wesentlich weniger
Speicherplatz - und ist damit die "Erste Wahl" für diejenigen, die
Windows- oder Samba-Shares auf der FritzBox mounten möchten.

### Konfiguration cifsmount

**Starttyp:** Automatisch (mit dem Starten der Box), oder Manuell
(starten des Dienstes von Hand).
**Shares:** Bis zu fünf Shares können über das Webinterface angelegt
werden.
**Share:** Hier wird die Freigabe, welche gemountet werde soll
eingetragen.
**User:** Benutzername der Freigabe.
**Pass:** Passwort der Freigabe.
**Mountpoint:** Der Ort, wohin die Freigabe auf der Box gemountet werden
soll.
**Mountoptions:** Zusätzliche Option die dem Mountbefehl angehängt wird,
zB `noserverino` bei sehr großen Festplatten.

### Fehlersuche

Mit `echo 1 > /proc/fs/cifs/cifsFYI` kann man cifs etwas gesprächiger
machen. Anschauen kann man sich die Meldungen mit `dmesg | tail`. Bei
fehlendem Benutzername oder falschem Passwort sieht das Beispielsweise
so aus:

```
root@fritz:/var/mod/root# mount -t cifs //192.168.1.1/Freetz /var/media/ftp
 CIFS VFS: Send error in SessSetup = -13
 CIFS VFS: Send error in SessSetup = -13
mount: mounting //192.168.1.172/Freetz on /var/media/ftp failed: Permission denied
root@fritz:/var/mod/root# dmesg | tail
 CIFS VFS: No username specified
Status code returned 0xc000006d NT_STATUS_LOGON_FAILURE
 CIFS VFS: Send error in SessSetup = -13
```


### Weiterführende Links

-   [Wikipedia
    Artikel](http://de.wikipedia.org/wiki/Server_Message_Block)
    zum SMB Protokoll und CIFS
-   [cifsmount Man
    page](http://www.obdev.at/resources/sharity/manual/manCifsmount.html)

