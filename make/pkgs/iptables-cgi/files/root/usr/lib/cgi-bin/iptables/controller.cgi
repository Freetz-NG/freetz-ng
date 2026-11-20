#!/bin/sh

. /usr/lib/libmodcgi.sh
csrf_require_post

# POST parameters for remove option
eval "$(modcgi chain:remove iptables_delete)"

# Deleting Rule
if [ $IPTABLES_DELETE_CHAIN ] && [ $IPTABLES_DELETE_REMOVE ]; then
	if [ $IPTABLES_DELETE_CHAIN = "PREROUTING" ] || [ $IPTABLES_DELETE_CHAIN = "POSTROUTING" ]; then
		SPECIAL='-t nat '
	fi
	iptables $SPECIAL-D $IPTABLES_DELETE_CHAIN $IPTABLES_DELETE_REMOVE > /dev/null 2>&1
	iptables-save > /var/tmp/flash/iptables_rules
fi

echo "Status: 302 Found"
echo "Location: $(href cgi iptables/editor)"
echo
exit
