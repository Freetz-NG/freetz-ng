# USB root 0.2 - DEPRECATED
  - Package: [master/make/pkgs/usbroot/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/usbroot/)
  - Maintainer: -

Mit **USB-Root** lässt sich das Root-Verzeichnis (`/`) auf ein an die
Fritz!Box angeschlossenes USB-Gerät auslagern - was zusätzlichen Platz
nicht nur für weitere Software schafft.

### Vorteile

-   Immer noch ein lauffähiges System im Flash-Speicher der Fritz!Box
    als Notfall-System vorhanden
-   Nahezu unbegrenzter Platz
-   Mehrere Systeme parallel zur Auswahl auf dem USB-Stick → einfaches
    Testen neuer Versionen und Konfigurationen. Dabei sollte allerdings
    die jeweils genutzte Firmwarebasis von AVM ein zueinander
    kompatibles Konfigurationsformat aufweisen!

**Ein Beispiel aus der Praxis:**

Annex A Box in Frankreich mit DAU als Besitzer
;-) Bei einem nicht
funktionierenden System im Flash würde da gar nichts mehr gehen. Strom
aus, USB-Stick ab und Strom wieder an, bekommt er aber hin um damit das
Notfallsystem im Flash nutzen zu können.

### Konfiguration und Kompilierung

USB-Root muss einfach bei Erstellung des Images mit `make menuconfig`
(siehe [Freetz Installation?]) mit ausgewählt werden. Um
später eine Shell auf der Fritz!Box zu haben und scp nutzen zu können,
sollte auch dropbear mit ins Image. Zuerst wird dann ein Image mit
USB-Root erzeugt, das in den Flashspeicher der Fritz!Box passt und dann
auch wie jedes Image auf die Fritz!Box geflasht wird.

Dann kann man sich sein System für den USB-Root zusammen stellen und
braucht nicht mehr auf den Platz zu achten. Das USB-Root Paket muss
jedoch ausgewählt bleiben! Die Fehlermeldung am Ende, dass das Image zu
groß ist, stört hier nicht weiter. Wir benötigen ja nur das erstellte
Systeme, das wir in [Freetz-Ordner]/build/modified/filesystem finden.

Es kann eine beliebige Freetz-Version für den USB-Stick verwendet
werden. Es muss nicht die gleiche Version verwendet werden, wie sie im
Flashspeicher der Fritz!Box abgelegt ist. Es muss ausschließlich der
Kernel im Flashspeicher zum Kernel des USB-Sticks passen.

Als Dateisystem ist eine Partition mit ext2 oder ext3 zu verwenden. Das
passende Kernel-Modul muss bei der Imageerstellung ausgewählt werden!

### Packen, kopieren auf die Fritz!Box und entpacken

```
# 1. Dateisystem packen, dabei Besitzer auf root:root ändern
tar --group=0 --owner=0 -czf rootfs.tar.gz -C build/modified/filesystem .

# 2. USB-Root im Freetz-Web deaktivieren, falls bereits aktiv

# 3. Box mit Firmware aus dem Flash neu starten

# 4. Archiv direkt auf an der Box angeschlossenes USB-Medium kopieren (Zielpfad anpassen!)

# Variante A: vom PC aus die Datei auf die Box schieben (benötigt SSH-Server auf der Box)
scp rootfs.tar.gz root@fritz.box:/var/media/ftp/uStor01/rootfs

# Variante B: von der Box aus die Datei vom PC holen (benötigt SSH-Server auf dem PC)
scp user@my_pc:/home/user/freetz-trunk/rootfs.tar.gz /var/media/ftp/uStor01/rootfs

# 5. Archiv auf der Box entpacken
cd /var/media/ftp/uStor01/rootfs
tar -xzf rootfs.tar.gz

# 6. Falls USB-Root noch nicht genutzt wurde muss es erst im Freetz-Web konfiguriert werden (Partition auswählen und Verzeichnis eintragen (z.B. /rootfs)

# 7. USB-Root in Freetz-Web aktivieren, Box vom USB-Root neu starten
```

**Neu in der Entwicklerversion seit
Changeset r8566:**
Man kann direkt in *Menuconfig* einstellen, daß beim Build zusätzlich
zum oder anstelle des Firmware-Images das Dateisystem direkt in ein
Archiv gepackt wird ("USB Root Mode", ersetzt Schritt 1 oben).
Alternativ ist es über den "NFS Root Mode" auch möglich, das
Dateisystem direkt (fix und fertig entpackt, Schritte 1, 3, 4) auf den
USB-Stick zu kopieren, sofern dieser am PC angeschlossen oder über NFS
erreichbar ist. Erstere Variante ist vermutlich die häufigere und sieht
so aus:

```
### Freetz Configuration

[*] Show advanced options
--> Advanced options
    --> Build system options
        --> Firmware packaging (fwmod) special options
            [*] Skip packing modified firmware
            [*] Pack file system into archive (USB root mode)
```

### Einbinden von Partitionen

Das Einbinden von weiteren Partitionen funktionierte in frühen
Freetz-Versionen nicht, somit mussten diese Partitionen manuell
eingebunden werden. In aktuellen Freetz-Versionen funktioniert dies nun,
so dass die AVM-Features, welche auf USB-Partitionen speichern,
verwendet werden können.

Allerdings gibt es beim Mounten der Partitionen eine Fehlermeldung für
die verwendete Root-Partition: da diese bereits gemountet ist, schlägt
ein weiterer Mount-Versuch (der "normale" von AVM) natürlich fehl.
Dies kann mit ruhigem Gewissen ignoriert werden.

### Mögliche Nebenwirkungen

Das Freetz usbroot Paket verändert die Environment-Variable kernel_args
und startet dort einen alternativen init Prozess
(init=/etc/init.d/rc.usbroot). Die Variable kernel_args1 wird auch
gesetzt. Beim Upgrade / Recover der Firmware kann dies zu Problemen
führen, daher **MUSS vor dem Firmware-Update bzw Recover die
usbroot-Funktion wieder deaktiviert werden''', wahlweise über das
Freetz Webinterface oder aus der Shell mit:**

```
echo kernel_args > /proc/sys/urlader/environment
echo kernel_args1 > /proc/sys/urlader/environment
```

Bemerkt man dies zu spät (Die Box startet als Beispiel gleich nach 5
Sekunden neu) helfen die ADAM2 Befehle:

```
quote SETENV kernel_args
quote SETENV kernel_args1
```

Sollte es nach den beiden Befehlen immernoch nicht helfen, so führt man
ein Recover aus und flasht danach ein Freetz **ohne jediglichen Umfang**
(ohne Packages sowie **ohne** usbroot) über das AVM-WebInterface auf die
Box und setzt die beiden Variablen (mittels Telnet) wieder auf ihren
normalwert, danach kann man wieder problemlos seine gewünschte
modifizierte Firmware auf die Box bringen!

### Verbesserungsmöglichkeiten

1.  Direkt per SCP oder rsync aus der Stinky-VM auf die Fritz!Box
    kopieren.
    Wenn man aus Buildsystem (z.B. VM mit STinky) direkt über Netzwerk
    die Fritz!Box per ssh/scp erreichen kann ist der Umweg über einen
    weiteren PC unnötig. Hier wäre es dann eine direkte Verbindung
    zwischen Fritz!Box und Buildsystem eleganter. Die Variante oben ist
    aber für entfernte Systeme, ohne von außen erreichbaren SSH-Zugang
    weiterhin brauchbar.
2.  Die sich wiederholenden Befehle in ein bash-script packen

