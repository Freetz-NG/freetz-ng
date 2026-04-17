#!/bin/sh

. /usr/lib/libmodcgi.sh

# Ensure config file exists even if init load path did not run yet.
mkdir -p /mod/etc/conf
if [ -r /mod/etc/conf/iptables-ng.cfg ]; then
	. /mod/etc/conf/iptables-ng.cfg
elif [ -r /etc/default.iptables-ng/iptables-ng.cfg ]; then
	. /etc/default.iptables-ng/iptables-ng.cfg
fi

: ${IPTABLES_NG_ENABLED:=no}
: ${IPTABLES_NG_AUTOSAVE_ON_STOP:=no}

ACTION="$(cgi_param action)"
FAMILY="$(cgi_param family)"
VIEW="$(cgi_param view)"
ACTION_MSG=""
ACTION_RC=0
SERVICE_RUNNING=0
SAVEFILE_V4=/var/tmp/flash/iptables-ng_rules.v4
SAVEFILE_V6=/var/tmp/flash/iptables-ng_rules.v6
FWD_PERSIST_FILE=/var/tmp/flash/iptables-ng_forwarding.conf
if /mod/etc/init.d/rc.iptables-ng status 2>/dev/null | grep -q '^running$'; then
	SERVICE_RUNNING=1
fi

[ "$VIEW" = all ] || VIEW=compact

module_is_loaded() {
	lsmod 2>/dev/null | awk '{print $1}' | grep -Fxq "$1"
}

module_file_exists() {
	local mod="$1"
	local kver
	kver="$(uname -r)"
	find "/lib/modules/$kver" -name "${mod}.ko*" -print -quit 2>/dev/null | grep -q .
}

module_state() {
	if module_is_loaded "$1"; then
		echo loaded
	elif module_file_exists "$1"; then
		echo available
	else
		echo missing
	fi
}

table_modules() {
	local family="$1"
	local table="$2"
	if [ "$family" = ipv4 ]; then
		case "$table" in
			filter) echo "ip_tables iptable_filter" ;;
			nat) echo "ip_tables iptable_nat nf_nat xt_nat" ;;
			mangle) echo "ip_tables iptable_mangle" ;;
			raw) echo "ip_tables iptable_raw" ;;
			security) echo "ip_tables iptable_security" ;;
		esac
	else
		case "$table" in
			filter) echo "ip6_tables ip6table_filter" ;;
			nat) echo "ip6_tables ip6table_nat nf_nat xt_nat" ;;
			mangle) echo "ip6_tables ip6table_mangle" ;;
			raw) echo "ip6_tables ip6table_raw" ;;
			security) echo "ip6_tables ip6table_security" ;;
		esac
	fi
}

cmd_for_family() {
	[ "$1" = ipv6 ] && echo ip6tables || echo iptables
}

chains_for_table() {
	local cmd="$1"
	local table="$2"
	"$cmd" -t "$table" -S 2>/dev/null | sed -n -e 's/^-P \([^ ]*\) .*/\1/p' -e 's/^-N //p' | sort -u
}

default_chains() {
	local table="$1"
	case "$table" in
		filter) echo "INPUT FORWARD OUTPUT" ;;
		nat) echo "PREROUTING INPUT OUTPUT POSTROUTING" ;;
		mangle) echo "PREROUTING INPUT FORWARD OUTPUT POSTROUTING" ;;
		raw) echo "PREROUTING OUTPUT" ;;
		security) echo "INPUT FORWARD OUTPUT" ;;
		*) echo "" ;;
	esac
}

table_status() {
	local family="$1"
	local table="$2"
	local cmd
	local errfile
	local out
	local mods
	local st
	local missing_mod=0

	cmd="$(cmd_for_family "$family")"
	if ! command -v "$cmd" >/dev/null 2>&1; then
		echo "command missing"
		return
	fi

	errfile="$(mktemp /tmp/iptables-ng.err.XXXXXX)"
	if "$cmd" -t "$table" -S >/dev/null 2>"$errfile"; then
		rm -f "$errfile"
		echo "active"
		return
	fi
	out="$(cat "$errfile")"
	rm -f "$errfile"

	if echo "$out" | grep -qi "Table does not exist"; then
		mods="$(table_modules "$family" "$table")"
		for st in $mods; do
			case "$(module_state "$st")" in
				loaded|available) ;;
				missing) missing_mod=1 ;;
			esac
		done
		if [ "$missing_mod" -eq 0 ]; then
			echo "inactive (module available)"
		else
			echo "inactive (module missing)"
		fi
		return
	fi

	echo "error"
}

status_html() {
	case "$1" in
		active)
			echo "<span style='color:#0b7a0b;font-weight:bold;'>$(lang de:"aktiv" en:"active")</span>"
			;;
		"inactive (module missing)")
			echo "<span style='color:#b00020;font-weight:bold;'>$(lang de:"inaktiv (Modul fehlt)" en:"inactive (module missing)")</span>"
			;;
		"command missing")
			echo "<span style='color:#b00020;font-weight:bold;'>$(lang de:"Befehl fehlt" en:"command missing")</span>"
			;;
		error)
			echo "<span style='color:#b00020;font-weight:bold;'>$(lang de:"Fehler" en:"error")</span>"
			;;
		*)
			echo "<span style='color:#a85e00;font-weight:bold;'>$(lang de:"inaktiv (Modul verfuegbar)" en:"inactive (module available)")</span>"
			;;
	esac
}

