# mediatomb 0.12.1 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/mediatomb/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/mediatomb/)
  - Maintainer: -

**MediaTomb** ist ein OpenSource (GPL) UPnP MediaServer mit einer
schönen Web-Oberfläche, der das Streamen digitaler Medien im Heimnetz
und das Ansehen/Anhören auf einer ganzen Reihe von UPnP kompatiblen
Geräten (oftmals auch mit "DLNA" gekennzeichnet) ermöglicht.

Eine vollständige Installation dürfte in den wenigsten Fällen in das
Dateisystem der Fritzbox passen (sofern man nicht etliche andere Dinge
weglässt): Allein das Binary bringt ca. 1.2 Megabyte auf die Waage, und
hinzu kommen noch weitere etwa 2.5 Megabyte Abhängigkeiten (`libavcodec`
mit gut 1.2 MB, `libsqlite3` mit knapp 700 kB, `libtag` mit knapp 500
kB, `ffmpeg` ...).

Die Konfiguration von *MediaTomb* erfolgt dateibasiert (im
[UbuntuWiki MediaTomb
Artikel](http://wiki.ubuntuusers.de/Mediatomb) ist dies recht
gut beschrieben). Informationen zu einem dafür in Freetz integrierten
Web-Interface finden sich u. a. in
Ticket #1993

^(vielleicht mag noch jemand, der *MediaTomb* erfolgreich auf seine Box bekommen hat, Hinweise zum "wie" ergänzen -- insbesondere hinsichtlich des Platzbedarfs?)^

### Weiterführende Links

-   [MediaTomb Homepage](http://mediatomb.cc/)
-   [UbuntuWiki MediaTomb
    Artikel](http://wiki.ubuntuusers.de/Mediatomb)
