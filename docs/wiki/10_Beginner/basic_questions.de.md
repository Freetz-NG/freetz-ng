# Grundlegende Fragen

### Gut zu wissen

  * Ein Eintrag in menuconfig/kconfig finden?<br>
    Öffne menuconfig und gib das Zeichen ```/``` ein, um zu suchen.
  * Ein (AVM oder modifiziertes) Image per Bootloader flashen?<br>
    Führe ```tools/push_firmware``` aus, nutze ```tools/push_firmware -h``` für Hilfe.
    Oder einfach ```make push_firmware``` nach ```make``` ausführen.
  * Flashen mit Raspberry?<br>
    Lege das erstellte Image auf den Raspberry. Lade das aktuelle push\_firmware-Skript herunter:
    ```wget https://raw.githubusercontent.com/Freetz-NG/freetz-ng/master/tools/push_firmware```
    Mache es ausführbar: ```chmod +x push_firmware```. Führe es dann aus: ```./push_firmware ...```
  * Warum In-Memory-Image-Format?<br>
    Es wird nicht mehr benötigt, da push\_firmware ein Image direkt flashen kann.
  * Ein Image entpacken?<br>
    Nutze ```tools/fwdu unpack the.image```, um das (interne) Dateisystem zu extrahieren.
  * Älterer Modem/DSL-Treiber?<br>
    Entpacke die Quell-Image-Datei mit fwdu. Kopiere dann die benötigten Dateien
    mit Verzeichnissen in ein Unterverzeichnis des ```addon/```-Verzeichnisses in Freetz.
    Aktiviere nun das neue Addon in einer ```addon/*.pkg```-Datei.
    Die benötigten Dateien hängen von deinem Gerät ab. Beispiele:
     - Für 7490: das gesamte Verzeichnis ```/lib/modules/dsp_vr9/```
     - Für 7590: das gesamte Verzeichnis ```/lib/modules/dsp_vr11/```
  * Kernel ersetzen?<br>
    Nicht verwenden – es sei denn, du weißt genau, warum du es brauchst!
    Du wirst nie einen Kernel haben, wie ihn AVM erwartet. Möglicherweise fehlen Patches,
    oder einige Optionen sind nicht so gesetzt, wie es AVM vorgesehen hat.
  * Kernel-Module erstellen?<br>
     - Falls du nicht weißt, welches Modul für ein bestimmtes Gerät benötigt wird, schließe das Gerät an einen Linux-PC an und überprüfe es mit den Befehlen: `dmesg`, `lsusb`, `lsmod` etc.
     - Stelle sicher, dass der neueste Quellcode für dein Gerät unter https://osp.avm.de/ verfügbar ist und in Freetz integriert wurde. Falls nicht, musst du AVM fragen: fritzbox_info@avm.de
     - Führe nun `make menuconfig` aus und wähle deine Fritzbox und dein Fritzos aus. Dann muss das Modul mit `make kernel-menuconfig` als "M(odule)" aktiviert werden, nutze `/` zum Suchen.
     - Falls du das nicht jedes Mal manuell tun möchtest, kannst du deine Änderungen in `make/linux/configs/freetz/` als Push-Request hochladen.
     - Um die Datei ins Image zu kopieren, wähle sie mit ```make menuconfig``` aus oder falls nicht verfügbar, füge ihren Namen unter `Kernel-Module` -> `Eigene Module` hinzu.
  * Dateien auf Speichermedien ausführen?<br>
    Seit einiger Zeit von AVM standardmäßig deaktiviert. Um dies zu erlauben,
    wähle den Patch "Drop noexec for (external) storages".
    Für interne Speichermedien ist es in Freetz immer aktiviert!
  * Befehle beim Neustart ausführen?<br>
    Lege dein ausführbares Skript hier ab: ```/tmp/flash/mod/shutdown```
  * Schreibgeschützte Dateien (oder Verzeichnisse) bearbeiten?<br>
    1) Datei kopieren: ```cp /some/path/to/file /tmp/file```<br>
    2) Mounten: ```mount -o bind /tmp/file /some/path/to/file```
  * motd ändern?<br>
    Du kannst dein eigenes \*Skript\* hier ablegen: ```/tmp/flash/mod/motd```
    Die motd wird einmal beim Booten generiert. Um sie regelmäßig zu aktualisieren,
    führe ```/mod/etc/init.d/rc.mod motd``` z. B. per Cron aus.
  * Alte Paketstruktur in menuconfig?<br>
    Um die alte Paketstruktur zu verwenden, führe ```make menuconfig-single``` aus.
  * Wie benutzt man Git?<br>
    Schnellstart-Anleitung für Anfänger: https://xkcd.com/1597/
