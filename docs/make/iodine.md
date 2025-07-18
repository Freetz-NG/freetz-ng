# iodine 0.7.0 - DEPRECATED
  - Package: [master/make/pkgs/iodine/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/iodine/)
  - Maintainer: -

**[iodine](http://code.kryo.se/iodine/)** erlaubt
es, IPv4 Daten über DNS zu tunneln. Eine hilfreiche Sache, wenn man z.B.
hinter einer restriktiven Firewall sitzt - da DNS Traffic in den
seltensten Fällen geblockt wird
;)

### Weiterführende Links

-   [iodine Homepage](http://code.kryo.se/iodine/)
-   [iodine Man
    page](http://linux.die.net/man/8/iodine)
-   [iodine
    documentation](http://code.kryo.se/iodine/README.html)

### Using with FreeDNS

See package [dns2tcp](dns2tcp.html) for signing up with FreeDNS
and some other details.

Put this in your *rc.custom* (there is no WebIF):

```
mkdir /tmp/iodine
chown nobody /tmp/iodine
iodined -c -P <password> -u nobody -t /tmp/iodine 10.0.0.1 -p 10053 dns2tcp.strangled.net
```

(assuming user *nobody* exists)

The trunk version of Freetz has an iodine WebIF now
(Changeset r6657; thanks oliver!)

Create a tunnel from the client like this:

```
sudo ./bin/iodine -f -P <password> dns2tcp.strangled.net
```

To connect to [Polipo?]:

```
ssh root@10.0.0.1 -L 8123:localhost:8123
```

The advantages over [dns2tcp](dns2tcp.html) are:

-   There is an iodine Windows client available
-   It is possible to run iodine on Android
-   Traffic can easily be route through the tunnel

Building [iodine for
Android](http://blog.bokhorst.biz/5123/computers-en-internet/iodine-for-android/).

### Security

Install [iptables](iptables.md) and add these rules to allow
only traffic to the internet and not your local net:

```
iptables -I OUTPUT -o dns0 -s 192.168.178.0/24 -j DROP
iptables -I INPUT -i dns0 -d 192.168.178.0/24 -j DROP
iptables -A FORWARD -i dns0 -o dsl -j ACCEPT
iptables -A FORWARD -i dns0 -j DROP
```

Of course you can always allow specific traffic from tunnel to your
local net, for example to a SSH server by using something like:

```
iptables -I INPUT -i dns0 -p tcp --dport 22 -j ACCEPT
```

### Forwarding

iodine can forward DNS requests for unknown (sub)domains to a real
DNS-server on another port with this switch:

```
-b 5353
```

