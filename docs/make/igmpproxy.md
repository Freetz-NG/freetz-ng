# IGMPproxy 0.4
 - Homepage: [https://github.com/pali/igmpproxy](https://github.com/pali/igmpproxy)
 - Changelog: [https://github.com/pali/igmpproxy/releases](https://github.com/pali/igmpproxy/releases)
 - Repository: [https://github.com/pali/igmpproxy/commits/master](https://github.com/pali/igmpproxy/commits/master)
 - Package: [master/make/pkgs/igmpproxy/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/igmpproxy/)

**[igmpproxy](http://sourceforge.net/projects/igmpproxy/)**
ist ein einfacher multicast routing Daemon der für multicast forwarding
zwischen Netzwerken z.B. für IPTV benutzt wird.

```
Usage: igmpproxy [-h] [-d] [-v [-v]] <configfile>

   -h   Display this help screen
   -d   Run in debug mode. Output all messages on stderr
   -v   Be verbose. Give twice to see even debug messages.
```

Configfile:

```
########################################################
#
#   Example configuration file for the IgmpProxy
#   --------------------------------------------
#
#   The configuration file must define one upstream
#   interface, and one or more downstream interfaces.
#
#   If multicast traffic originates outside the
#   upstream subnet, the "altnet" option can be
#   used in order to define legal multicast sources.
#   (Se example...)
#
#   The "quickleave" should be used to avoid saturation
#   of the upstream link. The option should only
#   be used if it's absolutely nessecary to
#   accurately imitate just one Client.
#
########################################################

##------------------------------------------------------
## Enable Quickleave mode (Sends Leave instantly)
##------------------------------------------------------
quickleave

##------------------------------------------------------
## Configuration for nas0 (Upstream Interface)
##------------------------------------------------------
phyint nas0 upstream  ratelimit 0  threshold 1
        altnet 10.1.12.0/24

##------------------------------------------------------
## Configuration for lan (Downstream Interface)
##------------------------------------------------------
phyint lan downstream  ratelimit 0  threshold 1

##------------------------------------------------------
## Configuration for Disabled Interfaces
##------------------------------------------------------
phyint dsl disabled
phyint lo disabled
```

Damit igmpproxy auf der FritzBox läuft muss multid mit der option "-i"
(disable IGMP-Proxy) gestarted werden. Die Namen der Interfaces sind
abhängig von der Konfiguration der Box und müssen angepasst werden. Im
Beispiel wird das von [br2684ctrl](br2684ctl.html) erzeugte
"nas0" als Upstream Interface verwendet.

Derzeit ist igmpproxy nur als Binary (0.1) für Freetz verfügbar, d.h. es
gibt noch kein WebGUI für grafische Einstellungen.

### Weiterführende Links

-   [igmpproxy
    SourceForge](http://sourceforge.net/projects/igmpproxy/)
-   [IPPF-Thread: AONTV mit der
    FritzBox](http://www.ip-phone-forum.de/showthread.php?t=208004&highlight=aontv)

