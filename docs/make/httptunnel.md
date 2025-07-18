# httptunnel 3.3 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/httptunnel/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/httptunnel/)
  - Maintainer: -

**[httptunnel](http://www.nocrew.org/software/httptunnel.html)**
erstellt eine virtuell, bi-direktionale Datenverbindung, welche über das
HTTP Protokoll getunnelt wird. Die erforderlichen HTTP-Requests können
bei Bedarf auch über Proxies geleitet werden.

Dieser Ansatz ist hilfreich für all jene, die hinter einer restriktiven
Firewall sitzen. Sofern WWW Zugriff erlaubt ist - und sei es auch nur
über einen Proxy -, kann *httptunnel* verwendet werden, um z.B. per
Telnet auf einen Rechner außerhalb der Firewall zuzugreifen.

Ein etwas anschaulicheres Beispiel anbei von
[sweetie-pie](http://www.ip-phone-forum.de/member.php?u=62645)
aus [diesem
Thread](http://www.ip-phone-forum.de/showthread.php?p=536622#post536622):

```
PC in der Firma          Proxy in der Firma         Fritzbox

   +-------+    Verbunden auf                       +-------+    Heimnetz
   |Putty  |--+ 127.0.0.1:22                        |sshd   |--> via ssh-Tunnel
   |-------|  |                +-----+              |       |<-+ (Port 22)
   |htc    |<-+ Port 22        |HTTP |              |-------|  |
   |       |------------------>|Proxy|------------->|hts    |--+
   +-------+                   +-----+    Port 9999 +-------+
```

Derzeit ist httptunnel nur als Binary (3.3) für Freetz verfügbar, d.h.
es gibt noch kein WebGUI für grafische Einstellungen.

### Weiterführende Links

-   [httptunnel
    Homepage](http://www.nocrew.org/software/httptunnel.html)
-   [Mini-HowTo bei
    LinuxWiki.org](http://linuxwiki.org/HttpTunnel)
-   [Wikipedia Artikel zum HTTP
    Tunneling](http://en.wikipedia.org/wiki/HTTP_tunnel)
    (Englisch)
-   [Thread im
    IP-Phone-Forum](http://www.ip-phone-forum.de/showthread.php?t=167980)

