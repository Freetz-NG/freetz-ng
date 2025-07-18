# owfs 2.7p32 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/owfs/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/owfs/)
  - Maintainer: -

Dieses Paket bietet ähnliche Funktionen wie das digitemp Paket, mit dem
Vorteil, dass eine größere Auswahl an Chips unterstützt wird. Eine
Integration in die Freetz Oberfläche ist jedoch noch nicht vorhanden.

Der 1-Wire-Bus sollte für längere Distanzen (x00m) mindestens mit
Shielded/TwistedPair Kabeln aufgebaut werden. Wie bei jedem Bus dürfen
die Zweige nicht zu lang werden, dh. < 1m, damit die Reflexionen das
Datensignal nicht überlagern.
Als Busmaster wurde derzeit der USB-1.1 Adapter DS9490R an einer
Fritzbox getestet.

Das Paket wird ohne Fuse-Support gebaut, die Shelltools erlauben jedoch
gleichwertige Funktionen. Grundsätzlich muss ein owserver gestartet
werden, er serialisiert/managed die Anfragen an den Bus.
Verbindungen laufen standardmäßig über Port 4304.
` owserver --usb=ALL `

owhttpd ist ein mini Webserver und erlaubt komfortables BUS-Debugging
per Webbrowser
([http://fritz.box:99](http://fritz.box:99))
` owhttpd -s 127.0.0.1:4304 -p 99 `
Dieser muss natürlich nicht zwingend auf der fritzbox laufen, denn die
option -s bestimmt die tcp/ip Verbindungsparameter zu irgendeinem
`owserver`.

owdir owread owwrite: erlaubt das einfache Auslesen und Beschreiben von
1-Wire Devices in der Shell bzw. in Shell-Skripten.

Mehr Infos gibts in den manpages unter "weiterführende Links".

### Weiterführende Links

-   [http://owfs.org/](http://owfs.org/)
-   [A Guide to the 1WRJ45
    Standard](http://1wire.org/index.html?target=p_2.html&lang=en-us)


