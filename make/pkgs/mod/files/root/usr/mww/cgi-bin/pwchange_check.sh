#!/bin/sh

WRONGPW=0
ID_IP=$(cat /tmp/pwchangesid 2>/dev/null)
CHAL=${ID_IP%#*}
IP=${ID_IP#*#}
oldhash=$PWCHANGE_OLDHASH
newhash=$PWCHANGE_NEWHASH
UPWHASH="$(cat /tmp/flash/mod/webmd5)"
myhash="$(echo -n "$CHAL$UPWHASH" | md5sum | sed 's/  .*//')"


if [ "$REMOTE_ADDR" = "$IP" -a  "$oldhash" = "$myhash" ]; then
	echo "$newhash" > /tmp/flash/mod/webmd5
	modsave flash > /dev/null 2>&1
	QUERY_STRING=""
	. /usr/mww/cgi-bin/pwchange.cgi successful
else
	WRONGPW=1
	QUERY_STRING=""
	REQUEST_METHOD=GET
	. /usr/mww/cgi-bin/pwchange.cgi && exit
fi

