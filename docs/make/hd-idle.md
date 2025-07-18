# hd-idle 0.99 - DEPRECATED
  - Package: [master/make/pkgs/hd-idle/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/hd-idle/)
  - Maintainer: -

**[hd-idle](http://hd-idle.sourceforge.net/)** ist
ein Tool, um externe Festplatten nach einer festgelegten "Idle-Zeit"
(also "Nix-Tun") herunterzufahren ("Spin-Down"). Da die meisten
externen IDE-Festplatten-Gehäuse das Setzen eines "Idle-Timers" nicht
erlauben, wird ein Utility wie *hd-idle* (oder das mit Freetz ebenfalls
verfügbare *[spindown-CGI](spindown.md)*) benötigt, um den Job
zu erledigen.

Es gibt, herstellerabhängig 3 verschiedene Powermodes:

```
active/idle (normal operation)
standby (low power mode, drive has spun down)
sleeping (lowest power mode, drive is completely shut down)
```

