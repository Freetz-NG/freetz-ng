# br2684ctl (binary only) - DEPRECATED
  - Package: [master/make/pkgs/br2684ctl/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/br2684ctl/)
  - Maintainer: -

This package allows you to connect to your ISP via additional virtual
circuits (ATM PVC's).
For some (older) setup's multiple virtual circuits are used to ofer
Triple Play services where for each service (e.g High speed Internet,
Broadband TV and Voice) a virtual circuit is used.
More modern networks often used one converged IP network with only one
virtual circuits.
More info on the br2684ctl package can be found at:
[https://home.regit.org/technical-articles/atm-bridging/](https://home.regit.org/technical-articles/atm-bridging/)
[http://http://home.sch.bme.hu/~cell/br2684/USAGE.br2684](http://http://home.sch.bme.hu/~cell/br2684/USAGE.br2684)

Source:
[http://home.sch.bme.hu/~cell/br2684/dist/010402/brctl-010226.c](http://home.sch.bme.hu/~cell/br2684/dist/010402/brctl-010226.c)
Patch:
[http://home.sch.bme.hu/~cell/br2684/dist/010402/br2684-against2.4.2.diff](http://home.sch.bme.hu/~cell/br2684/dist/010402/br2684-against2.4.2.diff)

### Creating a Freetz Image with br2684ctl

I used Freetz-1.2 for a FritzBox 7170.

Follow the directions from the [Wiki](../index.en.html#)
After the following step you can configure the packages you want to have
included in your image.

```
make menuconfig
```

```
Package selection  --->  Testing  --->    [*] br2684ctl (binary only)
```

For Client DHCP you can additionally enable the following option.
You can also add a script (default.script) to the image at compile time
(see below for details).

```
Advanced options  ---> BusyBox options  --->    [*] udhcpc
```


### Configuring br2684ctl

There is no GUI interface for br2684ctl. There is only one executable
with a number of mandatory and optional parameters.

```
 br2684ctl [-c n -e 0|1 -b -s buf_size [-q qos] -a [itf.]vpi.vci ]
```

ATM PVC number, VPI and VCI.
-a [itf.]vpi.vci

BR2684 interface number such as nas0, nas1,..., where the number is n
(e.g. nas0 is -c 0).
This is a mandatory parameter.
-c n

Encapsulation method. 0=LLC, 1=VC mux. default is 0, LLC
This is a mandatory parameter.
-e 0|1

Running background. Default (parameter ommited) is foreground.
-b

Send buffer size. Default is 8192.
-s buf_size

Optionally there are QoS parameters for traffic shaping, and cell rate
limiting.
-q <shaping type>,<encapsulation
type>:max_pcr≤rate>,min_pcr≤rate>,max_sdu≤frame-size>
shaping type: {ubr|cbr}
encapsulation type: all5
maximum peak cell rate: rate in [M|k]bps
minimum peak cell rate: rate in [M|k]bps
maximum service delivery unit: maximum frame size that is segmented in
the ATM cells.

Example:
Creating ATM PvC 0/32 in the background with interface name nas0 using
LLC encapsulation.

```
 br2684ctl -b -e 0 -c 0 -a 0.32
```

```
 br2684ctl -e 0 -c 0 -q ubr,aal5:max_pcr=5Mbps,min_pcr=320kbps,max_sdu=1524 -a 0.32
```

After the interface is created you can see it with the following
command:

```
 ifconfig -a
```

or

```
 ifconfig nas0
```

Some details can be viewed at:

```
cd /proc/net/atm/
ls -la
cat <file>
```


### Obtain IP configuration via DHCP

The udhcpc package, part of BusyBox, is a DHCP Client program, that
obtains configuration parameters from a DHCP Server.
Udhcpc configures enviroment variables with the parameter values
obtained from the DHCP Server.
A configure script (e.g. a shell script) can make use of these variables
to configure an interface, DNS servers, NTP Servers, and a lot of other
possible information.

Freetz doesn't have a (default) DHCP configure script.
Here an example script to just configure an IP address with broadcast
address and subnetmask.
To include the script (default.script) at compile time follow the
following steps:

```
cd ~/freetz-x.y/addon/
echo default.script >> static.pkg
mkdir -p default.script/root/etc/dhcp/
vi default.script/root/etc/dhcp/default.script

#!/bin/sh

[ -z "$1" ] && "Error: should be run by udhcpc" && exit 1

case "$1" in
        deconfig)
                ifconfig $interface 0.0.0.0
                # echo interface = $interface
        ;;
        leasefail)
        ;;
        nak)
        ;;
        renew|bound)
                ifconfig $interface $ip 
                broadcast $broadcast 
                netmask $subnet
                # echo interface = $interface
                # echo ip address = $ip
                # echo subnet = $subnet
                # echo netmask = ${subnet:-255.255.255.0}
        ;;
esac
```

Enable the interface:

```
 ifconfig nas0 up
```

Obtain ip configuration info via DHCP:

```
 udhcpc -i nas0 -s /etc/dhcp/default.script
```

### Debuging the DHCP process

To obtain additional debug information from the udhcpc package you need
to enable this, and recompile a new image.

```
cd ~/freetz-x.y/source/target-mipsel_uClibc-0.9.29/ref-8mb/busybox-1.18.5
vi .config
```

In the .config file search for CONFIG_UDHCP_DEBUG=0 and change it to:

```
CONFIG_UDHCP_DEBUG=3
```

Initiate recompile of the busybox packages during the next make:

```
cd ~/freetz-1.2/
make busybox-clean
```

Compile a new image with:

```
make
```

After installing the new image on the FritzBox start the DHCP Client
with:

```
udhcpc -i nas0 -s /etc/dhcp/default.script -vvv
```

> the number of v's determines the detail of debug packages.
