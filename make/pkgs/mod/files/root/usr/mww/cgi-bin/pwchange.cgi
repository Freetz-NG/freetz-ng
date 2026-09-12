#!/bin/sh

if [ "$1" = "successful" ]; then
	. /usr/lib/libmodcgi.sh
	cgi --id=PW_changed
	cgi_begin "$(lang de:"Passwort ge&auml;ndert!" en:"Password changed!")"
	echo "<p>&nbsp;<p><b>$(lang de:"Passwort erfolgreich ge&auml;ndert!" en:"Password successfully changed!")</b><p>"
	echo "<script type='text/javascript'> window.setTimeout('location.href=\"/cgi-bin/index.cgi\"', 5000);</script>"
	cgi_end
	exit
fi

if [ -n "$(echo "$QUERY_STRING" | sed -n 's%.*newhash=\([0-9a-f]*\).*%\1%p')" ]; then
	source /usr/mww/cgi-bin/pwchange_check.sh
else
	source /usr/mww/cgi-bin/pwchange_page.sh
fi
