#!/bin/sh
#by cuma


. /mod/etc/conf/vnstat.cfg
[ -r /etc/options.cfg ] && . /etc/options.cfg

_NICE="$(which nice 2>/dev/null)"
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
TEMPDIR=/tmp/vnstat
mkdir -p $TEMPDIR

gen_pic() {
	local trans dark range="$2"
	if [ "$FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON" != "y" ]; then
		[ "$range" = "top10" ] && range="top 10"
		[ "$VNSTAT_DARK_MODE" = "yes" ] && dark='--invert-colors'
		[ "$VNSTAT_TRANS_BGD" = "yes" ] && trans=' --transparent 1'
	fi
	$_NICE vnstati -i $1 --$range -o $TEMPDIR/$1-$2.png --config /tmp/flash/vnstat/vnstat.conf $trans $dark
	echo "<p><img src=\"/vnspix/$1-$2.png$NOCACHE\" alt=\"vnStat: $2 of $1\" border=\"0\"/></p>"
}

#main
echo "<center>"
netif=$(cgi_param netif)

#count ifs
ifcnt=0
for ifname in $VNSTAT_INTERFACES; do
	let ifcnt++
done
[ $ifcnt -eq 1 ] && netif=$VNSTAT_INTERFACES

#show pix
if [ -n "$netif" ]; then
	#subpages
	echo "<p><font size=+1><b>vnStat: $netif</b></font></p>"
	[ "$FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON" == "y" ] \
	  && periods="summary hours days months       top10" \
	  || periods="summary hours days months years top10"
	for period in $periods; do
		[ $ifcnt -ne 1 ] && echo "<a href=\"$SCRIPT_NAME\" class='image'>"
		gen_pic $netif $period
		[ $ifcnt -ne 1 ] && echo "</a>"
	done
	if [ $ifcnt -ne 1 ]; then
		[ -n "$HTTP_REFERER" ] && backdest="history.go(-1)" || backdest="window.location.href='$SCRIPT_NAME'"
		echo "<br><input type=\"button\" value=\"Back\" onclick=\"javascript:$backdest\" />"
	fi
else
	#mainpage
	echo "<p><font size=+1><b>vnStat</b></font></p>"
	if [ -z "$VNSTAT_INTERFACES" ]; then
		if [ "$FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON" == "y" ]; then
			VNSTAT_INTERFACES=$(ls /var/lib/vnstat/ 2>/dev/null)
		else
			VNSTAT_INTERFACES=$(vnstat --dbiflist 1 2>/dev/null)
		fi
	fi
	for dbfile in $VNSTAT_INTERFACES; do
		echo "<a href=\"$SCRIPT_NAME?netif=$dbfile\" class='image'>"
		gen_pic $dbfile summary
		echo "</a>"
	done
fi

echo "</center>"