module_state_html() {
	local state
	state="$(module_state "$1")"
	case "$state" in
		loaded)
			echo "$1 <span style='color:#0b7a0b;'>&#10004; ($(lang de:"geladen" en:"loaded"))</span>"
			;;
		available)
			echo "$1 <span style='color:#0b7a0b;'>&#10004; ($(lang de:"Modul verfuegbar" en:"module available"))</span>"
			;;
		missing)
			echo "$1 <span style='color:#b00020;font-weight:bold;'>&#10008; ($(lang de:"fehlt" en:"missing"))</span>"
			;;
	esac
}

savefile_status() {
	local f="$1"
	if [ -s "$f" ]; then
		printf "%s %s" "$(wc -c < "$f" 2>/dev/null)" "$(lang de:"Bytes" en:"bytes")"
	elif [ -e "$f" ]; then
		echo "$(lang de:"leer" en:"empty")"
	else
		echo "$(lang de:"fehlt" en:"missing")"
	fi
}

action_label() {
	case "$1" in
		save) echo "$(lang de:"Speichern" en:"Save")" ;;
		restore) echo "$(lang de:"Wiederherstellen" en:"Restore")" ;;
		*) echo "$1" ;;
	esac
}

family_label() {
	case "$1" in
		all) echo "$(lang de:"alle" en:"all")" ;;
		ipv4|v4) echo "IPv4" ;;
		ipv6|v6) echo "IPv6" ;;
		*) echo "$1" ;;
	esac
}

safe_ifname() {
	case "$1" in
		*[!A-Za-z0-9_.:-]*|"") return 1 ;;
		*) return 0 ;;
	esac
}

iface_exists() {
	[ -d "/sys/class/net/$1" ]
}

cgi_url() {
	local q="$1"
	local u
	local base
	local query
	local kv
	local key
	local keep=""
	u="$(href cgi iptables-ng)"
	case "$u" in
		*\?*)
			base="${u%%\?*}"
			query="${u#*\?}"
			local IFS='&'
			for kv in $query; do
				[ -n "$kv" ] || continue
				key="${kv%%=*}"
				case "$key" in
					action|family|view|ajax|fwd_family|fwd_if|fwd_val|fwd_persist|edit_family|edit_table|edit_chain|enabled|autosave_on_stop|chain_rules_*)
						continue
						;;
				esac
				[ -n "$keep" ] && keep="${keep}&"
				keep="${keep}${kv}"
			done
			if [ -n "$keep" ]; then
				echo "${base}?${keep}&${q}"
			else
				echo "${base}?${q}"
			fi
			;;
		*)
			echo "$u?$q"
			;;
	esac
}

iface_forward_state() {
	local family="$1"
	local ifn="$2"
	local p
	case "$family" in
		ipv6|v6) p="/proc/sys/net/ipv6/conf/$ifn/forwarding" ;;
		*) p="/proc/sys/net/ipv4/conf/$ifn/forwarding" ;;
	esac
	[ -r "$p" ] || {
		echo n/a
		return
	}
	case "$(cat "$p" 2>/dev/null)" in
		1) echo on ;;
		0) echo off ;;
		*) echo n/a ;;
	esac
}

set_iface_forwarding() {
	local family="$1"
	local ifn="$2"
	local val="$3"
	local p
	case "$family" in
		ipv6|v6) p="/proc/sys/net/ipv6/conf/$ifn/forwarding" ;;
		*) p="/proc/sys/net/ipv4/conf/$ifn/forwarding" ;;
	esac

	safe_ifname "$ifn" || {
		echo "$(lang de:"ungueltiges Interface" en:"invalid interface")" >&2
		return 1
	}
	[ "$val" = 0 ] || [ "$val" = 1 ] || {
		echo "$(lang de:"ungueltiger Wert" en:"invalid value")" >&2
		return 1
	}
	[ -w "$p" ] || {
		echo "$(lang de:"nicht schreibbar" en:"not writable"): $p" >&2
		return 1
	}
	echo "$val" > "$p"
}

fwd_persist_get() {
	local family="$1"
	local ifn="$2"
	[ -r "$FWD_PERSIST_FILE" ] || return 1
	awk -v f="$family" -v i="$ifn" '$1==f && $2==i && ($3=="0" || $3=="1") {print $3; found=1; exit} END{if(!found) exit 1}' "$FWD_PERSIST_FILE"
}

fwd_is_persistent() {
	fwd_persist_get "$1" "$2" >/dev/null 2>&1
}

fwd_persist_set() {
	local family="$1"
	local ifn="$2"
	local val="$3"
	local tmp

	safe_ifname "$ifn" || return 1
	case "$family" in
		ipv4|ipv6) ;;
		*) return 1 ;;
	esac
	[ "$val" = 0 ] || [ "$val" = 1 ] || return 1

	mkdir -p /var/tmp/flash || return 1
	tmp="$(mktemp /tmp/iptables-ng_fwdpersist.XXXXXX)" || return 1
	if [ -r "$FWD_PERSIST_FILE" ]; then
		awk -v f="$family" -v i="$ifn" '!( $1==f && $2==i )' "$FWD_PERSIST_FILE" > "$tmp" || { rm -f "$tmp"; return 1; }
	fi
	echo "$family $ifn $val" >> "$tmp" || { rm -f "$tmp"; return 1; }
	if [ -s "$tmp" ]; then
		sort -u "$tmp" > "${tmp}.sorted" || { rm -f "$tmp" "${tmp}.sorted"; return 1; }
		mv "${tmp}.sorted" "$FWD_PERSIST_FILE" || { rm -f "$tmp" "${tmp}.sorted"; return 1; }
	else
		: > "$FWD_PERSIST_FILE" || { rm -f "$tmp"; return 1; }
	fi
	rm -f "$tmp"
	return 0
}

