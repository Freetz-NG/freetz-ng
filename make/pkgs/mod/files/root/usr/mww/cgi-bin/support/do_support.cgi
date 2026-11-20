#!/bin/sh
# include environment variables
. /usr/lib/libmodcgi.sh
csrf_require_post

. /bin/env.mod.rcconf

fname=$(echo ${CONFIG_PRODUKT_NAME}_${CONFIG_VERSION_MAJOR}.${CONFIG_VERSION}-$(cat /etc/.freetz-version)$(date '+_%Y-%m-%d_%H%M_support.tgz') | tr ' !' '_.')
CR=$'\r'
echo "Content-Type: application/x-gzip${CR}"
echo "Content-Disposition: attachment; filename=\"$fname\"${CR}"
echo "${CR}"

# Make sure that no command accidentally writes stdout or stderr stuff into the
# output stream = gzipped tar archive. File descriptor 3 is the real output.
exec 3>&1 > /dev/null 2>&1


SUPDIR="/tmp/support"
rm -rf $SUPDIR 2>/dev/null
mkdir -p $SUPDIR

# general
[ -x "$(which run_clock)" ] && echo -e "run_clock -S:\n$(run_clock -S)\n"         >> $SUPDIR/general.txt
echo -e "uname -a:\n$(uname -a)\n"                                                >> $SUPDIR/general.txt
for f in /etc/.version /etc/.freetz-version /etc/.revision /etc/.subversion; do
	[ -e $f ] && echo -e "$f:\n$(cat $f)\n"                                       >> $SUPDIR/general.txt
done
for s in run_clock uptime free; do
	echo -e "$s:\n$($s)\n"                                                        >> $SUPDIR/general.txt
done

# bin-output
for b in ps dmesg lsmod mount logread ifconfig showdsldstat; do
	[ -x "$(which $b)" ] && $b > $SUPDIR/$b.out 2>&1
done

tffs_major="$(sed -n 's/ tffs$//p' /proc/devices)"
[ ! -e /var/flash/crash.log ] && mknod /var/flash/crash.log c "$tffs_major" 95
[ ! -e /var/flash/panic ] && mknod /var/flash/panic c "$tffs_major" 96
# (log)files
for l in $(find /etc/*.pkg /var/log/* /etc/.config /etc/options.cfg /tmp/flash/mod/rc.* /var/flash/debug.cfg /var/flash/crash.log /var/flash/panic /var/env.* /proc/partitions /proc/bus/usb/devices /mod/etc/conf/cs_cams.cfg /mod/etc/conf/tbflex.cfg -type f -o -type c); do
	cat $l > $SUPDIR/${l##*/} 2>&1
done
[ -e $SUPDIR/.config ] && mv $SUPDIR/.config $SUPDIR/config.txt

# anonymize
sed -i 's/\(callmonitor:   SOURCE=\).*/\1HIDDEN-FON/g;s/\(callmonitor:   DEST=\).*/\1HIDDEN-FON/g' $SUPDIR/*
sed -i 's/dsl serial number successfully set to.*/=HIDDEN-SER=/g' $SUPDIR/*
sed -i 's/\([0-9A-F]\{2\}:\)\{5\}[0-9A-F]\{2\}/=HIDDEN-MAC=/g' $SUPDIR/*
sed -i 's/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/=HIDDEN-IP4=/g' $SUPDIR/*
sed -i 's/[0-9a-f]\{1,4\}:\{1,2\}\([0-9a-f]\{1,4\}:\)\{2,6\}:\{0,1\}\([0-9a-f]\{1,4\}\)\{0,1\}/=HIDDEN-IP6=/g' $SUPDIR/*


# send to user
tar cz -C $SUPDIR $(ls $SUPDIR) >&3

#cleanup
rm -rf $SUPDIR

