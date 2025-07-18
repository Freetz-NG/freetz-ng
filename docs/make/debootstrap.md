# Debootstrap (binary only) - DEPRECATED
  - Package: [master/make/pkgs/debootstrap/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/debootstrap/)
  - Maintainer: -

**Debootstrap** kann verwendet werden, um ein Debian System von Grund
auf neu zu installieren. Dies kann aus einem laufenden System heraus auf
einer anderen Partition oder auch in einem Verzeichnis auf dem aktuellen
System geschehen, beispielsweise um eine andere Release-Version von
Debian zu testen. Auch ist es möglich, mittels *debootstrap* eine
Installation von Debian von einer anderen Linux-Distribution aus
vorzunehmen.

*Debootstrap* benötigt dazu initial weder
[dpkg](http://de.wikipedia.org/wiki/Debian_Package_Manager)
noch
[apt](http://de.wikipedia.org/wiki/Advanced_Packaging_Tool).
Das initiale System wird erstellt, indem die Debian-Pakete von einer
Mirror-Site heruntergeladen und vorsichtig in ein lokales Verzeichnis
entpackt werden, in welches man schließlich
"[chrooten](http://de.wikipedia.org/wiki/Chroot)"
kann.

Sofern z.B. unter Debian, Ubuntu *Debootstrap* noch nicht installiert
ist, kann dies mit

```
sudo apt-get install -y debootstrap
```

nachgeholt werden.

### Debian in wenigen Schritten nutzen

Zuerst mit Debootstrap das Debian-System herunterladen. Dies kann von
jedem anderen System aus gemacht werden, welches das
Debootstrap-Programm enthält (z.B. auch von der gefreezten Box mit
ausgewähltem Debootstrap-Paket). Sonst ist nur noch erforderlich, dass
die gemountete Partition ext2,3 oder 4 als Dateisystem besitzt. Da es
häufig Probleme mit dem aktuellen lenny Debian gibt wird hier etch
verwendet. Es empfiehlt sich die ersten beiden Befehle am Computer
auszuführen, da dies wesentlich schneller ist. In diesem Falle sollte
man *---foreign* zu den Argumenten hinzufügen. Für alle gängigen
FritzBox Modelle bis x2xx *---arch=mipsel* eintragen, für die aktuellen
x3xx Modelle *---arch=mips* eintragen

**Hinweis**:

Beim angeschlossenen USB-Gerät kann die Bezeichnung variieren, in den
unten angezeigten Pfaden lautet die Bezeichnung *uStor01*, bei anderen
Geräten kann diese auch Generic-FlashDisk-01 lauten. Um die Bezeichnung
herauszufinden, gibt es 3 Möglichkeiten, entweder per
[Weboberfläche](http://192.168.178.1/nas/index.lua)
(FRITZNAS), FTP (Wurzelverzeichnis (root) muss sichtbar sein) oder per
aktiviertem Telnet.

**Telnet** (in der Übersicht wird das USB-Gerät aufgelistet)

```
ls /var/media/ftp/
```

**Ausgabe könnte in wie folgt sein** (Variiert nach Modell/Firmware):

```
FRITZ-NAS.txt         FRITZ-Song.mp3        Generic-FlashDisk-01  lost+found
FRITZ-Picture.jpg     FRITZ-Video.mp4       Onlinespeicher
```

**Mit *Etch* ausprobieren** (veraltete Version):

(FritzBox Modelle bis Version x2xxx)

```
debootstrap --foreign --arch=mipsel etch /var/media/ftp/uStor01/debian http://ftp.de.debian.org/debian
```

(FritzBox Modelle ab Version x3xxx)

```
debootstrap --foreign --arch=mips etch /var/media/ftp/uStor01/debian http://ftp.de.debian.org/debian
```

**Mit *Wheezy* ausprobieren** (aktuelle Version):

(FritzBox Modelle bis Version x2xxx)

```
debootstrap --foreign --arch=mipsel wheezy /var/media/ftp/uStor01/debian http://ftp.de.debian.org/debian
```

(FritzBox Modelle ab Version x3xxx)

```
debootstrap --foreign --arch=mips wheezy /var/media/ftp/uStor01/debian http://ftp.de.debian.org/debian
```

anschließend

```
chroot /var/media/ftp/uStor01/debian /debootstrap/debootstrap --second-stage
```

Sollte man Debootstrap an einem anderen PC durchgeführt haben, steckt
man den betreffenden USB-Stick nun in die FritzBox. Um das Debian jetzt
noch nutzen zu können, muss das /proc/ Verzeichnis für das Debian
bereitgestellt werden und wie bereits erwähnt "gechrootet" werden:

```
mount -t proc proc /var/media/ftp/uStor01/debian/proc
chroot /var/media/ftp/uStor01/debian bash
```

Wenn alles gut geht sollte folgender Prompt da sein

```
root@fritz
```

Ab jetzt kann man sich wie gewohnt nach einem apt-get update mit apt-get
install zusätzliche Pakete installieren.

### Erfahrungswerte

Die Erst-Installation auf einer 7170 dauert etwa 2 Stunden, die sich mit
ca. 45/75 Minuten auf die ersten 2 Schritte verteilen. Der belegte
Speicherplatz auf einem EXT3-formatierten Datenträger liegt bei ca 505
MB (März 2011). Im Gegensatz zur späteren Nutzung (speziell von
Aptitude) benötigt die Installation noch keinen Swap, steigert
allerdings den CPU-Verbrauch während dieser Zeit auf 100%.

### Weiterführende Links

-   [Linux-Wiki:
    Debootstrap](http://www.linuxwiki.de/debootstrap)
-   [Debian-Anwenderhandbuch:
    Debootstrap](http://debiananwenderhandbuch.de/debootstrap.html)
-   [Installing new Debian systems with
    debootstrap](http://www.debian-administration.org/articles/426)
-   [IPPF-Thread über Mailserver in Debian
    chroot](http://www.ip-phone-forum.de/showthread.php?t=169744)
-   [Debootstrap im Wehavemorefun
    Wiki](http://wehavemorefun.de/fritzbox/index.php/Debootstrap)

#### Comment by oliver on Sa 26 Feb 2011 11:26:45 CET

Die Erstellung des Debootstrap ist relativ einfach und gut beschrieben.
Aber wie nutzt man das jetzt? Den proc mount kann man in die rc.custom
schreiben. Und was macht man mit dem chroot? Kann man beim Starten eine
Screen-Session erstellen und sich dann dahin verbinden? Oder jedesmal
den chroot Befehl eingeben?

#### Comment by mandy28 on Sa 26 Feb 2011 13:09:38 CET

chroot per Konsole starten oder bequem mit einem addon welches dann
gleichzeitig für binary ist die im chroot laufen soll

#### Comment by oliver on Di 01 Mär 2011 21:09:47 CET

Ich hab jetzt debootstrap installiert, aber die /etc/apt/sources.list
ist leer!? Könntest du noch beschreiben was da rein muss, dass man
Pakete installieren kann.

#### Comment by mandy28 on Di 01 Mär 2011 22:30:28 CET

sollte so aussehen

```
deb http://ftp.de.debian.org/debian stable main
```

#### Comment by oliver on Di 01 Mär 2011 22:43:32 CET

Sollte das da drin stehen oder muss man das selbst reinschreiben?

#### Comment by mandy28 on Di 01 Mär 2011 22:54:33 CET

sollte normalerweise so oder ähnlich schon drin stehn

#### Comment by MyRaCoLi on Mi 02 Mär 2011 02:55:27 CET

Funktioniert das mit der aktuellen stable, squeeze? Lenny ist hier noch
irrtümlich als stable aufgeführt.

#### Comment by mandy28 on Mi 02 Mär 2011 08:15:05 CET

mit den entsprechenden scrips in debootstrap ja , dann aber über anderen
Mirror z.B.:

```
debootstrap --foreign --arch=mipsel squeeze /var/media/ftp/uStor01/squeeze http://ftp.de.debian.org/debian
chroot /var/media/ftp/uStor01/squeeze /debootstrap/debootstrap --second-stage
```

#### Comment by kriegaex on Mo 12 Dez 2011 23:05:51 CET

Also ich kriege nach dem Erstellen von Debootstrap auf dem PC und dem
Kopieren auf die 7170 via NFS beim chroot nur die Fehlermeldung:
"FATAL: kernel too old"

#### Comment by zocky on Do 26 Jul 2012 18:43:38 CEST

zu diesem zu alter fb kernel problem

7170 Firmware-Version 29.04.76 hatte ich auch alles was höer als etch is
die meldung "FATAL: kernel too old" da must einfach ne ältere dist
nehmen bis es geht

die sources.list muss dan eventl auf archive server angepasst werden

in meinem fall funktioniert das im moment mit diesem einträgen :

deb http://archive.debian.org/debian-archive/debian/ etch main contrib
non-free
deb-src http://archive.debian.org/debian-archive/debian/ etch main
contrib non-free

aba das kann sich je nach dist und aktuellem zeitraum ändern

[AddComment?]