fwd_persist_unset() {
	local family="$1"
	local ifn="$2"
	local tmp

	safe_ifname "$ifn" || return 1
	case "$family" in
		ipv4|ipv6) ;;
		*) return 1 ;;
	esac

	mkdir -p /var/tmp/flash || return 1
	tmp="$(mktemp /tmp/iptables-ng_fwdpersist.XXXXXX)" || return 1
	if [ -r "$FWD_PERSIST_FILE" ]; then
		awk -v f="$family" -v i="$ifn" '!( $1==f && $2==i )' "$FWD_PERSIST_FILE" > "$tmp" || { rm -f "$tmp"; return 1; }
	fi
	if [ -s "$tmp" ]; then
		sort -u "$tmp" > "${tmp}.sorted" || { rm -f "$tmp" "${tmp}.sorted"; return 1; }
		mv "${tmp}.sorted" "$FWD_PERSIST_FILE" || { rm -f "$tmp" "${tmp}.sorted"; return 1; }
	else
		: > "$FWD_PERSIST_FILE" || { rm -f "$tmp"; return 1; }
	fi
	rm -f "$tmp"
	return 0
}

fwd_persist_update_if_enabled() {
	local family="$1"
	local ifn="$2"
	local val="$3"

	fwd_is_persistent "$family" "$ifn" || return 0
	fwd_persist_set "$family" "$ifn" "$val"
}

forward_candidate_ifaces() {
	for ifn in wan wanmodem lan eth0 eth1 eth2 eth3 ath0 ath1 ath2 guest guest6 guest7 guest8; do
		iface_exists "$ifn" && echo "$ifn"
	done
}

render_forward_controls() {
	local family="$1"
	local ifn st sid persist_checked
	local title
	if [ "$family" = ipv6 ] || [ "$family" = v6 ]; then
		title="$(lang de:"IPv6 Forwarding" en:"IPv6 forwarding")"
	else
		title="$(lang de:"IPv4 Forwarding" en:"IPv4 forwarding")"
	fi
	echo "<div style='margin-top:6px; font-size:11px;'><b>$title</b></div>"
	echo "<table width='100%' class='center' border='1' cellpadding='2' cellspacing='0' style='font-size:11px; margin-top:3px;'>"
	echo "<tr><th width='18%'>$(lang de:"Interface" en:"Interface")</th><th width='20%'>$(lang de:"Status" en:"State")</th><th width='42%'>$(lang de:"Aktion" en:"Action")</th><th width='20%'>$(lang de:"Persistent" en:"Persistent")</th></tr>"
	while IFS= read -r ifn; do
		[ -n "$ifn" ] || continue
		persist_checked=""
		fwd_is_persistent "$family" "$ifn" && persist_checked=" checked"
		st="$(iface_forward_state "$family" "$ifn")"
		if [ "$SERVICE_RUNNING" != "1" ] && [ -n "$persist_checked" ]; then
			st="<span style='color:#a85e00;font-weight:bold;'>$(lang de:"inaktiv" en:"inactive")</span>"
		else
			case "$st" in
				on) st="<span style='color:#0b7a0b;font-weight:bold;'>$(lang de:"aktiv" en:"on")</span>" ;;
				off) st="<span style='color:#b00020;font-weight:bold;'>$(lang de:"aus" en:"off")</span>" ;;
				*) st="<span style='color:#a85e00;font-weight:bold;'>n/a</span>" ;;
			esac
		fi
		sid="$(echo "${family}_${ifn}" | tr -c 'A-Za-z0-9_' '_')"
		cat << EOF
<tr>
<td><b>$ifn</b></td>
<td><span id='fwd_state_$sid'>$st</span></td>
<td>
<button type='button' onclick="iptNgSetFwd('$family','$ifn','1','fwd_state_$sid'); return false;">$(lang de:"Aktivieren" en:"Enable")</button>
&nbsp;
<button type='button' onclick="iptNgSetFwd('$family','$ifn','0','fwd_state_$sid'); return false;">$(lang de:"Deaktivieren" en:"Disable")</button>
</td>
<td style='text-align:center;'>
<input id='fwd_persist_$sid' type='checkbox'$persist_checked onchange="iptNgSetFwdPersist('$family','$ifn', this.checked ? '1' : '0', 'fwd_persist_$sid'); return true;">
</td>
</tr>
EOF
	done <<-EOF
	$(forward_candidate_ifaces)
	EOF
	echo "</table>"
}

render_forward_settings_block() {
	echo "<details style='margin-top:6px;'>"
	echo "<summary><b>$(lang de:"Forwarding Einstellungen" en:"Forwarding settings")</b></summary>"
	echo "<details style='margin-top:4px; margin-left:10px;'>"
	echo "<summary><b>$(lang de:"IPv4 Forwarding" en:"IPv4 forwarding")</b></summary>"
	render_forward_controls ipv4
	echo "</details>"
	echo "<details style='margin-top:4px; margin-left:10px;'>"
	echo "<summary><b>$(lang de:"IPv6 Forwarding" en:"IPv6 forwarding")</b></summary>"
	render_forward_controls ipv6
	echo "</details>"
	echo "</details>"
}

