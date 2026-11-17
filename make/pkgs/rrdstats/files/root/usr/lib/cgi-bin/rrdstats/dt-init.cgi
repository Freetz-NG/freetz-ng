#!/bin/sh

. /usr/lib/libmodcgi.sh
. /mod/etc/conf/rrdstats.cfg
csrf_check required

cgi_begin "$(lang de:"DigiTemp initialisieren" en:"Initialize DigiTemp")"

echo "<p>$(lang de:"Initialisiere DigiTemp" en:"Initializing DigiTemp") ... $(lang de:"Bitte warten" en:"Please wait")</p>"

[ -n "$RRDSTATS_DIGITEMPRS" ] && rs_param=" -s $RRDSTATS_DIGITEMPRS "

echo -n '<pre>'
{
	/mod/etc/init.d/rc.rrdstats stop
	killall digitemp >/dev/null 2>&1
	mkdir -p /tmp/flash/rrdstats
	cd /tmp
	digitemp $rs_param -i
	mv .digitemprc /tmp/flash/rrdstats/digitemp.conf >/dev/null 2>&1
} 2>&1 | html
echo '</pre>'

modsave >/dev/null 2>&1

echo -n "<p><input type='button' value='$(lang de:"Fenster schlie&szlig;en" en:"Close window")' onclick='window.close()'/></p>"

cgi_end

