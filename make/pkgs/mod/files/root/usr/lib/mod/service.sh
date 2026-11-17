stat_begin() {
	echo '<table class="daemons">'
cat << EOF
<th align="left">$(lang de:"Name" en:"Name")</th>
<th align="left">$(lang de:"Status" en:"State")</th>
<th align="left" colspan="3">$(lang de:"Kontrolle" en:"Control")</th>
EOF
	if [ "$MOD_SHOW_MEMORY_USAGE" = yes ]; then
cat << EOF
<th align="right">VmSize</th>
<th align="right">VmRSS</th>
EOF
	fi
}

STAT_SERVICE_URL=$(href mod daemons)
stat_button() {
	local pkg=$1 daemon=$2 cmd=$3 active=$4
	if ! $active; then disabled=" disabled"; else disabled=""; fi
	echo "<td><form class='btn' action='${STAT_SERVICE_URL}/$pkg/$daemon' method='post'> $(csrf_input) <input type='submit' name='cmd' value='$cmd'$disabled> </form></td>"
}

stat_packagelink() {
	local url
	case $1 in
		mod) url=$(href mod conf) ;;
		*)   url=$(href cgi "$1") ;;
	esac
	echo "<a href='$url'>$2</a>"
}

stat_line() {
	local pkg=$1
	local daemon=$2
	local description=${3:-$daemon}
	local rcfile="/mod/etc/init.d/${4:-rc.$daemon}"
	local disable=${5:-false}
	local hide=${6:-false}

	$hide && return

	local start=false stop=false
	local status=$("$rcfile" status 2> /dev/null)
	case $status in
		running | 'running (inetd)')
			class=running
			stop=true
			;;
		stopped | 'stopped (inetd)')
			class=stopped
			start=true
			;;
		inetd)
			case ${inetd_status=$(inetd_status)} in
				running)
					class=running
					;;
				stopped)
					class=stopped
					;;
				none)
					class=none
					inetd_status='<i>none</i>'
					;;
				*)	class=
					;;
			esac
			status="$inetd_status ($status)"
			;;
		none)
			status='<i>none</i>'
			class=none
			start=true
			;;
		*)
			class=
			start=true; stop=true
			;;
	esac
	echo "<tr${class:+ class='$class'}>"
	echo "<td width='180'>$(stat_packagelink "$pkg" "$description")</td><td class='status' width='120'>$status</td>"

	if $disable; then
		start=false; stop=false
	fi
	stat_button "$pkg" "$daemon" "$(lang de:"start" en:"start")" $start
	stat_button "$pkg" "$daemon" "$(lang de:"stop" en:"stop")" $stop
	stat_button "$pkg" "$daemon" "$(lang de:"restart" en:"restart")" $stop

	if [ "$MOD_SHOW_MEMORY_USAGE" = yes ] && [ $class = running ]; then
		pid="$(cat /var/run/$daemon.pid 2>/dev/null)"
		if [ -n "$pid" ] && [ -e "/proc/$pid/status" ]; then
			vmsize=$(cat "/proc/$pid/status" | grep "VmSize" | tr -s " " | cut -d " " -f 2)
			[ -n "$vmsize" ] && vmsize="$vmsize kB"
			echo "<td align='right' style='width: 75px'>$vmsize</td>"
			vmrss=$(cat "/proc/$pid/status" | grep "VmRSS" | tr -s " " | cut -d " " -f 2)
			[ -n "$vmrss" ] && vmrss="$vmrss kB"
			echo "<td align='right' style='width: 75px'>$vmrss</td>"
		fi
	fi

	echo '</tr>'
}

stat_end() {
	echo '</table>'
}

unset inetd_status

inetd_status() {
	if [ -e /mod/etc/default.inetd/inetd.cfg ]; then
		/mod/etc/init.d/rc.inetd status 2> /dev/null
	fi
}