render_rows_table() {
	local rows="$1"
	cat << EOF
<table width='100%' class='center' border='1' cellpadding='2' cellspacing='0' style='font-size:11px;'>
<tr><th width='12%'>$(lang de:"Tabelle" en:"Table")</th><th width='22%'>$(lang de:"Status" en:"Status")</th><th width='36%'>$(lang de:"Module" en:"Modules")</th><th width='30%'>$(lang de:"Chains" en:"Chains")</th></tr>
$rows
</table>
EOF
}

render_family_table() {
	local family="$1"
	local table
	local cmd
	local status
	local mods
	local m
	local mtxt
	local chains
	local chains_html
	local c
	local row
	local active_rows=""
	local inactive_rows=""
	local active_count=0
	local available_count=0
	local missing_count=0
	local inactive_count=0

	cmd="$(cmd_for_family "$family")"

	for table in filter nat mangle raw security; do
		status="$(table_status "$family" "$table")"
		mods="$(table_modules "$family" "$table")"
		mtxt=""
		for m in $mods; do
			[ -n "$mtxt" ] && mtxt="$mtxt<br>"
			mtxt="$mtxt$(module_state_html "$m")"
		done

		chains="$(chains_for_table "$cmd" "$table" | tr '\n' ' ')"
		[ -n "$chains" ] || chains="$(default_chains "$table")"
		chains_html=""
		for c in $chains; do
			[ -n "$chains_html" ] && chains_html="$chains_html<br>"
			chains_html="$chains_html$c"
		done

		row="$(cat << EOF
<tr>
<td><b>$table</b></td>
<td>$(status_html "$status")</td>
<td>$mtxt</td>
<td><span style='font-size:11px;'>$chains_html</span></td>
</tr>

EOF
)"

		case "$status" in
			active)
				active_count=$((active_count + 1))
				active_rows="${active_rows}${row}"
				;;
			"inactive (module available)")
				available_count=$((available_count + 1))
				inactive_count=$((inactive_count + 1))
				inactive_rows="${inactive_rows}${row}"
				;;
			*)
				missing_count=$((missing_count + 1))
				inactive_count=$((inactive_count + 1))
				inactive_rows="${inactive_rows}${row}"
				;;
		esac
	done

	echo "<p style='margin:4px 0;'><b>$(lang de:"Zusammenfassung" en:"Summary"):</b> <span style='color:#0b7a0b;'>$(lang de:"aktiv" en:"active"): $active_count</span> <span style='color:#a85e00;'>$(lang de:"verfuegbar" en:"available"): $available_count</span> <span style='color:#b00020;'>$(lang de:"fehlt/Fehler" en:"missing/error"): $missing_count</span></p>"

	if [ -n "$active_rows" ]; then
		render_rows_table "$active_rows"
	else
		render_rows_table "<tr><td colspan='4'>$(lang de:"Keine aktiven Tabellen." en:"No active tables.")</td></tr>"
	fi

	if [ "$VIEW" = all ]; then
		if [ -n "$inactive_rows" ]; then
			echo "<p style='margin-top:8px;'><b>$(lang de:"Inaktive / nicht verfuegbare Tabellen" en:"Inactive / unavailable tables")</b></p>"
			render_rows_table "$inactive_rows"
		fi
	else
		if [ -n "$inactive_rows" ]; then
			cat << EOF
<details style='margin-top:6px;'>
<summary>$(lang de:"Inaktiv / nicht verfuegbar" en:"Inactive / unavailable") ($inactive_count)</summary>
EOF
			render_rows_table "$inactive_rows"
			echo "</details>"
		fi
	fi
}

chain_rules_text() {
	local family="$1"
	local table="$2"
	local chain="$3"
	local cmd

	cmd="$(cmd_for_family "$family")"
	command -v "$cmd" >/dev/null 2>&1 || return 0
	"$cmd" -t "$table" -S "$chain" 2>/dev/null
}

table_chain_list() {
	local family="$1"
	local table="$2"
	local cmd

	cmd="$(cmd_for_family "$family")"
	{
		chains_for_table "$cmd" "$table"
		default_chains "$table" | tr ' ' '\n'
	} | sed '/^$/d' | sort -u
}

chain_has_user_rules() {
	local family="$1"
	local table="$2"
	local chain="$3"
	local cmd

	cmd="$(cmd_for_family "$family")"
	command -v "$cmd" >/dev/null 2>&1 || return 1
	"$cmd" -t "$table" -S "$chain" 2>/dev/null | grep -q '^-A '
}

table_has_user_rules() {
	local family="$1"
	local table="$2"
	local chain

	while IFS= read -r chain; do
		[ -n "$chain" ] || continue
		chain_has_user_rules "$family" "$table" "$chain" && return 0
	done <<-EOF
	$(table_chain_list "$family" "$table")
	EOF

	return 1
}

