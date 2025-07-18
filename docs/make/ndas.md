# ndas - DEPRECATED
  - Package: [master/make/pkgs/ndas/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/ndas/)
  - Maintainer: -

NDAS (**N**etwork **D**irect **A**ttached **S**torage) is Ximeta's
patented technology which enables all digital storage devices (HDD, ODD,
Memory, Tape Drives) direct connection into standard Ethernet networks.
All users or systems on the network can directly control, use and share
those devices.
More info about NDAS on Linux can be found via:
[http://ndas4linux.iocellnetworks.com/](http://ndas4linux.iocellnetworks.com/)
I'm using NDAS currenlty to play movies up to 720p.

### Creating a Feetz Image with NDAS

**Note** NDAS is now supported for little endian (e.g. 7170, 7270) and
big endian (e.g. 7390) thanks to
[ER13](http://www.ip-phone-forum.de/member.php?u=83184).
The changes are introduced in Changeset r11390 to
Changeset r11392, Changeset r11434, and
Changeset r11464.
Follow the directions from the [Wiki](../index.en.html#)
After the following step you can configure the packages you want to have
included in your image.

```
make menuconfig
```

Make sure the following is selected:

```
Package selection  ---> Packages  ---> [*] (binary only)
```

Recommended optional additional packages:

> [NTFS-3G](ntfs-3g.html)
> [Samba](samba.md)

or(/and)

> [NFS Server](nfsd.md) (no ntfs support, but a faster)
> with optionally some additional patches for ext3 or/and ReiserFS (see
> Patches ---→ ... in menuconfig)

### Setup in Freetz

There is currently (Freetz-trunk Changeset r11464) no
web-interface available for NDAS.
You can configure NDAS via console (e.g. via ssh or telnet access), but
you can also use a script in rc.custom to get all configured for NDAS to
work at startup.

#### Manual configure via console

Details can be found in the following two threads
[http://www.ip-phone-forum.de/showthread.php?t=241882](http://www.ip-phone-forum.de/showthread.php?t=241882)
and
[http://www.ip-phone-forum.de/showthread.php?t=149182](http://www.ip-phone-forum.de/showthread.php?t=149182)

First create the needed character and block-devices using the mknod
command.
You can create block-devices for multiple drives and multiple
partitions. Below example for one drive with one partition.

```
mknod -m 644 /dev/ndas c 60 0
mknod -m 644 /dev/nda b 60 0
mknod -m 644 /dev/nda1 b 60 1
```

> For additional partitions you can create the devices nodes with
> /dev/nda<partition-number> b 60 <partition-number>

You can verify the creation of the devices with the following well known
command

```
ls -la /dev/nd*
```

> The block-devices will start with a 'b', character-devices start
> will a 'c'.

Next the kernel moduls needs to be loaded.

```
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_sal.ko
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_core.ko ndas_dev=lan
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_block.ko
```

> The option ndas_dev=lan enables the module only for Eth and WiFi, and
> not for Wan interfaces.
> If you have your internal Ethernet switch configured as router (see
> [here](http://www.ip-phone-forum.de/showthread.php?t=243444)
> for more background info in German), you will connect and access the
> NDAS device only via one of the routed Ethernet ports, and you
> can/should use ndas_dev=eth0
> Be aware that the protocol used by the NDAS device is not routed, so
> only within the broadcast domain you can access the NDAS device.

To verify the three modules are loaded properly you can use the
following command:

```
lsmod
```

Now the NDAS driver 'NDAS Administration Tool' should be started. This
is done with:

```
ndasadmin start
```

Following is to register the netdisk with the ID and key, that should be
found on the NDAS device.

```
ndasadmin register "rrrrr-rrrrr-rrrrr-rrrrr-wwwww" --name ndas-01
```

> The ID is the 'rrrrr-rrrrr-rrrrr-rrrrr' part which is 20 characters
> long, and is always needed. The key is the 'wwwww' part which is 5
> characters long and is optional to allow write access.

If the disk is connected to the LAN network, and powered on the disk
should become visible at this point.
Verify the status via the proc filesystem /proc with the following
commands.

```
cat /proc/ndas/devs
```

> To see the disk details and the status.

```
cat /proc/ndas/devices/ndas-01/slots
```

> Shows the number of slots.

The NetDisks can be enabled with one of the following three modes: For
read access use the following

```
ndasadmin enable -s 1 -o r
```

For read/write access the following can be used:

```
ndasadmin enable -s 1 -o w
```

For shared write access use:

```
ndasadmin enable -s 1 -o s
```

Also a mountpoint is needed that can be created with:

```
mkdir /var/media/ndas/ntfs/
```

As last step, mounting the block-device under the mountpoint just
created. The mount command depends on the formatting of the drive. So
far I had only success with an NTFS formatted drive.

Mount an NTFS formatted drive:

```
ntfs-3g -o rw /dev/nda1 /var/media/ndas
```

A FAT formatted drive should be mounted with:

```
mount -t fat /dev/nda1 /var/media/ndas
```

But I wasn't able to mount my FAT32 formatted drive, also tried -t
vfat.

#### Script at startup

You can use the script in file rc.custom, which can be edited via the
[web-interface](mod.html#rc_custom).

```
#! /bin/sh
# Create the character file to send the commands
test ! -c /dev/ndas && mknod -m 644 /dev/ndas c 60 0
M=0
# Let's create the block device files to access the hard disk.
# Just for 3 hard disk, each with 3 partitions, but you can increase if you want.
for s in a b c;
do
    test ! -b /dev/nd${s} && mknod -m 644 /dev/nd${s} b 60 $M
    for t in 1 2 3;
    do
        M=$(($M + 1))
        test ! -b /dev/nd${s}${t} && mknod -m 644 /dev/nd${s}${t} b 60 $M
    done
    M=$(($M + 16 - $t))
done

# Now load the system abstraced layer implementation for NDAS technology
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_sal.ko > /dev/null 2>&1
if [ ! $? ] ; then
    echo " Module ndas_sal failed to load";
    exit 1;
fi
# Load the NDAS core functions, the proprietary driver.
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_core.ko ndas_dev=lan > /dev/null 2>&1
if [ ! $? ] ; then
    echo " Module ndas_core failed to load"
    exit 1;
fi
# Load the block device implementation for NDAS
insmod /lib/modules/`uname -r`/kernel/fs/ndas/ndas_block.ko > /dev/null 2>&1
if [ ! $? ] ; then
    echo " Module ndas_block failed to load"
    exit 1;
fi
# Start the service
/usr/bin/ndasadmin start > /dev/null 2>&1
if [ ! $? ]; then
    echo " ndasadmin start failed"
    exit 1;
fi

# Register the device
/usr/bin/ndasadmin register rrrrr-rrrrr-rrrrr-rrrrr-wwwww --name ndas-01 > /dev/null 2>&1
sleep 5

# Enable connection with first NDAS blockdevice in exclusive-write mode
/usr/bin/ndasadmin enable -s 1 -o s
sleep 5
mkdir -p /var/media/ndas/usb /var/media/ndas/ntfs /var/media/ndas/fat /var/media/ndas/ext2
sleep 5
# mount ntfs NDAS disk, /dev/nda1 in this case, in read write mode
ntfs-3g -o rw /dev/nda1 /var/media/ndas/ntfs
# mount ext2 NDAS disk, /dev/nda2 in this case
mount /dev/nda2 /var/media/ndas/ext2

# Restart Samba with NetDisk mounted
/etc/init.d/rc.samba restart
# Restart NFS server with NetDisk mounted
/etc/init.d/rc.nfsd restart
```

#### Troubleshooting

Here a list of troubleshooting commands.

1.  ls -la /dev/nd*
    The output should give one character device /dev/ndas, per disk one
    block device starting with /dev/nda for the first disk, and for each
    partition another block device.
    
2.  lsmod
    The output should show the 3 modules loaded, which are
    **ndas_sal**, **ndas_core**, **ndas_block**.
    
3.  cat /proc/ndas/devs
    The output should give the chosen NDASName, the ID, an indication
    if the key is used for write access, serialnumber of the NetDisk,
    NDAS version which is 1, the status of the NetDisk, and the slot
    number that is assigned to the NetDisk.
    
4.  cat /proc/ndas/devices/ndas-01/slots
    The output should give the assigned slots number, which is **1** in
    my case.
    
5.  cat /proc/partitions
    The output should show a NDAS partition for each NetDisk, and one
    for each partition on that NetDisk (so at least two).
    
6.  ls -la /var/media/ndas
    The output should show the mountpoint, and if the NetDisk is mounted
    the content of the NetDisk.
    
7.  mount
    The output should show one line for each partition mounted. It will
    show the device node, the mountpoint, the filesystem type and the
    options used (e.g. read/write (rw) or read only (ro))
    
8.  cat /etc/debug
    Behaves like a tail -f of a regular file where debug messages are
    shown to standard output.

#### Troubleclearing

Some hints that could be helpful.

1.  Unmount the NetDrive partition with
    ` umount /dev/nda<partition-number> `
    If the umount fails verify if applications like Samba are stopped.
    
2.  Disable the NetDisk with
    ` ndasadmin disable -s 1 `
    
3.  Stop the NDAS Driver with
    ` ndasadmin stop `
    Be aware that after stopping the driver you also have to re-register
    the NetDrive.
    
4.  If the enable command indicates the NetDrive is in use by another
    entity, and you know it isn't, power off the NetDrive and try
    again.
    
5.  After powering off the NetDisk I had to do the following to get it
    working again:
    -   Stop Samba or NFS (e.g. /etc/init.d/rc.samba stop, or
        /etc/init.d/rc.nfsd stop)
    -   Unmount the NetDisk (e.g. umount /dev/nda1)
    -   Disable the NDAS NetDisk (e.g. ndasadmin disable -s 1)
    -   Enable the NDAS NetDisk (e.g. ndasadmin enable -s 1 -o s)
    -   Mount the NetDisk again (e.g. ntfs-3g -o rw /dev/nda1
        /var/media/ndas/ntfs)
    -   Start Samba or NFS again (e.g. /etc/init.d/rc.samba start, or
        /etc/init.d/rc.nfsd start)

### Usages

I used to have Ndas toghether with Samba on my 7270v3, to play movies
from the ntfs formated NetDrive, via a Win7 pc over HDMI to my TV.
This is working well for movies upto 720p, 1080p (e.g. upto 8GB). I also
tried a 1080p of about 25GB, but that didn't work out.
Via monitoring using [Net-SNMP](netsnmp.en.html) I found that it is the
CPU resources on the 7270v3, which is the limiting factor.
Currently I'm using Ndas with NFS on my 7390, with ext3 formatted
NetDrive, via a Win7 pc over HDMI to my TV.
I found it possible to play a movie of about 25GB with 1080p, only the
very high detailed fragments where causing issues.
It is still the CPU resources on the 7390 causing a bottleneck.
