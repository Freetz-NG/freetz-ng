#!/bin/sh
. /usr/lib/libmodredir.sh

echo -en "Content-Type: text/html\r\n\r\n"

cat << EOF
<html><head><title>Freetz-NG&nbsp;&ndash;&nbsp;$(lang de:"Ausgeloggt" en:"Logged out")</title></head><body><center><br />
<h2>$(lang de:"Erfolgreich ausgeloggt" en:"Sucessfully logged out")!</h2>
<p><a href=$(self_prot)://$(self_host)$(self_port)>$(lang de:"Hier wieder einloggen" en:"Log in again").</a></p>
</center></body></html>
EOF

