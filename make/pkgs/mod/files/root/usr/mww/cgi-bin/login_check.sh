#!/bin/sh

WRONGPW=0
ID_IP=$(cat /tmp/loginsid 2>/dev/null)
SID=${ID_IP%#*}
IP=${ID_IP#*#}
eval "$(modcgi hash:subpage login)"
[ -f /tmp/flash/mod/webmd5 ] || echo "465d0ff27bb239292778dc3a0c2f28d9" > /tmp/flash/mod/webmd5
UPWHASH="$(cat /tmp/flash/mod/webmd5)"
myhash="$(echo -n "$SID$UPWHASH" | md5sum | sed 's/ .*//')"

if [ "$REMOTE_ADDR" = "$IP" ] && [ "$LOGIN_HASH" = "$myhash" ]; then
	touch /tmp/$SID.webcfg
else
	SENDSID=""
	QUERY_STRING=""
	WRONGPW=1
	. /usr/mww/cgi-bin/login_page.sh
fi
# still default-PW "freetz"? Change
if [ "$UPWHASH" == "465d0ff27bb239292778dc3a0c2f28d9" ]; then
	. /usr/lib/libmodredir.sh
	redirect_302 /cgi-bin/pwchange.cgi
	exit
fi
#. $PWD/index.cgi

subpage="$(echo "$LOGIN_SUBPAGE" | sed 's/^\/*//;s/&.*//;s/[^-_a-zA-Z0-9\.\/]//g;s/\.\.//g')"
[ "$subpage" == "cgi-bin/login.cgi" -o "$subpage" == "cgi-bin/logout.cgi" ] && subpage=''
. /usr/lib/libmodredir.sh
redirect "/$subpage"

