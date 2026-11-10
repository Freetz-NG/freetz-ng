#!/bin/sh

WRONGPW=0
ID_IP=$(cat /tmp/loginsid 2>/dev/null)
SID=${ID_IP%#*}
IP=${ID_IP#*#}
hash=${QUERY_STRING##*hash=}
[ -f /tmp/flash/mod/webmd5 ] || echo "465d0ff27bb239292778dc3a0c2f28d9" > /tmp/flash/mod/webmd5
UPWHASH="$(cat /tmp/flash/mod/webmd5)"
myhash="$(echo -n "$SID$UPWHASH" | md5sum | sed 's/[ ]*-.*//')"

if [ "$REMOTE_ADDR" = "$IP" -a "$hash" = "$myhash" ]; then
	touch /tmp/$SID.webcfg
else
	SENDSID=""
	QUERY_STRING=""
	WRONGPW=1
	. /usr/mww/cgi-bin/login_page.sh
fi
# still default-PW "freetz"? Change
[ "$UPWHASH" = "465d0ff27bb239292778dc3a0c2f28d9" ] && . /usr/mww/cgi-bin/pwchange.cgi && exit
#. $PWD/index.cgi

subpage="$(echo "${QUERY_STRING}" | sed -n 's/.*\?subpage=//p' | sed 's/^\/*//;s/&.*//;s/[^-_a-zA-Z0-9\.\/]//g;s/\.\.//g')"
[ "$subpage" == "cgi-bin/login.cgi" -o "$subpage" == "cgi-bin/logout.cgi" ] && subpage=''
. /usr/lib/libmodredir.sh
redirect "/$subpage"

