# Callmonitor 1.20.9-git
  - Package: [master/make/pkgs/callmonitor/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/callmonitor/)
  - Maintainer: -

Der Callmonitor ermöglicht es, bei eingehenden Anrufen auf einer
FritzBox beliebige Aktionen
auszuführen, abhängig davon, wer wen anruft. Beliebt sind das Senden von
Benachrichtigungen an verschiedenste Arten von "Boxen"
(TV/Sat-Receiver, Spielekonsolen, PCs) oder das Aufwecken von Geräten
(Wake on LAN).

Dabei kann über eine Rückwärtssuche in Internet-Telefonbüchern oft auch
der Name des Anrufers angezeigt werden.

Das Besondere an diesem Callmonitor (leider gibt es viele Projekte mit
ähnlichem Namen) ist, dass er komplett auf der Fritzbox läuft; es ist
also nicht nötig, weitere Rechner eingeschaltet zu haben.

## Installation

[![[Callmonitor WebInterface]](../../docs/screenshots/6_md.png)](../../docs/screenshots/6.png)

Der Callmonitor ist als Paket im Rahmen von Freetz
([Forum](http://www.ip-phone-forum.de/showthread.php?t=85371))
realisiert, und kann bei dessen Installation einfach ausgewählt werden.

Das Callmonitor-Paket kann nicht als Addon-Paket installiert werden.

##  Installation neuer Versionen

Bitte beachtet: Mit Freetz 1.1 können nur Callmonitor-Version bis 1.15
eingesetzt werden. Callmonitor 1.15.1 und höher benötigen Änderungen,
die in Freetz 1.2 oder der Freetz-Entwicklerversion enthalten sind.

Zum Einbinden der aktuellsten Version aus der Entwicklerversion in
Freetz 1.2 kann man so vorgehen (im Wurzelverzeichnis von Freetz):

```
svn switch http://svn_freetz_org/trunk/make/callmonitor/callmonitor.mk make/callmonitor/callmonitor.mk
```

## Weiterführende Links

-   [Entwicklungsseite bei
    Sourceforge](http://sourceforge.net/projects/callmonitor/)
-   [Forumsseite für Fragen und
    Diskussionen](http://www.ip-phone-forum.de/showthread.php?t=191723)


## Konfiguration

Die Konfiguration des Callmonitors nimmt man sinnvollerweise in mehreren
Schritten vor, die sich auf verschiedene Seiten im Web-Interface von
Freetz verteilen:

1.  Basiskonfiguration durchführen (im Folgenden beschrieben)
2.  Listeners für bestimmte Aktionen definieren
3.  mit einem Testanruf die Konfiguration testen

## Basiskonfiguration

Auf der Seite Pakete-Callmonitor des Web-Interfaces lassen sich einige
grundlegende Einstellungen vornehmen.

Als erstes wählt man den Starttyp - normalerweise "Automatisch", da
der Callmonitor sonst nach jedem Neustart der FritzBox per Hand
gestartet werden muss. Sollte es Probleme geben, kann man noch
zusätzlich die Debug-Ausgaben aktivieren, was jedoch normalerweise
unnötig ist.

Der nächste Block bietet lediglich Links zu den Listeners und zur
Durchführung von Testanrufen.

Im folgenden Block lassen sich die Standort-Angaben (Landes- und
Ortsvorwahl) noch einmal überprüfen und über einen Link zum AVM-WebGUI
auch anpassen. Es ist zu beachten, dass Änderungen der Landes- und/oder
Ortsvorwahl erst auf der Callmonitor-Seite angezeigt werden, wenn der
Callmonitor neu gestartet wurde.

So weit sind wir aber noch nicht, vorher sind noch die Einstellungen zur
Rückwärtssuche im dritten Block zu überprüfen. Sie kann komplett
deaktiviert werden, dafür ist die Checkbox vor "Rückwärtssuche
durchführen bei" zuständig. Möchte man sie benutzen, kann der "Dienst
für die Rückwärtssuche" ausgewählt werden,
an den die Anfragen geschickt werden. **Achtung:** Diese Funktion setzt
eine bestehende Internetverbindung voraus - es empfiehlt sich also
irgendeine Art von always-on Flatrate für den Internetzugang zu
verwenden (z.B. Volumentarif, komplette Flat).

Falls die Telefonnummer nicht gefunden werden kann (z.B. weil der
Teilnehmer der Rückwärtssuche widersprochen hat), wird ersatzweise die
Vorwahl bei dem dort ausgewählten Dienst nachgeschlagen. Dadurch kann
zumindest der Ort angezeigt werden. Zum Schluss kann noch ausgewählt
werden, ob die Ergebnisse der Rückwärtssuche dauerhaft im Telefonbuch
(also im Flash der Box) oder flüchtig (d.h. bis zum Neustart) im
Speicher abgelegt werden. Es ist auch möglich, die Zwischenspeicherung
ganz abzuschalten. Dann wird die Rückwärtssuche immer wieder neu
durchgeführt, selbst wenn dieselbe Rufnummer schon einmal nachgeschlagen
wurde.

Die Einstellung "Vorwahl für lokale Rufnummern" wird benötigt, da im
Ortsnetz nicht (immer) die Vorwahl mit übertragen wird. In aktuellen
Versionen wird die Vorwahl automatisch aus den Einstellungen zur
Internettelefonie übernommen (in der Weboberfläche von AVM).

## Listeners definieren

Als nächstes müssen sogenannte Listeners definiert werden, die dann bei
eingehenden Anrufen die gewünschte Aktion starten. Genaueres hierzu auf
einer speziellen Seite für die Listeners.

## Testanruf

Sind die Listeners einmal definiert, kann und sollte man sie mit einem
Testanruf ausprobieren. Dafür kann man natürlich einen echten Anruf
machen - allerdings hat man oft nicht die Möglichkeit, spezielle Regeln
zu testen. Daher gibt es die Möglichkeit, einen Testanruf über das
Web-Interface zu generieren.

## Fehlersuche

Die Ausgaben des Testanrufs und ggf. die Debug-Meldungen (siehe oben, um
das log zu sehen vorher in freetz-konfig diese option aktivieren um sie
in das image einzubauen) geben in den meisten Fällen ausreichend
Hinweise, warum die Aktion nicht ausgeführt wurde bzw. der Callmonitor
nicht startet. Außerdem lohnt sich auch ein Blick auf die
Wartungsseite - falls die
Callmonitor-Schnittstelle deaktiviert ist, kann dieser auch nicht
funktionieren. Einschalten mit einem Anruf der Fritzbox von einem
angeschlossenem Telefon aus mit der Nummer: #96*5* kann
helfen. Wenn das alles nicht weiterhilft, kann man
auf der [Forumsseite für Fragen und
Diskussionen](http://www.ip-phone-forum.de/showthread.php?t=100706)
Unterstützung bekommen.


## Regeln (Listeners)

Die Listeners-Datei enthält eine Liste von Regeln, die festlegen, welche
Aktionen unter welchen Bedingungen ausgeführt werden sollen.

Leerzeilen werden ignoriert, ebenso Zeilen, die mit *#* beginnen (das
sind Kommentare).

Jede Regel steht in einer Zeile und besteht aus vier Angaben, die durch
Leerraum getrennt in dieser Reihenfolge aufeinander folgen:

1.  Ereignis
2.  Quellrufnummer: Muster für SOURCE
3.  Zielrufnummer: Muster für DEST
4.  Aktion: Beliebiger Shell-Code

Die beiden Muster für *SOURCE* und *DEST* sind ["extended
regular expressions"
(ERE)](http://www.selflinux.org/selflinux/html/regex.html),
wie sie von *egrep* verstanden werden. Das Ereignis (ein-/ausgehender
Anruf; Klingeln, Annahme, etc.) wird mit der unten angeführten Syntax
angegeben.

Man kann negative Muster bei den Listeners verwenden, indem man ein
Ausrufezeichen voranstellt: `!123` passt auf alle Nummern, die nicht
irgendwo 123 enthalten.

Beispiele:

```
  Muster           passt auf
  ---------------- ---------------------------------------------------------------------
  `^`              alle Nummern
  `^034`           Nummern, die mit 034 beginnen
  `4563$`          Nummern, die auf 4563 enden
  `!^(045|0164)`   Nummern, die **nicht** mit 045 oder 0164 beginnen
  `^0123456$`      nur genau die Nummer 0123456
  `^04553...$`     die Nummern, bei denen nach 04553 genau drei weitere Zeichen folgen
  ---------------- ---------------------------------------------------------------------
```

Alle Regeln werden parallel abgearbeitet; eine bestimmte Reihenfolge ist
nicht garantiert.

Damit die Listeners über das Webinterface von Freetz bearbeitet werden
können, muss dessen Sicherheitsstufe auf 0 gesetzt werden. Das ist
nötig, da über die Listeners beliebiger Code ausgeführt werden kann.

[![[Callmonitor: Listener Konfiguration]](../../docs/screenshots/20_md.png)](../../docs/screenshots/20.png)

## Format

Seit Version 1.0 des Callmonitors gilt folgendes Format für die
Listeners, mit dem auf bis zu acht verschiedene Ereignisse
unterschiedlich reagiert werden kann:

-   ***:request**: Anruf kommt an (es klingelt)
-   ***:cancel**: Anruf wurde abgebrochen, bevor eine Verbindung
    zustande kam (so kann man direkt auf "verpasste Anrufe" reagieren)
-   ***:connect**: Verbindung beginnt
-   ***:disconnect**: Verbindung wurde beendet

Dazu kommt die Unterscheidung zwischen

-   **in:***: eingehenden und
-   **out:***: ausgehenden Anrufen.

Das ergibt folgende Menge von Ereignissen:

```
  |           *:request       *:cancel       *:connect       *:disconnect
  ----------- --------------- -------------- --------------- ------------------
  | in:*      in:request      in:cancel      in:connect      in:disconnect
  | out:*     out:request     out:cancel     out:connect     out:disconnect
  ----------- --------------- -------------- --------------- ------------------
```

Dazu passend haben die Listeners eine zusätzliche erste Spalte bekommen,
in der (mit Hilfe von Abkürzungen und Wildcards) das gewünschte Ereignis
angegeben werden kann, auf das die betreffende Regel reagieren soll:

```
in:request  ^       ^1234$  xboxmessage xbox
in:cancel   ^       ^       mailmessage -t test@example.com
out:cancel  ^1234$  ^0123   dboxpopup dbox-a "${DEST} geht nicht ran"
*:dis       ^       ^       echo "Anruf beendet: ${DURATION} Sekunden" >> log
```

Es kann mehrere Regeln geben, die auf dasselbe Ereignis passen.

Die Präfixe "NT:", "E:" und "*:" in der *SOURCE*-Spalte gibt es
nicht mehr. Eure bisherige Listeners-Datei (vor Version 1.0) könnt ihr
nicht einfach weiterverwenden. Der CallMonitor versucht aber, beim
ersten Start eine grobe Konvertierung vorzunehmen, um euch den Umstieg
zu erleichtern. Auf jeden Fall solltet ihr aber die Listeners nach der
Umstellung einmal kontrollieren.

Die Spalten 2 und 3 in den Listeners sind weiterhin Muster (reguläre
Ausdrücke) für Quell- und Zielrufnummer (*SOURCE* und *DEST*).
Dabei ist jedoch zu beachten, dass in Spalte 2 bzw. 3 die MSNs, also die
Internet-Rufnummern, anzugeben sind und nicht wie früher bspw. *SIP0*
oder *SIP1*.

## Ereignis-Informationen für Aktionen

Den Aktionen stehen Informationen über den auslösenden Anruf in
Umgebungsvariablen bereit. Sie werden in Shell-Scripten mit einem $
referenziert, also z.B. `echo $SOURCE_NAME`.

```
  Variable          Inhalt                                                                                                                                     | seit Version
  ----------------- -------------------------------------------------------------------------------------------------------------------------------------------- -----------------
  EVENT             das auslösende Ereignis                                                                                                                      1.0
  ID                die ID des Anrufs (direkt von der Callmonitor-Schnittstelle)                                                                                 1.0
  UUID              Global eindeutige ID für diesen Anruf (nicht für dieses Ereignis!)                                                                           1.20
  TIMESTAMP         der Zeitpunkt des Ereignisses (im Format "DD.MM.YY HH:MM")                                                                                   1.0
  SOURCE            Quellrufnummer                                                                                                                               ---
  SOURCE_DISP       "anzeigefreundlichere" Variante von SOURCE (Landesvorwahl weg, Call-by-Call-Vorwahlen weg, etc.)                                             1.8
  SOURCE_NAME       Name der Quelle, falls dieser bestimmt werden konnte                                                                                         ---
  SOURCE_ADDRESS    Die Adresse (Straße, Stadt, Land) ist seit 1.12 separat verfügbar und nicht mehr in SOURCE_NAME enthalten                                    1.12
  SOURCE_ENTRY      Der ganze Telefonbucheintrag (entspricht dem SOURCE_NAME vor 1.12)                                                                           1.12
  DEST              Zielrufnummer                                                                                                                                ---
  DEST_DISP        "anzeigefreundlichere" Variante von DEST (Landesvorwahl weg, Call-by-Call-Vorwahlen weg, etc.)                                                1.8
  DEST_NAME         Name des Ziels, falls dieses bestimmt werden konnte                                                                                          ---
  DEST_ADDRESS      Die Adresse (Straße, Stadt, Land) ist seit 1.12 separat verfügbar und nicht mehr in DEST_NAME enthalten                                      1.12
  DEST_ENTRY        Der ganze Telefonbucheintrag (entspricht dem DEST_NAME vor 1.12)                                                                             1.12
  EXT               die Nebenstelle, sofern bekannt (direkt von der Callmonitor-Schnittstelle)                                                                   1.0
  DURATION          bei *:disconnect die Dauer des Gesprächs in Sekunden                                                                                         1.0
  PROVIDER          Dienstleister, über den der Anruf abgewickelt wird ("POTS" für Festnetz oder "SIP0", "SIP1", ... für die verschiedenen SIP-Provider)         1.5
  ----------------- -------------------------------------------------------------------------------------------------------------------------------------------- -----------------
```

EXT kann auf einer FritzBox 7050 folgende numerische Werte haben (bei
einem eingehenden Anruf liegt diese Information erst ab in:connect vor;
vorher ist die Zuordnung ja nicht klar):

```
  Wert     Bedeutung
  -------- ------------------
  0        FON 1
  1        FON 2
  2        FON 3
  3        Durchwahl
  4        Fon S0
  5        Fon/Fax PC
  6        Anrufbeantworter
  36       Data S0
  37       Data PC
  -------- ------------------
```

## Formatierung der Ausgaben

Zur Formatierung der Ausgaben stehen folgende Funktionen bereit:

seit Version 1.8:

-   f_duration: zur Darstellung von Zeitdauern als "hh:mm:ss"

    ```
    f_duration <ZEIT_IN_SEKUNDEN>

      ZEIT_IN_SEKUNDEN:      Zeit in Sekunden, z.B. $DURATION
    ```

Beispiel:

```
    echo "Der Anruf dauerte $(f_duration $DURATION)"
```

führt zu einer Ausgabe

```
Der Anruf dauerte 1:05:03
```

falls DURATION den Wert 3903 hat.

Als nützlich kann sich auch die Konstante $LF erweisen, die einen
Zeilenumbruch enthält (line feed):

```
    dboxmessage foo.bar "Zeile 1${LF}Zeile 2"
```

## Muster für Ereignisse

Es gibt mehrere Möglichkeiten, in den Listeners die Ereignisse
anzugeben, bei der eine Regel auslösen soll:

-   Vollständige Ereignisnamen:

    ```
    in:request
    out:disconnect
    ```

-   Abkürzungen des vorderen und/oder hinteren Teils:

    ```
    in:req
    out:disc
    i:r
    o:d
    ```

-   Wildcards für den vorderen Teil (Richtung), den hinteren oder beide:

    ```
    *:req
    ou:*
    *
    ```

-   Listen dieser Bestandteile (mit Komma getrennt (Vorsicht, kein
    Whitespace); die Regel passt, wenn einer der Teile passt):

    ```
    in:req,out:*
    ```

## Beispiele:

Verpasster Anruf (in:cancel) mailmessage an mehrere Email Adressen
versenden:

```
in:cancel ^ ^ mailmessage -t user1@example.com,user2@example.com
```

Von einer bestimmten Rufnummer (0401234567) eine festgelegte Rufnummer
(0401234568) anrufen und den PC über WOL (Wake on Lan) einschalten:

```
in:request ^0401234567 ^0401234568 ether-wake -i eth0 00:13:DE:01:A4:DE
```

Benachrichtigungen über Dreambox mit Enigma2 auf Fernseher anzeigen:

```
in:request ^ ^ dream2message --user=root --pass=dreambox 192.168.178.104
```

Benachrichtigung per Email bei Faxempfang:

```
in:disconnect ^ 0401234567$ mailmessage -s "Faxeingang von $SOURCE"
```

## Ereignisse

Ein erfolgreicher eingehender Anruf erzeugt nacheinander folgende
Ereignisse (analog für ausgehende Anrufe mit `out:*`):

1.  in:request
2.  in:connect
3.  in:disconnect

Ein Anruf, der abgebrochen wird, bevor die Gegenseite ihn annimmt,
erzeugt folgende Ereignisse:

1.  in:request
2.  in:cancel

Die Ereignisse sind nicht direkt die Rohereignisse, wie sie an der
JFritz-Schnittstelle (Port 1012) sichtbar sind, sondern entstehen aus
diesen (bei gleicher ID) mit Hilfe eines endlichen Automaten (an den
Kanten sind oben die Eingangsereignisse angegeben, unten die
Ausgangsereignisse; das Ereignis `in:accept` wird nur intern benutzt):

[![[CallMonitor: Ereignisse]](../../docs/screenshots/36_md.png)](../../docs/screenshots/36.png)


## Aktionen

Aktionen werden anhand von Regeln ausgeführt, die in den sogenannten
Listeners definiert sind. Dabei kann beliebiger
der FritzBox bekannter Shell-Code (Programme/Befehle) ausgeführt werden.
Die Aktionen müssen im Listener als Parameter <action> übergeben
werden (siehe Beispielbild unten für die Aktion *dboxpopup*), wobei
Umgebungsvariablen mit Informationen über den auslösenden Anruf
verwendet werden können.

Einige Standardfunktionen werden direkt vom callmonitor bereitgestellt
und sind im Folgenden beschrieben. Mit dem Script *callaction* lassen
sich alle Callmonitor-Aktionen von außerhalb (z.B. von der Kommandozeile
zum Testen) aus aufrufen.

Wenn man in Verbindung mit *checkmaild* neu eingetroffene Emails auf
einem VDR ausgeben will, kann man das machen, indem man die Datei
`/var/mod/etc/maillog.cfg` z.B. wie folgt anlegt:

```
    #!/bin/sh
    # neue Email empfangen
    if [ "$1" = "0" ];
    then
       callaction vdr m741 "Am $6 um $7 Uhr schrieb $8: $9"
    fi
```

Hintergrundinfos zur Datei `maillog.cfg` und dem checkmaild Paket kann
man auch hier im Wiki unter [checkmaild](../checkmaild/README.mk)
nachlesen.

## Benachrichtigen

Benachrichtigungen sind dafür da, eingehende und/oder verpasste Anrufe
über verschiedene Kommunikationswege und auf verschiedenen Geräten zu
signalisieren.

Die vorgegebenen Standardtexte der Funktionen können an die eigenen
Bedürfnisse angepasst werden.

Funktionen, die auf getmsg basieren:

-   DGStation Relook 400S
-   DBox
-   DreamBox
-   XBox
-   Freecom MusicPal

Falls nötig, können beim Aufruf auch Passwörter und Benutzernamen
angegeben werden.

Funktionen, die auf rawmsg basieren:

-   SoundBridge von Roku
-   VDR
-   YACwiki}: Yet Another Caller ID Program

Benachrichtung auf ganz anderem Wege:

-   mailmessage: Benachrichtigung per Mail
-   Samsung TV: Benachrichtigung
    SOAP-Nachricht
-   Snarl: Benachrichtigung für Snarl

## Wählen, Wecken, Konfigurieren

-   Wählhilfe: Ansprechen der Wählhilfe der
    FritzBox
-   WOL}: Wake on LAN
-   Fritz!Box-Konfiguration: WLAN, SIP,
    Portforwarding ein- und ausschalten

## Eigene Aktionen

Mit den beiden Basisfunktionen *getmsg* und *rawmsg* können auf den
Zielmaschinen nahezu beliebige Funktionen ausgeführt werden --- sofern
sie dort entsprechend realisiert sind (Start über den Webserver oder
Lauschen an einem TCP-Port).

-   getmsg: HTTP-GET-Requests
-   rawmsg: Nachrichten über "rohe"
    TCP-Verbindungen
-   Aufruf: Hinweise zu Funktionsaufrufen

Auch andere, selbst-definierte Aktionen sind möglich:

-   Selbst-definierte Aktionen

## Third-Party Software

CallMon2: auf Windows und Linux laufendes Perl-Skript,
[http://zephyrsoftware.sf.net/](http://zephyrsoftware.sourceforge.net/?q=fritzbox/callmon2)
(dort genaue Informationen zum Einrichten des ganzen!)

## Telefonbuch (Callers)

Format:

```
<Rufnummer mit Vorwahl>` `<Name>(`;` <Adresse>)
```

Ergebnisse der Rückwärtssuche können hier
gespeichert werden für schnelleren Zugriff in der Zukunft; natürlich
können auch von Hand Nummer-Name-Paare eingetragen oder geändert werden

-   49er-Rufnummern (ohne 00, länger als 10 Zeichen) werden erkannt
-   Name des Angerufenen steht zur Verfügung (vor allem für SIP0 bis
    SIP9); man kann die Zuordnung zu Namen im Telefonbuch (Callers)
    vornehmen, entweder direkt für SIP0 bis SIP9 oder für Adressen der
    Form "username@registrar" (das zweite hat den Vorteil, dass man
    im Telefonbuch nichts anpassen muss, wenn man seine SIP-Accounts in
    anderer Reihenfolge einträgt). Beim Start werden Kurznamen für alle
    Accounts generiert und als Vorgabe in die Callers eingetragen.
-   Suchstrategie: Erst Nummer unverändert in den lokalen Telefonbüchern
    (Callers, AVM-Telefonbuch) nachschlagen, dann normalisieren (evtl.
    Orts- /Landesvorwahl davor; SIP[0-9] wird zu username@registrar)
    und noch einmal lokal probieren. Dann erst über Rückwärtssuche im
    Internet probieren.

[![[Callmonitor Callers]](../../docs/screenshots/216_md.png)](../../docs/screenshots/216.png)


## HTTP-Requests (getmsg)

Die Funktion `getmsg` sendet eine Benachrichtigung, indem sie diese per
HTTP GET an einen Webserver schickt. Es ist möglich, die URL (nur Pfad +
Query-String, also den Teil hinter dem Host-Namen) mit
[printf-Templates](http://www.gnu.org/software/libc/manual/html_node/Formatted-Output.html))
anzugeben. Im einfachsten Fall bedeutet dies, dass die Stelle in der
URL, an der die Nachricht eingesetzt werden soll, mit `%s` markiert
wird. `getmsg` sorgt selbst für die richtige Kodierung der Nachrichten
(URL Encoding).

## Syntax:

```
  Usage:  getmsg [OPTION]... <HOST> <url-template> [<message>]...
          getmsg [OPTION]... -t <url-template> <host> [<message>]...
  Send a message in a simple HTTP GET request.

    -t, --template=FORMAT  use this printf-style template to build the URL,
                           all following messages are URL-encoded and filled
                           into this template
    -d, --default=CODE     default for first parameter (eval'ed later)
    -p, --port=PORT        use a special target port (default 80)
    -w, --timeout=SECONDS  set connect timeout (default 3)
    -v, --virtual=VIRT     use a different virtual host (default HOST)
    -U, --user=USER        user for basic authorization
    -P, --password=PASS    password for basic authorization
        --help             show this help
```

Die **folgenden Funktionen basieren** auf `getmsg` und unterstützen daher
dieselben Optionen. Passend für den entsprechenden Empfänger sind
URL-Template (`-t`), die Standard-Nachricht (`-d`) und der Port (`-p`)
schon vorbelegt.

## Beispiel:

```
*:* ^ ^ getmsg 192.168.0.111 -p 222 -t "/home/phone?event=%s&id=%s&time=%s&source=%s&source_name=%s&destination=%s&destination_name=%s&extension=%s&duration=%s&provider=%s" "${EVENT}" "${ID}" "${TIMESTAMP}" "${SOURCE}" "${SOURCE_NAME}" "${DEST}" "${DEST_NAME}" "${EXT}" "${DURATION}" "${PROVIDER}"
```

Das obere Beispiel bewirkt einen GET-Aufruf an
[http://192.168.0.111:222/home/phone](http://192.168.0.111:222/home/phone)
mit allen relevanten Daten im Query-String.


## DBox2

## DBox2 mit Neutrino Image

```
  dboxmessage (default_dboxmessage)
  dboxpopup (default_dboxpopup)
```

Die Funktion unterscheiden sich nur darin, ob die angezeigte Nachricht
von alleine nach einiger Zeit verschwindet oder explizit bestätigt
werden muss.

default_dboxmessage und default_dboxpopup haben die Funktion default_dbox
als gemeinsame Grundlage.

```
  dboxlcd (default_dboxlcd)
```

Stellt eine Nachricht auf dem LCD der DBox dar.

## DBox2 mit Enigma Image

Wenn ihr ein Enigma Image auf eurer Box habt und im Popup vor dem
eigentlichen Text ein "popup=" oder "nmsg=" erscheint, so könnt ihr
wie bei der Dreambox folgenden Befehl nutzen:

```
  dreammessage (default_dreammessage)
```


## Wählhilfe

Die aus dem Webinterface von AVM bekannte Wählhilfe steht hier als
Funktion zur Verfügung (seit Callmonitor 1.1).

```
dial NUMMER [PORT]
```

Das erste Argument ist die zu wählende Nummer, das zweite (optional) der
Port (1, 2, 3, 50, 51, ...), natürlich ohne die eckigen Klammern.

Die Ports 1 bis 3 sind die analogen Telefonen, 50 alle ISDN-Telefone, ab
51 die einzelnen ISDN-Telefone.

Auflegen ist auch möglich (seit Callmonitor 1.5):

```
hangup [PORT]
```


## Selbstdefinierte Aktionen

Eigene Aktionen können als Shell-Funktionen in einer oder mehreren
Dateien `/tmp/flash/callmonitor/actions.local.d/*.sh` abgelegt werden.
(Es können so auch Standard-Funktionen überschrieben werden, z.B.
`default_message()`)

Natürlich können auch beliebige externe Programme aufgerufen werden.

## Benutzernamen und Passwörter

Alle Aktionen, die auf `getmsg` basieren, verstehen folgende Optionen,
mit denen man Benutzername und Passwort für das Webinterface der Zielbox
angeben kann:

```
  -U USERNAME
  --user USERNAME
  -P PASSWORD
  --password PASSWORD
```

Außerdem können die Daten in einer Kurzschreibweise direkt beim
Hostnamen angegeben werden:

```
  USERNAME:PASSWORD@HOST:PORT
```

## Beispiel

Also zum Beispiel:

```
  dboxmessage john:secret@mydbox
```

Das bewirkt das gleiche wie

```
  dboxmessage --user=john --password=secret mydbox
```

oder

```
  dboxmessage -U john -P secret mydbox
```

Oder falls die D-Box auf einem anderen als dem Standardport lauscht:

```
  dboxmessage john:secret@mydbox:3818
  dboxmessage --user=john --password=secret --port=3818 mydbox
```


## Freecom MusicPal

Version 1.15.1 enthält die neue Aktion **musicalpalmessage**, mit der
man Nachrichten auf dem Display eines MusicPals von Freecom darstellen
kann. Es werden maximal zwei Zeilen unterstützt; die Anzeigedauer
(standardmäßig 25 Sekunden) kann über die Umgebungsvariable
MUSICPAL_TIMEOUT verändert werden. Für den Fall, dass die Anzeige
vorher freigegeben werden soll, steht die Aktion **musicalpalclear**
bereit.

Einige Beispiele:

```
    # Standardnachricht, Benutzername und Passwort "admin"
    musicpalmessage musicpal.domain.my

    # eigene Nachricht mit zwei Zeilen, andere Zugangsdaten
    musicpalmessage --user="root" --password="secret" musicpal.domain.my "Wichtiger Anruf${LF}von ${SOURCE}!"

    # alternative Syntax
    musicpalmessage root:secret@musicpal.domain.my "Wichtiger Anruf${LF}von ${SOURCE}"

    # Nachricht löschen
    musicpalclear musicpal.domain.my
```

Zum Anpassen der Standardnachricht kann die Shell-Funktion
`default_musicpalmessage` überschrieben werden.


## Roku SoundBridge

Die [Roku
SoundBridge](http://www.rokulabs.com/products_soundbridge.php)
kann auf ihrem Display Nachrichten darstellen. Seit Callmonitor 1.12.4
stehen drei Funktionen zur Ansteuerung zur Verfügung:

```
  sbmessage
  (default_sbmessage)
```

Zur Anzeige einer statischen Nachricht. Mit der Umgebungsvariable
`SB_TIMEOUT` kann die Dauer der Anzeige bestimmt werden.

```
  sbmarquee
  (default_sbmarquee)
```

Zur Anzeige eines Lauftexts. Mit der Umgebungsvariable `SB_TIMES` kann
festgelegt werden, wie oft die Nachricht wiederholt werden soll.

```
  sbxmessage
  (default_sbxmessage)
```

Zur Anzeige einer statischen, mehrzeiligen Nachricht. Mit der
Umgebungsvariable SB_TIMEOUT kann die Dauer der Anzeige bestimmt
werden.


## VDR

VDR: Video Disk Recorder,
[http://www.cadsoft.de/vdr/](http://www.cadsoft.de/vdr/)

```
  vdr [OPTION]... [MESSAGE]
  (default_vdr)
```

## Benachrichtigung auf einem Samsung TV

Die Funktion `samsung` verschickt eine Benachrichtigung über einen
Telefonanruf mit Hilfe der SOAP-Methode an ein Samsung TV:

```
samsung {IP des TV}
```

Also z.B.:

```
samsung 192.168.178.19
```

Es werden der Anrufer-Name (sofern im Telefonbuch oder in den Callers
eingetragen, ansonsten die Telefonnummer), die angerufene Nummer, sowie
Datum und Uhrzeit angezeigt. Die Länge der darstellbaren Zeichen hängt
vom Inhalt ab. Wenn nicht mehr Text angezeigt werden kann (z.B. bei
Adresszusätzen in den Callers), wird er am Ende abgeschnitten, so dass
er mit "..." endet.

Der Listener-Eintrag im Callmonitor kann dazu z.B. so aussehen:

```
in:request ^ ^ samsung tv
```

Zum Testen kann man folgendes direkt vom Terminal der Fritzbox
ausführen:

```
callaction samsung tv
```

Die Funktion `samsung_text` verschickt eine Nachricht mit Hilfe der
SOAP-Methode an ein Samsung TV, z.B.:

```
echo "Hello, world!" | callaction samsung_text 192.168.178.19 \
--from="Absender" --from-number="069 123456" \
--to-number="089 987654" --to="Empfänger" \
--date="2010-05-21" --time="21:56:00"
```

Analog zum obigen Beispiel werden hier Anrufer-Name und dessen
Telefonnummer, Empfänger-Name und dessen Telefonnummer sowie Datum und
Uhrzeit angezeigt. D.h. die Nachricht wird mit derselben Methode (SOAP)
wie bei der Benachrichtigung über einen Telefonanruf verschickt, zzgl.
der o.g. Daten.

## Snarl

[Snarl](http://www.fullphat.net/index.php) ist
ähnlich wie Growl, welches einigen vielleicht bekannt ist, ist ein
Benachrichtigungs-Programm ("notification"), welches im Hintergrund
läuft und von verschiedenen Programmen etc. angesprochen werden kann.
Vorteil ist, dass man so benutzerdefinierte, systemweit einheitliche
Benachrichtigungen erhält.

Snarl verwendet ein eigenes Protokoll, welches sich SNP
([Snarl Network
Protocol](http://www.fullphat.net/dev/snp/index.htm)) nennt.

Mittels "rawmsg" wird an eine IP (Port 9887) im Netzwerk, an dem Snarl
wiederum selbst lauschen muss, eine Nachricht gesendet. Snarl zeigt
diese vom Callmonitor über SNP übermittelte Benachrichtigung dann an.

Also z. B. so:

```
echo -n "type=SNP#?version=1.0#?action=notification#?title=Anruf#?text=${SOURCE}#?timeout=20"$'\r\n' | nc IP 9887
```

(buehmann hat in diesem
[Thread](http://www.ip-phone-forum.de/showthread.php?t=216938)
gezeigt, wie es geht. Danke!)

## Listener-Eintrag:

Der Listener-Eintrag im Callmonitor kann dazu z.B. so aussehen:

```
in:request ^ ^ echo -n "type=SNP#?version=1.0#?action=notification#?title=eingehender Anruf#?text=von ${SOURCE} - ($SOURCE_NAME)${LF}für ${DEST_NAME} - (${DEST_DISP})${LF}#?timeout=20#?icon=C:\pic.png"$'\r\n' | nc 192.168.178.20 9887
```

## Screenshots:

So könnte eine Benachrichtung von Snarl dann aussehen. Die Angaben
betreffend Anrufer, Rufnummer, Ereignis etc., lassen sich ja mittels des
Callmonitor entsprechend anpassen bzw. erweitern.

> [![[Snarl Beispiel]](../../docs/screenshots/171_md.png)](../../docs/screenshots/171.png)
>
> [![[Snarl Beispiel]](../../docs/screenshots/167_md.png)](../../docs/screenshots/167.png)
>
> [![[Snarl Beispiel]](../../docs/screenshots/173_md.png)](../../docs/screenshots/173.png)

> Wichtig: "Curl" oder "getmsg" können [nicht] benutzt
> werden, diese sind nur für das HTTP (Protokoll) geeignet und
> funktionieren nicht mit dem SNP von Snarl.


## XBox

Für diese Funktion muss das [XBox Media Center
(XBMC)](http://www.xboxmediacenter.com) laufen und dort unter
*Einstellungen → Netzwerk* der Webserver aktiviert werden. Ggf. mit den
Optionen (s.o.) Port, Username und Passwort übergeben. Das XBMC stellt
die Nachricht dann in einem kleinen Fenster dar, das automatisch
geschlossen wird.

```
  xboxmessage (default_xboxmessage)
```

Die XBox erlaubt mit `xboxmessage` keine Kommas in den Nachrichten. Der
Titel der Nachricht kann über die Umgebungsvariable
`XBOX_CAPTION="Telefonanruf"` beeinflusst werden.

## Anpassungen auf der XBox

Anzeigedauer und Größe des Fensters können in der Datei
`DialogKaiToast.xml` angepasst werden. Je nach gewähltem TV-Typ ist die
jeweilige Datei unter `skin\Project Mayhem III\PAL\` oder
`skin\Project Mayhem III\PAL16x9\` zuständig. Folgende Überarbeitung der
"PAL"-Datei erreicht ein brauchbares Ergebnis (nur geänderte Zeilen):

```
...
  <coordinates>
    <system>1</system>
    <posx>275</posx>
    <posy>420</posy>
  </coordinates>
  <animation effect="slide" time="5000" start="300,0">WindowOpen</animation>
  <animation effect="slide" time="5000" end="300,0">WindowClose</animation>
...
    <control>
      <description>Popup Kai Toast Dialog Background</description>
      ...
      <width>400</width>
      <height>125</height>
...
    <control>
      <description>avatar</description>
      ...
      <posx>40</posx>
      <posy>25</posy>
...
    <control>
      <description>Caption Label</description>
      ...
      <posx>46</posx>
      <posy>30</posy>
      <width>305</width>
...
    <control>
      <description>Description Button</description>
      ...
      <posx>46</posx>
      <posy>46</posy>
      <width>305</width>
...
```

## Weitere Möglichkeiten

Es gibt außerdem einen
[Python-Script](http://ca.geocities.com/farside@rogers.com/Scripts/callerid.html),
das eine CallerID-Anzeige auf der Xbox ermöglicht. Dann kann die
Nachricht mit der Funktion `yac` an die XBox gesendet werden. Das Script
ist auch im Script
[xbmcfritz](http://www.xbmc.de/xbmc/download.php?view.150)
enthalten, das zusätzlich die Anruferliste der FritzBox auf der XBox
darstellen kann.


## YAC

YAC: Yet Another Caller ID Program,
[http://sunflowerhead.com/software/yac/](http://sunflowerhead.com/software/yac/)

Syntax:

```
  yac <IP>
    IP       IP des Rechners, auf dem der YAC-Listener läuft
```


## Allgemeine Hinweise zu Funktionsaufrufen

Der Aufruf von Funktionen, die auf getmsg oder rawmsg basieren,
sieht immer so aus:

```
  foomessage [OPTION]... <host> [<message>]...
```

Der einfachste und am meisten genutzte Fall ist dementsprechend

```
  foomessage <host>
```

Als Optionen können alle Optionen verwendet werden, die auch
getmsg bzw. rawmsg verstehen.

Die Standard-Nachricht wird generell von einer Funktion mit der
Namenskonvention `default_foomessage` erzeugt und kann so einfach
überschrieben wird.

Bei den Funktionen können eventuell Umgebungsvariablen verwendet werden.
Diese werden vor dem Funktionsaufruf gesetzt. Der Callmonitor sorgt
automatisch für die Kodierung der Umgebungsvariablen, die Text enthalten
(z.B. `XBOX_CAPTION` und `DREAM_CAPTION`). Man kann also einfach

```
  FOO_CAPTION="Dies ist der zu 100% richtige Titel" foomessage <host>
```

schreiben, ohne sich Gedanken über Kodierungen (URL- oder printf-)
machen zu müssen.

## FritzBox-Konfiguration

Mit der Aktion `config` aus der `config.sh` (seit Callmonitor 1.8)
lassen sich einige Funktionen in der Konfiguration der FritzBox
umstellen.

## Portforwarding

Das Portforwarding kann aktiviert und deaktiviert werden.

```
Syntax:
  config forward <NUMMER> <on|off|toggle>

    NUMMER                 Nummer des Portforwardings (beginnend bei 1)
    on|off|toggle          an- bzw. abschalten des Portforwardings: an, aus,
                           an-/abschalten des Forwardings abhängig der bereits
                           erfolgten Einstellung
```

Beispiele:

```
    config forward 1 on     # 1. Portforwarding aktivieren
    config forward 3 off    # 3. Portforwarding deaktivieren
    config forward 5 toggle # 5. Portforwarding an-/abschalten
```

## WLAN

Das WLAN kann aktiviert und deaktiviert werden.

```
Syntax:
  config wlan [2.4|5|guest] <on|off>

    2.4|5                  gewünschtes Frequenzband: 2,4 oder 5 GHz
    guest                  Gast-WLAN schalten (seit Version 1.20.1)
    on|off                 an- bzw. abschalten des WLANs
```

Fehlt die Angabe des Frequenzbandes, werden beide geschaltet, aber nur
das 2,4er abgefragt.

Beispiele:

```
    config wlan off      # WLAN aus
    config wlan on       # WLAN an
    config wlan 2.4 off  # WLAN im 2,4-GHz-Band aus
    config wlan 5 on     # 5-GHz-WLAN an
```

## DECT

DECT kann aktiviert und deaktiviert werden.

```
Syntax:
  config dect <on|off>

    on|off                 an- bzw. abschalten der DECT-Hardware
```

Beispiele:

```
    config dect off      # DECT aus
    config dect on       # DECT an
```

## SIP

Die SIP-Accounts können aktiviert und deaktiviert werden.

```
Syntax:
  config sip <NUMMER> <on|off>

    NUMMER                 Nummer des SIP-Accounts (beginnend bei 1)
    on|off                 an- bzw. abschalten des SIP-Accounts
```

Beispiele:

```
    config sip 4 on      # 4. SIP-Account aktivieren
    config sip 2 off     # 2. SIP-Account deaktivieren
```

## Rufumleitung

(De-)Aktivierung der Rufumleitungen. (Seit Version 1.8.2) Unterstützt
werden momentan nur Rufumleitungen des Typs "Anrufe von Rufnummer xy",
nicht aber "Alle Anrufe an Fon X".

```
Syntax
  config diversion <NUMMER> <on|off>

    NUMMER                 Nummer der Rufumleitung (beginnend bei 1)
    on|off                 an- bzw. abschalten der Rufumleitung
```

## Abfragen von Konfigurationswerten

(seit Version 1.9.1)

Einfach beim config-Aufruf den Wert weglassen:

```
    config sip 2
    config diversion 1
    config forward 3
    config wlan
```

Ausgabe ist einer der Werte "on", "off" oder "error" (wenn z.B.
die Wahlregel nicht existiert).

## Alternative

In neueren Firmware-Versionen ist der Callmonitor nicht unbedingt
erforderlich, um die Funktionen anzuzeigen oder zu ändern. Alternativ
lassen sich diese mit dem
[ctlmgr_ctl](http://wehavemorefun.de/fritzbox/index.php/Ctlmgr_ctl)
von AVM bearbeiten.


## DreamBox

## Dreambox mit Enigma 1

```
  dreammessage [user[:password]@]host[:port] ["Alternative Nachricht"]
```

[![[CallMonitor: Dreambox Auth abschalten]](../../docs/screenshots/1_md.jpg)](../../docs/screenshots/1.jpg)

Wie zu sehen ist, ist "host" (also Rechnername oder IP-Adresse) der
einzige Pflichtparameter. Damit die Nachricht aber auch wirklich
ankommt, muss die Authentifizierung berücksichtigt werden. Eine Lösung
ist es, wie beigefügter Screenshot aufzeigt, das Abschalten der
Nachrichten-Authentifizierung auf der Box selbst. Wer das nicht will,
dem bleibt zur Zeit nur, `user:password@` vor den Host zu setzen - was
dann allerdings bei den Listeners im Klartext angezeigt wird.

`dreammessage` kennt ein Standard-Nachrichten-Template, was
normalerweise verwendet wird. Wer die Nachricht lieber selbst
formatieren will, findet bei den Listeners eine Liste mit
verwendbaren Platzhaltern für Telefonnummer, Zeilenumbrüche, usw.

Desweiteren gibt es drei Umgebungsvariablen, die das Verhalten von
`dreammessage` beeinflussen. Sie sind hier in einem typischen Aufruf mit
ihren Standardwerten gezeigt:

```
  DREAM_TIMEOUT=10 DREAM_CAPTION="Telefonanruf" DREAM_ICON=1 dreammessage box1
```

##  StandBy Check

Befindet sich die zu benachrichtigende Dreambox im StandBy, werden die
Nachrichten solange zwischengespeichert, bis sie wieder aus selbigem
aufwacht. An und für sich ganz nett - nur wenn man sie gerade mal ein
paar Tage nicht benutzt hat, und dann nach dem Anschalten erstmal
hunderte von "verpassten" Anrufen zu sehen bekommt. Daher wäre es für
manchen sicher praktisch, würden die Nachrichten nur dann (und zwar
sofort) zugestellt, wenn die Dreambox sich zum Zeitpunkt des Anrufes
*nicht* im StandBy befindet - während andernfalls die Benachrichtigung
komplett unterbliebe.

Glücklicherweise ist das machbar (getestet mit DM600, DM 7000 und
DM7020). Auf folgende Weise lässt sich nämlich der Status ermitteln:

```
    # keine Passwort-Authentifizierung aktiv:
    standby=`wget -O- "http://dreambox/cgi-bin/status" | awk '/Standby/' | sed -e 's/<[^>]*>//g'`
    # mit Passwort-Authentifizierung:
    standby=`wget -O- --http-user=root --http-passwd=dreambox "http://dreambox/cgi-bin/status" | awk '/Standby/' | sed -e 's/<[^>]*>//g'`
```

Je nachdem, ob das WebIF für Passwort-Authentifizierung konfiguriert ist
oder nicht, kann man also die entsprechende Variante nutzen. Das
busybox-wget unterstützt allerdings keine Authentifizierung. Daher muss
beim Bauen von freetz das Paket 'wget' installiert werden. Die
Variable `$standby` ist anschließend entweder mit `STANDBY:ON` oder
`STANDBY:OFF` belegt. Für unsere Benachrichtigungs-Aktion können wir uns
das wie folgt nutzbar machen:

```
    [ "$(wget -O- "http://dreambox/cgi-bin/status" | awk '/Standby/' | sed -e 's/<[^>]*>//g')" = "Standby:OFF" ] && DREAM_TIMEOUT=10 dreammessage dreambox "${SOURCE_DISP} ruft an.${LF}${SOURCE_NAME}"
```

wobei natürlich *dreambox* mit dem Hostnamen bzw. der IP-Adresse der
Dreambox ersetzt, sowie ggf. die Passwort-Authentifizierung mit
eingebaut werden muss.

*Quelle: [IPPF
Thread](http://www.ip-phone-forum.de/showthread.php?t=100706&page=55)*

## DreamBox mit Enigma 2

```
  dream2message (default_dream2message)
```

`DREAM_TIMEOUT` und `DREAM_ICON` werden auch hier unterstützt.

Beispiel für ein Popup das nur den Namen (sofern in der Callers
vorhanden) und die Telefonnummer des Anrufers anzeigt:

```
in:request ^ ^ dream2message 192.168.178.25 "${SOURCE_NAME} ${SOURCE} ruft an."
```


## E-Mail-Benachrichtigung

Die Funktion `mailmessage` verschickt eine E-Mail mit Hilfe der Daten,
die für den Push-Service eingerichtet sind (falls man nicht beim Aufruf
etwas anderes befiehlt (mailer-Optionen)). Der Push-Service selbst kann
ruhig ausgeschaltet bleiben, wichtig sind die Einstellungen für
Adressen, Mailserver & Co. Beispiele zum Einsatz in Listeners:

```
mailmessage
mailmessage -t me@my.self
mailmessage -s "Oh, oh ... ($SOURCE)"
```

-   Mailadressen, Servereinstellungen, Passwörter & Co. werden aus der
    Konfiguration des Push Service der FritzBox übernommen. Einzelne
    Teile können durch Optionen überschrieben werden (im Beispiel zum
    Beispiel die Zieladresse mit `-t`).
-   Die Optionen werden an `mail` durchgereicht; diese wiederum
    größtenteils an `mailer`. Deswegen können folgende Optionen
    verwendet werden:

    ```
      -s STRING          - Subject. ("FRITZ!Box")
      -f STRING          - From. (NULL)
      -t STRING          - To. (NULL)
      -m STRING          - mailserver. (NULL)
      -a STRING          - authname. (NULL)
      -w STRING          - passwd. (NULL)
      -d STRING          - attachment. (NULL)
      -i STRING          - inline attachment. (NULL)
    ```

-   Zur Anpassung der Mails: siehe `mail_subject` und `mail_body` in
    `mail.sh` (zum Überschreiben am besten
    `/tmp/flash/callmonitor/actions.local.d/` verwenden, siehe Anpassen
    der Benachrichtigungstexte).

## mail

`mail` ist ein Skript, um Mails bei Mailserverfehlern
zwischenzuspeichern und erneut zu schicken (alle Parameter und
Attachments werden gepackt in `/var/spool/mail/` abgelegt).

-   Es wird von der Aktion mailmessage verwendet.
-   Ihr solltet regelmäßig (mit cron) ein `mail process` ausführen, um
    evtl. wartende Mail zu versenden.
-   `mail` gehört streng genommen nicht unbedingt zum Callmonitor, weil
    auch andere Dienste es brauchen könnten; vielleicht wird in Zukunft
    mal ein eigenes Paket daraus.

## Ersatz für mail_missed_call

Die Funktion `mail_missed_call` existiert seit Version 1.0 nicht mehr.
An ihre Stelle tritt eine allgemeine Benachrichtigungsfunktion per
E-Mail (`mailmessage`), die (auch) in Kombination mit dem Ereignis
`in:cancel` genutzt werden kann, um bei verpassten Anrufen eine Mail zu
verschicken:

```
in:cancel   ^   ^   mailmessage
```

Das schöne ist, dass die Mail sofort rausgeschickt wird, wenn der
Gesprächspartner aufgibt; es gibt keine Wartezeit von einer Minute mehr
wie in den Vorversionen. Außerdem kann jetzt zuverlässiger bestimmt
werden, wann ein Anruf verpasst wurde.

Aber natürlich kann man sich so auch per Mail über alle eingehenden
Anrufe informieren lassen, oder über alle ausgehenden an eine bestimmte
Nummer oder oder oder ...


## DGStation Relook 400S

Die [DGStation Relook
400S](http://www.dgstation.co.kr) unterstützt nur die Anzeige
einer kurzen Zeile ohne Umlaute. Die Anzeigedauer kann über die
Umgebungsvariable `RELOOK_TIMEOUT` beeinflusst werden (in Sekunden).

```
  relookmessage (default_relookmessage)
```

Beispiel für Benutzung mit veränderter Anzeigedauer (25 Sekunden):

```
  RELOOK_TIMEOUT=25 relookmessage 192.168.34.56
```


## Einfache TCP-Verbindungen (rawmsg)

```
  Usage: rawmsg [OPTION]... <HOST> <template> [<param>]...
         rawmsg [OPTION]... -t <template> <host> [<param>]...
  Send a message over a plain TCP connection.

    -t, --template=FORMAT  use this printf-style template to build the message,
                           all following parameters are filled in
    -d, --default=CODE     default for first parameter (eval'ed later)
    -p, --port=PORT        use a special target port (default 80)
    -w, --timeout=SECONDS  set connect timeout (default 3)
        --help             show this help
```

Die **folgenden Funktionen basieren** auf `rawmsg` und unterstützen daher
dieselben Optionen. Passend für den entsprechenden Empfänger sind
URL-Template (`-t`), die Standard-Nachricht (`-d`) und der Port (`-p`)
schon vorbelegt.


## Wake on LAN

Zum Aufwecken eines Rechners im LAN --- sofern der Rechner dies generell
unterstützt --- dient das in Freetz
vorhandene Programm `ether-wake`. Zur Benutzung sei auf dessen
Online-Hilfe verwiesen:

```
Usage: ether-wake [-b] [-i iface] [-p aa:bb:cc:dd[:ee:ff]] MAC

Send a magic packet to wake up sleeping machines.
MAC must be a station address (00:11:22:33:44:55) or
    a hostname with a known 'ethers' entry.

Options:
        -b              Send wake-up packet to the broadcast address
        -i iface        Use interface ifname instead of the default "eth0"
        -p pass Append the four or six byte password PW to the packet
```


## Wartung

Die Wartungsseite im Web-Interface ermöglicht folgendes:

-   Telefonbuch aufräumen: Sortiert die Einträge im Telefonbuch und
    entfernt Leerzeilen.
-   SIP-Update durchführen: Erstellt Standardeinträge im Telefonbuch für
    neu angelegte Internetrufnummern.
-   Callmonitor-Schnittstelle (Port 1012) (de)aktivieren: Aktiviert bzw.
    deaktiviert die Callmonitor-Schnittstelle an Port 1012. Der
    Callmonitor funktioniert nur mit aktivierter Schnittstelle.

Die Wartungsseite findet man im Freetz Webinterface unter *Extras ⇒
Wartung*.

[![[Callmonitor: Wartung]](../../docs/screenshots/24_md.png)](../../docs/screenshots/24.png)


## Rückwärtssuche

Die Rückwärtssuche wird in der Basiskonfiguration
des Callmonitors eingestellt. Sie wird bei einem der folgenden Dienste
durchgeführt:

-   [http://telefonbuch.de/](http://telefonbuch.de/)
-   [http://inverssuche.de/](http://inverssuche.de/)
-   [http://goyellow.de/](http://goyellow.de/)
-   [http://11880.com/](http://11880.com/)
-   [http://www.dasoertliche.de/](http://www.dasoertliche.de/)
-   [http://tel.search.ch/](http://tel.search.ch/)
-   [http://www.das-telefonbuch.at/](http://www.das-telefonbuch.at/)
-   [http://www.anywho.com/](http://www.anywho.com/)

Optional kann eine zusätzliche Suche bei Google nach dem Ortsnetz des
Anrufers durchgeführt werden. Das Ergebnis dieser Suche wird nur
verwendet, wenn die volle Rückwärtssuche kein Ergebnis liefert.

-   Bei ausgehenden Anrufen wird für die angerufene Nummer ggf. eine
    Anfrage durchgeführt, nicht für die eigene.
-   Rückwärtssuche mit dauerhaftem (im Flash), flüchtigen (im RAM) oder
    ohne Caching möglich

[![[Callmonitor: Rückwärtssuche]](../../docs/screenshots/23_md.png)](../../docs/screenshots/23.png)


## Testanruf

Nachdem die Listeners definiert sind, empfiehlt
es sich, sie auf korrekte Funktion zu testen. Da man nicht immer jede
Konfiguration mit echten Anrufen testen kann, gibt es eine Seite im
Web-Interface, die Anrufe simuliert. Dabei klingeln keine Telefone, es
wird lediglich dem CallMonitor ein Anruf vorgetäuscht, den er wie einen
echten Anruf behandelt.

[![[Callmonitor: Testanruf]](../../docs/screenshots/22_md.png)](../../docs/screenshots/22.png)


Die Maske sollte weitgehend selbsterklärend sein. Unter "Ereignis"
kann man einstellen, welches Ereignis
simuliert werden soll. Die Quellrufnummer ist diejenige, von der dieses
Ereignis ausgeht und die Zielrufnummer diejenige, die das Ziel des
Ereignisses ist. Man gibt jeweils ein Ereignis mit Rufnummern ein, die
zu einem in den Listeners definierten Muster passen. Nach einem Klick
auf "Testanruf" sollte der Callmonitor nun die zu diesem
Listener-Eintrag gehörende Aktion ausführen. Im Webinterface werden die
Debug-Informationen des Callmonitors angezeigt, die bei einer
eventuellen Fehlersuche helfen.


## Callmonitor-FAQ

- Kann ich das Ergebnis der Rückwärtssuche auch auf meinem DECT-Telefon sehen?

Nein. Es gibt momentan keine bekannte Möglichkeit, in die
Anrufsignalisierung über DECT einzugreifen.


## Anpassen der Benachrichtigungstexte

Um den Inhalt einer Benachrichtigung an die eigenenen Bedürfnisse
anpassen, gibt es folgenden Weg:

1.  Verzeichnis `/tmp/flash/callmonitor/actions.local.d` erstellen
2.  darin eine Datei `foobar.sh` anlegen (oder irgendetwas anderes mit
    Endung `.sh`)
3.  dorthinein nur die zu überschreibende Funktion kopieren (z.B.
    `mail_body() { ... } `) und anpassen (oder nur Variablen setzen wie
    z.B. `RELOOK_TIMEOUT`)
4.  `modsave flash` aufrufen, um die Datei im Flash zu sichern
5.  Callmonitor neustarten

Bei den meisten Aktionen ist eine Funktion
`default_foomessage` vorgesehen, die die Standardnachricht für diesen
Typ Aktion erzeugt; diese Funktion kann also einfach überschrieben
werden. Bei mailmessage mail gibt es z.B.
`mail_subject` und `mail_body`; bei anderen Aktionen hilft nur ein Blick
in den Quelltext (oder eine Nachfrage), solange bis deren Funktionen
auch im Wiki beschrieben sind.



