# nfs-utils 1.3.4 (binary only) - DEPRECATED
  - Homepage: [https://sourceforge.net/projects/nfs/](https://sourceforge.net/projects/nfs/)
  - Manpage: [https://www.linux-nfs.org/](https://www.linux-nfs.org/)
  - Changelog: [https://sourceforge.net/projects/nfs/files/nfs-utils/](https://sourceforge.net/projects/nfs/files/nfs-utils/)
  - Repository: [http://git.linux-nfs.org/?p=steved/nfs-utils.git](http://git.linux-nfs.org/?p=steved/nfs-utils.git)
  - Package: [master/make/pkgs/nfs-utils/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/nfs-utils/)
  - Maintainer: -

Die NFS-Utils erweitern Freetz um einen NFS Server inklusive
Administrationswebinterface (siehe [nfsd-cgi](nfsd.md)) für die
Konfigdateien `Exports`, `allow_hosts` und `deny_hosts`.

### Hinweise

-   Exports funktionieren nur richtig mit ext2, ext3 oder ReiserFS
    Dateisystemen.
-   Squashfs und tmpfs/ramfs (/var) können nicht über NFS exportiert
    werden
-   Wenn keine Verbindung zustande kommt kann das an einer falschen NFS
    Version des Clients liegen. Beheben kann man das mit dem
    zusätzlichen mount Parameter `-o nfsvers=3`.

### Referenzen

-   [http://www.ip-phone-forum.de/showthread.php?p=1609992](http://www.ip-phone-forum.de/showthread.php?p=1609992)
-   [http://de.wikipedia.org/wiki/Network_File_System](http://de.wikipedia.org/wiki/Network_File_System)

