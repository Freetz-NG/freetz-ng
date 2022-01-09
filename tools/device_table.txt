# Device Table

When building a target filesystem, it is desirable to not have to<br>
become root and then run 'mknod' a thousand times. Using a device<br>
table you can create device nodes and directories "on the fly".<br>
<br>
This is a sample device table file for use with genext2fs. You can<br>
do all sorts of interesting things with a device table file. For<br>
example, if you want to adjust the permissions on a particular file<br>
you can just add an entry like:<br>
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/sbin/foobar		f	2755	0	0	-	-	-	-	-
```
and (assuming the file /sbin/foobar exists) it will be made setuid<br>
root (regardless of what its permissions are on the host filesystem.<br>
Furthermore, you can use a single table entry to create a many device<br>
minors. For example, if I wanted to create /dev/hda and /dev/hda[0-15]<br>
I could just use the following two table entries:<br>
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/hda		b	640	0	0	3	0	0	0	-
/dev/hda		b	640	0	0	3	1	1	1	15
```

Device table entries take the form of:<br>
```
#<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
where name is the file name,  type can be one of:<br>
```
	f	A regular file
	d	Directory
	c	Character special device file
	b	Block special device file
	p	Fifo (named pipe)
```
uid is the user id for the target file, gid is the group id for the<br>
 target file. The rest of the entries (major, minor, etc) apply only<br>
to device special files.<br>
<br>
Have fun<br>
-Erik Andersen <andersen@codepoet.org><br>
<br>

### Regular directories
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev			d	755	0	0	-	-	-	-	-
/dev/pts		d	755	0	0	-	-	-	-	-
/dev/mapper		d	755	0	0	-	-	-	-	-
/dev/misc		d	755	0	0	-	-	-	-	-
/dev/vinax		d	755	0	0	-	-	-	-	-
#/dev/shm		d	755	0	0	-	-	-	-	-
#/tmp			d	1777	0	0	-	-	-	-	-
#/etc			d	755	0	0	-	-	-	-	-
```

### Regular files
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
#/bin/busybox		f	4755	0	0	-	-	-	-	-
#/etc/shadow		f	600	0	0	-	-	-	-	-
#/etc/passwd		f	644	0	0	-	-	-	-	-
```

### System devices
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/mem		c	640	0	0	1	1	0	0	-
/dev/kmem		c	640	0	0	1	2	0	0	-
/dev/null		c	666	0	0	1	3	0	0	-
/dev/zero		c	666	0	0	1	5	0	0	-
/dev/random		c	666	0	0	1	8	0	0	-
/dev/urandom		c	666	0	0	1	9	0	0	-
#/dev/ram		b	640	0	0	1	1	0	0	-
#/dev/ram		b	640	0	0	1	0	0	1	4
/dev/loop		b	640	0	0	7	0	0	1	8
#/dev/rtc		c	640	0	0	10	135	-	-	-
/dev/console		c	666	0	0	5	1	-	-	-
/dev/tty		c	666	0	0	5	0	-	-	-
/dev/tty		c	666	0	0	4	0	0	1	8
/dev/ttyp		c	666	0	0	3	0	0	1	10
/dev/ptyp		c	666	0	0	2	0	0	1	10
/dev/ptmx		c	666	0	0	5	2	-	-	-
/dev/ttyP		c	666	0	0	57	0	0	1	4
/dev/ttyS		c	666	0	0	4	64	0	1	4
/dev/fb			c	640	0	5	29	0	0	32	4
#/dev/ttySA		c	666	0	0	204	5	0	1	3
/dev/psaux		c	666	0	0	10	1	0	0	-
/dev/ppp		c	666	0	0	108	0	-	-	-
#/dev/pts/		c	640	0	0	136	0	0	1	8
/dev/log		p	666	0	0	1	0	-	-	-
/dev/initrd		b	400	0	0	1	250	-	-
```

### MTD stuff
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/mtd		c	640	0	0	90	0	0	2	11
/dev/mtdblock		b	640	0	0	31	0	0	1	13
```

### Tun/tap driver
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/net		d	755	0	0	-	-	-	-	-
/dev/net/tun		c	640	0	0	10	200	-	-	-
```