apply_chain_rules() {
	local family="$1"
	local table="$2"
	local chain="$3"
	local payload="$4"
	local cmd
	local line
	local mod
	local mods
	local rc=0

	cmd="$(cmd_for_family "$family")"
	command -v "$cmd" >/dev/null 2>&1 || {
		echo "$(lang de:"Befehl nicht gefunden" en:"command not found"): $cmd" >&2
		return 1
	}

	# Load only the modules needed for this family/table; do not start rc.iptables-ng here.
	mods="$(table_modules "$family" "$table")"
	for mod in $mods; do
		modprobe "$mod" >/dev/null 2>&1 || true
	done

	"$cmd" -t "$table" -F "$chain" >/dev/null 2>&1 || {
		echo "$(lang de:"Kette konnte nicht geleert werden" en:"could not flush chain"): $table/$chain" >&2
		return 1
	}

	while IFS= read -r line; do
		line="$(echo "$line" | tr -d '\r')"
		line="$(echo "$line" | sed 's/^[[:space:]]*//')"
		# Accept full command lines pasted from shell, e.g. "iptables -A ...".
		case "$line" in
			iptables\ *|ip6tables\ *)
				line="${line#* }"
				;;
		esac
		# Drop optional explicit table prefix ("-t <table>") to avoid duplicates.
		case "$line" in
			-t\ *)
				set -- $line
				if [ "$1" = "-t" ] && [ -n "$2" ]; then
					shift 2
					line="$*"
				fi
				;;
		esac
		case "$line" in
			""|\#*|COMMIT*)
				continue
				;;
			:*)
				set -- $line
				if [ "${1#:}" = "$chain" ] && [ -n "$2" ] && [ "$2" != "-" ]; then
					"$cmd" -t "$table" -P "$chain" "$2" >/dev/null 2>&1 || rc=1
				fi
				continue
				;;
			-P\ *)
				set -- $line
				[ "$2" = "$chain" ] || continue
				"$cmd" -t "$table" -P "$chain" "$3" >/dev/null 2>&1 || rc=1
				continue
				;;
			-A\ *)
				set -- $line
				[ "$2" = "$chain" ] || continue
				set -f
				# shellcheck disable=SC2086
				$cmd -t "$table" $line >/dev/null 2>&1 || rc=1
				set +f
				continue
				;;
			-I\ *|-D\ *|-R\ *|-C\ *)
				set -- $line
				[ "$2" = "$chain" ] || continue
				set -f
				# shellcheck disable=SC2086
				$cmd -t "$table" $line >/dev/null 2>&1 || rc=1
				set +f
				continue
				;;
			-*)
				set -f
				# shellcheck disable=SC2086
				$cmd -t "$table" -A "$chain" $line >/dev/null 2>&1 || rc=1
				set +f
				continue
				;;
			*)
				set -f
				# shellcheck disable=SC2086
				$cmd -t "$table" -A "$chain" $line >/dev/null 2>&1 || rc=1
				set +f
				continue
				;;
		esac
	done <<-EOF
	$payload
	EOF

	return "$rc"
}

render_chain_editors() {
	local family="$1"
	local table
	local chain
	local rule_text
	local table_open_attr
	local chain_open_attr
	local row_count
	local area_id
	local key

	echo "<div style='margin-top:6px; font-size:11px;'><b>$(lang de:"Chain-Editor (live)" en:"Chain editor (live)")</b></div>"
	for table in filter nat mangle raw security; do
		table_open_attr=""
		table_has_user_rules "$family" "$table" && table_open_attr=" open"
		cat << EOF
<details$table_open_attr style='margin-top:4px;'>
<summary><b>$table</b></summary>
EOF
		while IFS= read -r chain; do
			[ -n "$chain" ] || continue
			rule_text="$(chain_rules_text "$family" "$table" "$chain")"
			area_id="chain_rules_${family}_${table}_${chain}_id"
			key="chain_rules_${family}_${table}_${chain}"
			chain_open_attr=""
			row_count=4
			if chain_has_user_rules "$family" "$table" "$chain"; then
				chain_open_attr=" open"
				row_count=7
			fi
			cat << EOF
<details$chain_open_attr style='margin-top:3px; margin-left:10px;'>
<summary><b>$chain</b>$( [ -z "$rule_text" ] && echo " - $(lang de:"leer" en:"empty")" )</summary>
<div style='margin:3px 0;'>
<textarea id='$area_id' name='$key' rows='$row_count' cols='90' style='width:98%;'>$(html "$rule_text")</textarea><br>
<button type='button' onclick="(function(){var t=document.getElementById('$area_id');var u='$(cgi_url "view=$VIEW&action=save_chain&edit_family=$family&edit_table=$table&edit_chain=$chain")';u += '&$key=' + encodeURIComponent(t ? t.value : '');window.location.href=u;})(); return false;">$(lang de:"Kette speichern" en:"Save chain")</button>
</div>
</details>
EOF
		done <<-EOF
		$(table_chain_list "$family" "$table")
		EOF
		echo "</details>"
	done
}

