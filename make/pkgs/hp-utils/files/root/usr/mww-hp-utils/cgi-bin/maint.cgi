#!/bin/sh


. /usr/lib/libmodcgi.sh

[ -r "/mod/etc/conf/hp-utils.cfg" ] && . /mod/etc/conf/hp-utils.cfg

cgi_begin 'hp-utils'

action=$(cgi_param action)
sel=' style="background-color: #bae3ff;"'
maint_sel=''
maint_clean_sel=''
maint_align_sel=''
if [ -z "$action" ]; then
	maint_sel=$sel
elif [ "$action" = "clean" ]; then
	maint_clean_sel=$sel
elif [ "$action" = "align" ]; then
	maint_align_sel=$sel
fi

cat << EOF
<div class="menu">
<div><a href="/cgi-bin/index.cgi">Status</a></div>
<div$maint_sel><a href="/cgi-bin/maint.cgi">$(lang de:"Wartung" en:"Maintenance")</a></div>
<div$maint_clean_sel class="su"><a href="/cgi-bin/maint.cgi?action=clean">$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")</a></div>
<div$maint_align_sel class="su"><a href="/cgi-bin/maint.cgi?action=align">$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")</a></div>
</div>
EOF

if [ -z "$action" ]; then
	sec_begin "$(lang de:"Wartung" en:"Maintenance")"
cat << EOF
<table>
<tr>
<td><a href="/cgi-bin/maint.cgi?action=clean"><img src="/images/clean.png"></a></td>
<td valign="middle"><a href="/cgi-bin/maint.cgi?action=clean">$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")</a></td>
</tr>
<tr>
<td><a href="/cgi-bin/maint.cgi?action=align"><img src="/images/align.png"></a></td>
<td valign="middle"><a href="/cgi-bin/maint.cgi?action=align">$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")</a></td>
</tr>
</table>
EOF
	sec_end
elif [ "$action" = "clean" ]; then
	sec_begin "$(lang de:"Druckkopfreinigung" en:"Print Cartridge Cleaning")"
	if [ -z "$HP_UTILS_URI" ]; then
		echo "<p>$(lang de:"Drucker nicht konfiguriert." en:"Printer not configured.")</p>"
	else
cat << EOF
<form name="clean" action="/cgi-bin/clean.cgi" method="post">
$(csrf_input)
<table>
<tr>
<td>$(lang de:"Reinigungsstufe" en:"clean level")</td>
<td>
<select name="level">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
</select>
</td>
<td><input type="submit" value="$(lang de:"Reinigen" en:"Clean")"></td>
</tr>
</table>
</form>
EOF
	fi
	sec_end
elif [ "$action" = "align" ]; then
	sec_begin "$(lang de:"Druckkopfausrichtung" en:"Print Cartridge Alignment")"
	echo "<p>$(lang de:"(noch) nicht implementiert" en:"not (yet) implemented")</p>"
	sec_end
fi

cgi_end
