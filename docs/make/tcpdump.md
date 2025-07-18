# tcpdump 4.1.1/4.99.5 (binary only)
  - Homepage: [https://www.tcpdump.org](https://www.tcpdump.org)
  - Manpage: [https://www.tcpdump.org/manpages/tcpdump.1.html](https://www.tcpdump.org/manpages/tcpdump.1.html)
  - Changelog: [https://github.com/the-tcpdump-group/tcpdump/blob/master/CHANGES](https://github.com/the-tcpdump-group/tcpdump/blob/master/CHANGES)
  - Repository: [https://github.com/the-tcpdump-group/tcpdump](https://github.com/the-tcpdump-group/tcpdump)
  - Package: [master/make/pkgs/tcpdump/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/tcpdump/)
  - Maintainer: [@fda77](https://github.com/fda77)

**[tcpdump](http://www.tcpdump.org/)** ist ein
Netzwerk-[Sniffer](http://de.wikipedia.org/wiki/Sniffer)
(zu Deutsch: Netzwerk-Schnüffler) - oder, etwas eleganter ausgedrückt:
ein Netzwerk- Diagnoseprogramm. Es ist standardmäßig bei allen
Linux-Distributionen dabei und existiert auch für andere UNIX-Derivate.
Es ist zwar relativ schwer zu bedienen, und die Ausgabe auch recht
schwer zu lesen - weswegen *tcpdump* gegenüber Sniffern wie
[Wireshark](http://de.wikipedia.org/wiki/Wireshark),
die über eine grafische Oberfläche verfügen, gewisse Nachteile hat. Der
Vorteil insbesondere für die FritzBox liegt aber genau in diesem
Nachteil, da auf der Box kein X installiert ist (oder war etwa jemand so
wahnsinnig, und hat das gemacht?).
:o

### Warning

A lot of traffic will use a lot of CPU, even if that traffic isn't
monitored. However, filtering by network adapter helps.

### Weiterführende Links

-   [Wikipedia Artikel](http://de.wikipedia.org/wiki/Tcpdump)
-   [Linux-Wiki Artikel](http://www.linuxwiki.de/TcpDump)


