# Iptables 1.4.11.1/1.4.21/1.6.2/1.8.11 (binary only)
  - Homepage: [https://netfilter.org/projects/iptables/index.html](https://netfilter.org/projects/iptables/index.html)
  - Changelog: [https://netfilter.org/projects/iptables/downloads.html](https://netfilter.org/projects/iptables/downloads.html)
  - Repository: [https://git.netfilter.org/iptables/](https://git.netfilter.org/iptables/)
  - Package: [master/make/pkgs/iptables/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/iptables/)
  - Maintainer: [@fda77](https://github.com/fda77)

### Current state (largely broken)

For the 7390 and later, but also for the 7270 with releases from the
last years, iptables doesn't work with 'connection tracking' and
'state matching'.
Without these two options a lot of configuration scenarios are not
possible. If you look for an iptables/ip6tables solution without the use
of connection tracking or state matching you can try to add ip tables
form the Freetz menu configuration (make menuconfig), but read on for
additional information.

What I understood the reason for connection tracking & state matching
not working is two fold.
For connection tracking and state matching specifically, AVM has its own
connection tracking solution, which uses the same symbol names, causing
a conflict with the iptables modules. Secondly the behavior of Packet
Acceleration (PA) causes packets not to be handled by the kernel, but by
the PA kernel module
([Avm_pa.ko](http://www.wehavemorefun.de/fritzbox/Avm_pa.ko)).
Packet Acceleration is a feature that AVM introduced years back (end
2011).

An reason not to use an older firmware for e.g. the 7270 is a
significant vulnerability that was publically misused around February
2014 ([vulnerability
info](https://www.heise.de/newsticker/meldung/Angriffe-auf-Fritzboxen-AVM-empfiehlt-Abschaltung-der-Fernkonfiguration-2106542.html)).
AVM released firmware fixes for most boxes.

### What is iptables and who needs it?

**iptables** is a command line user interface for managing and
configuring the built-in Linux kernel netfilter firewall.

It targets users, who want to achieve full control over their network
traffic and efficiently protect their private networks from Internet
hacker attacks and spy-ware.

Properly configured, the iptables / netfilter package on the FritzBox
router protects all devices behind from unwanted access. This filter is
able to check, dump, forward, prioritize or manipulate network packages
and implement a border line defense against DoS attacks, port scans and
unwanted traffic. It can e.g. stop "home calling" of installed
software packages etc. This package leverages the FritzBox hardware to a
feature-rich, powerful Firewall solution, comparable to expensive
professional business grade devices.

The basic netfilter filter engine is built-in into the Linux kernel -
this has implications to the different FritzBox types since the 72xx
boxes all have a more recent kernel than the 71xx variants. So some
features of iptables are only available in the newer 7270.

-   the older boxes (71xx) have issues with the conntrack module
    (limited RAM and the old Linux kernel leads to Memory overflows of
    the tracking tables resulting in unexpected reboots of the box)
-   There is no Web UI for iptables on the 7270 yet.
-   7270 has more RAM and a more recent kernel - conntrack works great
    (conntrack = connection tracking module, implements stateful
    firewall package rules, e.g. for ftp, VoIP, etc.)
-   some syntax of iptables commands / abilities differ between 71xx and
    7270 boxes.
-   the command / abilities depend on loaded modules (iptables is a
    modular system!), some error messages result from missing / not yet
    loaded modules.

### What is the difference between AVM Firewall and iptables, can they co-exist on the same system?

-   The [AVM Firewall](avm-firewall.md) is an integrated part
    of the **dsld** from AVM (dsl daemon). It "sits" on the DSL
    interface and controls exclusively the traffic trough this
    interface. The abilities include connection tracking (stateful),
    port forwarding, traffic shaping and packet filtering. After passing
    the dsld module, the data packages arrive at the internal interface
    and are distributed to the box and their interfaces without further
    control. The default input / output rules are set to PERMIT,
    anything is allowed, what is not blocked by a specific rule. There
    are only few rules set to block some NetBIOS ports and a known virus
    port. Inbound traffic is protected by NAT (network address
    translation) only, only packages requested from inside (connection
    tracking) or set by port forwarding rules can be translated to the
    destination private (RFC) IP address range. However this is a week
    protection, many ports are open by default (VoIP, TR064 / TR069
    ...), the dsld is a piece of proprietary undocumented software of
    AVM, no source code is available, many multimedia ports are open,
    also remote management via tr069/tr064 is by default open to the
    ISPs, what is a potential vulnerability. Logging is not implemented.

<!-- -->

-   iptables based firewalls are deeply integrated into lowest layers of
    the Linux kernel. They control any network traffic from / to or
    through the box. They are the ultimate protection of the box from
    unwanted access both from outside and LAN traffic. Using iptables
    one can implement powerful DMZ security zones, protection against
    DoS attacks and port scans, and even a deep-inspection of data
    packages is possible. Beside this, one can define rules for virtual
    interfaces, control VPN tunnel traffic and create source /
    destination NAT rules for virtual hosts. Iptables / netfilter is a
    powerful, state-of-the-art Open Source firewall - and last but not
    least it can log the traffic by rules!

<!-- -->

-   Both firewall solutions act on completely different areas (AVM FW is
    completely encapsulated in the dsld module, iptables/netfilter is
    integrated in the OS kernel), so they and their rules are
    independent from each other, beside the fact, that the (external)
    traffic is serialized and must bypass both: that means a ALLOW rule
    of the one cannot bypass a DENY/REJECT rule of the other, both must
    be configured to allow the desired traffic. Here some pass-trough
    examples:

> > Traffic targeting the FritzBox:
> > **DSL < --- > AVM Firewall (NAT) < --- > iptables Firewall <
> > --- > (FritzBox) < --- > iptables Firewall < --- > LAN /
> > WLAN**

> > Traffic between the Internet and LAN interfaces:
> > **DSL < --- > AVM Firewall (NAT) < --- > iptables Firewall <
> > --- > LAN / WLAN**

> > DMZ or VPN Tunnel traffic to LAN/WLAN :
> > **DMZ / Tunnel Interfaces < --- > iptables Firewall < --- > LAN
> > / WLAN**

-   Because AVM FW controls the dsl modem, one cannot completely remove
    it without a replacement while operating the box as a DSL router.
-   Both firewalls can operate side-by-side without any issues, one has
    to consider, that both need to be configured to allow desired
    traffic (serialization)
-   Because they are "cascaded", one can benefit from increased
    security: a hacker must bypass 2 independent firewall solutions to
    gain access to the box and devices behind.
-   Even ISP operators are using the "backdoor" configuration
    capabilities of tr064/tr069 protocol have no chance to access the
    router and devices behind protected by well-configured iptables
    rules.
-   The best-practise configuration / strongest protection can be
    achieved by applying rigorous traffic rules on both firewalls and
    allowing only necessary traffic.

### How to build iptables for Freetz?

-   select iptables **and** all needed modules using **[make
    menuconfig](../help/howtos/common/install/menuconfig.html)**
    while building the firmware (unstable branch)
-   not listed modules (e.g. ULOG target) can be added after
    reconfiguring and replacing the kernel **[replace
    kernel](../help/howtos/development/make_kernel.html)** /
    **make kernelconfig** (for experienced developers only!)
-   the availability of the modules depends on the kernel version and
    configured kernel options.

### Configuration: After successful firmware build and upload

-   first of all: it is recommended to test the rules interactively
    using ssh or telnet.
-   before one can start defining rules, the modules have to be loaded
    by **modprobe** into the RAM.

Here an example script to load the necessary modules for the rules
described in this wiki:

```
# the most common modules needed:
modprobe ip_tables
modprobe iptable_filter
modprobe x_tables
modprobe xt_tcpudp

# Alternative LOG und REJECT targets:
modprobe ipt_LOG
modprobe ipt_REJECT

# if one wants to use ip ranges in the rules:
modprobe ipt_iprange

# same for port ranges:
modprobe xt_multiport

# for stateful firewall rules (conntrack):
modprobe xt_state
modprobe xt_conntrack
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_conntrack_tftp
```

-   After registering / loading the modules we can start defining rules
    (here some rules for a strong basic protection):

```
# # # FIREWALL RULES

iptables -N TRANS
# Outbound for surfing the Internet:
# 20 FTP data, 21 FTP, 22 SSH, 25 SMTP, 80 HTTP, 110 POP3, 443 HTTPS, 465 SSMTP, 995 POP3S, 5060 VoIP
# 53 DNS, 67/68 DHCP, 80 HTTP, 123 NTP, 5060 VoIP
iptables -A TRANS -p tcp  -s 192.168.0.0/24 -m multiport --dport 20,21,22,25,80,110,443,465,995,5060 -j ACCEPT
iptables -A TRANS -p udp  -s 192.168.0.0/24 -m multiport --dport 53,67,68,80,123,5060 -j ACCEPT
iptables -A TRANS -p icmp -s 192.168.0.0/24 -j ACCEPT

# conntrack rules for returning data packages:
iptables -A TRANS -m state --state RELATED,ESTABLISHED -j ACCEPT

# ... Some rules for known hosts
# ...

iptables -A TRANS -j LOG --log-prefix "[IPT] DENY-LAN-ACCESS "          # log all dropped packets
iptables -A TRANS -j DROP                                               # PARANOIA LINK

# # # Rules for Fritz Device

iptables -A INPUT -p udp -s 0.0.0.0 -d 255.255.255.255 --sport 68 --dport 67 -j ACCEPT #DHCP
iptables -A INPUT -s 127.0.0.1 -d 127.0.0.1 -j ACCEPT                 # LOCALHOST
iptables -A INPUT -s 192.168.0.0/24 -j ACCEPT                         # LAN
iptables -A INPUT -s 169.254.0.0/16 -i lan -j ACCEPT                  # EMERGENCY LAN
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 5060 -j ACCEPT                       # VoIP
iptables -A INPUT -p udp --dport 5060 -j ACCEPT                       # VoIP
iptables -A INPUT -j LOG --log-prefix "[IPT] DENY-FRITZ-ACCESS "      # Log other traffic
iptables -A INPUT -j DROP                                             # PARANOIA IN
iptables -P INPUT DROP                                                # Default policy DROP

iptables -A OUTPUT -d 192.168.0.0/24 -j ACCEPT                        # Allow LAN
iptables -A OUTPUT -d 224.0.0.1/24 -j ACCEPT                          # UPnP
iptables -A OUTPUT -d 239.255.255.250 -j ACCEPT
iptables -A OUTPUT -d 127.0.0.1 -j ACCEPT                             # Local Host
iptables -A OUTPUT -p udp -m multiport --dport 53,123,5060 -j ACCEPT  # DNS, TIME, VoIP
iptables -A OUTPUT -p tcp --dport 5060 -j ACCEPT                      # VoIP
iptables -A OUTPUT -p tcp --dport 80 -d 63.208.196.0/24 -j ACCEPT     # DynDNS
iptables -A OUTPUT -d myMailServer.com -j ACCEPT                      # e-Mail OUT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT     # stateful conntrack
iptables -A OUTPUT -d 212.42.244.73 -p tcp --dport 80 -j ACCEPT       # Plugins Server AVM

# iptables -A OUTPUT -d www.dasoertliche.de    -p tcp --dport 80 -j ACCEPT # Phone book reverse look-up targets
# iptables -A OUTPUT -d www.dastelefonbuch.de  -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.goyellow.de        -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.11880.com          -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.google.de          -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.das-telefonbuch.at -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.search.ch          -p tcp --dport 80 -j ACCEPT
# iptables -A OUTPUT -d www.anywho.com         -p tcp --dport 80 -j ACCEPT

iptables -A OUTPUT -j LOG --log-prefix "[IPT] WARNING-CALL-HOME "      # Log forbidden outbound traffic
iptables -P OUTPUT DROP                                                # and DROP it.

# # # Rules for FORWARD

iptables -P FORWARD DROP
iptables -A FORWARD -j TRANS                                           # LAN - WAN traffic rules
iptables -A FORWARD -j LOG --log-prefix "[IPT] DENY-FWD-ACCESS "
```

-   compared to the AVM firewall, iptables rules apply immediately,
    without the need of a restart.
-   after testing, iptables rules can be persisted in the following
    script: **/var/flash/debug.cfg**, so they survive a box reboot.
-   first load all needed modules with **modprobe**
-   than define **iptables** rules in the right order (top down
    processing)
-   Packages passing LOG targets are shown on console 0.

### Hints regarding FritzBox 7270:

AVM has customized the printk module while implementing DECT base
station functions, that is responsible for the handling of the kernel
log messages, and they do not hit the syslog any longer. With this
command one can temporary turn off the AVM printk (what leads to
unavailability of DECT) to get a real syslog / klog of system messages.

> ***echo STD_PRINTK > /dev/debug***

To revert the settings to AVM printk and re-enable DECT type:

> ***echo AVM_PRINTK > /dev/debug***

The log appears then again on console 0 and is no longer in the syslog.

You can also try a patch from Ticket #254, but first read
the comments carefully.

### What is the difference of INPUT, OUTPUT and FORWARD chains

-   the INPUT chain filters inbound traffic to the box / localhost
    itself, this rules expose services of the FritzBox to the "rest of
    the world".
-   the OUTPUT chain filters outbound traffic initiated by the box, this
    are rules for services the box needs from outside (e.g. DNS,
    NTP,etc.)
-   the FORWARD chain filters traffic trough the box from one interface
    to another (e.g. Internet < --- > LAN/WLAN ) (pass-trough
    services)
-   the conntrack rules target the returning data packets, they must be
    defined in the complementary path (for INPUT rules in the OUTPUT
    path etc.)

### Hints regarding the example code

-   the first rule of the INPUT chain should be an ACCEPT rule for the
    admin interface to prevent a lock-out from the box (don't forget
    the according conntrack rule in the OUTPUT chain!).
-   set the default policy for all chains to DENY after everything is
    tested and works (last rule!)
-   in the example there was a new chain TRANS defined to show the
    capabilities of this great piece of software.
-   in the example there are no rules for VoIP traffic, one can easily
    add them when needed
-   there are no NAT rules, because NAT is already done by dsld, we use
    both firewalls here
-   we use only some of the available modules, please feel free to load
    others using *modprobe* when needed for special rules
-   this example is quite restrictive regarding the traffic of the box
    to the Internet, anything not explicitly allowed is forbidden.
-   it gives you only a glimpse of the opportunities iptables offers,
    for more information search online for the wiki of iptables /
    netfilter in your preferred language.

### Isolate guest network from LAN

These rules will prevent access to the local area network, including the
box itself from the guest network:

```
iptables -A INPUT -d 192.168.178.0/24 -i guest -j DROP
iptables -A FORWARD -i guest -o dsl -j ACCEPT
iptables -A FORWARD -i guest -j DROP
iptables -A OUTPUT -s 192.168.178.0/24 -o guest -j DROP
```

The guest network can only use the internet. Assuming the default subnet
(192.168.178.0/24).

### More Links

-   [cpmaccfg](../help/howtos/security/switch_config.html) - How
    to build a DMZ
-   [OpenVPN](openvpn.md) - VPN Tunnel on the FritzBox
-   [AVM Firewall](avm-firewall.md) - The little Brother of
    iptables
-   [Freetz as interner Router /
    Firewall](../help/howtos/security/router_and_firewall.html)
-   [Split WLAN and LAN using
    iptables](../help/howtos/security/split_wlan_lan.html)
-   [IPv6
    Sicherheit](http://www.ip-phone-forum.de/showpost.php?p=1488444&postcount=74)
-   [On
    Netfilter](http://wiki.openwrt.org/doc/howto/netfilter)
-   Search [Freetz -
    Forum](http://www.ip-phone-forum.de/forumdisplay.php?f=525) -
    Best place for questions regarding Freetz!

### Questions

-   Should UDP 80 not be blocked?
-   Should 224.0.0.1/24 and 239.255.255.250 not be blocked on the WAN
    side?
