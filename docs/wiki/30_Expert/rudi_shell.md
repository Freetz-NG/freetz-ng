# Rudi-Shell

"Rudi" steht für rudimentär, denn wir haben es mit einem rudimentären
Shell-Ersatz via CGI-Interface zu tun. Ich hatte angefangen, ihn recht
komplex zu gestalten und mich dann eines Besseren besonnen: Small is
beautiful. Rudi kann inzwischen nicht weniger als ursprünglich geplant,
aber die Oberfläche ist puristischer als noch während der ersten
Entwicklungsphase. Nicht zuletzt sind auch die CGI-Quelldateien
inzwischen viel kleiner und einfacher geworden. Puristischere
Oberflächen erfordern andererseits etwas mehr Dokumentation, also
beschreibe ich im Folgenden, teils bebildert, was man mit Rudi so
anstellen kann - kurz: **alles!**

### Feature-Übersicht

Mit Rudi kann man direkt über eine Weboberfläche Folgendes tun:

-   Beliebige (eingetippte oder per Copy & Paste ins Befehlsfenster
    eingefügte) **Shell-Skripte** auf der FritzBox ausführen.
    Root-Rechte sind selbstverständlich.
-   In einer beliebig langen **Historie** der zuletzt eingegebenen
    Befehle und Ausgaben(!) blättern, alte Befehle (bzw. Skripten)
    editieren und/oder erneut ausführen
-   Wählen, ob die **Befehls-Ausgabe in Textform** inline im Browser
    angezeigt **oder als Datei-Download** gespeichert werden soll.
    Dieses Konzept ist sehr mächtig, denn man kann z.B. die Ausgabe
    eines *Tar*-Befehls so umleiten, daß man auf einfache Weise Backups
    beliebiger Dateien oder Verzeichnisse anfertigen kann.
-   Lokale **Dateien** (auch Archive) **hochladen** an einen beliebigen
    Zielort auf der Box, um sie dort anschließend ggf. mit weiteren
    Befehlen zu bearbeiten: Archiv auspacken, Patch für `debug.cfg`
    einspielen, mittels mini\_fo (falls
    installiert) nur lesbare Dateien zum Test mit einer Schattenkopie
    überschreiben usw.

### Systemvoraussetzungen

Ich habe die Rudi-Shell entwickelt für den Danisahne-Mod, genauer gesagt
für Olivers (olistudent) Version mit Kernel 2.6. Getestet habe ich
konkret auf meiner FritzBox Fon WLAN 7170 mit Firmware 29.04.29,
ds-0.2.9\_26-13, Kernel 2.6.13.1, Busybox 1.4.1, Haserl 0.9.16
CGI-Handler. Grundsätzlich sollte meiner Meinung nach aber Folgendes
ausreichen (*ohne* DS-Mod/Freetz):

### Server

-   beliebige Box (genug Platz zum Speichern und Ausführen von Rudi
    vorausgesetzt)
