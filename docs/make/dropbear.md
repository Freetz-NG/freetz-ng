# Dropbear 2025.88
  - Homepage: [https://matt.ucc.asn.au/dropbear/dropbear.html](https://matt.ucc.asn.au/dropbear/dropbear.html)
  - Manpage: [https://linux.die.net/man/8/dropbear](https://linux.die.net/man/8/dropbear)
  - Changelog: [https://matt.ucc.asn.au/dropbear/CHANGES](https://matt.ucc.asn.au/dropbear/CHANGES)
  - Repository: [https://github.com/mkj/dropbear](https://github.com/mkj/dropbear)
  - Package: [master/make/pkgs/dropbear/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/dropbear/)
  - Maintainer: [@fda77](https://github.com/fda77)

> "Dropbear is a relatively small SSH 2 server and client. [... ...]
> Dropbear is particularly useful for "embedded"-type Linux (or other
> Unix) systems, such as wireless routers."
> [http://matt.ucc.asn.au/dropbear/dropbear.html](http://matt.ucc.asn.au/dropbear/dropbear.html)

Dropbear ist ein SSH Server und Client + SCP. Es gibt zwei Pakete:
dropbear Server, Client und scp - sowie ein auf den dropbear Server
beschränktes Paket. Dropbear wurde so modifiziert, dass nur root Logins
erlaubt sind.

### Grundbegriffe

-   **SSH** (Secure Shell): ermöglicht eine Verbindung zwischen zwei
    Rechnern (als sichere Alternative zu z.B. telnet). Dabei baut ein
    *SSH-Client (z.B. PuTTY, OpenSSH, Dropbear)* eine verschlüsselte
    Verbindung zu einem *SSH-Server (z.B. OpenSSH, Dropbear)* nach einer
    erfolgreichen Authentifizierung auf.
    Die Howtos beziehen sich größtenteils auf 2 SSH-Clients:
    1.  OpenSSH für [Windows (über eine
        Cygwin-Installation](http://www.cygwin.com/)) oder
        [Linux und andere
        Betriebssysteme](http://www.openssh.com/de/)
    2.  [Putty mit Puttygen für Windows und
        Linux](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
-   **SCP** (Secure Copy): ermöglicht verschlüsselte Übertragung von
    Dateien zwischen zwei Rechnern. Dabei baut ein *SCP-Client (z.B.
    PSCP, OpenSSH, Dropbear)* eine verschlüsselte Verbindung zu einem
    *SCP-Server (z.B. OpenSSH, Dropbear)* über SSH auf.
-   **Password-based Authentication**: SSH-Verbindung kommt zustande,
    nachdem sich der (SSH-)Client mit einem Passwort authentifiziert
    hat.

    ``` 
    # ssh user@host
    user@host's password:

    # scp [user@host:]file_to_copy [user@host:]target_path
    user@host's password:
    file_to_copy     100%     20KB/s     00:10
    ```

-   **Public Key Authentication**: SSH-Verbindung kommt zustande,
    nachdem sich der (SSH-)Client mit einem *Private Key (geheimen
    Schlüssel)* gegenüber einem auf dem (SSH-)Server abgelegten *Public
    Key (öffentlichen Schlüssel)* authentifiziert hat. Ein Vorteil ist,
    dass man zur Anmeldung kein Passwort mehr eingeben muss.

    ``` 
    # ssh user@host
    Authenticating with public key "rsa-key-XXXXXXXX"

    # scp [user@host:]file_to_copy [user@host:]target_path
    Authenticating with public key "rsa-key-XXXXXXXX"
    file_to_copy     100%     20KB/s     00:10
    ```

-   **Host-based Authentication**: SSH definiert auch eine optionale
    Host-basierte Authentifizierung. Diese wird jedoch selten verwendet
    und von dropbear nicht unterstützt.

### Web-Config

[![Dropbear Konfiguration](../screenshots/201_md.png)](../screenshots/201.png)

-   *Starttyp*: wahlweise bei Systemstart (**automatisch**) oder
    **manuell**
-   *Authorized keys*: Liste bekannter Public Keys für die Public Key
    Authentication. Entspricht in der Syntax und Funktion genau der
    Datei `~/.ssh/authorized_keys` bei einer normalen Unix-Installation.
    Weitere Details sind
    [hier](http://www.lrz.de/services/security/ssh/)
    beschrieben. Das Format der *Authorized keys* im Web-GUI sollte (für
    root) so aussehen (hier durch ... abgekürzt):

    ``` 
    ---root
    ssh-rsa AAAAB3...o1b0=0
    ```

<!-- -->

-   *Port des SSH-Servers* (default: 22): Änderung des Standardports hat
    zur Folge, dass bei SSH-Clients explizit der Port angegeben werden
    muss.
-   *Passwort Login*: **aktiviert** oder **deaktiviert** Password-based
    Authentication. Sollte deaktiviert werden, wenn Public Key
    Authentication verwendet wird.
-   *Zusätzliche Kommandozeilen-Optionen*: Dropbear wird mit bestimmten
    Optionen gestartet. Übersicht über Optionen mit
    `dropbear -?`

### SSH-Zugang mit Passwort (Password-based Authentication)

Das ist die Standardeinstellung im Dropbear. Ohne weitere Einstellungen
kann die Fritzbox folgendermaßen über SSH erreicht werden:

### Zugang mit OpenSSH

```
# ssh root@fritz.box
root@fritz.box's password: freetz
```

### Zugang mit Putty

1.  Einstellungen setzen
    `Session/Host` Name: `fritz.box`
    `Session/Port: 22` (bzw. die Einstellung unter *Pakete* →
    *Dropbear*)
    `Session/Protocol: SSH`
    `Connection/Data/Auto-login username: root`
2.  Einstellungen speichern (optional)
    bei *Session* → *Saved Sessions* beliebigen Namen (z.B. *fritzbox
    ssh*) eingeben und *Save* drücken. Ab sofort kann dann per
    Doppelklick auf den Namen die Verbindung aufgebaut werden (oder die
    Einstellungen mit *Load* geladen werden)
3.  *Open*
4.  `root@fritz.box's password: fritzbox`

**Wichtig:** Bei den neuen freetz Paketen ist das Standard root Passwort
nicht mehr fritzbox, sondern freetz und muss nach dem ersten Einloggen
geändert werden.

### SSH-Zugang ohne Passwort (Public Key Authentication)

### Zugang mit OpenSSH

1.  `ssh-keygen`, alle Abfragen mit Enter bestätigen
2.  `cat ~/.ssh/id_rsa.pub`
3.  Ausgabe von `cat` kopieren
    *Vorsicht: Je nach verwendeter Kommandozeile können Zeilenumbrüche
    mitkopiert werden, welche mit Hilfe eines Editors (Key in Editor
    kopieren, Zeilenumbrüche entfernen, Key wieder kopieren) entfernt
    werden sollten.*
4.  Webinterface von Freetz öffnen, nach *Einstellungen* → *Authorized
    keys* wechseln
5.  vorher kopierten Key einfügen, *Übernehmen*
6.  nun sind die serverseitigen Einstellungen abgeschlossen. Es gibt nun
    2 Möglichkeiten zum Einloggen:
    -   [Zugang vom selben PC und User, unter dem `ssh-keygen`
        ausgeführt worden ist]
        `ssh root@fritz.box`
    -   [Zugang von anderen PC oder User als `ssh-keygen` ausgeführt
        worden ist]
        Wurde `ssh-keygen` als *user1@pc1* ausgeführt, man möchte jetzt
        jedoch als *user2@pc2* Zugang über SSH auf die Fritzbox
        erhalten, liegt das Problem darin, dass Dropbear *user2@pc2*
        nicht kennen kann. Deshalb braucht user2 einen Ausweis, den
        `ssh-keygen` standardmäßig im Heimatverzeichnis von user1
        `~/.ssh/id_rsa` ablegt und user2 zugänglich gemacht werden muss.
        `id_rsa` kann dann beliebig umbenannt werden. Zum Einloggen über
        SSH auf die Fritzbox kann nun über
        `ssh -i PfadZumIdentityFile root@fritz.box` erfolgen (z.B.
        `ssh -i id_rsa root@fritz.box`).
        Soll es jedoch genauso einfach gehen wie für *user1@pc1*, muss
        einfach nur für jede Konstellation (*user1@pc2*, *user2@pc1*,
        ...) ssh-keygen genutzt werden um neue Schlüsselpaare zu
        erzeugen. Die öffentlichen Schlüssel davon (i.d.R. `id_rsa.pub`)
        sind dann wieder in Freetz einzutragen. Jeder Schlüssel in eine
        eigene Zeile. Es können quasi unendlich viele Schlüssel
        aufgelistet werden.

### Zugang mit Putty

1.  `puttygen` starten
2.  *Key/Generate Key Pair*
3.  Maus über die leere Fläche bewegen
4.  aus der Box *Public Key for pasting into ...* Key komplett kopieren
5.  *Save Private Key*, Warnung übergehen und in einem beliebigem
    Verzeichnis mit beliebigem Namen speichern
6.  Freetz Webinterface öffnen, nach *Einstellungen* → *Authorized keys*
    wechseln
7.  vorher kopierten Key einfügen, *Übernehmen*
8.  `putty` starten
9.  Einstellungen setzen
    *Session/Host Name: fritz.box
    Session/Port: 22* (bzw. die Einstellung unter *Pakete*, *Dropbear*)
    *Session/Protocol: SSH*
    *Connection/Data/Auto-login username: root*
    *Connection/SSH/Auth/Private key file for authentication: Pfad zum
    vorher gespeichertem Private Key*
10. Einstellungen speichern (optional)
    bei *Session* → *Saved Sessions* beliebigen Namen (z.B. *fritzbox
    ssh*) eingeben und *Save* drücken. Ab sofort kann dann per
    Doppelklick auf den Namen die Verbindung aufgebaut werden (oder die
    Einstellungen mit *Load* geladen werden)
11. *Open*

### Zugang zur Fritzbox von außerhalb

Um den SSH-Port von außen zu erreichen muß "lediglich" eine
Portweiterleitung eingerichtet werden. Leider verbietet mittlerweile das
AVM-Webinterface eine Weiterleitung auf die Box selbst. Es gibt aber ein
CGI-Paket namens AVM-Firewall, welches diese Restriktionen nicht hat:

1.  Paket CGI/AVM-Firewall mitinstallieren
2.  im Menüpunkt AVM-Firewall im Freetz-Webinterface unter Ansicht
    "Port Forwarding" auswählen
3.  netterweise ist das was wir wollen schon voreingestellt: tcp
    0.0.0.0:22 0.0.0.0:22, also ein Forwarding von Port 22 auf Port 22
4.  die Buttons Hinzufügen und dann Übernehmen anklicken
5.  den dsld, unter AVM-Dienste zu finden, neustarten

Es kann Sinn machen Dropbear auf anderen Ports lauschen zu lassen, z.B.
um aus restriktiven Netzen herauszukommen. Dafür bieten sich Port
80(HTTP) und 443(HTTPS) an, da diese am notwendigsten sind. Wenn die
auch zu sind, ist Port 53(DNS) noch einen Versuch wert. Es können
alternativ oder zusätzlich zur obrigen Regel noch weitere für andere
Ports hinzugefügt werden. Hierzu den gewünschten Port in die obere,
etwas unglücklich, mit "(Start-)Port" Beschriftete Box eintragen.

### Zugang zum Webinterface der Fritzbox oder anderen Diensten im Heimnetz von außerhalb (z.B. hinter einem Proxy)

***Achtung, das Tunneln durch Proxies in Firmennetzen kann u.a. zur
Abmahnung oder sogar zur Kündigung führen. Entsprechende
Betriebsvereinbarungen bzw. Vertragsbestandteile sind unbedingt zu
berücksichtigen. Das Befolgen dieser Tipps erfolgt auf eigene Gefahr!***

Wer von unterwegs Zugriff auf die Freetz-Oberfläche (Freetz-GUI) bzw.
die AVM-Oberfläche (AVM-GUI) benötigt, kann dafür ebenfalls PuTTY
verwenden (analog auch andere SSH-Tools).

In Putty trägt man unter Proxy den Proxy ein. Unter Tunnels folgendes
(für das Freetz-GUI):

```
Source Port: 1081 {ein beliebiger, freier, lokaler Port}
Destination: 192.168.178.1:81 {die IP der Box im LAN)
```

Nach dem Hinzufügen erscheint im PuTTY-Fenster unter "Forwarded
Ports":

```
L1081 192.168.178.1:81
```

Entsprechend kann man sich das für das AVM-GUI (Port 80) einrichten:

```
Source Port: 1080 {ein beliebiger, freier, lokaler Port}
Destination: 192.168.178.1:80 {die IP der Box im LAN)
```

Nach dem Starten der SSH-Session und dem Login ruft man dann das
Freetz-GUI so auf:

```
http://localhost:1081/
```

... und das AVM-GUI so:

```
http://localhost:1080/
```

Anmerkung:

Damit der Zugriff auf das AVM-GUI (Port 80) funktioniert, muss man den
Referer unterbinden. Unter Firefox ist dazu der Wert für
[network.http.sendRefererHeader](http://kb.mozillazine.org/Network.http.sendRefererHeader)
unter about:config auf 0 (Null) zu setzen. Inwieweit dies auch für das
Freetz-GUI (Port 81) nötig ist, müsste noch ausgiebiger getestet werden.
Wer den Referer nicht benötigt, schaltet ihn wie oben beschrieben besser
ab.

Es lassen sich auch Weiterleitungen auf beliebige Maschinen und Dienste
im Lan schalten. Z.B. Remotedesktopverbindung für eine Maschine im LAN:

```
Source Port: 3399 {ein beliebiger, freier, lokaler Port}
Destination: 192.168.178.21:3389 (die IP der gewünschten Maschine im LAN; statische DHCP-Leases sind hier vorteilhaft)
```

im Remotedesktopclient dann:

```
localhost:3399
```

Noch mehr Spass bereitet die Tunneloption "Dynamic": Hier muss nur
noch der lokale, frei wählbare Quellport (z.B. 8888) angegeben werden.
Solange die SSH-Session offen ist, steht dann ein SOCKS-Proxy auf dem
angegebenen Port. Wenn man den Browser oder andere Programme mit diesem
Proxy konfiguriert (localhost:8888 in diesem Beispiel), lässt sich so
der gesamte Netzverkehr durch den Tunnel schieben. Das wird durch den
geringen Upstream üblicher DSL-Anschlüsse zwar etwas langsam, führt den
Netzverkehr aber sicher aus einem unsicheren Netz wie z.B. einem freien
WLAN heraus.

### Zugang zu anderen Rechnern mit der Fritzbox

**Anmerkung**: In der folgenden Beschreibung wird der Host-Key, der für
den Server benötigt wird, gleichzeitig als Benutzer-Key (für den
Benutzer root) genutzt. Üblicher wäre es, dafür einen eignen
Benutzer-Key anzulegen.

Freetz legt automatisch beim ersten Systemstart einen RSA und DSS
private key für die Fritzbox an. Diese liegen in `/var/mod/etc/ssh/` in
`dss_host_key` und `rsa_host_key` (als symlinks zu `/tmp/flash`). Um nun
auf einen anderen Rechner per public Key authentication zugreifen zu
können, ist erst einmal der public Key nötig, den man mit
`# dropbearkey -f /tmp/flash/rsa_host_key -y` zB für den RSA key, auf
dem Terminal ausgegeben bekommt. Diesen dann in die `authorized_keys`
Datei des anderen Rechners kopieren, wie es bei SSH üblich ist.

Der nachfolgende Befehl kopiert den RSA key auf das Remote-System mit
der IP 192.168.178.2 für den User:user01 in die Datei
~/.ssh/authorized_keys

```
# dropbearkey -f /tmp/flash/rsa_host_key -y | ssh user01@192.168.178.2 'umask 077; cat >> .ssh/authorized_keys'
```

Für einen Login ohne Passwort Angabe, muss das Keyfile wie im Beispiel
als Parameter angegeben werden.

```
# ssh -i /tmp/flash/rsa_host_key user@machine
```

Dies liefert dann einen passwortlosen Login auf 'machine' wenn dort
vorher der public key hin kopiert wurde.

### mögliche Anwendung von ssh

-   Ausführen eines auf der Fritzbox abgelegten Skriptes
    `ssh root@fritz.box [command]` bzw.
    `ssh -i identityfile root@fritz.box [command]` (z.B.
    `ssh root@fritz.box '/var/tmp/flash/testscript.sh'` zum Ausführen
    von `/var/tmp/flash/testscript.sh`)

### mögliche Probleme

-   Sollte die Verbindung nach korrekter Passwortangabe auf Modellen mit
    4MB Flash Speicher abbrechen und auch Telnet Login scheitern ist es
    wahrschinlich das das Kernel ohne pty devices gebaut ist. Hier hilft
    die Aktivierung des Menüpunktes *Replace Kernel*. Getestet mit FBF
    5140 FW 43.04.67-freetz-1.1.3.
-   *folgende Fehlermeldung nach Anmeldung mit `ssh root@fritz.box`:
    `Permission denied (publickey).`
    Falls man sich mit einem Passwort einloggen möchte, muss
    Password-Based Authentication aktiviert sein, was unter dem
    Menüpunkt* Pakete *→* Dropbear *unter* Passwort Login*,* Aktiviert
    *einstellen kann.*
-   *folgende Warnung nach Anmeldung mit `ssh root@fritz.box`: [br]
    `The authenticity of host 'fritz.box (<deine Fritzbox IP>)'
    can't be established.` [[BR?]
    `RSA key fingerprint is XX:XX:...:XX:XX.`
    `Are you sure you want to continue connecting (yes/no)?`
    Einfach mit* yes *bestätigen. Wird genau dann gefragt, wenn man sich
    zum ersten Mal mit dem User auf die Fritzbox verbindet (bzw. der
    Host in* ~/.ssh/known_hosts *nicht bekannt ist).*
-   *folgende Warnung nach Anmeldung mit* ssh root@...*:*

    ``` 
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
    Someone could be eavesdropping on you right now (man-in-the-middle attack)!
    It is also possible that the RSA host key has just been changed.
    The fingerprint for the RSA key sent by the remote host is XX:XX:...:XX:XX.
    Please contact your system administrator.
    Add correct host key in ~/.ssh/known_hosts to get rid of this message.
    ...
    ```

    Einfach die *~/.ssh/known_hosts* löschen (wird automatisch neu
    angelegt), oder die *~/.ssh/known_hosts* öffnen und entsprechende
    Zeile, wo *fritz.box* erwähnt wird, löschen. Beim nächsten
    Verbindungsversuch erscheint die oben erwähnte Warnung über eine
    Unsicherheit über die Authentizität des Hosts, einfach mit *yes*
    bestätigen.

### Verbindungsaufbau beschleunigen

Wem der Aufbau einer Verbindung zu Dropbear nicht schnell genug geht,
hier ein paar Tipps: (Bei meiner Fritzbox 7050 hat es in letzter Zeit 5
bis 6 Sekunden gedauert; Hauptursache sind laut einigen Einträgen auf
der Dropbear-Mailingliste wohl die aufwendigen Berechnungen bei
Schlüsselaustausch.)

-   Nutzt man OpenSSH als Client, gibt es die Möglichkeit, eine
    bestehende Verbindung für weitere Zugriffe (ssh, scp) zu nutzen:
    Siehe die Optionen ControlMaster, ControlPath, ControlPersist;
    [http://www.debian-administration.org/articles/290](http://www.debian-administration.org/articles/290)

<!-- -->

-   In `/etc/profile` wird die Datei `/etc/init.d/rc.conf` gelesen, was
    recht lange dauert. Als Alternative kann man deren Cache-Version
    `/var/env.cache` lesen, die in `rc.mod` erstellt wird.

Mit diesen beiden Maßnahmen verbinde ich mich nun (beim zweiten bis
n-ten Mal) in Sekundenbruchteilen mit meiner Fritzbox.

