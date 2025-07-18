# SANE 1.0.27 - DEPRECATED
  - Package: [master/make/pkgs/sane-backends/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/sane-backends/)
  - Maintainer: -

### Beschreibung

Dieses Paket ermöglicht den Betrieb von Scannern an der Fritz!Box. Diese
können dann wie Drucker von allen Rechnern im lokalen Netzwerk genutzt
werden. Ebenso ist es damit möglich, Scanner direkt von der Fritz!Box
aus zu nutzen (z.B. in Scripts).

### Schnellstart

### Installation und Konfiguration

-   make menuconfig
-   Sicherstellen, daß im Hauptmenü `Show advanced options` und unter
    `Package selection` `Unstable` ausgewählt sind
-   Im Hauptmenü zu `Package selection` → `Unstable` → `SANE` wechseln
    und `SANE` auswählen
-   Empfehlung: `sane-find-scanner` und `scanimage` auswählen. (Diese
    sind nicht notwendig für den Betrieb, aber hilfreich, falls das
    Scannen im nächsten Schritt nicht funktioniert. Wenn einmal alles
    klappt, kann man die beiden Punkte wieder abwählen um Speicherplatz
    zu sparen (~150kB) und ein neues Image erstellen)
-   Backend auswählen:
    -   Geräte von Hewlett-Packard (HP): Eine Ebene höher wechseln,
        HPLIP auswählen (HPLIP ist momentan nur im Trunk verfügbar) und
        dann `Printer Class` und `Printer Type` entsprechend auswählen
        (Hilfefunktion steht zur Verfügung)
    -   Für alle anderen Geräte (und sehr alte HPs): Über die
        [Liste unterstützter
        Geräte](http://www.sane-project.org/sane-mfgs.html)
        den Namen des Backends feststellen und auswählen.
-   Unter `Package selection` → `Standard packages` `Inetd` auswählen
    (wird in kommenden Versionen automatisch ausgewählt)
-   Image erstellen, flashen, neu starten

### Nutzung vom PC unter Linux/Windows

#### Linux

-   [XSane](http://www.xsane.org/) installieren
    (inkl. net-Backend)
-   `SANE_NET_HOSTS=fritz.box xsane` starten
    -   Tip: `/etc/sane.d/net.conf` um eine neue Zeile `fritz.box`
        erweitern, dann reicht es, nur `xsane` einzutippen.

#### Windows

-   Mit [SaneTwain](http://sanetwain.ozuzo.net/)
    kann man den Scanner aus allen Windows-Anwendungen heraus verwenden,
    die Scanner über die TWAIN-Schnittstelle unterstützen.
-   [XSane für
    Windows](http://www.xsane.org/xsane-win32.html)
    -   Die Sprache läßt sich so auf Deutsch ändern, indem man die
        Umgebungsvariable `LANG` auf `de` setzt. Z.B. Folgendes in
        xsane.bat:

        ``` 
        @echo off
        set LANG=de
        c:sanebinxsane.exe
        ```

### Scannen funktioniert nicht

Falls das Scannen wie in dieser Anleitung beschrieben nicht
funktioniert:

-   Auf der Box einloggen und dort schauen, ob `sane-find-scanner` das
    Gerät findet
    -   Falls man sich nicht an die Empfehlung gehalten hat,
        sane-find-scanner und scanimage ins Image aufzunehmen: Neues
        Image mit den beiden Tools erstellen und flashen
-   Falls kein Scanner gefunden wird, hat man schlechte Karten
-   Falls das geht, mit `scanimage -L` schauen, ob der Scanner
    aufgelistet wird. Falls es hier scheitert, stimmt mit dem Backend
    was nicht
    -   Manche Backends brauchen zusätzliche Anpassungen/Einstellungen,
        z.B. einen Firmware-Upload ⇒ man page zum Backend durchlesen
        (sind auch hier verlinkt:
        [http://www.sane-project.org/sane-mfgs.html](http://www.sane-project.org/sane-mfgs.html))
    -   Evtl. wird der Scanner unterstützt, aber die Version von SANE
        bzw. HPLIP in Freetz ist zu alt:
        [http://www.sane-project.org/sane-backends-1.0.19.html](http://www.sane-project.org/sane-backends-1.0.19.html)
        für Freetz 1.1.3, sonst unter
        [http://www.sane-project.org/sane-supported-devices.html](http://www.sane-project.org/sane-supported-devices.html)
        bzw.
        [http://hplipopensource.com/hplip-web/supported_devices/index.html](http://hplipopensource.com/hplip-web/supported_devices/index.html)
        schauen und **Versionen vergleichen**.
-   Falls der Scanner nicht aufgelistet worden ist, hat es gar keinen
    Sinn, es mit Programmen wie `xsane` weiter zu versuchen. Ansonsten
    bei [Probleme und
    Lösungen](sane-backends.html#ProblemeundLösungen) weiterlesen

### Probleme und Lösungen

-   *Problem*: Es wird kein Scanner gefunden
    *Lösung*: Netzwerkeinstellungen prüfen (ping fritz.box
    funktioniert?); im Web-Interface unter Dienste schauen, ob saned
    läuft und unter Pakete die Einstellungen von SANE prüfen (mal auf
    Standard zurücksetzen und sicherstellen, daß man im richigen Subnetz
    ist); Scanner aus- und wieder einschalten
-   *Problem*: Nach einmaligem Scannen ist der Scanner nicht mehr
    erreichbar.
    *Lösung*: Sicherstellen, daß `Inetd` installiert worden ist, und im
    Webinterface prüfen, ob als Starttyp für saned `inetd` ausgewählt
    ist (in kommenden Versionen ist kein anderer Starttyp mehr
    auswählbar und dieses Problem tritt nicht mehr auf).

### Einschränkungen und Hinweise

-   Dieses Paket erlaubt standardmäßig den Zugriff für alle Rechner im
    LAN (192.168.178.0/24)
-   Man sollte einen Scanvorgang nicht abbrechen, da das zum Einfrieren
    des Scanners führen kann
-   Neben reinen Scannern werden auch Multifunktionsgeräte mit Scanner
    sowie ein paar Kameras unterstützt
-   Es sollte möglich sein, auch mehrere Scanner gleichzeitig
    anzuschließen (nicht getestet)
-   Es sind nicht alle Backends von SANE enthalten (wen's interessiert:
    [[source:trunk/make/sane-backends/config-update.pl#L134](/browser/trunk/make/sane-backends/config-update.pl#L134){.source}[​](/export/HEAD/trunk/make/sane-backends/config-update.pl#L134 "Download"){.trac-rawlink})
-   saned ist trotz des Namens kein Dämon
-   saned ist zum Scannen mit scanimage auf der Box nicht nötig
-   scanimage ist zum Scannen über saned nicht nötig

### Hinweise zu speziellen Geräten

#### AGFA SnapScan e20

-   Firmwaredatei besorgen (z.B. aus einer Windowsinstallation) -
    snape20.bin
-   diese in den Ordner "`root/usr/share`" kopieren
-   die Dateien "`snapscan.conf`" und "`snapscan.conf.in`" aus dem
    Ordner "`source/sane-backends-1.0.19/backend`" anpassen:

```
#------------------------------ General -----------------------------------

# Change to the fully qualified filename of your firmware file, if
# firmware upload is needed by the scanner
firmware /usr/share/snape20.bin

# If not automatically found you may manually specify a device name.
```

-   freetz-image erstellen
-   und der Scanner kann z.B. per xsane genutzt werden

#### Mustek BearPaw 1200 TA

-   Firmwaredatei besorgen - A1fw.usb -
    [http://www.meier-geinitz.de/sane/gt68xx-backend/](http://www.meier-geinitz.de/sane/gt68xx-backend/)
-   In freetz Verzeichnis eingeben:

    ``` 
    mkdir -p make/sane-backends/files/root/usr/share/sane/gt68xx
    cp <Pfad zu A1fw.usb> make/sane-backends/files/root/usr/share/sane/gt68xx
    ```

-   freetz-image erstellen

#### HP-Geräte, die ein Plugin benötigen

Folgende HP-Geräte benötigen zum Scannen ein Plugin, das nur für x86 und
x86_64 verfügbar ist, und können nach derzeitigem Wissensstand nicht
als Scanner an der Fritz!Box betrieben werden (s.a.
[Forum](http://www.ip-phone-forum.de/showthread.php?t=108479&page=19#379)):

-   HP Color LaserJet CM1015 Multifunction Printer
-   HP Color LaserJet CM1017 Multifunction Printer
-   HP Color LaserJet CM1312 Multifunction Printer
-   HP Color LaserJet CM1312nfi Multifunction Printer
-   HP Color LaserJet CM2320 Multifuntion Printer
-   HP Color LaserJet CM2320fxi Multifunction Printer
-   HP Color LaserJet CM2320n Multifunction Printer
-   HP Color LaserJet CM2320nf Multifunction Printer
-   HP LaserJet M1005 Multifunction Printer
-   HP LaserJet M1120 Multifunction Printer
-   HP LaserJet M1120n Multifunction Printer
-   HP LaserJet M1319f Multifunction Printer
-   HP LaserJet M1522 Multifunction Printer
-   HP LaserJet M1522n Multifunction Printer
-   HP LaserJet M1522nf Multifunction Printer
-   HP LaserJet M2727 Multifunction Printer
-   HP LaserJet M2727nf Multifunction Printer
-   HP LaserJet M2727nfs Multifunction Printer

Generell betroffen sind alle Geräte, bei denen in der models.dat aus
HPLIP als scan-type 3, 4 oder 5 steht.

### Weiterführende Links

-   [IPPF-Thread](http://www.ip-phone-forum.de/showthread.php?t=108479)
    zur Entstehung dieses Freetz-Paketes, mit entsprechenden Hinweisen
-   [SANE-Homepage](http://www.sane-project.org/)
-   [Von SANE unterstützte
    Geräte](http://www.sane-project.org/sane-mfgs.html)
-   [XSane](http://www.xsane.org/)
-   [HPLIP](http://hplipopensource.com/)
-   [Von HPLIP unterstützte
    Geräte](http://hplipopensource.com/hplip-web/supported_devices/index.html)

