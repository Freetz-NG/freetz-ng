# bluez-utils 2.25 (binary only, incl. Pin-Change and NAP) - DEPRECATED
  - Package: [master/make/pkgs/bluez-utils/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/bluez-utils/)
  - Maintainer: -

Official Linux Bluetooth protocol stack

### General

It was quite an adventure to get this working, without any BlueZ
documentation, but here we go
:-)

PAN
---

Freetz PAN Server:

-   Use provided default config
-   Start/enable DBUS & BlueZ

(Android) PANU Client:

-   Pair your device with *fritz.fonwlan.box-0*
-   Make your device discoverable

Freetz PAN Server:

-   Find your device

    ``` 
    hcitool scan
    ```

-   Trust your device:

    ``` 
    dbus-send --system --type=method_call --dest=org.bluez --print-reply /org/bluez/$(pidof bluetoothd)/hci0/dev_YY_YY_YY_YY_YY_YY org.bluez.Device.SetProperty string:Trusted variant:boolean:true
    ```

-   Restart BlueZ to persist data

Android PANU Client:

-   Make the connection (Android: root required!):

    ``` 
    hcitool scan
    pand --connect xx:xx:xx:xx:xx:xx
    sleep 7
    netcfg bnep0 dhcp
    setprop net.dns1 46.182.19.48
    ifconfig rmnet0 up # trick to make apps think there is an internet connection
    ```

Ignore any message from the Android browser that there is no connection
:-)

Automation: use [Script
Manager](https://market.android.com/details?id=os.tools.scriptmanager) or
use [NC Bluetooth
Tether](https://market.android.com/details?id=earlmagnus.nctether).

Ubuntu client:

-   Make the connection:

    ``` 
    hcitool scan
    sudo pand --connect xx:xx:xx:xx:xx:xx
    sudo ifconfig bnep0 up
    sudo dhclient bnep0
    ```

*Tested with a Sitecom CN-517 USB dongle (pretty generic) through a
USB-hub on a 7270v2 international with the (patched) btusb module and an
Android device with a [CyanogenMod
7](http://www.cyanogenmod.com/) ROM and with a Ubuntu Lucid
Lynx client.*

lsusb:

```
VID=0a12
PID=0001
CLS=224
SCL=01
SPEED='full'
VER='2.0'
ISOC=1
INUM=2
ICLS1=224
ISCL1=01
ICLS2=224
ISCL2=01
```

*Not tested with hci_usb (earlier kernels; will probably work) and
bfusb (AVM - BlueFRITZ! USB).*

DUN
---

-   Select 'Replace kernel'
-   Select package pppd (Standard packages, Point-to-Point)
-   I have no idea how DUN works, so maybe someone else can write the
    rest of the guide
    :-)

### DBUS

See all interface methods:

```
dbus-send --system --dest=org.bluez --print-reply /org/bluez/$(pidof bluetoothd)/hci0 org.freedesktop.DBus.Introspectable.Introspect
```

See the properties of your adapter:

```
dbus-send --system --type=method_call --dest=org.bluez --print-reply /org/bluez/$(pidof bluetoothd)/hci0 org.bluez.Adapter.GetProperties
```

See the properties of your device:

```
dbus-send --system --type=method_call --dest=org.bluez --print-reply /org/bluez/$(pidof bluetoothd)/hci0/dev_YY_YY_YY_YY_YY_YY org.bluez.Device.GetProperties
```

### Sizes

```
  libbluetooth .................   55.07 Kb
  libdbus ......................   86.59 Kb
  libexpat .....................   43.79 Kb
  libglib_2 ....................  237.86 Kb
  libpcre ......................   60.75 Kb

  crc16.ko .....................    1.27 Kb
  btusb.ko .....................    6.25 Kb
  bnep.ko ......................    7.30 Kb
  bluetooth.ko .................   27.58 Kb
  l2cap.ko .....................   17.07 Kb
  rfcomm.ko ....................   22.10 Kb

  dbus-1.5.8 ...................  143.21 Kb
  bluez-4.101 ..................  285.39 Kb
```

### Weiterführende Links

-   [BlueZ](http://www.bluez.org/)
-   Bluez 4.98 patch: Ticket #602

