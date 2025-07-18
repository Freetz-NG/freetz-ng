# USB/IP 0.1.8 - DEPRECATED
  - Package: [master/make/pkgs/usbip/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/usbip/)
  - Maintainer: -

Das Ziel von
**[USB/IP](http://usbip.sourceforge.net/)** ist es,
die an einem Rechner angeschlossenen USB-Geräte von anderen Rechnern
benutzbar zu machen - und zwar im vollen Funktionsumfang. Dazu werden
"USB I/O messages" in IP-Pakete gepackt, um über das Netzwerk
übertragen zu werden. Jeder einzelne Rechner kann die betreffenden
USB-Geräte nun so benutzen, als seien sie direkt bei ihm angeschlossen.
Damit lassen sich folgende Dinge tun:

-   **USB Storage Devices**: `fdisk`, `mkfs`, `mount`/`umount`, diverse
    Dateioperationen, Filme von einer DVD abspielen, eine DVD brennen...
-   **USB Tastaturen und USB Mäuse**: Benutzung selbiger sowohl von der
    Konsole als auch aus dem X Window System.
-   **USB Webcams und USB Lautsprecher**: Durch die Webcam schauen,
    Bilddaten "capturen" (aufzeichnen), Musik abspielen.
-   **USB Drucker**: Wie die AVM-Druckerfreigabe, zusätzlich kann zB der
    Füllstand ermittelt werden.
-   **USB Scanner, USB Serial Converter und USB Netzwerk Interfaces**:
    Naja - halt benutzen eben.

In Hardware gegossen, findet man über Google auch schon etliche
sogenannte "USB Extender" (und zwar stellen diese bei weitem die
größte Treffermenge dar) - mit diesem Paket bringen wir das jedoch
einfach vorhandener Hardware, nämlich unserer Freetz-Box, bei.

Im IPPF ist beschrieben wie man es nutzt: [Teil
1](http://www.ip-phone-forum.de/showpost.php?p=1392146&postcount=45)
[Teil
2](http://www.ip-phone-forum.de/showpost.php?p=1609255&postcount=50)

### Verwendete Bibliotheken

-   libglib2
-   libsysfs

### Weiterführende Links

-   [USB/IP
    Projektseite](http://usbip.sourceforge.net/)
-   [IPPF Thread: Wie kam USB/IP auf die
    Freetz-Box](http://www.ip-phone-forum.de/showthread.php?t=131278)
-   Windows-Client:
    [usbip_windows_v0.1.0.0_signed.zip](https://sourceforge.net/projects/usbip/files/usbip_windows/)


