#!/bin/sh


. /usr/lib/libmodcgi.sh

SELF='downremover'
TITLE="$(lang de:"Downloader - Aufr&auml;umen" en:"Downloader - Removing")"
NM_REMOVE="$(lang de:"Aufr&auml;umen" en:"Removing")"

cmd_button() {
local name=${1:-cmd} act=$2 cmd=$3 label=$4 method=post
cat << EOF
<div class="btn">
<form class="btn" action="$act" method="$method">
$(csrf_input)
EOF
if [ $cmd ]; then
cat << EOF
<input name="$name" value="$cmd" type="hidden">
EOF
fi
cat << EOF
<input value="$label" type="submit">
</form>
</div>
EOF
}

cgi_begin "$TITLE"
sec_begin "$NM_REMOVE"
if [ "$REQUEST_METHOD" == "POST" ]; then
	eval "$(modcgi cmd downloader)"
	case $DOWNLOADER_CMD in
		remove)
			echo -n "<pre>"
			/mod/etc/init.d/rc.downloader remove
			echo "</pre>"
			back_button cgi downloader
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
cat << EOF
<p>
$(lang de:"Alle vom Downloader heruntergeladenen Dateien vom Zielort l&ouml;schen.<br>Bitte nicht vergessen vorher die dazugeh&ouml;rigen Dienste zu stoppen!" en:"Removing of all by Downloader downloaded files.<br>Please do not forget to stop before all appropriate services!")
</p>
EOF
	cmd_button "" $SELF "remove" "$NM_REMOVE"
	back_button cgi downloader
fi
sec_end

cgi_end
