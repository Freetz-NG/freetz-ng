#!/bin/sh


. /usr/lib/libmodcgi.sh

SELF='downlog'
TITLE="$(lang de:"Downloader - Protokoll" en:"Downloader - log")"
DOWNLOGFILE='/var/log/downloader.log'

cgi_begin "$TITLE"
echo "<h1>$DOWNLOGFILE</h1>"

if [ "$REQUEST_METHOD" == "POST" ]; then
	eval "$(modcgi cmd downloader)"
	case $DOWNLOADER_CMD in
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
$(lang de:"Falscher Parameter" en:"Wrong parameter") $DOWNLOADER_CMD
</p>
EOF
		;;
	esac
else
	if [ -r "$DOWNLOGFILE" ]; then
		echo -n '<pre class="log full">'
		html < "$DOWNLOGFILE"
		echo '</pre>'
		echo -n "<div class="btn"><form class="btn" action="$SELF" method="post">$(csrf_input)<input type="hidden" name="cmd" value="remove"><input type="submit" value='$(lang de:"Protokolldatei l&ouml;schen" en:"Delete log file")'></form></div>"
	else
cat << EOF
<pre>$DOWNLOGFILE $(lang de:"existiert nicht" en:"does not exist")</pre><p>
EOF
	fi
fi
back_button cgi downloader

cgi_end
