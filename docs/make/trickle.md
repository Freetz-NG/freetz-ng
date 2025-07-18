# trickle 1.07 (binary only) - DEPRECATED
  - Package: [master/make/pkgs/trickle/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/trickle/)
  - Maintainer: -

**trickle** (Tröpfeln) ist ein leichtgewichtiger bandwidth shaper, der
mit trickled oder im stand alone mode verwendet werden kann. Mit trickle
kann man festlegen, welche Bandbreite eine Anwendung benutzen darf.
Somit kann die Internetverbindung auch während großer
[Downloads](../Download.html), noch für andere Programme (z. B.
Telefonie) benutzbar bleiben. Der Datenverkehr wird über eine eigene
dynamische Bibliothek (trickle-overload.so), die von trickle beim Start
geladen wird, geregelt. trickle kann nur TCP-Verbindungen drosseln.
trickle benötigt keine root-Rechte. trickle kann nur mit dynamisch
gelinkten Anwendungen verwendet werden. Will man die Bandbreite von
statisch gelinkten Anwendungen drosseln, so sollte man trickle mit einem
Proxy (z. B. Privoxy oder ffproxy) verwenden und die statisch gelinkten
Anwendungen zwingen (z. B. mit iptables), diesen Proxy zu verwenden. Bei
Mehrbenutzerbetrieb an der Box, sollte trickle auch mit einem proxy
verwendet werden. Mit trickle hat man auch die Belastung der Box unter
Kontrolle, da eine geringere Bandbreite auch weniger Speicher und
weniger CPU-Leitung beansprucht. D. h. man kann das Neustarten
(rebooten) der Box verhindern. Mit trickle kann der ein- und ausgehende
Netzwerkverkehr so gesteuert werden, dass sowohl die Leitung als auch
die Box optimal genutzt werden.

### Syntax

```
Usage: trickle [-hvVs] [-d <rate>] [-u <rate>] [-w <length>] [-t <seconds>]
               [-l <length>] [-n <path>] command ...
        -h           Help (this)
        -v           Increase verbosity level
        -V           Print trickle version
        -s           Run trickle in standalone mode independent of trickled
        -d <rate>    Set maximum cumulative download rate to <rate> KB/s
        -u <rate>    Set maximum cumulative upload rate to <rate> KB/s
        -w <length>  Set window length to <length> KB
        -t <seconds> Set default smoothing time to <seconds> s
        -l <length>  Set default smoothing length to <length> KB
        -n <path>    Use trickled socket name <path>
        -L <ms>      Set latency to <ms> milliseconds
        -P <path>    Preload the specified .so instead of the default one
```

```
Usage: trickled [-hvVfs] [-d <rate>] [-u <rate>] [-t <seconds>] [-l <length>]
                [-p <priority>] [-c <file>] [-n <path>] [-N <seconds>]
                [-w <length>]
        -h            Help (this)
        -v            Increase verbosity level
        -V            Print trickled version
        -f            Run trickled in the foreground
        -s            Use syslog instead of stderr to print messages
        -d <rate>     Set maximum cumulative download rate to <rate> KB/s
        -u <rate>     Set maximum cumulative upload rate to <rate> KB/s
        -t <seconds>  Set default smoothing time to <seconds> s
        -l <length>   Set default smoothing length to <length> KB
        -p <priority> Set default priority to <priority>
        -c <file>     Use configuration file <file>
        -n <path>     Set socket name to <path>
        -N <seconds>  Notify of bandwidth usage every <seconds> s
        -w <length>   Set window size to <length> s
```

### Beispiele für die Benutzung von trickle

**1. Über einen Proxy:**

```
trickle -s -u 20 -d 100 /var/mod/etc/init.d/rc.privoxy start
```

```
wget -e "http_proxy = http://192.168.127.253:8118" http://speedtest.netcologne.de/test_10mb.bin
--2010-02-21 10:07:58--  http://speedtest.netcologne.de/test_10mb.bin
Verbindungsaufbau zu 192.168.127.253:8118... verbunden.
Proxy Anforderung gesendet, warte auf Antwort... 200 OK
Länge: 10485760 (10M) [application/octet-stream]
In »test_10mb.bin« speichern.
100%[==========================================================================================================================================>] 10.485.760  20,2K/s   in 8m 53s
2010-02-21 10:16:51 (19,2 KB/s) - »test_10mb.bin« gespeichert [10485760/10485760]
```

**2. Direkt auf die Anwendung:**

```
trickle -s -u 50 -d 70 wget http://speedtest.netcologne.de/test_10mb.bin
--2010-03-06 22:54:02--  http://speedtest.netcologne.de/test_10mb.bin
Resolving speedtest.netcologne.de... 87.79.12.103, 87.79.12.102
Connecting to speedtest.netcologne.de|87.79.12.103|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 10485760 (10M) [application/octet-stream]
Saving to: `test_10mb.bin.1'

100%[==========================================================================================================================================>] 10,485,760  52.6K/s   in 2m 59s

2010-03-06 22:57:00 (57.4 KB/s) - `test_10mb.bin.1' saved [10485760/10485760]
```

**Auslastung der Box (aus top):**

```
2660  1901 root     S     3028  10%   2% wget http://speedtest.netcologne.de/test_10mb.bin
```

**Stichworte für die Suche:** traffic, bandwidth, shaping, shaper,
limiter, throttling, bandbreitenbegrenzung, bandbreite, drosseln,
begrenzen

### Weiterführende Links

[trickle](http://monkey.org/~marius/pages/?page=trickle)

[Artikel in
linuxuser](http://www.linux-user.de/ausgabe/2005/11/056-trickle/index.html)

[manpage
trickle](http://monkey.org/~marius/trickle/trickle.1.txt)

[manpage
trickled](http://monkey.org/~marius/trickle/trickled.8.txt)

[manpage
trickled.conf](http://monkey.org/~marius/trickle/trickled.conf.5.txt)

[trickle bei
Debian](http://patch-tracker.debian.org/package/trickle/1.07-9)

