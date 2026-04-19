#!/bin/sh

. /usr/lib/libmodcgi.sh

STATE_FILE="/var/run/virtualip_ng.state"

if echo "${QUERY_STRING:-}" | grep -Eq '(^|&)vipng_devices=1(&|$)'; then
	printf '%s\n' "$(ip a 2>&1)"
	exit 0
fi

cfg_entries="$VIRTUALIP_NG_ENTRIES"
cfg_ipv4_wait_ifaces="$INTERFACE_IPV4_WAIT_IFACES"
[ -n "$cfg_ipv4_wait_ifaces" ] || cfg_ipv4_wait_ifaces="lan"

CFG_IFACE=""
CFG_IP=""
CFG_MASK=""
CFG_FLAG=""

ip_family_of_address() {
	case "$1" in
		*:* ) echo "6" ;;
		* ) echo "4" ;;
	esac
}

ipv4_netmask_to_prefix() {
	local NM1=${1%%.*.*.*}
	local NM2=${1#*.}; NM2=${NM2%%.*.*}
	local NM3=${1#*.*.}; NM3=${NM3%%.*}
	local NM4=${1#*.*.*.}
	local INM=$(($NM1 << 24 | $NM2 << 16 | $NM3 << 8 | $NM4))
	local prefix=0

	while [ "$INM" -ne 0 ]; do
		prefix=$(($prefix + ($INM & 1)))
		INM=$(($INM >> 1))
	done

	echo "$prefix"
}

mask_to_prefix() {
	local ipaddr="$1"
	local mask="$2"
	local family

	family="$(ip_family_of_address "$ipaddr")"
	if [ "$family" = "6" ]; then
		echo "$mask" | grep -Eq '^[0-9]{1,3}$' || return 1
		[ "$mask" -ge 0 ] && [ "$mask" -le 128 ] || return 1
		echo "$mask"
		return 0
	fi

	if echo "$mask" | grep -Eq '^[0-9]{1,2}$'; then
		[ "$mask" -ge 0 ] && [ "$mask" -le 32 ] || return 1
		echo "$mask"
		return 0
	fi

	echo "$mask" | grep -Eq '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' || return 1
	ipv4_netmask_to_prefix "$mask"
}

entry_is_present() {
	local ifname="$1"
	local ipaddr="$2"
	local mask="$3"
	local family
	local famopt="-4"
	local prefix

	prefix="$(mask_to_prefix "$ipaddr" "$mask" 2>/dev/null)" || return 1
	family="$(ip_family_of_address "$ipaddr")"
	[ "$family" = "6" ] && famopt="-6"
	ip -o "$famopt" addr show dev "$ifname" to "$ipaddr/$prefix" 2>/dev/null | grep -q .
}

normalize_cfg_flag() {
	local raw="$(echo "$1" | tr 'A-Z' 'a-z' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
	case "$raw" in
		active|inactive)
			echo "$raw"
			;;
		*)
			echo ""
			;;
	esac
}

parse_cfg_entry_line() {
	local line
	local ifname
	local ip
	local mask
	local flag

	line=$(echo "$1" | tr -d '\r')
	line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	case "$line" in
		""|\#*)
			return 1
			;;
	esac

	ifname=""
	ip=""
	mask=""
	flag=""

	case "$line" in
		*\|*)
			IFS='|' read -r ifname ip mask flag <<-EOF
			$line
			EOF
			;;
		*,*,*)
			IFS=',' read -r ifname ip mask flag <<-EOF
			$line
			EOF
			;;
		*)
			set -- $line
			[ "$#" -ge 4 ] || return 1
			ifname="$1"
			ip="$2"
			mask="$3"
			flag="$4"
			;;
	esac

	ifname=$(echo "$ifname" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	ip=$(echo "$ip" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	mask=$(echo "$mask" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	flag=$(echo "$flag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
	flag=$(normalize_cfg_flag "$flag")

	[ -n "$ifname" ] && [ -n "$ip" ] && [ -n "$mask" ] && [ -n "$flag" ] || return 1

	CFG_IFACE="$ifname"
	CFG_IP="$ip"
	CFG_MASK="$mask"
	CFG_FLAG="$flag"
	return 0
}

print_config_entries_rows() {
	local line
	local live
	local printed=0
	local idx=0
	local key
	local checked

	while IFS= read -r line; do
		parse_cfg_entry_line "$line" || continue
		key="${CFG_IFACE},${CFG_IP},${CFG_MASK}"
		checked=""
		[ "$CFG_FLAG" = "active" ] && checked=" checked"

		if entry_is_present "$CFG_IFACE" "$CFG_IP" "$CFG_MASK"; then
			live="$(lang de:"vorhanden" en:"present")"
		else
			live="$(lang de:"fehlt" en:"missing")"
		fi

		cat << EOF
<tr><td>$(html "$CFG_IFACE")</td><td>$(html "$CFG_IP")</td><td>$(html "$CFG_MASK")</td><td style="text-align:center;"><input type="checkbox" id="vipng_active_$idx" class="vipng-toggle" data-entry-key="$(html "$key")" data-initial-state="$(html "$CFG_FLAG")"$checked><label for="vipng_active_$idx"></label></td><td>$live</td></tr>
EOF
		printed=1
		idx=$((idx + 1))
	done <<-EOF
	$(printf '%s\n' "$cfg_entries")
	EOF

	if [ "$printed" -eq 0 ]; then
		cat << EOF
<tr><td colspan="5">$(lang de:"Keine g&uuml;ltigen Eintr&auml;ge gefunden." en:"No valid entries found.")</td></tr>
EOF
	fi
}

print_network_devices_box() {
	local ip_output
	ip_output="$(ip a 2>&1)"

	cat << EOF
<details style="max-width:100%; min-width:0; overflow:hidden;">
<summary>$(lang de:"Netzwerkdevices" en:"Network devices")</summary>
<p style="margin:4px 0 6px 0;">
<button type="button" id="vipng-reload-devices">$(lang de:"Neu laden" en:"Reload")</button>
</p>
<div style="width:100%; max-width:100%; min-width:0; border:1px dotted #888; padding:6px; box-sizing:border-box; overflow:hidden;">
<textarea id="vipng-devices-output" readonly rows="18" wrap="off" style="width:100%; box-sizing:border-box; margin:0; border:0; padding:0; resize:none; overflow-x:auto; overflow-y:hidden; background:transparent; color:inherit; font:inherit;">$(html "$ip_output")</textarea>
</div>
</details>
EOF
}

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$VIRTUALIP_NG_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Netwerkeinstellungen" en:"Network settings")"

cat << EOF
<p>$(lang de:"Eintrag je Zeile: Interface,IP,Netzmaske-oder-Prefix,active|inactive" en:"One entry per line: interface,ip,netmask-or-prefix,active|inactive")<br />
<textarea id="entries" name="entries" rows="6" cols="54">$(html "$cfg_entries")</textarea></p>
<p style="font-size:10px;">$(lang de:"Beispiel: guest,192.168.181.1,255.255.255.0,active" en:"Example: wlan1,192.168.188.2,255.255.255.0,active")<br />
$(lang de:"IPv6-Beispiel: lan,fd00::2,64,active" en:"IPv6 example: lan,fd00::2,64,active")<br />
$(lang de:"Der Dienststart erfolgt nur, wenn mindestens eine IP als active konfiguriert ist." en:"Service startup is performed only if at least one IP is configured as active.")<br />
$(lang de:"Leere Liste: Es werden keine IPs verwaltet. Zuvor vom Mod gesetzte bekannte IPs werden beim Speichern entfernt." en:"Empty list: no IPs are managed. Previously known IPs added by this mod are removed on save.")</p>
EOF

sec_end

sec_begin "$(lang de:"Vom Mod gesetzte IPs" en:"IPs added by this mod")"

cat << EOF
<table>
<tr><th>$(lang de:"Interface" en:"Interface")</th><th>IP</th><th>$(lang de:"Netzmaske/Prefix" en:"Netmask/Prefix")</th><th>$(lang de:"Aktiv" en:"Active")</th><th>$(lang de:"Status" en:"Status")</th></tr>
EOF
print_config_entries_rows
cat << EOF
</table>
EOF
print_network_devices_box
cat << EOF
<script type="text/javascript">
(function () {
	var entriesField = document.getElementById('entries');
	if (!entriesField || !entriesField.form) {
		return;
	}

	var toggles = Array.prototype.slice.call(document.querySelectorAll('.vipng-toggle'));

	function normalizeStatus(value) {
		var v = (value || '').toLowerCase().trim();
		if (v === 'inactive') {
			return 'inactive';
		}
		if (v === 'active') {
			return 'active';
		}
		return '';
	}

	function parseEntry(line) {
		var cleaned = (line || '').replace(/\r/g, '').trim();
		if (!cleaned || cleaned.charAt(0) === '#') {
			return null;
		}

		var parts;
		if (cleaned.indexOf('|') !== -1) {
			parts = cleaned.split('|');
		} else if (cleaned.indexOf(',') !== -1) {
			parts = cleaned.split(',');
		} else {
			parts = cleaned.split(/\s+/);
		}

		if (parts.length < 4) {
			return null;
		}

		var iface = (parts[0] || '').trim();
		var ip = (parts[1] || '').trim();
		var mask = (parts[2] || '').trim();
		if (!iface || !ip || !mask) {
			return null;
		}

		var status = normalizeStatus(parts[3] || '');
		if (!status) {
			return null;
		}

		return {
			iface: iface,
			ip: ip,
			mask: mask,
			status: status,
			key: [iface, ip, mask].join(',')
		};
	}

	function collectOverrides() {
		var overrides = {};
		toggles.forEach(function (toggle) {
			var key = toggle.getAttribute('data-entry-key') || '';
			if (!key) {
				return;
			}
			var initialState = normalizeStatus(toggle.getAttribute('data-initial-state') || 'active');
			var currentState = toggle.checked ? 'active' : 'inactive';
			if (currentState !== initialState) {
				overrides[key] = currentState;
			}
		});
		return overrides;
	}

	entriesField.form.addEventListener('submit', function (evt) {
		var overrides = collectOverrides();
		var lines = entriesField.value.split(/\n/);
		var rebuilt = [];
		var invalid = [];

		lines.forEach(function (line, index) {
			var raw = (line || '').replace(/\r/g, '');
			var trimmed = raw.trim();
			if (!trimmed || trimmed.charAt(0) === '#') {
				rebuilt.push(raw);
				return;
			}

			var entry = parseEntry(line);
			if (!entry) {
				invalid.push(index + 1);
				rebuilt.push(raw);
				return;
			}

			var finalState = Object.prototype.hasOwnProperty.call(overrides, entry.key)
				? overrides[entry.key]
				: entry.status;
			rebuilt.push([entry.iface, entry.ip, entry.mask, finalState].join(','));
		});

		if (invalid.length > 0) {
			alert('Invalid entry format in line(s): ' + invalid.join(', ') + '\nUse: interface,ip,netmask-or-prefix,active|inactive');
			entriesField.value = rebuilt.join('\n');
			evt.preventDefault();
			return false;
		}

		entriesField.value = rebuilt.join('\n');
	});

	var reloadDevicesButton = document.getElementById('vipng-reload-devices');
	var devicesOutput = document.getElementById('vipng-devices-output');
	function adjustDevicesHeight() {
		if (!devicesOutput) {
			return;
		}
		devicesOutput.style.height = 'auto';
		devicesOutput.style.height = devicesOutput.scrollHeight + 'px';
	}
	adjustDevicesHeight();
	if (reloadDevicesButton && devicesOutput) {
		reloadDevicesButton.addEventListener('click', function () {
			var url = window.location.href.split('#')[0];
			reloadDevicesButton.disabled = true;
			fetch(url, { cache: 'no-store', credentials: 'same-origin' })
				.then(function (response) {
					if (!response.ok) {
						throw new Error('HTTP ' + response.status);
					}
					return response.text();
				})
				.then(function (text) {
					if (/\<html[\s>]/i.test(text)) {
						var m = text.match(/<textarea[^>]*id=["']vipng-devices-output["'][^>]*>([\s\S]*?)<\/textarea>/i);
						if (!m) {
							m = text.match(/<textarea[^>]*readonly[^>]*>([\s\S]*?)<\/textarea>/i);
						}
						if (!m) {
							var allAreas = text.match(/<textarea[^>]*>([\s\S]*?)<\/textarea>/ig);
							if (allAreas && allAreas.length > 0) {
								var longest = '';
								for (var i = 0; i < allAreas.length; i++) {
									var mm = allAreas[i].match(/<textarea[^>]*>([\s\S]*?)<\/textarea>/i);
									if (mm && mm[1] && mm[1].length > longest.length) {
										longest = mm[1];
									}
								}
								if (longest) {
									m = ['', longest];
								}
							}
						}
						if (!m) {
							var compact = text.replace(/\s+/g, ' ').trim().slice(0, 220);
							throw new Error('unexpected html response @ ' + url + ' :: ' + compact);
						}
						var decoder = document.createElement('textarea');
						decoder.innerHTML = m[1];
						devicesOutput.value = decoder.value;
						adjustDevicesHeight();
						return;
					}
					devicesOutput.value = text;
					adjustDevicesHeight();
				})
				.catch(function (err) {
					devicesOutput.value = 'reload failed';
					adjustDevicesHeight();
				})
				.finally(function () {
					reloadDevicesButton.disabled = false;
				});
		});
	}
}());
</script>
EOF

sec_end

sec_begin "$(lang de:"Onlinechanged-Timing" en:"Onlinechanged timing")"

cat << EOF
<p>$(lang de:"Verz&ouml;gerung vor dem ersten Start (Sekunden)" en:"Delay before first start (seconds)"): <input id="online_delay_secs" type="text" name="online_delay_secs" size="5" maxlength="4" value="$(html "$VIRTUALIP_NG_ONLINE_DELAY_SECS")">
<br />$(lang de:"Verz&ouml;gerung vor erneutem Start (Sekunden)" en:"Delay before retry start (seconds)"): <input id="online_retry_secs" type="text" name="online_retry_secs" size="5" maxlength="4" value="$(html "$VIRTUALIP_NG_ONLINE_RETRY_SECS")">
<br />$(lang de:"Interfaces mit IPv4-Start-Wartezeit (kommagetrennt)" en:"Interfaces to wait for base IPv4 (comma separated)"): <input id="interface_ipv4_wait_ifaces" type="text" name="interface_ipv4_wait_ifaces" size="24" value="$(html "$cfg_ipv4_wait_ifaces")">
<br /><span style="font-size:10px;">$(lang de:"F&uuml;r diese Interfaces wartet virtualip-ng vor dem Setzen der Virtualip kurz auf eine vorhandene Basis-IPv4." en:"For these interfaces, virtualip-ng briefly waits for an existing base IPv4 before applying the Virtualip.")</span></p>
EOF

sec_end

sec_begin "$(lang de:"Debug" en:"Debug")"

cat << EOF
<p><input type="hidden" name="debug" value="no">
<input id="debug1" type="checkbox" name="debug" value="yes"$([ "$VIRTUALIP_NG_DEBUG" = "yes" ] && echo " checked")><label for="debug1"> $(lang de:"Debug-Ausgaben im System-Log aktivieren" en:"Enable debug output in system log")</label></p>
EOF

sec_end
