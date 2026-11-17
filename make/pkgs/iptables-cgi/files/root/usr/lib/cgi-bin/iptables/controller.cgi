#!/bin/sh

. /usr/lib/libmodcgi.sh
csrf_check required

# HTML QUERY STRING for remove option
IPTABLES_DELETE_CHAIN=$(cgi_param chain)
IPTABLES_DELETE_RULE=$(cgi_param remove)

# Deleting Rule
if [ $IPTABLES_DELETE_CHAIN ] && [ $IPTABLES_DELETE_RULE ]; then
	if [ $IPTABLES_DELETE_CHAIN = "PREROUTING" ] || [ $IPTABLES_DELETE_CHAIN = "POSTROUTING" ]; then
		SPECIAL='-t nat '
	fi
	iptables $SPECIAL-D $IPTABLES_DELETE_CHAIN $IPTABLES_DELETE_RULE > /dev/null 2>&1
	iptables-save > /var/tmp/flash/iptables_rules
fi

echo "Status: 302 Found"
echo "Location: $(href cgi iptables/editor)"
echo
exit