### coda driver
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/cfs		c	666	0	0	67	0	0	1	4
```

### bluez
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/vhci		c	644	0	0	10	250	-	-	-
/dev/rfcomm		c	666	0	0	216	0	0	1	32
```

### autofs4
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/autofs		c	660	0	0	10	235	0	0	-
```

### SCSI Devices
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/sda		b	640	0	0	8	0	0	0	-
/dev/sda		b	640	0	0	8	1	1	1	16
/dev/sdb		b	640	0	0	8	16	0	0	-
/dev/sdb		b	640	0	0	8	17	1	1	16
/dev/sdc		b	640	0	0	8	32	0	0	-
/dev/sdc		b	640	0	0	8	33	1	1	16
/dev/sdd		b	640	0	0	8	48	0	0	-
/dev/sdd		b	640	0	0	8	49	1	1	16
/dev/sde		b	640	0	0	8	64	0	0	-
/dev/sde		b	640	0	0	8	65	1	1	16
/dev/sdf		b	640	0	0	8	80	0	0	-
/dev/sdf		b	640	0	0	8	81	1	1	16
```

### Proprietary devices
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/acxHwDrv		c	666	0	0	254	0	0	0	-
/dev/avm_audio		c	666	0	0	250	0	0	0	-
/dev/avm_event		c	666	0	0	241	0	0	0	-
/dev/avm_net_trace	c	666	0	0	255	0	0	1	31
/dev/avm_net_trace	c	666	0	0	255	0	128	1	13
/dev/avm_power		c	666	0	0	252	0	0	0	-
/dev/c55xavm		c	666	0	0	245	0	0	0	-
/dev/capi20		c	666	0	0	68	0	0	0	-
/dev/debug		c	666	0	0	246	0	0	0	-
/dev/dect_io		c	666	0	0	227	0	0	0	-
/dev/dk			c	666	0	0	63	0	0	1	2
/dev/eeprom		c	666	0	0	239	0	0	0	-
/dev/eeprom		c	666	0	0	239	0	1	1	3
/dev/ethsrctab		c	666	0	0	244	255	0	0	-
/dev/kdsld		c	666	0	0	243	0	0	0	-
/dev/kdsld_multid	c	666	0	0	243	1	0	-	-
/dev/kdsld_port		c	666	0	0	254	0	0	-	-
/dev/kdsld_traffic	c	666	0	0	226	0	0	-	-
/dev/kdsld_user		c	666	0	0	229	0	0	0	-
/dev/kdsldptrace	c	666	0	0	244	0	0	1	5
/dev/kdsldptrace	c	666	0	0	244	0	17	1	4
/dev/led		c	666	0	0	247	0	0	0	-
/dev/new_led		c	666	0	0	251	0	0	0	-
/dev/Piglet		c	666	0	0	250	0	0	0	-
/dev/tffs		c	666	0	0	240	0	0	0	-
/dev/tiatm		c	644	0	0	230	0	0	0	-
/dev/ubik_boot_0	c	666	0	0	245	0	0	0	-
/dev/ubik_boot_last	c	666	0	0	245	3	0	0	-
/dev/ubik_debug		c	666	0	0	245	30	0	0	-
/dev/usblp0		c	666	0	0	180	0	0	0	-
/dev/userman		c	666	0	0	228	0	0	0	-
/dev/watchdog		c	666	0	0	242	0	0	0	-
/dev/ttyUSB		c	666	0	0	188	0	0	1	4
/dev/ttyACM		c	666	0	0	166	0	0	1	2
/dev/fuse		c	666	0	0	10	229	-	-	-
/dev/misc/fuse		c	666	0	0	10	229	-	-	-
/dev/mapper/control	c	666	0	0	10	63	-	-	-
/dev/vinax/0		c	666	0	0	253	0	-	-	-
/dev/vinax/cntrl0	c	666	0	0	253	128	-	-	-
/dev/mmf		b	666	0	0	254	0	0	1	5
```

### Fritzbox 7340
```
#<name>			<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
```
```
/dev/acl		c	666	0	0	201	0	-	-
/dev/bme		c	666	0	0	254	0	-	-
/dev/kdsld_misc		c	666	0	0	253	0	0	0	-
```

