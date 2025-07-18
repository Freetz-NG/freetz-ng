# NFSD CGI
  - Package: [master/make/pkgs/nfsd-cgi/](https://github.com/Freetz-NG/freetz-ng/tree/master/make/pkgs/nfsd-cgi/)
  - Maintainer: -

NFSD_CGI is the web-interface for the NFSD (Server) on Freetz.

Some observations:
Currently using NFS with a 7390 using Freetz-trunk revision 11466.
Using this revision I didn't observe permission issues like with
Freetz-1.2 for my 7270v3.
As mount I'm using a [NDAS-NetDisk](ndas.md) which is Ext3
formatted.

### /etc/exports (exports in GUI)

My currect config allows 192.168.178.0/24 and localhost (for the local
NFS Client).

```
/var/media/ndas/ext3 192.168.178.0/255.255.250.0(rw,no_subtree_check) localhost(rw)
```

### /etc/hosts.allow

Looks only the first two lines are needed, but the others should not
harm.

```
mountd,nfsd,portmap: 192.168.178.0/255.255.255.0 , localhost
lockd: 192.168.178.0/255.255.255.0 , localhost
rquotad: 192.168.178.0/255.255.255.0 , localhost
statd: 192.168.178.0/255.255.255.0 , localhost
```

### /etc/hosts.deny

Only deny the NFS related services

```
mountd,nfsd,portmap:ALL
lockd:ALL
rquotad:ALL
statd:ALL
```

### Verification on Server:

Below some helpfull commands for trouble-shooting on the server.
Unfortunately `rpcinfo` and `nfsstat` where not available on my FB.
Maybe `rpcinfo` is available if 'replace kernel' is used.

List of kernel supported filesystems by the FB:

```
cat /proc/filesystems
```

Just look if the filesystems you are planning to use are listed.

```
/etc/init.d/rc.nfsd status
```

Status should be `running`. Use the following `ps` command first to see
which processes are actually running before restarting the nfs server.

```
ps -wl | grep 'nfs|portmap|lockd|statd|mountd|quota'
```

portmap, lockd, mountd, and nfsd should be all listed as a process.
You can use `/etc/init.d/rc.nfsd stop` and `/etc/init.d/rc.nfsd start`
to stop and start the nfs server.

```
exportfs
```

Should show the hosts or subnets (incl. localhost if configured)
configured in /etc/exports

```
mount
```

Look that the mounted disk allows rw (if intended)

If you also have the [NFS Client](/wiki/packages/nfs.en) installed on
the FB, the following verification is available:

```
mount -t nfs localhost:/<share-path> /<mount-point>
```

To show from the server which nfs exports are in use:

```
showmount --all
showmount --exports
```

To verify layer-4 network information (e.g. used ports):

```
netstat -anp
```


```
logread
```

### rsize and wsize buffers

The read and write buffers are assigned during the `mount` on the
client.
The server supports a buffer size that range from 4kbytes to 1024kbytes
(RPCSVC_MAXPAYLOAD (1*1024*1024u)) in steps of 1kbyte.
Finding the optimal buffer size is normally the best option to get a
better performance.
I only have a ndas Net-Disk mounted, and found that all rsize values had
a similar variation in the results.
The FB CPU is the bottleneck.
It might be interesting to retest this with a USB-stick to see if than
varying the buffersizes would show a difference.

I tested the performance with
[Bonnie++](http://www.coker.com.au/bonnie++) using
one of the [experimental
versions](http://www.coker.com.au/bonnie++/experimental/)

#### Bonnie++

For this I used two scripts to: run the test, unmount/mount both client
and server mounts, restart nfsd, and mounted the client with a different
rsize parameter.
During the tests I only varied the rsize parameter, because I'm only
interested in the read optimalisation now, but changing both wsize and
rsize is also possible.
Each test takes about 35 minutes (with 1gigbyte transfers), so you can
do about 16 overnight.
Here the scripts I used:

main script:

```
#!/bin/sh

# the initial test with a rsize of 32768 (=32k) and increased with steps of 32k to 1024k
# rsize=32768
# for the second test again 32 test using 1gigabyte using the best result -16*1k to +16*1k
# rsize to test is rsize=294912. Start rsize is
rsize=(294912-16384)
i=1
date > results.txt
date +%s >> results.txt
while [ $i -le 32 ]; do
        echo ======================================================= >> results.txt
        echo =======================================================
        echo setup bonny++ test with rsize of $(($rsize+1024*$i))
        echo setup bonny++ test with rsize of $(($rsize+1024*$i)) >> results.txt
        mount -o hard,intr,rsize=$(($rsize+1024*$i)) 192.168.178.1:<full_share_path> <local_mount_point>
        bonnie++ -d <local_mount_point> -s 1g -n 0 -m nfs_client_$rsize -f -b -u root >> results.txt 2>> results.txt
        echo ======================================================= >> results.txt
        umount <local_mount_point>
        expect autologin.sh
        i=$(($i + 1))
done
date >> results.txt
date +%s >> results.txt
```

expect script:

```
#!/usr/bin/expect

spawn ssh root@192.168.178.1
# expect "connecting (yes/no)?"
# send "yes"
expect "assword:"
send "<your_passwd>"
expect "#"
send "/etc/init.d/rc.nfsd stop"
expect "done."
send "umount /dev/nda2"
expect "#"
send "mount /dev/nda2 <mount-point>"
expect "#"
send "/etc/init.d/rc.nfsd start"
expect "done."
```

You can obtain a nice html page of your results with:

```
cat results.txt | grep ,,, | bon_csv2html > /tmp/nfs_client_test.html
```

But you can also use the csv format output in an Excel sheet. I attached
3 html files showing my results.

#### MRTG CPU Util

[![CPU Util 7390 bonnie++ test script](../screenshots/276_md.png)](../screenshots/276.png)

In the [MRTG](netsnmp.en.html) graph of the CPU Utilization you can
clearly see that the CPU Utilization is the bottleneck in my setup using
a [NDAS NetDisk](ndas.md).
The picture shows I started the test at about 7:20am which took until
1:10am the next day.
Than I did two manual bonny++ tests at 1:15am and 2am. Than started a
new batch test using the scripts at about 2:45am.

### References

[NFS
howto](http://nfs.sourceforge.net/nfs-howto/index.html)
[bonnie++](http://www.coker.com.au/bonnie++/) and
the
[experimental](http://www.coker.com.au/bonnie++/experimental/)
page
[bonnie++
examples](http://www.googlux.com/bonnie.html)

