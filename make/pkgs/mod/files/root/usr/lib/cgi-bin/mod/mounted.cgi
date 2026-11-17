#!/bin/sh
ERRORFILE=/tmp/mounted.err

eval "$(modcgi cmd:path mounted)"

do_remount() {
	mount -o remount "$@" 2> "$ERRORFILE"
}

do_unmount() {
	sec_begin "$(lang de:"Unmount-Meldungen" en:"Unmount messages")"
	echo "<pre class='plain'>"
	if [ ! -e /var/tmp/mediadevmap ]; then
		/etc/hotplug/storage unplug "$MOUNTED_PATH" 2> "$ERRORFILE" | html
	else
		for _UD in $(sed -rn "s,=[^:]*:${MOUNTED_PATH##*/}$,,p" /var/tmp/mediadevmap); do
			/sbin/hotplug_env /etc/hotplug/storage remove "$_UD" 2> "$ERRORFILE" | html
		done
		grep -q ":${MOUNTED_PATH##*/}$" /var/tmp/mediadevmap && \
		  /sbin/hotplug_env /etc/hotplug/storage umount_all 2> "$ERRORFILE" | html
	fi
	echo "</pre>"
	sec_end
}

decim="$(lang de:"," en:".")"
format_size() {
	echo "$1B" | sed -e "s/[KMGT]\?B/ &/;s/KB$/kB/;s/\./$decim/g"
}
format_path() {
	echo "$1" | sed -e 's#/#/\&shy;#g'
}

print_mountpoints() {
	while read -r fstyp mountopts device path; do
		echo "$DFOUT" | sed -ne "\#$path# { s/\(% [^ ]*\) /\1\n/g; p; q}" |
		while read -r device total used free percent path; do
			print_mp
		done
	done
}

print_mp() {
	case "$fstyp=$device" in
		fuse=http*)	fstyp="davfs" ;;
		fuseblk=*)	fstyp="$(blkid $device | sed -nr 's!.*TYPE="([^"]*).*!\1!p')" ;;
	esac
	total=$(format_size "$total")
	used=$(format_size "$used")
	free=$(format_size "$free")
	percent=${percent%\%}
	case $mountopts in
		ro*) actstatus=o ;;
		rw*) actstatus=w ;;
	esac
	showpath=$(format_path "$path")
	showdev=$(format_path "$device")
	rdisabled=$disabledbtn
	wdisabled=$disabledbtn
	if [ "$actstatus" = "w" ]; then
		barstyle="rw"
		newstatus="r"
		$actions && rdisabled=''
	else
		barstyle="ro"
		newstatus="w"
		$actions && wdisabled=''
	fi
	echo "<tbody class='$barstyle'>"
	if [ "$outsize" != "small" ]; then
		echo -n "<tr>"
		echo -n "<td class='path'>$showpath</td><td class='device'>$showdev</td>"
		echo -n "<td class='fstype'>$fstyp</td>"
		echo -n '<td class='actions'>'
		$actions && echo -n "<small>$(lang de:"Mountoptionen" en:"Mount options"):</small>"
		echo '</td></tr>'
	fi
	echo -n "<tr><td colspan='3' class='free'>${used} $(lang de:"von" en:"of") ${total} $(lang de:"belegt" en:"used"), ${free} $(lang de:"frei" en:"free")</td>"
	echo '<td colspan="1" class="actions">'
	if [ "$outsize" != "small" ]; then
		echo "<form class='btn' action='$formact' method='post' onsubmit='return confirm(\"$(lang de:"Ausf&uuml;hren" en:"Execute")?\")' >"
		csrf_input
		echo "<input type='hidden' name='path' value='$(html "$path")'>"
		echo "<input class='button' type='submit' name='cmd' value='R' $rdisabled>"
		echo "<input class='button' type='submit' name='cmd' value='W' $wdisabled>"
		$actions && echo "<input type='submit' name='cmd' value='&nbsp;U&nbsp;'>"
		echo '</form>'
	fi
	echo '</td></tr>'
	if [ "$errpath" = "$path" -a -r "$ERRORFILE" ]; then
		echo "<tr><td colspan='4'>"
		echo "<pre class='plain error'>"
		html < "$ERRORFILE"
		echo "</pre>"
		echo "</td></tr>"
	fi
	echo "<tr><td colspan='4'>"
	stat_bar $barstyle $percent
	echo "</td></tr>"
	echo "</tbody>"
}


