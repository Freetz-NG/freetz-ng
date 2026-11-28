# Stunnel 5.82
  - Homepage: [https://www.stunnel.org/](https://www.stunnel.org/)
  - Manpage: [https://www.stunnel.org/static/stunnel.html](https://www.stunnel.org/static/stunnel.html)
  - Changelog: [https://www.stunnel.org/NEWS.html](https://www.stunnel.org/NEWS.html)
  - Repository: [https://github.com/mtrojnar/stunnel](https://github.com/mtrojnar/stunnel)
  - Package: [master/make/pkgs/stunnel/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/stunnel/)
  - Steward: [@fda77](https://github.com/fda77)

[![Stunnel Webinterface](../screenshots/202_md.png)](../screenshots/202.png)

*"Stunnel is a program that allows you to encrypt arbitrary TCP
connections inside SSL (Secure Sockets Layer) available on both Unix and
Windows. Stunnel can allow you to secure non-SSL aware daemons and
protocols (like POP, IMAP, LDAP, etc) by having Stunnel provide the
encryption, requiring no changes to the daemon's code. "*
[http://www.stunnel.org/](http://www.stunnel.org/)

**Stunnel** könnte man auf Deutsch mit "Sicherer Tunnel" wiedergeben.
Hinter dem Begriff verbirgt sich die Möglichkeit, beliebige TCP
Verbindungen per SSL zu verschlüsseln - auch bzw. gerade wenn die
Anwendung selbst dies nicht unterstützt, und somit dem
"Man-in-the-Middle" das Schnüffeln zu verderben. Zahlreiche gute
Anwendungsbeispiele finden sich auf der [Stunnel
Homepage](http://www.stunnel.org/examples/).

### HTTPS Zertifkat
Es kann ein eigenes Zertifkat genutzt werden
oder das im FritzOS hinterlegte Zertifkat.

##### FritzOS Zertifikat
Dieses Zertifkat wurde entweder von FritzOS generiert
oder vom Benutzer im AVM-Webinterface hochgeladen.

##### Eigenes Zertifikat
Dieses Zertifikat ist unabhängig von FritzOS

1. Erzeugen der Keys:
   <pre><code>
   openssl genrsa 1024 > key.pem
   openssl req -new -x509 -nodes -sha1 -days 365 -key key.pem > certs.pem
   </code></pre>

2. Das Zertifikat und den Schlüssel im Webinterface unter Einstellungen → Stunnel einfügen:
    - "Certificate Chain" (certs.pem)
    - "Private Key" (host.key)

### Services
   Die Angabe des Pfads zum Zertifikat und zum Schlüssel sind optional.
   Ohne ausdrückliche Angabe und bei "Eigenes Zertifikat"
   wird das Zertifikat `/tmp/flash/stunnel/certs.pem`
   und der Schlüssel `/tmp/flash/stunnel/key.pem`
   verwendet, welche vom Webinterface verwaltet werden.

##### Beispiel Freetz-Webif (default)
   <pre><code>
   [freetz-ng]
   client = no
   accept = 4433
   connect = 127.0.0.1:81
   sslVersionMin = TLSv1.2
   </code></pre>
   Zugriff (intern) über [https://fritz.box:4433](https://fritz.box:4433).

##### Beispiel Rudi-Shell
   <pre><code>
   [rudi]
   client = no
   accept = 44391
   connect = 127.0.0.1:91
   </code></pre>
   Zugriff (intern) über [https://fritz.box:44391](https://fritz.box:44391).

##### Beispiel vnStat
   <pre><code>
   [vnstat]
   accept = 44387
   connect = 87
   </code></pre>
   Zugriff (intern) über [https://fritz.box:44387](https://fritz.box:44387).

### Hinweis
Für den externen Zugriff muss noch eine Port-Freigabe angelegt werden.

### Erweitert

Die Standardeinstellungen von Freetz können mit der Zeile `#EXCLUSIVE#` deaktiviert werden.
Dies ermöglicht, globale Einstellungen außerhalb der `[<section>]` vorzunehmen.
Zum Beispiel:
<pre><code>
   #EXCLUSIVE#

   TIMEOUTclose = 0
   verifyChain = yes
   CAfile = /tmp/flash/stunnel/certs.pem
   cert = /tmp/flash/stunnel/key.pem
   options = SINGLE_ECDH_USE
   options = SINGLE_DH_USE

   [freetz https Web-Interface]
   accept = 4433
   connect = 81

   [avm https Web-Interface]
   accept = 4434
   connect = 80
</code></pre>

### Weiterführende Links

-   [Wikipedia (EN)](http://en.wikipedia.org/wiki/Stunnel)
-   [xrelayd](xrelayd.md)
-   [Artikel im IPPF](http://www.ip-phone-forum.de/showthread.php?t=123174)

