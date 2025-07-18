# Transmission 3.00/4.0.6 (binary only)
  - Homepage: [https://transmissionbt.com/download/](https://transmissionbt.com/download/)
  - Manpage: [https://github.com/transmission/transmission/wiki](https://github.com/transmission/transmission/wiki)
  - Changelog: [https://github.com/transmission/transmission/releases](https://github.com/transmission/transmission/releases)
  - Repository: [https://github.com/transmission/transmission](https://github.com/transmission/transmission)
  - Package: [master/make/pkgs/transmission/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/transmission/)
  - Maintainer: [@fda77](https://github.com/fda77)

### Blocklist

If you want to use a peer-blocklist (you can enable this in the web
interface if you are using the trunk version of Freetz), you have to
know that you have to provide a blocklist yourself. The simplest is to
make a 'update-blocklist.sh' with the content below and to invoke it
daily or so using cron (don't forget to make the file executable).

```
#!/var/tmp/sh

cd /path-to/bittorrent/config/blocklists/
if wget -q http://www.bluetack.co.uk/config/level1.gz ; then
        rm -f level1 && gunzip level1.gz
        killall -HUP transmission-daemon
        logger -s -t transmission "blocklist updated"
else
        logger -s -t transmission "blocklist not updated"
fi
```

This can be done from the transmission web interface too now.

### Number of peers

It is probably a good idea to reduce the number of peers by editing the
*.../bittorrent/config/settings.json* file:

```
    "peer-limit-global": 150,
    "peer-limit-per-torrent": 50,
```

You have to stop transmission before changing this! Or you could use
this command to reload the config file:

```
killall -HUP transmission-daemon
```

This can be done from the transmission web interface too now.

### Memory usage

Huge, relatively.

You will probably need a swap file and you may want to increase
[swappiness](http://lwn.net/Articles/83588/) to 80
or something (in Freetz WebIF since
(Changeset r6886).

```
  ------------------------- ------------ -----------
                            **VmSize**   **VmRSS**
  No blocklist              ~8,5 mB     ~6 mB
  level1 blocklist          ~17 mB      ~8 mB
  One torrent + blocklist   ~19 mB      ~12 mB
  ------------------------- ------------ -----------
```

You can monitor these values easily with the patch from ticket
Ticket #1308

### Limit memory usage

To prevent memory shortage (could cause reboots and crashing processes):

```
    "cache-size-mb": 1,
    "open-file-limit": 32,
```

The cache size is by default 2 MiB and the open file limit is by default
32.

To minimize the number of connections you could decide to forward TCP
traffic only and not UDP traffic.

### Watchdog

It may be necessary to disable the watchdog by adding this line to for
example *rc.custom*:

```
    echo "disable">/dev/watchdog
```

### Weiterführende Links

-   [Transmission](http://transmissionbt.com/)
    (external)
-   [Editing Configuration
    Files](https://trac.transmissionbt.com/wiki/EditConfigFiles)
    (external)
-   [Block List Updater
    Script](http://trac.transmissionbt.com/wiki/Scripts/BlockListUpdater)
    (external)
-   [Wikipedia about
    µTP](http://en.wikipedia.org/wiki/Micro_Transport_Protocol)
-   [Transmission Remote
    GUI](http://code.google.com/p/transmisson-remote-gui/)
