#!/bin/sh

. /usr/lib/libmodcgi.sh
csrf_check required

cgi_begin 'Addhole - download'

echo "<p>$(lang de:"Lade Hosts herunterladen" en:"Downloading hosts now") ... $(lang de:"Bitte warten" en:"Please wait")!</p>"

echo -n '<pre>'
{
	/mod/etc/init.d/rc.addhole download
} 2>&1 | html
echo '</pre>'

echo -n "<p><input type='button' value='$(lang de:"Fenster schlie&szlig;en" en:"Close window")' onclick='window.close()'/></p>"

cgi_end

