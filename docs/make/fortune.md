# fortune 1.2 - DEPRECATED
  - Package: [master/make/pkgs/fortune/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/fortune/)
  - Maintainer: -

Das Computerprogramm Fortune ist traditionell auf Computern mit Unix
oder Linux als Betriebssystem zu finden. Es existieren aber auch für
Windows entsprechende Programme.
Seine Funktion besteht darin, "fortune cookies" (Glückskekse) und
andere humorvolle Aphorismen anzuzeigen.
Dank an
[zyrill](http://www.ip-phone-forum.de/member.php?u=234921)
für dieses sinnfreie aber äußerst lustige Paket. So macht Konsole wieder
Spaß.

### Paket konfigurieren

[![Fortune Einstellungen](../screenshots/220_md.png)](../screenshots/220.png)

Falls man das Paket fortune im menuconfig ausgewählt hat kann man es
über das Webinterface konfigurieren. Dazu ist nur der Pfad mit den
Keksen anzugeben und nach dem Speichern kann man sich sofort an den
Sprüchen erfreuen. Solche fortune-Dateien findet man zum Beispiel
[hier](http://www.freebsd.org/cgi/cvsweb.cgi/src/games/fortune/datfiles/).

### Anzeigen von fortunes beim Konsolen-Login

Meist werden fortunes automatisch beim Systemstart oder Einloggen
gestartet. Das Unix-Shell-Kommando für Fortune ist ***fortune***
Um dies zu bewerkstelligen, müssen die entsprechenden Befehle in die
*.profile* im HOME-Directory des users eingefügt werden.
Dies kann zum einen über das Freetz-Webinterface unter *Freetz:.profile*
geschehen, oder über die Konsole in der */var/mod/root/.profile*
Folgendes reicht dafür aus:

```
echo
/usr/bin/fortune
echo
```

Nach erfolgtem Login auf der Box per telnet bzw. ssh begrüßt die Box
euch mit einem zufällig gewählten Glückskeks:

```
   __  _   __  __ ___ __
  |__ |_) |__ |__  |   /
  |   |  |__ |__  |  /_

   The fun has just begun...

BusyBox v1.15.3 (2010-01-21 20:22:22 CET) built-in shell (ash)
Enter 'help' for a list of built-in commands.

ermittle die aktuelle TTY
tty is "/dev/pts/0"
Console Ausgaben auf dieses Terminal umgelenkt

GRAMMAR IS NOT A TIME OF WASTE
GRAMMAR IS NOT A TIME OF WASTE
GRAMMAR IS NOT A TIME OF WASTE
GRAMMAR IS NOT A TIME OF WASTE

        Bart Simpson on chalkboard in episode AABF10

/var/mod/root #
```

### Weiterführende Links

-   [fortune auf
    Wikipedia](http://en.wikipedia.org/wiki/Fortune_%28Unix%29)
-   [fortune man
    page](http://linux.die.net/man/6/fortune)
-   [IPPF-Thread](http://www.ip-phone-forum.de/showthread.php?t=196686)