errpath=""
if [ "$sec_level" -eq 0 -a -n "$MOUNTED_CMD" ]; then
	csrf_check required
	case $MOUNTED_CMD in
		R)       do_remount -r "$MOUNTED_PATH" ;;
		W)       do_remount -w "$MOUNTED_PATH" ;;
		*U*)     do_unmount    "$MOUNTED_PATH" ;;
	esac
	if [ -r "$ERRORFILE" ]; then
		errpath=$MOUNTED_PATH
	fi
fi

# The status page is called both as /cgi-bin/(index|status).cgi and /cgi-bin/status/mod/mounted(/index.html)
[ "$SCRIPT_NAME" != "/cgi-bin/index.cgi" -a "$SCRIPT_NAME" != "/cgi-bin/status.cgi" ] && onmain=false || onmain=true

# actions=true if action buttons are to be displayed
if [ "$sec_level" -eq 0 ]; then
	actions=true
else
	actions=false
fi
[ "$onmain" == "true" -a "$MOD_MOUNTED_UMOUNT" != "yes" ] && actions=false

outsize=small
formact=$(html "$SCRIPT_NAME${QUERY_STRING:+?$QUERY_STRING}")
disabledbtn="disabled='disabled' "
DFOUT=$(df -hP)
MOUNT=$(mount)


# /var/flash
if [ "$MOD_MOUNTED_CONF" == "yes" -a "$onmain" == "true" ]; then
	mfilt=$(echo "$MOUNT" | sed -rn 's/^([^ ]+) on (\/var\/flash) type ([^ ]*) \(([^)]*)\)$/\3 \4 \1 \2/p')
	if [ -n "$mfilt" ]; then
		sec_begin "$(lang de:"Konfigurationspartition" en:"Config partition") (/var/flash)"
		echo '<table class="mounted">'
		echo "$mfilt" | print_mountpoints
		echo "</table>"
		sec_end
	fi
fi

# /var
if [ "$MOD_MOUNTED_TEMP" == "yes" -a "$onmain" == "true" ]; then
	mfilt=$(echo "$MOUNT" | sed -rn 's/^([^ ]+) on (\/var) type ([^ ]*) \(([^)]*)\)$/\3 \4 \1 \2/p' | uniq)
	if [ -n "$mfilt" ]; then
		sec_begin "$(lang de:"Tempor&auml;rer Speicher" en:"Temporary storage") (/var)"
		echo '<table class="mounted">'
		echo "$mfilt" | print_mountpoints
		echo "</table>"
		sec_end
	fi
fi

# storages
if [ "$MOD_MOUNTED_MAIN" == "yes" -o "$onmain" == "false" ]; then
	mfilt=$(echo "$MOUNT" |
		sed -rn '
			\#^/dev/(sd|mapper/)|^https?://|^.* on .* type (cifs|fuse|jffs|ubifs|yaffs|ext)|^.*:/.* on .* type nfs# {
				\# on /wrapper | on /var/flash #! {
					s/^([^ ]+) on (.*) type ([^ ]*) \(([^)]*)\)$/\3 \4 \1 \2/; p
				}
			}
		'
	)
	outsize=large
	sec_begin "$(lang de:"Datenspeicher" en:"Storages")"
	if [ -n "$mfilt" ]; then
		echo '<table class="mounted">'
		echo "$mfilt" | print_mountpoints
		echo "</table>"
	else
		echo "<p>$(lang de:"Keine gefunden" en:"None found")</p>"
	fi
	sec_end
fi


rm -f "$ERRORFILE"

