#!/bin/sh

. /mod/etc/conf/minidlna.cfg
. /usr/lib/libmodcgi.sh
. /usr/lib/libmodredir.sh

eval "$(modcgi branding:pkg:cmd mod_cgi)"

if [ -n "$MOD_CGI_CMD" ]; then
	csrf_check required
	sec_begin "$(lang de:"Hinweis" en:"Remark")"
	echo "<font size=-2 color=red><br>$(lang de:"Die Datenbank wird neu aufgebaut. Dies kann eine Weile dauern." en:"The database will be recreated. This may take a while.")<br></font>"
	sec_end
	/mod/etc/init.d/rc.minidlna rescan >/dev/null 2>&1
fi

if [ "$(/mod/etc/init.d/rc.minidlna status)" != "running" ]; then
echo "<br>$(lang de:"MiniDLNA ist nicht gestartet." en:"MiniDLNA is not running.")"
else
cat << EOF
<center>

<pre class="log">
EOF
wget http://127.0.0.1:${MINIDLNA_PORT}/ -O - | sed -r ' \
  s#(<table)#\1 width=550px style="border:0px"#g; \
  s#(<table)#\1 width=123px#; \
  s#(<td)#\1 style="text-align:left; border-bottom:1px dashed"#g'
cat << EOF
</pre>

<form class="btn" action="$(href status minidlna minidlna_status)" method="post" style="display:inline;">
$(csrf_input)
<input type="hidden" name="cmd" value="rescan">
<input type="submit" value="$(lang de:"neu einlesen" en:"rescan")">
</form>
&nbsp;&nbsp;&nbsp;
<form class="btn" action="$(href status minidlna minidlna_status)" method="post" style="display:inline;">
$(csrf_input)
<input type="hidden" name="cmd" value="">
<input type="submit" value="$(lang de:"aktualisieren" en:"refresh")">
</form>

</center>
EOF
fi

