# bash 3.2.57 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/bash/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/bash/)
  - Maintainer: -

Bei der **B**ourne **A**gain **Sh**ell handelt es sich um eine
[Unix
Shell](http://de.wikipedia.org/wiki/Unix-Shell) - oder,
anders ausgedrückt, um einen "Kommandozeilen Interpreter" für Unix-
und Linuxsysteme. Dabei ist die *Bash* nicht einfach irgend eine Shell,
sondern die wohl am meisten verbreitete - und findet sich daher auch auf
fast allen Unix-/Linuxsystemen wieder. *Bash* ist Teil des
[GNU
Projekts](http://de.wikipedia.org/wiki/GNU-Projekt).

Der Name wurde absichtlich vieldeutig gewählt. So ist die *Bash* voll
kompatible zur originalen *Bourne Shell* (sh) (also "(schon) wieder
eine Bourne Shell", oder die "Wiedergeborene Shell"). Andere leiten
den Namen vom Verb "to bash" (schlagen) oder auch vom Substantiv
"bash" (Feier, Party, Schlag) ab...

Wie bereits erwähnt, ist die Bash für viele Systeme verfügbar: Unixe,
Linux,
[Cygwin](http://de.wikipedia.org/wiki/Cygwin),
[MSYS](http://de.wikipedia.org/wiki/MSYS) und sogar
die [Microsoft Windows Services for
UNIX](http://de.wikipedia.org/wiki/Microsoft_Windows_Services_for_UNIX)
gehören dazu. Und hiermit natürlich auch die Freetz Box
:-?

Hinweis: Die im Folgenden beschriebene manuelle Anpassung des Prompts
ist seit
Changeset r5803 (freetz-devel)
nicht mehr nötig, da es dort bereits eingebaut ist.

Man kann den sog. Prompt anpassen, also das, was jeweils vor dem Cursor
angezeigt wird. Dazu muss man die Variable PS1 anpassen, was man sehr
bequem über das Freetz-WebGUI unter Einstellungen/.profile machen kann.
Die Bash kennt für den Prompt u.a. folgende Variablen für PS1:

```
h : Host name
H : Host name inklusive Domain
d : Datum
t : time Zeit
u : User Benutzerkennung
w : Working directory, aktuelles Arbeitsverzeichnis
l : Terminalname, zum Beispiel tty1
# : Eingabezeilennummer
 : Das Zeichen ""
```

So lassen sich im Prompt z.B. auch noch User- und Hostname zusätzlich
zum aktuellen Pfad anzeigen:

```
export PS1="u@h w $ "
```

Das Resultat mit o.g. Beispiel sieht dann so aus:

```
root@fb1 /var/mod/root $
```

Der Host (die Fritzbox) heisst genauso wie es in der Variable
/proc/sys/kernel/hostname steht, hier also "fb1" (Standard ist
"fritz.box").

Ash
===

Das Ganze funktioniert sowohl für bash (mit diesem Paket installiert)
als auch für ash (Standard in Freetz, ohne zusätzliches Paket), wobei
ash nur folgendes unterstützt:

```
h : Host name
u : User Benutzerkennung
w : Working directory, aktuelles Arbeitsverzeichnis
# : Eingabezeilennummer
```

### Bash als Loginshell

TODO

### Weiterführende Links

-   [Wikipedia
    Artikel](http://de.wikipedia.org/wiki/Unix-Shell#Die_Bourne-Again-Shell)
-   [Englischer Wikipedia
    Artikel](http://en.wikipedia.org/wiki/Bash) mit
    umfangreicheren Details
-   [Homepage der
    Bash](http://www.gnu.org/software/bash/bash.html)
-   [Bash
    Guide](http://tldp.org/LDP/Bash-Beginners-Guide/html/index.html)
    for Beginners
-   [ABS](http://tldp.org/LDP/abs/html/index.html) -
    der **A**dvanced **B**ash **S**cripting Guide
-   [Bash Online Forum](http://bashscripts.org/)
-   [bash - Die Bourne again shell im
    LinuxWiki](http://linuxwiki.de/Bash)