run_action() {
	[ -n "$ACTION" ] || return
	case "$ACTION" in
		start|stop|restart|status)
			if /mod/etc/init.d/rc.iptables-ng "$ACTION" >/tmp/iptables-ng_action.log 2>&1; then
				ACTION_RC=0
				if [ "$ACTION" = "status" ]; then
					ACTION_MSG="$(lang de:"Dienststatus" en:"Service status"): $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
				else
					ACTION_MSG="$(lang de:"Aktion erfolgreich" en:"Action successful"): $ACTION"
				fi
			else
				ACTION_RC=1
				ACTION_MSG="$(lang de:"Aktion fehlgeschlagen" en:"Action failed"): $ACTION - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
			fi
			;;
		save|restore)
			if /mod/etc/init.d/rc.iptables-ng "$ACTION" "${FAMILY:-all}" >/tmp/iptables-ng_action.log 2>&1; then
				ACTION_RC=0
				ACTION_MSG="$(lang de:"Aktion erfolgreich" en:"Action successful"): $(action_label "$ACTION") ($(family_label "${FAMILY:-all}"))"
			else
				ACTION_RC=1
				ACTION_MSG="$(lang de:"Aktion fehlgeschlagen" en:"Action failed"): $(action_label "$ACTION") ($(family_label "${FAMILY:-all}")) - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
			fi
			;;
		set_fwd)
			local fwd_family fwd_if fwd_val
			fwd_family="$(cgi_param fwd_family)"
			fwd_if="$(cgi_param fwd_if)"
			fwd_val="$(cgi_param fwd_val)"
			[ -n "$fwd_family" ] || fwd_family=ipv4
			if set_iface_forwarding "$fwd_family" "$fwd_if" "$fwd_val" >/tmp/iptables-ng_action.log 2>&1; then
				# If this iface is marked persistent, update only the staged persistence file.
				if fwd_persist_update_if_enabled "$fwd_family" "$fwd_if" "$fwd_val" >/dev/null 2>&1; then
					:
				fi
				ACTION_RC=0
				ACTION_MSG="$(lang de:"Forwarding gesetzt" en:"Forwarding updated"): $(family_label "$fwd_family") $fwd_if=$( [ "$fwd_val" = 1 ] && echo on || echo off )"
			else
				ACTION_RC=1
				ACTION_MSG="$(lang de:"Forwarding-Update fehlgeschlagen" en:"Forwarding update failed"): $(family_label "$fwd_family") $fwd_if - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
			fi
			;;
		set_fwd_persist)
			local fwd_family fwd_if fwd_persist fwd_state
			fwd_family="$(cgi_param fwd_family)"
			fwd_if="$(cgi_param fwd_if)"
			fwd_persist="$(cgi_param fwd_persist)"
			[ -n "$fwd_family" ] || fwd_family=ipv4
			if [ "$fwd_persist" = 1 ]; then
				fwd_state="$(iface_forward_state "$fwd_family" "$fwd_if")"
				case "$fwd_state" in
					on) fwd_persist_set "$fwd_family" "$fwd_if" 1 >/tmp/iptables-ng_action.log 2>&1 ;;
					off) fwd_persist_set "$fwd_family" "$fwd_if" 0 >/tmp/iptables-ng_action.log 2>&1 ;;
					*)
						echo "invalid forwarding state: $fwd_state" >/tmp/iptables-ng_action.log
						false
						;;
				esac
				if [ "$?" -eq 0 ]; then
					ACTION_RC=0
					ACTION_MSG="$(lang de:"Forwarding-Persistenz vorgemerkt" en:"Forwarding persistence staged"): $(family_label "$fwd_family") $fwd_if=$fwd_state"
				else
					ACTION_RC=1
					ACTION_MSG="$(lang de:"Persistenz-Update fehlgeschlagen" en:"Persistence update failed"): $(family_label "$fwd_family") $fwd_if - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
				fi
			else
				if fwd_persist_unset "$fwd_family" "$fwd_if" >/tmp/iptables-ng_action.log 2>&1; then
					ACTION_RC=0
					ACTION_MSG="$(lang de:"Forwarding-Persistenz entfernt" en:"Forwarding persistence removed"): $(family_label "$fwd_family") $fwd_if"
				else
					ACTION_RC=1
					ACTION_MSG="$(lang de:"Persistenz-Update fehlgeschlagen" en:"Persistence update failed"): $(family_label "$fwd_family") $fwd_if - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
				fi
			fi
			;;
		get_fwd)
			local fwd_family fwd_if fwd_state
			fwd_family="$(cgi_param fwd_family)"
			fwd_if="$(cgi_param fwd_if)"
			[ -n "$fwd_family" ] || fwd_family=ipv4
			fwd_state="$(iface_forward_state "$fwd_family" "$fwd_if")"
			case "$fwd_state" in
				on|off)
					ACTION_RC=0
					ACTION_MSG="$fwd_state"
					;;
				*)
					ACTION_RC=1
					ACTION_MSG="n/a"
					;;
			esac
			;;
		save_chain)
			local edit_family edit_table edit_chain key chain_payload
			edit_family="$(cgi_param edit_family)"
			edit_table="$(cgi_param edit_table)"
			edit_chain="$(cgi_param edit_chain)"
			key="chain_rules_${edit_family}_${edit_table}_${edit_chain}"
			chain_payload="$(cgi_param "$key")"
			if [ -z "$edit_family" ] || [ -z "$edit_table" ] || [ -z "$edit_chain" ]; then
				ACTION_RC=1
				ACTION_MSG="$(lang de:"Chain-Editor: ungueltige Parameter" en:"Chain editor: invalid parameters")"
			elif apply_chain_rules "$edit_family" "$edit_table" "$edit_chain" "$chain_payload" >/tmp/iptables-ng_action.log 2>&1; then
				ACTION_RC=0
				ACTION_MSG="$(lang de:"Kette gespeichert" en:"Chain saved"): $edit_family/$edit_table/$edit_chain"
			else
				ACTION_RC=1
				ACTION_MSG="$(lang de:"Kette speichern fehlgeschlagen" en:"Chain save failed"): $edit_family/$edit_table/$edit_chain - $(tr '\n' ' ' </tmp/iptables-ng_action.log)"
			fi
			;;
	esac
}

