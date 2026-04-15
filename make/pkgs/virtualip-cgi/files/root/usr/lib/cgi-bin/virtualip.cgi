#!/bin/sh

. /usr/lib/libmodcgi.sh

STATE_FILE="/var/run/virtualip.state"

cfg_entries="$VIRTUALIP_ENTRIES"
[ -n "$cfg_entries" ] || cfg_entries="$VIRTUALIP_INTERFACE $VIRTUALIP_IP $VIRTUALIP_NETMASK"
cfg_ipv4_wait_ifaces="$INTERFACE_IPV4_WAIT_IFACES"
[ -n "$cfg_ipv4_wait_ifaces" ] || cfg_ipv4_wait_ifaces="$VIRTUALIP_INTERFACE_IPV4_WAIT_IFACES"
[ -n "$cfg_ipv4_wait_ifaces" ] || cfg_ipv4_wait_ifaces="lan"

print_active_entries_rows() {
	local line
	local ifname
	local ip
	local mask
	local live
	local printed=0

	if [ ! -r "$STATE_FILE" ]; then
		cat << EOF
<tr><td colspan="4">$(lang de:"Keine vom Mod hinzugef&uuml;gten IPs gefunden." en:"No IPs currently added by this mod.")</td></tr>
EOF
		return
	fi

	if grep -q '^LAST_VIRTUALIP_INTERFACE=' "$STATE_FILE" 2>/dev/null; then
		. "$STATE_FILE"
		if [ -n "$LAST_VIRTUALIP_INTERFACE" ] && [ -n "$LAST_VIRTUALIP_IP" ] && [ -n "$LAST_VIRTUALIP_NETMASK" ]; then
			if ip -o -4 addr show dev "$LAST_VIRTUALIP_INTERFACE" 2>/dev/null | grep -Fq " $LAST_VIRTUALIP_IP/"; then
				live="$(lang de:"vorhanden" en:"present")"
			else
				live="$(lang de:"fehlt" en:"missing")"
			fi
			cat << EOF
<tr><td>$(html "$LAST_VIRTUALIP_INTERFACE")</td><td>$(html "$LAST_VIRTUALIP_IP")</td><td>$(html "$LAST_VIRTUALIP_NETMASK")</td><td>$live</td></tr>
EOF
			printed=1
			return
		fi
	fi

	while IFS= read -r line; do
		line=$(echo "$line" | tr -d '\r')
		case "$line" in
			""|\#*)
				continue
				;;
		esac
		IFS='|' read -r ifname ip mask <<-EOF
		$line
		EOF
		[ -n "$ifname" ] && [ -n "$ip" ] && [ -n "$mask" ] || continue

		if ip -o -4 addr show dev "$ifname" 2>/dev/null | grep -Fq " $ip/"; then
			live="$(lang de:"vorhanden" en:"present")"
		else
			live="$(lang de:"fehlt" en:"missing")"
		fi

		cat << EOF
<tr><td>$(html "$ifname")</td><td>$(html "$ip")</td><td>$(html "$mask")</td><td>$live</td></tr>
EOF
		printed=1
	done < "$STATE_FILE"

	if [ "$printed" -eq 0 ]; then
		cat << EOF
<tr><td colspan="4">$(lang de:"Keine vom Mod hinzugef&uuml;gten IPs gefunden." en:"No IPs currently added by this mod.")</td></tr>
EOF
	fi
}

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VIRTUALIP_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Netwerkeinstellungen" en:"Network settings")"

cat << EOF
<p>$(lang de:"Eintrag je Zeile: Interface,IP,Netzmaske" en:"One entry per line: interface,ip,netmask")<br />
<textarea id="entries" name="entries" rows="6" cols="54">$(html "$cfg_entries")</textarea></p>
<p style="font-size:10px;">$(lang de:"Beispiel: guest,192.168.181.1,255.255.255.0" en:"Example: wlan1,192.168.188.2,255.255.255.0")<br />
$(lang de:"Kompatibilit&auml;t: Wenn die Liste leer ist, werden die alten Felder (Interface/IP/Netzmaske) genutzt." en:"Compatibility: If the list is empty, legacy single-IP fields are used.")</p>
EOF

sec_end

sec_begin "$(lang de:"Vom Mod gesetzte IPs" en:"IPs added by this mod")"

cat << EOF
<table>
<tr><th>$(lang de:"Interface" en:"Interface")</th><th>IP</th><th>$(lang de:"Netzmaske" en:"Netmask")</th><th>$(lang de:"Status" en:"Status")</th></tr>
EOF
print_active_entries_rows
cat << EOF
</table>
EOF

sec_end

sec_begin "$(lang de:"Onlinechanged-Timing" en:"Onlinechanged timing")"

cat << EOF
<p>$(lang de:"Verz&ouml;gerung vor dem ersten Start (Sekunden)" en:"Delay before first start (seconds)"): <input id="online_delay_secs" type="text" name="online_delay_secs" size="5" maxlength="4" value="$(html "$VIRTUALIP_ONLINE_DELAY_SECS")">
<br />$(lang de:"Verz&ouml;gerung vor erneutem Start (Sekunden)" en:"Delay before retry start (seconds)"): <input id="online_retry_secs" type="text" name="online_retry_secs" size="5" maxlength="4" value="$(html "$VIRTUALIP_ONLINE_RETRY_SECS")">
<br />$(lang de:"IPv4-Warte-Interfaces (kommagetrennt)" en:"IPv4 wait interfaces (comma separated)"): <input id="interface_ipv4_wait_ifaces" type="text" name="interface_ipv4_wait_ifaces" size="24" value="$(html "$cfg_ipv4_wait_ifaces")"></p>
EOF

sec_end

sec_begin "$(lang de:"Debug" en:"Debug")"

cat << EOF
<p><input type="hidden" name="debug" value="no">
<input id="debug1" type="checkbox" name="debug" value="yes"$([ "$VIRTUALIP_DEBUG" = "yes" ] && echo " checked")><label for="debug1"> $(lang de:"Debug-Ausgaben im System-Log aktivieren" en:"Enable debug output in system log")</label></p>
EOF

sec_end