-   beliebiger Kernel (2.4.x oder 2.6.x)
-   beliebige
    [Busybox](http://www.busybox.net/)-Version mit
    *httpd* und *sed*
-   beliebige
    [Haserl](http://haserl.sourceforge.net/)-Version
    (z.B. die aktuelle *stable* 0.8.0)

### Client

-   Web-Browser mit eingeschaltetem
    [JavaScript](http://de.wikipedia.org/wiki/JavaScript);
    getestetet mit IE7, Opera 9.10, Firefox 2.0.0.2. Es wird ein wenig
    JavaScript benutzt, um im
    [DOM](http://de.wikipedia.org/wiki/Document_Object_Model)
    zu navigieren, die Historie zu steuern und
    [CGI](http://de.wikipedia.org/wiki/Common_Gateway_Interface)-Unterprozesse
    in einem unsichtbaren
    [IFrame](http://de.wikipedia.org/wiki/Iframe)
    auszuführen und mit deren Ergebnisse die Hauptseite zu aktualisieren
    (Konsolenausgabe).

### Was NICHT gebraucht wird

-   Auf dem Server sind grundsätzlich weder Telnet noch
    [SSH](../../make/dropbear.md) noch [OpenVPN](../../make/openvpn.md)
    notwendig, d.h. Rudi sollte auch (und gerade) für
    "schwachbrüstige" Boxen mit wenig Speicher interessant sein.
-   Eine Dateisystem-Verbindung, gleich in welche Richtung, ist auch
    nicht notwendig. D.h., wir brauchen weder [Samba](../../make/samba.md)
    noch smbmount noch [NFS](../../make/nfs.md).
-   Es ist keine Filetransfer-Verbindung via FTP notwendig, alles läuft
    mittels HTTP, auch Up- und Downloads.
-   Zum Datenaustausch wird auch kein externes Speichermedium
    (USB-Stick, Festplatte) und somit kein USB-Anschluß an der Box
    benötigt.

### Platzbedarf der Rudi-Shell

-   Der Patch besteht aus drei CGI-Skripten im horrenden ;-)
    Gesamtumfang von 3,5 KB sowie ggf. einer Textzeile für das Menü von
    Freetz.
-   Hinzu kommt Haserl. Das Binary meiner Version 0.9.16 für Kernel 2.6
    ist knapp 24 KB groß. Im Vergleich dazu ist bereits
    [bftpd](../../make/bftpd.md) 67 KB groß (und man kann weniger damit
    tun!) und [Dropbear](../../make/dropbear.md) mit 179 KB riesig. Ein
    [Samba-Server](../../make/samba.md) schlägt gar mit knapp 900 KB zu
    Buche.
-   Rudi verwendet von sich aus keine temporären Dateien für die
    auszuführenden Skripten oder die Befehlsausgaben. Alles läuft direkt
    durch anonyme
    [UNIX-Pipes](http://de.wikipedia.org/wiki/Pipe_%28Informatik%29#Unix),
    von der Eingabe über die Verarbeitung bis zur Ausgabe. Lediglich,
    wenn der Benutzer selbst Dateien durch Ausgabeumleitung oder
    Datei-Uploads erstellt, wird Platz im Dateisystem benötigt.

## Funktionsweise

[![Freetz Menü](../../screenshots/39.gif)](../../screenshots/39.gif)

Der Einstieg in die Rudi-Shell erfolgt in Freetz übers Hauptmenü (siehe
Bild). Direkt kann sie ebenfalls erreicht werden, und zwar über
[http://fritz.box:81/cgi-bin/rudi\_shell.cgi](http://fritz.box:81/cgi-bin/rudi_shell.cgi).

Die Oberfläche präsentiert sich spartanisch, aber funktionell und
besteht aus folgenden Elementen:

-   Mehrzeiliges **Eingabefenster** für
    [UNIX-Shell](http://de.wikipedia.org/wiki/Unix-Shell)-Skripte.
    Verwendet wird die auch von der Original-Firmware bekannte
    Standard-Shell `/bin/sh` der Busybox, die
    [ash](http://en.wikipedia.org/wiki/Almquist_shell)
    (eine
    [Bourne-Shell](http://de.wikipedia.org/wiki/Bourne_Shell#Die_Bourne-Shell)-Variante).
-   **Ausführen-Knopf**, um die Skripten zur FritzBox zu schicken und
    dort auszuführen.
-   **Ergebnis-Ausgabe** (scrollbar) im unteren Fensterbereich. Dorthin
    werden Standard- und Fehlerausgabe der Shell umgelenkt, sofern
    nichts anderes angegeben ist.
-   **Befehls-Historie**, bestehend aus einer numerierten Auswahlliste.
    #0 ist immer die zuletzt eigegebene
    Befehlsfolge, die höheren Nummern sind entsprechend ältere Skripten.
    Die Anzahl der Einträge ist grundsätzlich unbegrenzt. Sollte der
    Browser irgendwann langsamer werden, weil er zu viele Informationen
    puffert, einfach auf den **Löschen-Knopf** drücken.
-   **Download-Schalter**, um die
    Befehls-Ausgabe anstatt auf der Konsole als Datei zu empfangen.
    Normalerweise hat der Download den (im
    Speichern-Dialog des Browsers änderbaren) Namen *rudi\_download*.
-   Kreuzt man zusätzlich einen der **Dateiendung-Schalter (.tar, .gz)**
    an, wird die entsprechende Endung (oder beide zusammen, also
    .tar.gz) an den Namensvorschlag angehängt. Das dient nur zur
    Bequemlichkeit, man kann es auch selbst beim Speichern machen. Für
    Benutzer mit Download-Manager und
    ausgeschaltetem Speichern-Dialog ist es so ein bißchen einfacher.
    **Achtung**: Die Schalter ändern *nicht* das Dateiformat, nur die
       Dateiendung.
-   **Datei-Uploads** werden über die beiden Textfelder "Quelldatei"
    und "Zieldatei" abgewickelt. Die Quelldatei kann mit
    "Durchsuchen" direkt über einen Datei-Browser ausgewählt werden,
    die Zieldatei hat den änderbaren Vorschlagsnamen
    `/var/tmp/rudi_upload`. Es sollte natürlich ein existierendes,
    beschreibbares Verzeichnis gewählt werden. Ein nicht existierendes
    kann ja vorher über die Befehlseingabe erzeugt werden.
    **Achtung:** Bitte nicht versuchen, Dateien nach `/var/flash`
       hochzuladen. Immer erst temporär woanders speichern und mittels
      `cat` ins *tffs* schreiben!

**Achtung, besonders wichtig**:
Die Rudi-Shell, insbesondere die Historie, funktioniert ohne
Navigation auf der Hauptseite. D.h., Sie brauchen weder
die Schaltflächen "Vor/Zurück" noch "Neu laden" des Browsers.
Im Gegenteil, wenn Sie sie benutzen, werden erstens die Historie
gelöscht und zweitens alle Schalter und Textfelder auf ihre
Standardwerte zurückgesetzt.**
*Für die Techniker unter uns: Alles, was an Rudi-Shell
dynamisch ist, passiert in einem unsichtbaren IFrame
bzw. auf der Hauptseite durch javascript-basierte
Änderungen am DOM der Seite.*

## Illustrierte Anwendungsfälle

### Shell-Skript ausführen

Befehl eingeben, ausführen, Ergebnis anschauen - fertig.

[![Rudi-Shell: Shell-Skript ausführen](../../screenshots/40.gif)](../../screenshots/40.gif)

### Historie verwenden

Historien-Liste öffnen, per Maus oder Tastatur durchblättern. Beim
Blättern aktualisieren sich schon Befehlsfenster und Ergebniskonsole.
Durch Drücken des Knopfes "Hist. löschen" wird die Historie bereinigt
und ist wieder jungfräulich.

[![Rudi-Shell: History](../../screenshots/41.gif)](../../screenshots/41.gif)

### Download Tar-Archiv

Man kann mittels eines Befehls wie `tar c *` ein Archiv erzeugen, im
Beispiel von allen Dateien und Unterverzeichnissen im aktuellen
Verzeichnis - übrigens bei Shellskript-Start immer `/usr/mww/cgi-bin`,
weil von dort aus die CGI-Skripten ausgeführt werden. Wenn man
zusätzlich den Download-Schalter vor dem Ausführen aktiviert und evtl.
zur Bequemlichkeit noch den Dateiendung-Schalter *.tar*, erhält man das
Archiv direkt als Download, den man speichern kann, wohin man will. Was
hier technisch passiert, ist, daß die Standardausgabe der Shell - wir
haben ja keine Zieldatei für *Tar* angegeben, also gilt die
Standardausgabe - umgeleitet wird, und zwar in den Rückgabekanal des
CGI-Skripts hin zum Browser des Benutzers.

**Trouble-Shooting:** Manchmal kommt es vor, daß *Tar* (oder auch andere
Shell-Befehle) zusätzlich zur eigentlichen Ausgabe noch Meldungen
(Fehler, Informationen, Warnungen) in einen anderen Ausgabekanal, die
sog. Fehlerausgabe, schreiben. Da ohne weitere Vorkehrungen bei der
Rudi-Shell - wie bei anderen interaktiven Shells auch - Standard- und
Fehlerausgabe gebündelt werden, landen evtl. Informationen im Download,
die wir dort gar nicht haben wollen. Im Falle unseres *Tar*-Archivs wird
dadurch die Datei "verunreinigt" und ist nicht mehr entpackbar. Um das
zu diagnostizieren, lassen wir uns das Tar-Archiv einfach kurzerhand auf
die Konsole ausgeben (Download-Schalter deaktivieren). Das sieht dann so
aus:

[![Rudi-Shell: Tar Diagnose](../../screenshots/42.gif)](../../screenshots/42.gif)

Es gibt im Prinzip zwei Möglichkeiten, solche Verunreinigungen zu
umgehen: Erstens kann man die Shell explizit anweisen, die Fehlerausgabe
umzuleiten in eine Datei, auf eine andere Konsole oder ins Nirgendwo
(`/dev/null`, das beliebte Faß ohne Boden), wie im folgenden Beispiel:

[![Rudi-Shell: Fehlerausgabe ins Nirvana umleiten](../../screenshots/43.gif)](../../screenshots/43.gif)

Die zweite (etwas unsicherere, da nicht immer vorhersehbare) Möglichkeit
besteht schlicht in der Vermeidung von Fehlerausgaben, indem man vorher
die Syntax von Befehlen, notwendige Berechtigungen etc. prüft. In
unserem Fall kann man die Meldung vermeiden, indem man vorher in das
passende Basisverzeichnis wechselt, aus dem heraus *Tar* operieren soll:

[![Rudi-Shell: Fehlerausgabe durch vorbereitende Schritte vermeiden](../../screenshots/44.gif)](../../screenshots/44.gif)

### Download langer Konsolenausgabe

Lange Konsolenausgaben eines Skripts werden von Rudi auf knapp 64 KB
gekürzt, weil je nach Browser das Umkopieren mehrerer hundert KB langer
Ausgaben aus dem unsichtbaren IFrame, worin die Original-Ausgabe
zunächst landet, den Browser extrem ausbremst. Außerdem ist solch ein
langer Text im Browser nur schlecht zu analysieren, das sollte man
lieber offline in einem leistungsfähigen Editor mit guten Suchfunktionen
machen. Ein Beispiel für eine lange Ausgabe ist z.B. `ls -leAR /`, also
die detaillierte Anzeige sämtlicher Dateien mit vollem Datum usw,
rekursiv beginnend im Wurzelverzeichnis.

Es gibt browserbedingte Unterschiede, die beeinflussen, wieviel von
diesen 64 KB tatsächlich beim Umkopieren im Hauptfenster ankommen. Der
*Internet Explorer* schneidet gar nichts ab (er würde auch 1 MB
umkopieren und daraufhin, warum auch immer, für eine Weile blockieren).
Opera kappt den Text bei 32 KB, Firefox bereits bei 8 KB. Nun sind 8 KB
nicht sehr viel, aber in den meisten Fällen ausreichend für normale
Befehle. Im Hinblick auf die Historie, welche ja u.U. sehr viele Befehle
mit zugehörigen Ausgaben speichern muß, ist die Begrenzung auch gesund.

Wer nun also eine lange Konsolenausgabe in voller Länge genießen will,
aktiviert einfach den Download-Schalter und lädt sich das Ganze als
Textdatei herunter:

[![Rudi-Shell: Lange Konsolenausgabe als Datei-Download](../../screenshots/45.gif)](../../screenshots/45.gif)

### Datei-Upload

Das Ausführen von Befehlen und das Herunterladen von Dateien und
Konsolen-Ausgaben sind bereits mächtige Werkzeuge, aber richtig Spaß
macht die Arbeit mit der Rudi-Shell erst durch die Möglichkeit,
beliebige Dateien hochzuladen. Das geht ganz einfach:

[![Rudi-Shell: Erfolgreicher Datei-Upload](../../screenshots/46.gif)](../../screenshots/46.gif)

*Für die Techniker: Es handelt sich um einen normalen Form-based Upload
gemäß [RFC
1867](http://www.ietf.org/rfc/rfc1867.txt).*

Nun kann beim Upload auch mal etwas schief gehen. Dann benötigt man eine
entsprechende, einigermaßen informative Rückmeldung des Systems. Auch
hierfür ist gesorgt - das sieht dann so aus:

[![Rudi-Shell: Fehler beim Datei-Upload](../../screenshots/47.gif)](../../screenshots/47.gif)

## Grenzen & Einschränkungen

Wie erwähnt, gibt es kaum Grenzen bei dem, was man mit der Rudi-Shell
auf und mit der Box anstellen kann. Was man noch verbessern könnte,
wäre, dem Benutzer eine **interaktive Shell-Session** zu geben, welche
den Aufruf eines Skripts überdauert. Das würde z.B. bedeuten, daß ein
Verzeichniswechsel in Skript A noch Wirkung hätte für das anschließend
ausgeführte Skript B und nicht nur innerhalb von A. auch würden in A
geänderte oder gesetzte Umgebungsvariablen noch in B gelten etc. Das zu
erreichen, wäre nicht besonders schwierig. Alles, was man dazu bräuchte,
wäre ein virtuelles Terminal. Ich habe beispielsweise
[Screen](../../make/screen.md) installiert. Das Schöne an diesem
Werkzeug ist, daß man es nicht nur interaktiv an der Konsole benutzen
kann, sondern auch einer *Detached Session*, also einer vom Terminal
abgetrennten Benutzersitzung, per Fernsteuerung Befehle schicken kann,
die innerhalb der Sitzung ausgeführt werden. In Verbindung mit einer
Log-Datei oder einer [Named
Pipe](http://de.wikipedia.org/wiki/Named_Pipe) könnte man
dann von außen die Ausgaben lesen und an den Web-Client weiterreichen.
Genau dieses Feature hatte ich ursprünglich implementieren wollen, aber
das war auch noch, als ich an einzeilige Kommandos anstatt an ein
mehrzeiliges Skript-Fenster dachte. Inzwischen finde ich es so
einfacher, eleganter und vor allem schlanker. Benutzer kleiner Boxen
brauchen nicht extra *Screen* in die Firmware einzubauen, nur um ein
klein wenig mehr Komfort in der Benutzersitzung zu haben. Potentielle
Probleme mit Mehrfach-Logins in dieselbe *Screen*-Sitzung etc. müßten
auch behandelt werden. Ich brauche das nicht. Wer es haben will - die
Idee habe ich ja formuliert, der Weg ist gewiesen. Ausprobiert habe ich
die *Screen*-Fernsteuerung via Kommandozeile bereits, sie funktioniert
gut.

Was geht noch alles nicht? Na ja, es macht kaum Sinn, Programme
aufzurufen, die ohne Benutzerinteraktion keinen Sinn ergeben, also z.B.
den [Midnight Commander (mc)](../../make/mc.md), `tail -f`, seitenweise
Ausgaben mit `more` oder `top` in der nicht automatisch terminierenden
Variante. Von interaktiven Editoren wie `vi` rede ich jetzt mal gar
nicht - es gibt ja `sed` und `awk` für kommandozeilenbasiertes
Editieren. Für interaktives gibt es Down- und Uploads (dazwischen
offline am Client editieren, klar).

## Tips & Tricks

### Sicherer Zugriff via HTTPS

**Achtung**:
Diese Anleitung wurde geschrieben bevor AVM eine eigene Fernzugrifffunktion
integriert hat, weshalb die hier auch nicht erwähnt wird.

Jetzt haben wir endlich eine Shell, die über ein reines Web-Interface
läuft, sind also unabhängig von *Telnet, [SSH](../../make/dropbear.md)*
& Co. Was jetzt noch schön wäre: sicherer Zugriff auf die Rudi-Shell
oder am besten gleich die ganze Freetz-Konfiguration von außen über eine
[SSL](http://de.wikipedia.org/wiki/Transport_Layer_Security)-gesicherte
Verbindung. Wir könnten dann aus dem Büro oder von jedem Internet-Café
der Welt aus unseren Router konfigurieren, ohne auf Proxies oder
Portbeschränkungen Rücksicht nehmen zu müssen. Port 443 für
[HTTPS](http://de.wikipedia.org/wiki/Hypertext_Transfer_Protocol_Secure)
ist bei 99% aller Proxies freigeschaltet. Wir bräuchten keinen
SSH-Client und hätten trotzdem eine sicher verschlüsselte Verbindung vom
Browser zum Router.

Genau das konfigurieren wir uns jetzt! Zunächst brauchen wir eine
Firmware mit dem Paket **[stunnel](../../make/stunnel.md)**. Das Paket
aktiviert übrigens automatisch die beiden Shared Libraries für
[OpenSSL](http://de.wikipedia.org/wiki/OpenSSL),
nämlich `libcrypto.so` und `libssl.so`. Außerdem wird die
[zlib](http://de.wikipedia.org/wiki/Zlib)
(`libz.so`) benötigt. Weitere Tips und Infos hierzu:

-   Der Platzbedarf dieser Pakete ist nicht zu unterschätzen, somit
    nichts für kleine Boxen: 90 KB für
    [stunnel](../../make/stunnel.md), 70 KB für die *zlib* und sage und
    schreibe 1.150 KB für *OpenSSL*. Das sind fast 1,3 MB und somit eine
    Menge. Aber wenn die Box es verkraftet (meine 7170 tut es), werden
    wir gleich noch viel Spaß haben.
-   Wer eine Firmware mit OpenSSL-Bibliotheken von AVM einsetzt, z.B.
    die aktuelle 29.04.59 für die 7170, muß aufpassen, daß er in
    `/var/flash/tr069.cfg` - so vorhanden - die Option *enabled = no*
    setzt, bevor die Firmware mit den eigenen Bibliotheken installiert
    wird (oder aber beim Erstellen des Images gleich den ganzen [TR-069
    Kram rauspatchen](../../patches/README/REMOVE_TR069.md) lassen).
    Ansonsten würde es mit Boxen von 1&1 Probleme beim Aufrufen der
    durch Freetz ersetzten *OpenSSL*-Bibliotheken geben. *Einige
    Provider wie z.B. 1&1 verlangen bei Support-Anfragen, dass TR-069 in
    der Box aktiviert ist!*

Als nächstes brauchen wir für den HTTPS-Server ein Serverzertifikat und
ein Schlüsselpaar. Das bauen wir uns selbst mit *OpenSSL*. Das geht
unter Linux prinzipiell genauso wie unter Windows, man sollte nur
vorsichtshalber darauf achten, daß die Schlüsseldatei, welche am Ende
auf der Box landet, UNIX-Zeilenenden hat. Ich erkläre im Folgenden, wie
die Generierung eines [Self-Signed
Key](http://en.wikipedia.org/wiki/Self-signed_certificate)
unter Linux abläuft. Es genügt, folgendes Skript auszuführen:

```
    #!/bin/bash

    # Paßwortgeschützten Server Key erzeugen
    openssl genrsa -des3 -out server.key 1024

    # Ungeschützte Version extrahieren (der SSL-Server kann ja nicht
    # vor der Benutzung selbst ein Paßwort eingeben)
    openssl rsa -in server.key -out server.key.unsecure

    # Certificate Signing Request (CSR) mit persönlichen Daten erzeugen
    openssl req -new -key server.key -out server.csr

    # Ein Jahr gültiges, selbst signiertes Zertifikat anfordern
    openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

    # CSR wird nicht mehr benötigt
    rm server.csr

    # Schlüssel + Zertifikat (in dieser Reihenfolge!)


    # in einer Datei zusammenführen
    cat server.key.unsecure server.crt > stunnel-key.pem

    # Nachschauen, ob auch alles da ist
    ls -l
```

Der gesamte Vorgang erfordert zwischendurch die Eingabe einer Passphrase
für den Serverschlüssel sowie von persönlichen Daten für das Zertifikat.
Das sieht dann inkl. Ein- und Ausgaben beispielsweise so aus:

```
	$ openssl genrsa -des3 -out server.key 1024
	Generating RSA private key, 1024 bit long modulus
	..................++++++
	.......++++++
	e is 65537 (0x10001)
	Enter pass phrase for server.key:
	Verifying - Enter pass phrase for server.key:

	$ openssl rsa -in server.key -out server.key.unsecure
	Enter pass phrase for server.key:
	writing RSA key

	$ openssl req -new -key server.key -out server.csr
	Enter pass phrase for server.key:
	You are about to be asked to enter information that will be incorporated
	into your certificate request.
	What you are about to enter is what is called a Distinguished Name or a DN.
	There are quite a few fields but you can leave some blank
	For some fields there will be a default value,
	If you enter '.', the field will be left blank.
	-----
	Country Name (2 letter code) [AU]:DE
	State or Province Name (full name) [Some-State]:Bavaria
	Locality Name (eg, city) []:Munich
	Organization Name (eg, company) [Internet Widgits Pty Ltd]:ACME Ltd.
	Organizational Unit Name (eg, section) []:
	Common Name (eg, YOUR name) []:Manni Muster
	Email Address []:manni@acme.de

	Please enter the following 'extra' attributes
	to be sent with your certificate request
	A challenge password []:
	An optional company name []:

	$ openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
	Signature ok
	subject=/C=DE/ST=Bavaria/L=Munich/O=ACME Ltd./CN=Manni Muster/emailAddress=manni@acme.de
	Getting Private key
	Enter pass phrase for server.key:

	$ rm server.csr

	$ cat server.key.unsecure server.crt > stunnel-key.pem

	$ ls -l
	insgesamt 16
	-rw-r--r-- 1 ubuntu ubuntu  895 2007-02-26 21:50 server.crt
	-rw-r--r-- 1 ubuntu ubuntu  963 2007-02-26 21:41 server.key
	-rw-r--r-- 1 ubuntu ubuntu  887 2007-02-26 21:42 server.key.unsecure
	-rw-r--r-- 1 ubuntu ubuntu 1782 2007-02-26 22:00 stunnel-key.pem
```

Anschließend haben wir in Form der Datei `stunnel-key.pem`, was wir
wollten: ein selbst signiertes Schlüsselpaar für unseren HTTPS-Server.
Das muß jetzt nur noch irgendwie auf die Box. Dafür gibt es zwei Wege:

-   Einbau in die Firmware: Einfach an den gewünschten Ort unter
    `<Mod-Verzeichnis>/root` kopieren, z.B. nach
    `/usr/share/stunnel-key.pem`.
-   Einbau in `/var/flash/debug.cfg` oder `/tmp/flash/rc.custom` in der
    üblichen Form eines Hier-Dokuments, welchen beim Booten der Box
    entpackt wird, z.B. nach `/tmp/stunnel-key.pem` oder nach
    `/mod/usr/share/stunnel-key.pem`. Das
    [Here-Dokument](http://en.wikipedia.org/wiki/Here-document)
    kann so aussehen:
    ```
        cat << EOF_CERT > /tmp/stunnel-key.pem
        -----BEGIN RSA PRIVATE KEY-----
        # Server-Schlüssel ...
        -----END RSA PRIVATE KEY-----
        -----BEGIN CERTIFICATE-----
        # Zertifikat ...
        -----END CERTIFICATE-----
        EOF_CERT
    ```

Wo auch immer die Schlüsseldatei liegt, wir müssen uns in der
*stunnel*-Konfiguration lediglich auf den richtigen Ablageort beziehen.
Weiter geht\'s:

Über die Freetz-Oberfläche sorgen wir dafür, daß *stunnel* als Dienst
automatisch gestartet wird und geben unter *Einstellungen → stunnel
services* folgende Konfiguration ein, um eben diese Web-Oberfläche, in
der wir uns gerade aufhalten, zukünftig HTTPS-gesichert verfügbar zu
machen:

```
	[freetz_web]
	cert = /tmp/stunnel-key.pem
	client = no
	accept = 443
	connect = 81
```

D.h. nichts anderes, als daß wir einen von uns
Freetz getauften Service verfügbar machen,
welcher eingehende SSL-Verbindungen auf dem HTTPS-Port 443 akzeptiert
und diese nach dem Entschlüsseln an den Port 81 des Freetz-Webservers
weiterleitet. Wichtig: Das Ganze läuft nicht im Client-, sondern im
Server-Modus.

Das war\'s schon! Jetzt können wir ausprobieren, was passiert, wenn wir
[https://fritz.box](https://fritz.box) aufrufen. Es
sollten zunächst der Passwort-Dialog von Freetz und anschließend die
Web-Oberfläche erscheinen.

Wenn wir jetzt noch Services für Port 80 (AVM-Oberfläche) und/oder Port
82 ([WOL](../../make/wol.md)-Oberfläche) haben wollen, fügen wir einfach
entsprechende Abschnitte in die Konfiguration ein nach obigem Muster.

**Achtung:** Um den oder die HTTPS-Ports nach außen verfügbar zu machen,
müssen entweder die üblichen Einstellungen in `/var/flash/ar7.cfg`
vorgenommen werden, also z.B. folgender Abschnitt unter *forwardrules*

```
        "tcp 0.0.0.0:443 0.0.0.0:443",
```

oder aber über die AVM-Oberfläche ein entsprechendes [Port
Forwarding](http://de.wikipedia.org/wiki/Portweiterleitung)
auf ein virtuelles Interface konfiguriert werden. Das Ganze benötigen
wir pro Service, d.h. wir müssen uns entscheiden, welcher Service den
"Premium Port" 443 bekommt, der von überall her erreichbar sein
sollte. Ich schlage vor, der Freetz-Oberfläche diesen Port zu geben,
denn dadurch gelangen wir an die Rudi-Shell und können somit alles mit
der Box anstellen, was wir wollen.

**Wichtig:** Es muß wohl nicht weiter erklärt werden, weshalb bei diesem
Szenario einem sicheren Passwort für die Web-Oberfläche besondere
Bedeutung zukommt...

### HTTPS-Zugriff reloaded & improved

Die Aussicht auf ein Paket von (bei mir) 1.310 KB für die oben
beschriebene Lösung ist natürlich ein K.O.-Kriterium für kleine Boxen,
die sowieso schon mit dem Speicherplatz für einen Firmware-Mod
haushalten müssen. Wer sowieso OpenSSL auf der Box für etwas anderes
braucht, dem werden die 160 KB für **stunnel + zlib** zusätzlich nicht
mehr viel ausmachen. Aber wer SSL nur für den HTTPS-Server benötigt,
würde sich sicher über eine schlankere Variante freuen. Das Schöne ist:
es gibt eine.

Es gibt eine für Embedded-Systeme optimierte Open-Source-SSL-Bibliothek
Namens [matrixssl](http://www.matrixssl.org).
Außerdem hat jemand für
[OpenWRT](http://openwrt.org) den kleinen Wrapper
[matrixtunnel](http://znerol.ch/svn/matrixtunnel/trunk)
geschrieben, welcher unsere Alternative zu
[stunnel](../../make/stunnel.md) sein wird. Und es gab das Ganze auch
bereits als Paket für Freetz. Es handelt
sich um ein Paket und eine Bibliothek mit der Gesamtgröße von 110 KB(!).
Das entspricht einer Platzersparnis von ca. 92% gegenüber der ersten
Lösung und funktioniert genauso gut nach meinen bisherigen Erfahrungen.
So schnell wie ohne Verschlüsselung ist das Browsen subjektiv mit beiden
HTTPS-Varianten nicht, aber absolut in Ordnung zum Arbeiten.

*Inzwischen wurde auch [xrelayd](../../make/xrelayd.md) der Nachfolger
von matrixtunnel} in Freetz aufgenommen.
Hier wird xyssl} (inzwischen polarssl) als
Crypt-Lib eingesetzt.*

Der Aufruf, den man am besten in einer der beim Start ausgeführten
Dateien (siehe Beschreibung der **stunnel**-Variante) unterbringt, sieht
beispielhaft so aus:

```
    matrixtunnel -A cert.pem  -p server_key.pem -d 443 -r 81 -P /tmp/matrixssl.pid
```

Ich verwende übrigens für `-A` und `-p` denselben Dateinamen und
dieselbe kombinierte Datei mit Serverschlüssel und Zertifikat wie für
*stunnel* (Bauanleitung s.o.). Gibt man zusätzlich `-f` an, startet der
Server im Vordergrund und man kann die Ausgaben beobachten. Einen
Debug-Schalter gibt es auch - einfach mal mit `-?` aufrufen und schauen.

Übrigens: matrixtunnel kann auch für jede
Schnitstelle (IP-Adresse) eine andere Regel nutzen. Einfach die
IP-Addresse vor dem Port (ip:port) angeben wie z.B.

```
    # ds_mod web über SSL auf LAN
    matrixtunnel -A mycert.pem -p mycert.pem -d 192.168.1.1:443 -r 192.168.1.1:81 -P /tmp/matrixssl.pid
    # eigene Internetseite über SSL auf Virtual IP für externen Zugang
    matrixtunnel -A mycert.pem -p mycert.pem -d 192.168.1.253:443 -r 192.168.1.253:82 -P /tmp/matrixssl.pid
```

### Firmware remote flashen

Auch das geht mit Rudi wunderbar, wie ich seit längerer Zeit in einem
[Beitrag im
Forum](http://www.ip-phone-forum.de/showthread.php?p=846233)
beschrieben habe. Hier nochmals der Code, den man in der Rudi-Shell auf
einmal ausführen kann. Vorher stoppen wir am besten noch einige
Freetz-Dienste, welche dem im Code aufgerufenen AVM-Skript nicht bekannt
sind und die deshalb weiter laufen und Speicher verbrauchen würden.

```
    # Bevor wir anfangen, ein Hintergrundbefehl: notfalls in 10 min die Box
    # zwangsweise neu starten, das müßte für Download + FW-Update reichen.
    { sleep 600 ; reboot -f; } &

    {
    # Unnötige Dienste stoppen, aber websrv und dsld weiter laufen lassen
    prepare_fwupgrade start_from_internet
    # FW-Image herunterladen und direkt nach "/" entpacken
    wget -q -O - http://mein.server.xy/mein.image 2> /dev/null | tar -C / -x
    # Restliche Dienste stoppen
    prepare_fwupgrade end
    # Installation vorbereiten
    /var/install
    # Installation initialisieren
    /var/post_install
    # Box neu starten
    reboot
    }
```

Dieser Code funktioniert übrigens nicht nur in der Rudi-Shell, sondern
grundsätzlich auch innerhalb einer Telnet- oder SSH-Sitzung.


