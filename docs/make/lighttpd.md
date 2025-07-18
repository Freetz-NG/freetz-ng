# Lighttpd 1.4.79
  - Homepage: [https://www.lighttpd.net/](https://www.lighttpd.net/)
  - Manpage: [https://redmine.lighttpd.net/projects/lighttpd/wiki](https://redmine.lighttpd.net/projects/lighttpd/wiki)
  - Changelog: [https://www.lighttpd.net/releases/](https://www.lighttpd.net/releases/)
  - Repository: [https://git.lighttpd.net/lighttpd/lighttpd1.4.git](https://git.lighttpd.net/lighttpd/lighttpd1.4.git)
  - Package: [master/make/pkgs/lighttpd/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/lighttpd/)
  - Maintainer: [@fda77](https://github.com/fda77)

Mit diesem Paket ist es möglich, den lighttpd Webserver zu erstellen.

### Einrichtung

Um den Webserver nutzen zu können, muss ein Verzeichnis erstellt werden,
in dem der lighttpd agieren kann. Dieses muss unbedingt erstellt und mit
den nötigen Rechten versehen werden.


**Unbedingt beachten:** In dieser Anleitung wird angenommen, dass
[USB-root](usbroot.md) genutzt wird. Sollte USB-root nicht
verwendet werden, muss auf die folgenden Verzeichnisstrukturen noch
größeres Augenmerk gelegt werden. In solch einem Fall **könnte**
`/var/media/ftp/uStor01/rootfs/www` eine Analogie für `/www` sein.


Zunächst muss eine Konsolensitzung mit dem Router bestehen, es spielt
keine Rolle, ob dafür Telnet oder [SSH](dropbear.md) genutzt
wird.

```
# erstelle Webserver-Verzeichnis und setze 'rwxr-xr-x'-Rechte
mkdir /www
chmod -R 755 /www
```

Nun kann man im Freetz-Konfigurationsfrontend die Einstellungen für den
lighttpd anpassen und übernehmen. Daraufhin wird die benötigte
Verzeichnisstruktur innerhalb des Webserver-Verzeichnisses angelegt. Die
Dokumente müssen im Verzeichnis `/www/websites` liegen. Je nach
Einstellung ist der Server nun bspw. über `http://fritz.box:8008`
verfügbar.

### Perl

Will man Perl-Skripte mit dem Webserver benutzen und den `chroot`-Modus
benutzen, muss man sich darum kümmern, dass das Paket
[microperl](microperl.md) sowie dessen Bibliotheken in die
Verzeichnisstruktur des lighttpd kopiert wird.

```
# kopiere 'microperl' als 'perl' in das '/usr/bin'-Verzeichnis des Webservers
cp -p /usr/bin/microperl /www/usr/bin/perl

# erstelle ein Verzeichnis '/lib' für die Bibliotheken
mkdir /www/lib

# kopiere die von 'microperl' benötigten Bibliotheken in das '/lib'-Verzeichnis des Webservers
# Abhängigkeiten können mit 'ldd /usr/bin/microperl' ausgegeben werden
cp -p /lib/ld-uClibc.so.0 /www/lib
cp -p /lib/libc.so.0 /www/lib
cp -p /lib/libgcc_s.so.1 /www/lib
cp -p /lib/libm.so.0 /www/lib
```

Wenn neben `*.cgi`-Dateien auch `*.pl`-Dateien ausgeführt werden sollen,
muss außerdem noch eine Zeile in die 'Additional'-Konfiguration von
lighttpd (zu finden im Freetz-Konfigurationsmenü unter `Settings` →
`'lighttpd: Additional`):

```
# aktiviere CGI Unterstützung für *.pl-Dateien
cgi.assign += ( ".pl" => "/usr/bin/perl" )
```

Außerdem muss darauf geachtet werden, dass jegliche Perl-Skripte
Ausführrechte haben, dies ist mit einem einfachen `chmod 755 DATEI.pl`
zu erledigen.

### Lua

make menuconfig:

-   *lighttpd > build with LUA support*
-   *lighttpd > lighttpd Modules > include mod_magnet*

Example:

-   put this in *lighttpd > Additional*:

```
server.modules += ( "mod_magnet" )
magnet.attract-physical-path-to = ( server.document-root + "/ip.lua" )
```

-   put this in *ip.lua* in your document root:

```
lighty.header["Content-Type"] = "text/html"
lighty.content = { "Your IP-address is: ", lighty.env["request.remote-ip"] }
return 200
```

-   browse to *http://fritz.box:<configured port>/ip.lua*

### Geoblocking
Um die Zugriffe aus bestimmten Ländern zu sperren werden die Lighttpd-Module `mod_magnet` und `mod_maxminddb` genutzt.
Dadurch wird die Library `libmaxminddb` ausgewählt welche eine `GeoLite2-City.mmdb`-Datenbank (~70MB) benötigt die von
[https://github.com/P3TERX/GeoLite.mmdb/](https://github.com/P3TERX/GeoLite.mmdb/) heruntergelden werden kann.

Ausserdem ein LUA-Script `geoblock.lua`, `XX` entsprechend anpassen:
```
if (lighty.r.req_env["GEOIP_COUNTRY_CODE"] == "XX") then return 403 end
return 0
```

Erweiterung der Lighttpd-Konfiguration, die Pfade der `.lua` und `.mmdb` sind anzupassen:
```
server.modules += ( "mod_maxminddb" )
maxminddb.activate = "enable"
maxminddb.db = "/var/media/ftp/GeoLite2-City.mmdb"
maxminddb.env = (
 "GEOIP_COUNTRY_CODE"   => "country/iso_code",
 "GEOIP_COUNTRY_NAME"   => "country/names/en",
 "GEOIP_CITY_NAME"      => "city/names/en",
 "GEOIP_CITY_LATITUDE"  => "location/latitude",
 "GEOIP_CITY_LONGITUDE" => "location/longitude",
)

server.modules += ( "mod_magnet" )
magnet.attract-raw-url-to = ( "/var/media/ftp/geoblock.lua" )
```

### Links

-   [The Programming Language
    LUA](http://www.lua.org/)
-   [Lighttpd - Docs:ModMagnet - lighty
    labs](http://redmine.lighttpd.net/wiki/lighttpd/Docs:ModMagnet)
-   [AbsoLUAtion - The powerful combo of Lighttpd +
    Lua](http://redmine.lighttpd.net/wiki/1/AbsoLUAtion)

Advantage over PHP: small, fast, low memory usage, feature rich
programming language.

### Weiterführende Links

-   [Wikipedia
    Artikel](http://de.wikipedia.org/wiki/Lighttpd) zu
    Lighttpd
-   [Lighttpd Homepage](http://www.lighttpd.net)
-   [Forumsdiskussion](http://www.ip-phone-forum.de/showthread.php?t=185448)
    im IPPF zu diesem Paket
-   [HowTo](http://www.howtoforge.com/setting-up-webdav-with-lighttpd-debian-etch)
    setting up webdav with lighttpd in Debian Etch
-   [HowTo](http://www.howtoforge.de/howto/wie-man-webdav-mit-lighttpd-auf-debian-etch-konfiguriert)
    (s.o., auf Deutsch)

