#!/bin/sh



[ -r "/mod/etc/conf/hp-utils.cfg" ] && . /mod/etc/conf/hp-utils.cfg

cgi_width=560
. /usr/lib/libmodcgi.sh
csrf_check required

eval "$(modcgi level clean)"

if [ -z "$CLEAN_LEVEL" ]; then
	cgi_error "$(lang de:"Keine Reinigungsstufe angegeben" en:"no clean level")"
	exit 1
fi

cgi_begin "$(lang de:"Reinige" en:"Cleaning")"

echo -n '<pre>starting cleaning ... '

if [ -z "$HP_UTILS_URI" ]; then
	echo "error"
	echo "Printer not configured.</pre>"
else
	if hp-clean --device "$HP_UTILS_URI" --mode printserv --clean-level $CLEAN_LEVEL >/dev/null 2>&1; then
		echo "done"
		echo "wait for cleaning to complete</pre>"
	else
		echo "error"
		echo "execute hp-clean on the command line to see details</pre>"
	fi
fi

echo "<form action="/cgi-bin/maint.cgi"><input type="hidden" name="action" value="clean"><input type="submit" value="$(lang de:"Zur&uuml;ck" en:"Back")"></form>"

cgi_end