run_action

if [ "$(cgi_param ajax)" = "1" ]; then
	if [ "$ACTION_RC" -eq 0 ]; then
		echo "__IPTNG_OK__|$ACTION_MSG"
	else
		echo "__IPTNG_ERR__|$ACTION_MSG"
	fi
	exit 0
fi

sec_begin "$(lang de:"Iptables NG" en:"Iptables NG")"
cgi_print_radiogroup_service_starttype "enabled" "$IPTABLES_NG_ENABLED" "" "" 0
cat << EOF
<script type='text/javascript'>
function iptNgParseAjax(text) {
	var body = (text || '');
	var okTag = '__IPTNG_OK__|';
	var errTag = '__IPTNG_ERR__|';
	var i = body.lastIndexOf(okTag);
	var kind = 'ok';
	if (i < 0) {
		i = body.lastIndexOf(errTag);
		kind = 'err';
	}
	if (i < 0) return { kind: 'none', msg: '' };
	var start = i + (kind === 'ok' ? okTag.length : errTag.length);
	var tail = body.substring(start);
	var endNl = tail.indexOf('\n');
	var endCr = tail.indexOf('\r');
	var endHtml = tail.indexOf('<');
	var end = tail.length;
	if (endNl >= 0 && endNl < end) end = endNl;
	if (endCr >= 0 && endCr < end) end = endCr;
	if (endHtml >= 0 && endHtml < end) end = endHtml;
	return { kind: kind, msg: tail.substring(0, end).replace(/^\s+|\s+$/g, '') };
}

function iptNgGetFwd(fam, ifn, cb) {
	var xhr = new XMLHttpRequest();
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		var p = iptNgParseAjax(xhr.responseText || '');
		if (xhr.status >= 200 && xhr.status < 300 && p.kind === 'ok') {
			cb(true, p.msg);
		} else {
			cb(false, '');
		}
	};
	xhr.open('GET', '$(cgi_url "view=$VIEW&action=get_fwd&ajax=1")' + '&fwd_family=' + encodeURIComponent(fam) + '&fwd_if=' + encodeURIComponent(ifn), true);
	xhr.send(null);
}

function iptNgRenderFwdState(stateId, stateVal) {
	var state = document.getElementById(stateId);
	if (!state) return;
	if (stateVal === 'on') {
		state.innerHTML = "<span style='color:#0b7a0b;font-weight:bold;'>$(lang de:"aktiv" en:"on")</span>";
	} else if (stateVal === 'off') {
		state.innerHTML = "<span style='color:#b00020;font-weight:bold;'>$(lang de:"aus" en:"off")</span>";
	}
}

function iptNgSetMsg(text, color) {
	var msg = document.getElementById('iptng_fwd_msg');
	if (!msg) return;
	msg.innerHTML = text;
	msg.style.color = color;
}

function iptNgVerifyFwd(fam, ifn, expected, stateId, triesLeft) {
	iptNgGetFwd(fam, ifn, function(okState, stateVal) {
		if (okState && (stateVal === 'on' || stateVal === 'off')) {
			iptNgRenderFwdState(stateId, stateVal);
			if (stateVal === expected) {
				iptNgSetMsg('$(lang de:"Forwarding gesetzt" en:"Forwarding updated")' + ': ' + fam + ' ' + ifn + '=' + expected, '#0b7a0b');
				return;
			}
		}

		if (triesLeft > 0) {
			setTimeout(function() {
				iptNgVerifyFwd(fam, ifn, expected, stateId, triesLeft - 1);
			}, 250);
			return;
		}

		if (okState && (stateVal === 'on' || stateVal === 'off')) {
			iptNgSetMsg('$(lang de:"Forwarding-Update fehlgeschlagen" en:"Forwarding update failed")' + ': ' + fam + ' ' + ifn + ' ($(lang de:"aktuell" en:"current"): ' + stateVal + ')', '#b00020');
		} else {
			iptNgSetMsg('$(lang de:"Forwarding-Update fehlgeschlagen" en:"Forwarding update failed")', '#b00020');
		}
	});
}

function iptNgSetFwd(fam, ifn, val, stateId) {
	var xhr = new XMLHttpRequest();
	var expected = (val === '1') ? 'on' : 'off';
	iptNgSetMsg('$(lang de:"Bitte warten..." en:"Please wait...")', '#666');
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		var p = iptNgParseAjax(xhr.responseText || '');
		if (xhr.status >= 200 && p.kind === 'err' && p.msg) {
			iptNgSetMsg(p.msg, '#b00020');
			return;
		}
		iptNgVerifyFwd(fam, ifn, expected, stateId, 5);
	};
	xhr.open('GET', '$(cgi_url "view=$VIEW&action=set_fwd&ajax=1")' + '&fwd_family=' + encodeURIComponent(fam) + '&fwd_if=' + encodeURIComponent(ifn) + '&fwd_val=' + encodeURIComponent(val), true);
	xhr.send(null);
}

