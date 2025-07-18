# Knock 0.8 - DEPRECATED
  - Homepage: [https://www.zeroflux.org/projects.html](https://www.zeroflux.org/projects.html)
  - Manpage: [https://linux.die.net/man/1/knockd](https://linux.die.net/man/1/knockd)
  - Changelog: [https://github.com/jvinet/knock/blob/master/ChangeLog](https://github.com/jvinet/knock/blob/master/ChangeLog)
  - Repository: [https://github.com/jvinet/knock](https://github.com/jvinet/knock)
  - Package: [master/make/pkgs/knock/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/knock/)
  - Maintainer: -

*"Wer klopfet, dem wird aufgetan"* - so könnte man dieses Paket
überschreiben. *knockd* bietet eine gute Möglichkeit, Dienste von Remote
zu starten. Läuft der (übrigens sehr resourcenschonende) Knock-Daemon
auf der Fritzbox, so kann man z.B. - bei entsprechender Konfiguration -
durch das korrekte "Klopfzeichen" signalisieren, dass man "rein
möchte". Wurde der richtige "Knock Code" gesendet, startet knockd das
zugehörige Programm (z.B. den SSH Daemon). Ein weiteres "Klopfen"
beendet ihn dann später wieder. Dieses Vorgehen bietet zusätzliche
Sicherheit, da Ports nur dann offen sind, wenn man sie auch wirklich
braucht - der Portscan eines Hackers läuft also damit meist ins Leere.

### Weiterführende Links

-   [Ein kurzer Workshop zu
    knockd](http://wiki.hetzner.de/index.php/Knockd)
-   [Artikel zu
    "Portknocking"](http://blog.roothell.org/archives/146-Portknocking-Tools-Teil-1-knockd.html)
-   [Knockd Demo auf
    YouTube](http://www.youtube.com/watch?v=EbzrLPf6D7Y)

