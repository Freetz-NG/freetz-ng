#!/bin/sh


. /usr/lib/libmodcgi.sh
[ -n "$QUERY_STRING" ] && csrf_check required

SELF='downlog'
TITLE="$(lang de:"Downloader - Protokoll" en:"Downloader - log")"
DOWNLOGFILE='/var/log/downloader.log'

cgi_begin "$TITLE"
echo "<h1>$DOWNLOGFILE</h1>"

if [ -n "$QUERY_STRING" ]; then
	cmd=$(cgi_param cmd)
	case $cmd in
		remove)
			echo "<pre>"
			if [ -r "$DOWNLOGFILE" ]; then
				echo -n "Delete $DOWNLOGFILE ... "
				rm -f $DOWNLOGFILE
				echo "done"
			fi
			echo "</pre>"
		;;
		*)
cat << EOF
<p>
$(lang de:"Falscher Parameter" en:"Wrong parameter") $cmd
</p>
EOF
		;;
	esac
else
	if [ -r "$DOWNLOGFILE" ]; then
		echo -n '<pre class="log full">'
		html < "$DOWNLOGFILE"
		echo '</pre>'
		echo -n "<div class="btn"><form class="btn" action="$SELF">$(csrf_input)<input type="hidden" name="cmd" value="remove"><input type="submit" value='$(lang de:"Protokolldatei l&ouml;schen" en:"Delete log file")'></form></div>"
	else
cat << EOF
<pre>$DOWNLOGFILE $(lang de:"existiert nicht" en:"does not exist")</pre><p>
EOF
	fi
fi
back_button cgi downloader

cgi_end
