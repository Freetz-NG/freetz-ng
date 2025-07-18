# FUSE 2.9.9 (binary only) - DEPRECATED
  - Homepage: [https://github.com/libfuse/libfuse](https://github.com/libfuse/libfuse)
  - Manpage: [https://github.com/libfuse/libfuse/wiki](https://github.com/libfuse/libfuse/wiki)
  - Changelog: [https://github.com/libfuse/libfuse/releases](https://github.com/libfuse/libfuse/releases)
  - Repository: [https://github.com/libfuse/libfuse/commits/master](https://github.com/libfuse/libfuse/commits/master)
  - Package: [master/make/pkgs/fuse/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/fuse/)
  - Maintainer: -

**[FUSE](http://de.wikipedia.org/wiki/Filesystem_in_Userspace)**
([Filesystem](http://de.wikipedia.org/wiki/Dateisystem)
in
[Userspace](http://de.wikipedia.org/wiki/Userspace))
ist ein
[Kernel-Modul](http://de.wikipedia.org/wiki/Kernel-Modul),
das es ermöglicht, Dateisystem-Treiber aus dem
[Kernel-Mode](http://de.wikipedia.org/wiki/Betriebssystemkern)
in den
[User-Mode](http://de.wikipedia.org/wiki/Ring_(CPU))
zu verlagern. Auf diese Weise können auch nicht-priviligierte Benutzer
(also jene, die nicht *root* heißen) Dateisysteme einbinden bzw.
erstellen. Die *FUSE* Module agieren quasi als "Bridge" zu den
Kernel-Schnittstellen.

*FUSE* lässt sich besonders gut einsetzen, um virtuelle Dateisysteme zu
verwirklichen. Anders als bei traditionellen Dateisystemen, die sich um
das Speichern und Laden von Daten auf der Disk zu kümmern haben,
speichern virtuelle Dateisysteme selbst keine Daten. Sie sind vielmehr
eine "View" oder "Übersetzung" eines bereits existierenden Datei-
oder Speichersystems. Im Prinzip kann jede für *FUSE* verfügbare
Resource als Dateisystem exportiert werden.

In Freetz basiert z.B. das [NTFS](ntfs-3g.html) Paket auf *FUSE*.

### Weiterführende Links

 - [Wikipedia: FUSE](http://de.wikipedia.org/wiki/Filesystem_in_Userspace)
 - s3fslite für Freetz: Ticket #796

