# dnsd-cgi
  - Package: [master/make/pkgs/dnsd-cgi/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/dnsd-cgi/)
  - Maintainer: -

Schlanker DNS-Server für statische Namensauflösung (BusyBox Applet)

### Weiterführende Links

-   [Man
    page](http://www.busybox.net/downloads/BusyBox.html#dnsd)

### Beispielkonfiguration

Port 53 mit [AVM firewall CGI](avm-firewall.md) nach 10053
mappen wo [iodine](iodine.md) läuft. Dieses leitet Anfragen
unbekannter Domains auf Port 5353 weiter wo *dnsd* läuft. *dnsd*
beantwortet für ein paar Subdomains diese Anfragen.

