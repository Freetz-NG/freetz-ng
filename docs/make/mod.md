# Freetz(-MOD)
  - Package: [master/make/pkgs/mod/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/mod/)

"mod" ist das sogenannte Base-Package. Es wird immer automatisch
installiert.
Hiermit können grundlegende Dienste von Freetz wie Swap, FREETZMOUNT,
external und das Freetz-Webinterface konfiguriert werden.<br>
 * Abhängig von der Konfiguration sind nur bestimmte zu sehen!

### swap

Als Faustregel sollte man die Größe des RAMs als Größe der Swapdatei
nehmen.

Über den Parameter *swappiness* (seit
Changeset r6882) kann das Swapverhalten beeinflusst
werden. Je höher der eingetragene Wert ist desto früher fängt die Box an
den Auslagerungsspeicher zu nutzen
([Weiterlesen](http://lwn.net/Articles/83588/)).

Vor allem beim Betrieb speicher hungriger Pakete wie z.B.
[PHP](php.md), Tor [packages/tor](tor.md) oder
[Transmission](transmission.md) ist die Nutzung von Swap zu
empfehlen.

### Udevmount

 * Methode zur Ermittlung des Mountpoints:<br>
   Der Name des Mountpoints kann durch AVM vom Gerätenamen oder
   Partitionsnamen abgeleitet werden. Die aktive Methode wird hier
   angezeigt.<br>
   Um die Methode auf LABEL zu ändern:
   ```
	ctlmgr -s
	sleep 1
	cat /var/flash/usb.cfg > /tmp/usb.cfg.tmp
	sed 's/volume_labels = .*/volume_labels = yes;/' /tmp/usb.cfg.tmp > /var/flash/usb.cfg
	ctlmgr
	sleep 30
	reboot
   ```
   Zum aktivieren der DEVICE-Methode das ```yes``` oben auf ```no``` ändern.
 * Alle Programme beenden die das Aushängen verhindern:<br>
   Beim Unmounten oder Rebooten werden alle Programme ermittelt die ein
   sauberes Aushängen verhindern und versucht sie zu beenden.
 * Automatisch autorun.sh und autoend.sh ausführen<br>
   Beim Mounten wird autorun.sh und beim Unmounten autoend.sh
   ausgeführt, falls sie sich auf dem Datenträger befinden.
   Dies sollte nur aktiviert werden wenn man es benötig da es
   ein Sicherheitsrisiko darstellt!

### get_ip

Das Skript *get_ip* ermittelt die öffentliche IP, was an verschiedenen
Stellen in Freetz und dessen Packages benötigt wird.

Hier kann das standardmäßige Verhalten von *get_ip* an die lokalen
Gegebenheiten angepasst werden. So funktioniert bei einer FritzBox, die
das Internet "mitbenutzt" (IP-Client) oder UMTS verwendet, nur die
`--extquery` Methode, da die Box keine öffentliche IP erhält (NAT). Die
Standardeinstellung `--all` deckt diesen Fall jedoch ab, weil sie
nacheinander mehrere Methoden durchprobiert, bis die externe IP
ermittelt wurde. Wer ca. 0,4 s pro Abfrage (also 90%) sparen möchte,
kann hier in diesem Fall aber die Methode von `-all` auf `--extquery`
ändern.

### Konfigurationsdateien



### .profile

Dies wird beim Login ausgeführt. Es können zB Aliase für häuftig
genutzte Befehle definiert werden:
Beispiel:

```
alias nl="sed '=' | sed 'N;s/n/t/'"
alias tcpdump6="tcpdump ip6 or proto ipv6"
```



### crontab

Der "cron" Daemon führt Befehle zu bestimmten Zeiten aus. Er wird
durch die crontab konfiguriert.
Syntax:

```
Minute | Stunde | Tag | Monat | Wochentag | Befehl
```

Beispiel:

```
55  23  * * 7  logger "Es ist Sonntag, 5 Minuten vor 12"
*/10  * * * *  logger "Es sind wieder 10 Minuten vergangen"
* 6,18  * * *  logger "Es ist 6 Uhr"
```

 * Im Gegensatz
zu "normalen" Linux Systemen fehlt die "Besitzer"-Spalte und alle
Befehle werden als root ausgeführt.



### dtrace

Die Befehle in dieser Datei werden durch die Tastenkombination `#97*3*`
am Telefon ausgeführt.
Beispiel:

```
#!/bin/sh
if [ "$(/etc/init.d/rc.lighttpd status)" != "stopped" ]; then
    /etc/init.d/rc.lighttpd stop
else
    /etc/init.d/rc.lighttpd start
fi
```

 * Nur sichtbar
wenn der replace-dtrace Patch ausgewählt wurde!

### hosts

Hier können IP-Adressen, Hostnamen und MAC-Adressen für DNS und DHCP
zueinander zugeordnet werden. Siehe auch [dnsmasq: Einträge in der
Hosts-Liste](dnsmasq.html#EinträgeinderHosts-Liste)
Syntax:

```
<ipaddr>|* <hwaddr>|[id:]<client_id>|* [net:]<netid>|* <hostname>|* [ignore]
```

Beispiel:

```
192.168.178.20    *           * MeinPC-1
192.168.178.21  11:22:33:44:55:66   * MeinPC-2
```



### modules

Die Kernel-Module die in dieser Datei aufgeführt sind werden während des
Bootvorgangs geladen.
Beispiel:

```
pl2303
ftdi_sio
```

 * Die Namen der
Module sind ohne Pfad und die Endung `.ko` anzugeben.



### rc.custom

Die Befehle in dieser Datei werden nach dem Bootvorgang ausgeführt.
 * Es dürfen
keine Befehle eingetragen sein, die im Vordergrund bleiben oder sehr
lange brauchen. Dies könnte Probleme beim Starten der FritzBox
verursachen. Bei Befehlen in Verbindung mit einen USB-Stick, bitte die
Erweiterung rc.external verwenden.

### rc.external

Diese Datei wird ausgeführt nachdem der Datenträger auf dem sich die
[external](../help/howtos/common/external.html)-Dateien befinden
eingehängt wurde und bevor er ausgehängt wird.
Beispiel:

```
#!/bin/sh
case "$1" in
    load)
        logger "Datenträger eingehängt"
        ;;
    unload)
        logger "Datenträger ausgehängt"
        ;;
esac
```

 * Bitte
`Advanced Options` → `External` → `Enable external processing` für diese
Erweiterung aktivieren.



### shutdown

Die Befehle in dieser Datei werden während des Herunterfahres
ausgeführt.



### udev_first / udev_final

Regeln die von UDEV ausgeführt werden. Siehe [Custom UDEV
rules](../patches/custom_udev_rules.html).

