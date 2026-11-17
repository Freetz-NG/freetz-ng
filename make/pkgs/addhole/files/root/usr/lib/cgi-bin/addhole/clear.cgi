#!/bin/sh

. /usr/lib/libmodcgi.sh
csrf_check required

cgi_begin 'Addhole - clear'

echo "<p>$(lang de:"Leere Hosts-Datei" en:"Clearing hosts file") ...</p>"

echo -n '<pre>'
{
	/mod/etc/init.d/rc.addhole clear
} 2>&1 | html
echo '</pre>'

echo -n "<p><input type='button' value='$(lang de:"Fenster schlie&szlig;en" en:"Close window")' onclick='window.close()'/></p>"

cgi_end