function iptNgSetFwdPersist(fam, ifn, persistVal, checkboxId) {
	var xhr = new XMLHttpRequest();
	iptNgSetMsg('$(lang de:"Bitte warten..." en:"Please wait...")', '#666');
	xhr.onreadystatechange = function() {
		if (xhr.readyState !== 4) return;
		var p = iptNgParseAjax(xhr.responseText || '');
		if (xhr.status >= 200 && p.kind === 'ok') {
			iptNgSetMsg(p.msg || ('$(lang de:"Persistenz aktualisiert" en:"Persistence updated")'), '#0b7a0b');
			return;
		}
		var cb = document.getElementById(checkboxId);
		if (cb) cb.checked = (persistVal !== '1');
		iptNgSetMsg((p.kind === 'err' && p.msg) ? p.msg : '$(lang de:"Persistenz-Update fehlgeschlagen" en:"Persistence update failed")', '#b00020');
	};
	xhr.open('GET', '$(cgi_url "view=$VIEW&action=set_fwd_persist&ajax=1")' + '&fwd_family=' + encodeURIComponent(fam) + '&fwd_if=' + encodeURIComponent(ifn) + '&fwd_persist=' + encodeURIComponent(persistVal), true);
	xhr.send(null);
}
</script>
<p style='margin:4px 0;'>
<span style='font-size:11px;'>$(lang de:"Beim Start werden gespeicherte Regeln automatisch wiederhergestellt (falls vorhanden)." en:"Saved rules are automatically restored on start (if present).")</span><br>
<span style='font-size:11px;'>$(lang de:"Hinweis: Aenderungen unter /var/tmp/flash werden erst durch den normalen Webif-Speichervorgang dauerhaft." en:"Note: Changes under /var/tmp/flash become persistent only after the regular webif save.")</span><br>
<input type='hidden' name='autosave_on_stop' value='no'>
<input id='ia_as' type='checkbox' name='autosave_on_stop' value='yes'$( [ "$IPTABLES_NG_AUTOSAVE_ON_STOP" = yes ] && echo " checked")><label for='ia_as'> $(lang de:"Regeln beim Stop speichern" en:"Save rules on stop")</label>
</p>
<div style='font-size:11px; margin:4px 0;'>
<div style='margin-bottom:3px;'>
<b>$(lang de:"Ansicht" en:"View"):</b>
EOF
if [ "$VIEW" = all ]; then
	echo "<span>$(lang de:"Alle Tabellen" en:"All tables")</span>"
	echo "&nbsp;|&nbsp;<a href='$(cgi_url "view=compact")'>$(lang de:"Kompaktmodus" en:"Compact mode")</a>"
else
	echo "<span>$(lang de:"Kompaktmodus" en:"Compact mode")</span>"
	echo "&nbsp;|&nbsp;<a href='$(cgi_url "view=all")'>$(lang de:"Alle Tabellen zeigen" en:"Show all tables")</a>"
fi
cat << EOF
</div>
<div style='margin-bottom:2px;'>
<b>$(lang de:"Aktionen" en:"Actions"):</b>&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=save")';">$(lang de:"Alles speichern" en:"Save all")</button>
&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=restore")';">$(lang de:"Alles wiederherstellen" en:"Restore all")</button>
</div>
<div style='margin-bottom:2px;'>
<b>IPv4:</b>&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=save&family=ipv4")';">$(lang de:"IPv4 speichern" en:"Save IPv4")</button>
&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=restore&family=ipv4")';">$(lang de:"IPv4 wiederherstellen" en:"Restore IPv4")</button>
&nbsp;<span style='font-size:11px;'>$SAVEFILE_V4 ($(savefile_status "$SAVEFILE_V4"))</span>
</div>
<div>
<b>IPv6:</b>&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=save&family=ipv6")';">$(lang de:"IPv6 speichern" en:"Save IPv6")</button>
&nbsp;
<button type='button' onclick="window.location.href='$(cgi_url "view=$VIEW&action=restore&family=ipv6")';">$(lang de:"IPv6 wiederherstellen" en:"Restore IPv6")</button>
&nbsp;<span style='font-size:11px;'>$SAVEFILE_V6 ($(savefile_status "$SAVEFILE_V6"))</span>
</div>
</div>
<div id='iptng_fwd_msg' style='font-size:11px; margin-top:4px;'></div>
EOF
render_forward_settings_block
if [ -n "$ACTION_MSG" ]; then
	if [ "$ACTION_RC" -eq 0 ]; then
		echo "<p><b>$(lang de:"Status" en:"Status"):</b> <span style='color:#0b7a0b;'>$ACTION_MSG</span></p>"
	else
		echo "<p><b>$(lang de:"Status" en:"Status"):</b> <span style='color:#b00020;'>$ACTION_MSG</span></p>"
	fi
fi
sec_end

sec_begin "$(lang de:"IPv4 Tabellen" en:"IPv4 Tables")"
echo "<details><summary><b>$(lang de:"Modul-Check" en:"Module check")</b></summary>"
render_family_table ipv4
echo "</details>"
render_chain_editors ipv4
sec_end

sec_begin "$(lang de:"IPv6 Tabellen" en:"IPv6 Tables")"
echo "<details><summary><b>$(lang de:"Modul-Check" en:"Module check")</b></summary>"
render_family_table ipv6
echo "</details>"
render_chain_editors ipv6
sec_end
