#!/bin/sh

. /usr/lib/libmodcgi.sh
csrf_require_post

cgi_begin "$(lang de:"SmartHome aktualisieren" en:"Refresh DigiTemp")"

echo "<p>$(lang de:"Aktualisiere SmartHome" en:"Refreshing SmartHome") ... $(lang de:"Bitte warten" en:"Please wait")</p>"

echo -n '<pre>'
{
    mkdir -p /tmp/flash/rrdstats
    echo -n | tee /tmp/flash/rrdstats/smarthome.alias > /tmp/flash/rrdstats/smarthome.kinds
    /usr/bin/aha.sh alias
    cat /tmp/flash/rrdstats/smarthome.alias 2>/dev/null 
} 2>&1 | html
echo '</pre>'

modsave >/dev/null 2>&1

echo -n "<p><input type='button' value='$(lang de:"Fenster schlie&szlig;en" en:"Close window")' onclick='window.close()'/></p>"

cgi_end

