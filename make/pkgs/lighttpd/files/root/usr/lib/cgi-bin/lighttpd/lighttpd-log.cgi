#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

LOGA="/var/log/lighttpd_access.log"
LOGE="/var/log/lighttpd_error.log"

if [ "$FREETZ_PACKAGE_LIGHTTPD_MOD_ACCESSLOG" = "y" ]; then
	if [ -r "$LOGA" ]; then
		echo "<h1>lighttpd access log $(realpath $LOGA)</h1>"
		echo -n '<pre class="log">'
		html < $LOGA
		echo '</pre>'
	else
		echo "<h1>lighttpd access log unavailable</h1>"
	fi
else
	echo "<h1>mod_accesslog unavailable</h1>"
fi

if [ -r "$LOGE" ]; then
	echo "<h1>lighttpd error log $(realpath $LOGE)</h1>"
	echo -n '<pre class="log">'
	html < $LOGE
	echo '</pre>'
else
	echo "<h1>lighttpd error log unavailable</h1>"
fi
