#!/bin/sh

. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"

if [ "$(/mod/etc/init.d/rc.mysql status)" != "running" ]; then
echo "<br>$(lang de:"MySQL ist nicht gestartet." en:"MySQL is not running.")"
else
cat << EOF

<pre class="log">
EOF

echo "<br><center><b>$(lang de:"MySQL Status" en:"MySQL status")</b></center>"
sh /tmp/flash/mysql/status.sh
echo

cat << EOF
</pre>

<center>
<form class="btn" action="$(href status mysql mysql_status)" method="post" style="display:inline;">
$(csrf_input)
<input type="hidden" name="cmd" value="">
<input type="submit" value="$(lang de:"aktualisieren" en:"refresh")">
</form>
</center>

EOF
fi

