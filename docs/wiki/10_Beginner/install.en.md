# Installation

Freetz provides some scripts for
modifying an original firmware. Because of license issues the
distribution of original or modified firmware images is forbidden.

 the
installation of a modified firmware invalidates the manufacturer's
warranty! In case of problems, do NOT contact AVM support.


**Speedports**: (see
[sp2fritz](http://wiki.ip-phone-forum.de/skript:speedport2fritz#was_mach_ich_mit_dem_fertigen_kernel.image)).
From scriptversion 2.2.2008 the use of speed2fritz is possible.

**Newbies**: Please read 'Freetz for Beginners'
first!

### Virtual LINUX: FriBoLi / StinkyLinux / Freetz-Linux

[StinkyLinux](http://www.ip-phone-forum.de/showthread.php?p=1019861)
(formerly FriBoLi) is a virtual Linux operating system for building
FritzBox firmware images on Windows. Unfortunately, support for
StinkyLinux was discontinued some time ago. This means it cannot be used
for freetz anymore without hassle with updates.

Because of that, a new build environment
[Freetz-Linux](http://www.ip-phone-forum.de/showthread.php?t=194433)
was created by Silent-Tears (cinereous), who also maintains it. The use
of this environment is strongly recommended if no native linux can be
used.

The following instructions were initially adopted from
[Saphir](http://www.ip-phone-forum.de/member.php?u=118161)
, but have grown over time and were completed and/or edited by many
different users. We try to keep these up-to-date and adapt it to the
current versions of VM and freetz. However, the steps below can (with
some minor limitations) be used for every freetz-VM.

### Preparation

See also:

[Installing
Freetz-Linux](http://www.ip-phone-forum.de/showthread.php?t=194433)

[Installing
StinkyLinux](http://wiki.ip-phone-forum.de/skript:stinkylinux)
(!!!obsolete!!!)

[Installing Freetz and
Speed-to-Fritz](http://wiki.ip-phone-forum.de/skript:freetz_und_speed-to-fritz)
(SpeedPort users only)

[StinkyLinux
Homepage](http://stinkylinux.slightlystinky.servebbs.net/)
(Attention! instructions and images there are out of date!)

### Execution

1.  Needed files:
    -   [VMware
        Player](http://www.vmware.com/products/player/overview.html)
    -   [Freetz-Linux](http://www.ip-phone-forum.de/showthread.php?t=194433):
        Image for VMWare Player or StinkyLinux: Image for VMWare Player
        (StinkyLinux-v1.06.7z),
        (Download-Source:
        [Mirrors](http://www.ip-phone-forum.de/showthread.php?p=1019861))
    -   Freetz, (Download-Source:
        Downloadseite)
    -   optional patches for freetz, (Quelle: [Freetz
        Forum](http://www.ip-phone-forum.de/showthread.php?t=135258))
2.  Unpack
    [Freetz-Linux](http://www.ip-phone-forum.de/showthread.php?t=194433)
    under Windows using
    [7-Zip](http://downloads.sourceforge.net/sevenzip/7z442.exe)
    or
    [WinRAR](http://www.rarlab.com/rar/wrar380d.exe)
    .
3.  Run VMWare Player. Leave all settings as they are; the Player will
    be able to connect to the Internet by itself. If not, you can set up
    internet access manually like so:

    ```
		ifconfig eth0 192.168.178.xx netmask 255.255.255.0 broadcast 192.168.178.255
    ```

    (where `eth0` might have to be replaced with your configured network
    interface. **"ifconfig -a"** will list all network interfaces
    available to your virtual machine.)

4.  In VMWare Player, log on as user **freetz** with password     **freetz**.
    \
    From here, there are several ways to work with Freetz-Linux and to
    exchange files between Freetz-Linux and the rest of the world. One
    might work on Freetz-Linux' console, for example.
    -   **SSH/SCP**: One might also connect to the VM using an SSH/SCP
        connection. Windows clients include
        [putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
        and
        [WinSCP](http://winscp.net/eng/download.php#download2).
        Enter the VM's hostname (or IP-Address) under "Server name".
        For "name" and "password" please use the credentials
        indicated above.
    -   **SAMBA**: It is also possible to exchange data between Windows
        and Freetz-Linux via SAMBA. To do that, enter "\
        Freetz-Linux" or "\
        Freetz-Linuxs-IP-Address" in Explorer's address bar and you
        get a listing of files and folders present in your VM. Then, you
        can move and copy them around as usual.
        \
        All those connection options have been pre-set in Freetz-Linux
        and should work out-of-the-box. If problems occur, please verify
        your network connection(s), and your firewall settings (if
        applicable). Also, don't forget to verify VMWare Player's
        network connection settings. By default, VMWare Player uses
        **Bridged Mode**. To start with, run
        `ping <IP-Address-of-Freetz-Linux>` inside Command Prompt.
5.  Depending on your preferred choice, you proceed with one of the
    following:
    -   **SSH/TELNET**: (the preferred method)

        ```
			svn co URL
        ```

You can replace `freetz-1.1.x` with any other valid tag, or use the
development `/trunk` if you wish.

1.  *Optional*: Apply patch(es) (see
    Howto)
2.  Change into the freetz directory you just checked out (or unpacked
    into):

    ```
		cd freetz-*/
    ```

3.  Configure freetz. It is possible to do this using a
    [ncurses](http://de.wikipedia.org/wiki/Ncurses)
    interface, the same one being used to configure the Linux kernel.
    For a detailed description, see
    menuconfig.

    ```
		make menuconfig
    ```

4.  Modify firmware. In this step, the original firmware and packages
    matching your configuration as well as the necessary build tools are
    being downloaded automatically and a new one is being built,
    according to your configuration, in three distinct steps. The first
    run through will take a little while, so you might want to have some
    coffee or tea in the meantime.

    ```
		unset CFLAGS CXXCFLAGS
		make
    ```

<!-- -->

1.  In `~/freetz-*/images`, you'll find your newly built firmware (e.g.
    `7170_04.76freetz-devel-3790.de_20091021-180742.image`).
2.  Upload the image
    `<BOX_VERSION>_<ORIG_FIRMWARE_VERSION>freetz-devel-VVVV.<LANG>_YYYYMMDD-HHMMSS.image`
    as Firmware Update to your FritzBox. After successful Upload, you
    can access a secondary web interface on port 81 of your box,
    offering detailed instructions to finalize installation. Should your
    Box be unreachable even though INFO-LED stopped flashing several
    minutes ago - especially if, in **regular intervals**, all LEDs
    light up), you can recover your box' original firmware on most Box
    types.

### Linux

### Notwendige Pakete

* Siehe [PREREQUISITES](../../prerequisites/README.md)

Für das Erstellen der Firmware kann auch Knoppix verwendet werden, wozu
keine Linux-Installation erforderlich ist. Wichtig ist, dass zum
Kompilieren des Mods unter Linux keine FAT oder NTFS Partition verwendet
wird. Die folgende Anleitung benötigt für

#### freetz-1.0

-   **gcc** - GNU C Compiler
-   **g++** - GNU C++ Compiler
-   **binutils** - GNU Assembler, Linker und Binary-Werkzeuge
-   **autoconf** - dem Make vorgeschalteter Generator für
    Konfigurationsskripten nach GNU-Standard; hilft dabei,
    plattformunabhängig programmierte Software letztendlich für einen
    plattformspezifischen Build vorzubereiten
-   **automake** ab Version 1.10 - Makefile-Generator nach GNU-Standard;
    wird nicht für alle DS-Mod-Pakete benötigt, aber z.B. für
    privoxy; Paketmanager
    installiert normalerweise *autoconf* als abhängiges Paket gleich mit
-   **automake-1.9** - Version, die zusätzlich speziell von `tar-1.15.1`
    aus *tools* benötigt wird
-   **libtool** - hilft beim Erstellen von statischen und dynamischen
    Bibliotheken; kann z.B. beim aufruf von *autoreconf* notwendig
    werden
-   **GNU make** ab Version 3.81 - skriptgesteuertes Build-System
-   **bzip2** - (Ent)packen von Software-Archiven
-   **libncurses5-dev** - Entwickler-Bibliothek für ncurses (Erzeugung
    komfortabler textbasierter Benutzerschnittstellen, vgl.
    `make menuconfig`)
-   **zlib1g-dev** - Entwickler-Bibliothek für gzip-Kompression
-   **flex** - lex-kompatibler Generator für lexikalische Analyse
-   **bison** - YACC-kompatibler Parser-Generator
-   **patch** - Programm, um Patches anzuwenden
-   **texinfo** - Online-/Druck-Doku aus gemeinsamer Quelle erzeugen
-   **gettext** - Texte in Programmen internationalisieren
-   **pkg-config** - Hilfstool welche zum Bauen von Binaries und
    Libraries nötig ist; notwendig für Packages ntfs und transmission
-   **ecj-bootstrap** - Eclipse Java Compiler (evtl. auch libecj-java
    und ecj in neueren Distributionen); nur notwendig für Package
    *classpath* ab 0.95 bzw. ds26-14.5
-   **perl** - Perl-Interpreter; notwendig für `make recover`
-   **libstring-crc32-perl** - Perl-Modul zur Berechnung von
    CRC32-Prüfsummen; notwendig für `make recover`
-   **intltool** - `make menuconfig`

### freetz-1.3

-   **xz-utils** - (Ent)packen von Software-Archiven im xz-Format

#### aktuelle Entwicker Version und spezielle Pakete

Diese benötigen zusätzlich zu bereits unter *freetz-1.0* genanntem noch
folgende Pakete:

-   **svn** - Subversion zum Auschecken der aktuellen Freetz-Versionen
-   **ruby1.8** - objektorientierte Skriptsprache (Version 1.8.6); nur
    notwendig für Package *ruby* (ab freetz-devel) - seltsamerweise
    benötigt der Crosscompile für *ruby-1.8.6* eine installierte Version
    seiner selbst als Voraussetzung. Zu allem Überfluß könnte es sein,
    daß Sie im Paket zwar `/usr/bin/ruby1.8` o.ä. haben, aber nicht das
    vom Makefile benötigte Binary Namens *ruby*. Da hilft im o.g.
    Beispiel `sudo ln -s ruby1.8 /usr/bin/ruby` bzw. die Ausführung des
    `ln`-Befehls als Benutzer *root*.
-   **gawk** - GNU awk; notwendig für das Skript `tools/extract-images`
    (ab freetz-devel), wenn man z.B. ein Recover-EXE zerlegen, also
    *urlader.image* und *kernel.image* extrahieren möchte. Die in
    anderen *awk*-Varianten nicht vorhandene Funktion *strtonum* wird an
    einer Stelle verwendet.
-   **python** - Python-Interpreter; notwendig, um via `tools/mklibs.py`
    unbenutzte Symbole aus Bibliotheken zu entfernen, um Platz zu sparen
    (ab freetz-devel)
-   **libusb-dev** - Entwicklungs-Bibliothek für USB-Anwendungen im
    Userspace; nur notwendig für SANE, wenn bspw.
    Multifunktionsdrucker/-scanner an die FritzBox angebunden werden
    sollen. Siehe auch
    [Forums-Beitrag](http://www.ip-phone-forum.de/showpost.php?p=1075181&postcount=199)
    dazu.
-   **realpath** - wird nur von Entwicklern benötigt, die ab ds26-15
    innerhalb von *fwmod* beim Build das Patch-Auto-Fixing verwenden
    (AUTO_FIX_PATCHES im Environment). Wer nicht weiß, wovon die Rede
    ist, braucht es auch nicht.
-   **fastjar** - Implementation des Java jar utils; nur notwendig für
    Package *classpath*
-   **graphicsmagick** - enthält `composite` mit dem Bilder kombiniert
    werden können; nur notwendig wenn man das AVM-Webinterface
    "taggen" möchte

#### alte Entwicker Versionen

Hier wird zusätzlich folgendes benötigt:

-   **automake-1.8** - Version, die zusätzlich speziell von *libid3tag*
    benötigt wird. Nicht mehr erforderlich ab Freetz 1.0.
-   **jikes** - Java Byte Code Compiler; nur notwendig für Package
    *classpath* bis 0.93 bzw. ds26-14.4

### Installation der benötigten Pakete

* Verschoben: [PREREQUISITES](../../prerequisites/README.md)

### Erstellung & Installation

1.  Shell öffnen, ins Verzeichnis von `freetz-//xxx//.tar.bz2` wechseln
    und diesen mit `tar -xvjf ds-x.y.z.tar.bz2` entpacken
2.  *Optional*: Patch einspielen (siehe
    Howto)
3.  Mit `cd freetz-xxx/` in das Verzeichnis des entpackten Freetz
    wechseln
4.  Konfiguration wählen. Dies ist über ein ncurses Interface möglich,
    welches z.B. aus der Konfiguration des Linux Kernels bekannt ist.
    Details und Beschreibungen zu den Optionen gibt es in der
    Beschreibung zum make menuconfig.
5.  Firmware modifizieren. In diesem Schritt werden die zu der gewählten
    Konfiguration passenden original Firmware und Pakete, sowie Sourcen
    für die benötigten Tools vollautomatisch heruntergeladen und die
    modifizierte Firmware in drei Schritten erzeugt. Dies erledigt ein
    simples `make`.
6.  `*.image` als Firmware Update auf die Box hochladen. Nach einem
    erfolgreichen Upload ist nun auf Port 81 ein weiteres Webinterface
    verfügbar, welches Instruktionen zum Abschluss der Installation
    enthält. Sollte die Box nach dem Hochladen der Firmware auch Minuten
    nachdem die Info LED aufgehört hat zu blinken nicht mehr erreichbar
    sein (typischerweise leuchten **periodisch** immer wieder alle LEDs
    auf), so kann die originale Firmware bei den meisten Box-Typen, wie
    in diesem Howto
    beschrieben, wiederhergestellt werden.

### coLinux / andLinux / speedLinux

Siehe auch: [andlinux unter Vista
installieren](http://wiki.ip-phone-forum.de/skript:andlinux)

Alternativ kann auch [coLinux](http://colinux.org)
benutzt werden, ist etwas resourcenschonender als der vmware player. Mit
speedLinux ist alles vorbereitet für freetz oder speed-to-fritz. Mit
./freetz werden alle notwendigen Vorbereitungen und Installationen
durchgeführt. aktueller Stand 25.10.2009

Anmerkung von Alexander Kriegisch (kriegaex), 24.02.2008: Ja, das
benutze ich auch seit gestern, und zwar speziell die mit Ubuntu Gutsy
und XFCE (wahlweise auch KDE) vorkonfigurierte Variante
**[andLinux](http://www.andlinux.org)**, die man
wahlweise als Dienst oder als Anwendung starten kann und mit einem
einfachen Installer ausgeliefert wird. Scheint etwas langsamer zu sein
als ein reines Linux, aber es ist schon cool, Linux-Fenster nativ neben
Windows-Fenstern zu haben.
*:-)* Der
mitgelieferte X-Server Xming (für Windows) macht's möglich. Ich
verwende übrigens nicht mal ein X-Terminal, sondern logge mich sozusagen
"headless" über SSH ein (Putty). Ab und zu lasse ich mal Synaptic oder
als X-Editor SciTE laufen, den ich nachinstalliert habe. Ich baue gerade
sämtliche Freetz-Pakete "from scratch" inkl.
Download, es geht genauso wie in VMware
oder nativem Linux, also Linux-Paketliste siehe oben.

Nachteile von coLinux/andLinux/speedLinux:

-   bei Multicore-Prozessoren wird nur ein Kern benutzt
-   keine 64bit Unterstützung
-   gravierende Systemanpassungen (spezieller Kernel, etc) bei Updates
    des Systems notwendig.

Vorteile von coLinux/andLinux/speedLinux:

-   kommt mit weniger RAM aus als VMWare (geringerer Ressourcenbedarf)
-   native Windowsfenster

### Cygwin

 **Unter
Cygwin funktioniert Freetz definitiv *nicht*, und auch für ds-0.2.9
(Kernel 2.4) wird Linux empfohlen, weil es mit Cygwin Probleme geben
kann und es außerdem einen *riesigen* Geschwindigkeitsverlust beim Bauen
(mehrfache Build-Dauer) bedeutet, Cygwin zu verwenden.**


Da Freetz sich unter Cygwin ohnehin nicht bauen lässt, folgt hier
lediglich die Beschreibung für ds-mod:

Ein Howto von dsl123 zum Kompilieren des ds-mod's unter Cygwin gibt es
[hier](http://www.ip-phone-forum.de/showthread.php?t=98657).
Zum Entpacken der Datei `ds-*.tar.bz2` unter Windows **ausschließlich**
das Cygwin-tar --- wie in der Anleitung beschrieben --- verwenden:

1.  Cygwin Installer von
    [http://www.cygwin.com/](http://www.cygwin.com/)
    herunterladen und ausführen
2.  Cygwin mit den folgenden Paketen installieren:
    -   Archive > unzip
    -   Devel > gcc, libncurses-devel, make, patchutils
    -   Interpreters > perl
    -   Web > wget
3.  `ds-*.tar.bz2` in das Cygwin Home-Verzeichnis herunterladen (je nach
    Installation z.B. `C:/Cygwin/home/<Windows-Benutzername>/`)
4.  Cygwin Shell öffnen und den ds-mod entpacken
    `tar -xvjf ds-x.y.z.tar.bz2`
5.  *Optional*: Patch einspielen (siehe
    Howto)
6.  In das Verzeichnis des entpackten ds-mod wechseln `cd ds-*/`
7.  Konfiguration wählen. Dies ist über ein
    [ncurses](http://de.wikipedia.org/wiki/Ncurses)
    Interface möglich, welches z.B. aus der Konfiguration des Linux
    Kernels bekannt ist. Details und Beschreibungen zu den Optionen gibt
    es in der Beschreibung zum
    menuconfig. `make menuconfig`
8.  Firmware modifizieren. In diesem Schritt werden die zu der gewählten
    Konfiguration passenden original Firmware und Pakete, sowie Sourcen
    für die benötigten Tools vollautomatisch heruntergeladen und die
    modifizierte Firmware in drei Schritten erzeugt. `make`
9.  `firmware_*.image` als Firmware Update auf die Box hochladen. Nach
    einem erfolgreichen Upload ist nun auf Port 81 ein weiteres
    Webinterface verfügbar, welches Instruktionen zum Abschluss der
    Installation enthält. Sollte die Box nach dem Hochladen der Firmware
    auch Minuten nachdem die Info LED aufgehört hat zu blinken nicht
    mehr erreichbar sein (typischerweise leuchten **periodisch** immer
    wieder alle LEDs auf), so kann die original Firmware mit Hilfe der
    `recover.exe` von AVM wiederhergestellt werden.

### Mac OS X

Im Prinzip und mit ein paar Patches funktioniert ein aktuelles ds-mod
auch unter Mac OS X. Zumindest ist mir gelungen, ds-0.2.9_26-14.2 unter
Mac OS X zum Funktionieren zu überreden.

Zunächst sind folgende Voraussetzungen zu erfüllen:

1.  Datenpartition erstellen, bei der das HFS+ case sensitive
    konfiguriert ist.
2.  Xcode installieren. Dadurch erhält man geeignete Versionen von u. a.
    -   gcc
    -   g++
    -   autoconf
    -   automake
    -   make
    -   [ncurses](http://de.wikipedia.org/wiki/Ncurses)
    -   zlib
    -   flex
    -   bison

Außerdem sind einige (GNU) Utilities nötig, die z.B. über Darwin Ports
installiert werden können:

-   gettext
-   texinfo
-   dos2unix
-   gawk
-   coreutils
-   findutils
-   gsed

Und vermutlich ein paar weitere, wenn man die entsprechenden Packages
anwählt.

Die zusätzlichen Utilities werden in der Regel unter Namen installiert,
die mit g beginnen, um nicht mit den nativen Utilities von Mac OS X in
Konflikt zu geraten. Manche Konfigurationsskripte setzen aber die
Eigenschaften von GNU-Utilities voraus, auch wenn sie unter dem
Standardnamen aufgerufen werden. Daher habe ich mir ein Verzeichnis
erstellt, in dem Symlinks der Standardnamen auf die GNU Utilities
zeigen. Zum Arbeiten mit ds-mod ist dieses Verzeichnis in den Suchpfad
aufzunehmen:

```
	~/gnubin $ ls -l
	total 64
	-rwxr-xr-x   1 enrik  enrik  106 20 Mär 17:23 as
	lrwxr-xr-x   1 enrik  enrik   19 20 Mär 17:18 awk -> /opt/local/bin/gawk
	lrwxr-xr-x   1 enrik  enrik   18 20 Mär 18:32 cp -> /opt/local/bin/gcp
	lrwxr-xr-x   1 enrik  enrik   22 11 Apr 10:11 cpp -> /usr/local/bin/cpp-3.3
	lrwxr-xr-x   1 enrik  enrik   20 11 Apr 10:11 find -> /opt/local/bin/gfind
	lrwxr-xr-x   1 enrik  enrik   23 20 Mär 17:18 install -> /opt/local/bin/ginstall
	-rwxr-xr-x   1 enrik  enrik  106 20 Mär 17:24 ld
	lrwxr-xr-x   1 enrik  enrik   21 20 Mär 17:18 sed -> /opt/local/bin/gnused
```

Die Pseudebefehle `as` und `ld` dienen hier nur dazu, der glibc für den
Kernel-Compiler, die über crosstool erstellt wird, geeignete binutils
vorzugaukeln. Die beiden Dateien sehen so aus:

```
	~/gnubin $ cat as
	#! /bin/sh

	# fake as version for crosstool

	[ "$1" = -v ] && echo GNU assembler 2.13 || /usr/bin/as "$@"
```

```
	~/gnubin $ cat ld
	#! /bin/sh

	# fake ld version for crosstool

	[ "$1" = --version ] && echo GNU ld 2.13 || /usr/bin/ld "$@"
```

```
	~/gnubin $ PATH=$HOME/gnubin:$PATH
```

Außerdem wird ein Patch für ds-mod benötigt, den man hier herunterladen
kann:

-   [ds-0.2.9_26-14.2-macosx.patch.gz](http://www.akk.org/~enrik/fbox/ds-mod/ds-0.2.9_26-14.2-macosx.patch.gz)

Das ganze ist wenig getestet, insbesondere habe ich noch kein so
erstelltes Image ausprobiert.

## Aktualisierung

*Freetz* läuft nun also super auf der Box, und das schon seit längerer
Zeit. Da kommt es unvermeidlich vor, dass AVM eine neue Firmware-Version
herausbringt, und auch die *Freetz*-Entwicklung ist weitergegangen.
Kurzum: Man möchte nun natürlich auch von den neuen Features und
Bugfixes profitieren. Wie bringt man also *Freetz* auf der Box auf den
neuesten Stand?

Die Antwort ist recht einfach: "Siehe oben". Eine Aktualisierung geht
genau so vonstatten, wie auch die Erst-Installation: Man baut sich ein
neues *Freetz*-Image und nutzt dann das "Firmware-Update" der Box.

Hat man für die Installation eine Repository-Version verwendet, bringt
man selbige zuvor auf den aktuellen Stand, indem man in das
Quellverzeichnis wechselt und...

```
	# In das Verzeichnis wechseln, in dem sich das "ausgecheckte" Freetz befindet:
	cd freetz
	# Quelldateien aktualisieren
	svn up
	# ggf. die Paketauswahl überprüfen, verändern, neue Patches aktivieren, etc.
	make menuconfig
	# Image bauen
	make
```

Und jetzt das fertige Image auf die Box.

