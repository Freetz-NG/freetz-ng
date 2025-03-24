#!/bin/sh

. /usr/lib/libmodcgi.sh

check "$TOR_SOCKS_POLICY_REJECT" yes:closed "*":open
check "$TOR_STRICT_NODES" yes:strict_nodes
check "$TOR_RELAY_ENABLED" yes:relay_enabled
check "$TOR_DATADIRPERSISTENT" yes:datadirpersistent_enabled
check "$TOR_BRIDGERELAY" yes:bridgerelay

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$TOR_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Configuration")"

cat << EOF
<h2>$(lang de:"Der Tor Server ist gebunden an" en:"The Tor server is listening on")</h2>
<p>$(lang de:"IP Adresse" en:"IP Address"):&nbsp;<input id="address" type="text" size="16" maxlength="16" name="socks_address" value="$(html "$TOR_SOCKS_ADDRESS")">
$(lang de:"Port" en:"Port"):&nbsp;<input id="port" type="text" size="5" maxlength="5" name="socks_port" value="$(html "$TOR_SOCKS_PORT")"></p>
<h2>$(lang de:"Fernsteuerung" en:"Remote Control") (optional)</h2>
<p>Control Port:&nbsp;<input id="control" type="text" size="5" maxlength="5" name="control_port" value="$(html "$TOR_CONTROL_PORT")"></p>
<p>Control Interface&nbsp;($(lang de:"z.B." en:"e.g.") 192.168.178.1):&nbsp;<input id="controlif" type="text" size="21" maxlength="21" name="control_address" value="$(html "$TOR_CONTROL_ADDRESS")"><br />
<span style="font-size:10px;">127.0.0.1 $(lang de:", falls nicht angegeben" en:", if not specified")</span></p>
<p>Control Password Hash:&nbsp;<input id="controlpw" type="text" size="61" maxlength="61" name="control_hashed_pass" value="$(html "$TOR_CONTROL_HASHED_PASS")"><br />
<span style="font-size:10px;">$(lang de:"Falls ein Control Interface angegeben wurde, muss hier ebenfalls ein Passwort-Hash angegeben werden." en:"If Control Interface is not empty you must provide a password.")<br />
($(lang de:"Ein Passwort Hash kann durch den Befehl <i>tor --hash-password mein_passwort</i> erzeugt werden." en:"You can create a password hash with <i>tor --hash-password my_password</i>."))</span></p>
<p>$(lang de:"Zeitlimit f&uuml;r Tor-Verbindungen" en:"Circuits Available Timeout") (optional):&nbsp;<input id="circuits_available_timeout" type="text" size="5" maxlength="5" name="circuits_available_timeout" value="$(html "$TOR_CIRCUITS_AVAILABLE_TIMEOUT")"></p>
<p>memory soft limit (bytes):&nbsp;<input id="softlimit" type="text" size="5" maxlength="15" name="softlimit" value="$(html "$TOR_SOFTLIMIT")"></p>
EOF

sec_end
sec_begin "$(lang de:"Zugriffskontrolle" en:"Access Control")"

cat << EOF
<p>$(lang de:"Erlaubte Clients" en:"Allowed clients"): <input id="e4" type="radio" name="socks_policy_reject" value="no"$open_chk><label for="e4"> $(lang de:"alle" en:"all")</label> <input id="e3" type="radio" name="socks_policy_reject" value="yes"$closed_chk><label for="e3"> $(lang de:"eingeschr&auml;nkt" en:"restricted")</label></p>
<h2>$(lang de:"Liste mit IP-Adressen (eine pro Zeile)" en:"List of IP-Addresses (one per line)")</h2>
<p><textarea id="accept" name="socks_policy_accept" rows="4" cols="50" maxlength="255">$(html "$TOR_SOCKS_POLICY_ACCEPT")</textarea><br />
Syntax: &lt;addr&gt;[/&lt;mask&gt;]<br />
<span style="font-size:10px;">$(lang de:"Um alle lokal verbundenen Netzwerke zu erlauben, kann man den Alias <i>private</i> anstelle einer Adresse eintragen" en:"To specify all internal and link-local networks, you can use the <i>private</i> alias instead of an address").</span>
</p>
EOF

sec_end
sec_begin "$(lang de:"Eingangs- und Ausgangsknoten" en:"Entry and exit nodes")"

cat << EOF
<h2>$(lang de:"Tor-Eingangsknoten (einer pro Zeile)" en:"Tor entry nodes (one per line)")</h2>
<p><textarea id="accept" name="entry_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_ENTRY_NODES")</textarea></p>

<h2>$(lang de:"Tor-Ausgangsknoten (einer pro Zeile)" en:"Tor exit nodes (one per line)")</h2>
<p><textarea id="accept" name="exit_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_EXIT_NODES")</textarea></p>

<h2>$(lang de:"Zu vermeidende Tor-Knoten (einer pro Zeile)" en:"Tor nodes to avoid (one per line)")</h2>
<p><textarea id="accept" name="exclude_nodes" rows="4" cols="50" maxlength="255">$(html "$TOR_EXCLUDE_NODES")</textarea></p>

<p>$(lang de:"Zu vermeidende Knoten als sicher auszuschlie&szlig;ende interpretieren" en:"Treat nodes to avoid as the ones definitely to exclude"): <input type="hidden" name="strict_nodes" value="no"><input id="e7" type="checkbox" name="strict_nodes" value="yes"$strict_nodes_chk></p>
EOF

sec_end

if [ "$FREETZ_PACKAGE_TOR_RELAY" == "y" ]; then
sec_begin "$(lang de:"Tor als Relay (Node) konfigurieren" en:"Relay (node) configuration")"

cat << EOF
<p>$(lang de:"Tor auch als Server starten" en:"Open tor relay"): <input type="hidden" name="relay_enabled" value="no"><input id="e8" type="checkbox" name="relay_enabled" value="yes"$relay_enabled_chk></p>
<p>$(lang de:"Nickname des Servers" en:"Nickname"):&nbsp;<input id="nick" type="text" size="16" maxlength="16" name="nickname" value="$(html "$TOR_NICKNAME")")></p>
<p>$(lang de:"IP oder FQDN des Servers" en:"IP or FQDN for your server"):&nbsp;<input id="address" type="text" size="30" maxlength="30" name="address" value="$(html "$TOR_ADDRESS")")></p>
<p>BandwidthRate ($(lang de:"z.B." en:"e.g.") "20 KB"):&nbsp;<input id="bandwith" type="text" size="5" maxlength="7" name="bandwidthrate" value="$(html "$TOR_BANDWIDTHRATE")"></p>
<p>BandwidthBurst ($(lang de:"z.B." en:"e.g.") "40 KB"):&nbsp;<input id="bandwithburst" type="text" size="5" maxlength="7" name="bandwidthburst" value="$(html "$TOR_BANDWIDTHBURST")"></p>
<p>ORPort:&nbsp;<input id="or" type="text" size="5" maxlength="5" name="orport" value="$(html "$TOR_ORPORT")"> &nbsp; DirPort:&nbsp;<input id="dir" type="text" size="5" maxlength="5" name="dirport" value="$(html "$TOR_DIRPORT")"></p>
<p>ExitPolicy ($(lang de:"z.B." en:"e.g.") "reject *.*" = no exits allowed):&nbsp;<input id="policy" type="text" size="20" maxlength="20" name="exitpolicy" value="$(html "$TOR_EXITPOLICY")"></p>
<p>$(lang de:"Diesen Server als Bridge verwenden" en:"Use this server as a bridge"): <input type="hidden" name="bridgerelay" value="no"><input id="e10" type="checkbox" name="bridgerelay" value="yes"$bridgerelay_chk></p>
<p>DataDirectory (Default /var/tmp/tor): &nbsp;<input id="datadir" type="text" size="40" maxlength="40" name="datadirectory" value="$(html "$TOR_DATADIRECTORY")"></p>
<p>$(lang de:"Verzeichnis" en:"directory") persistent: <input type="hidden" name="datadirpersistent" value="no"><input id="e9" type="checkbox" name="datadirpersistent" value="yes"$datadirpersistent_enabled_chk></p>

EOF

sec_end

if [ "$TOR_RELAY_ENABLED" == "yes" ]; then
sec_begin "$(lang de:"Erweiterte Relay-Konfiguration" en:"Advanced relay options")"
cat << EOF
<ul>
<li><a href="$(href file tor secret_id_key)">$(lang de:"Secret ID Key bearbeiten" en:"Edit secret id key")</a></li>
EOF

for pkg in rules firewall forwarding; do
[ -x "/mod/etc/init.d/rc.avm-$pkg" ] && PKG="$pkg" && break
done
if [ -n "$PKG" ]; then
cat << EOF
<li>$(lang de:"Lokale Portfreigaben einrichten" en:"Edit local port-forwarding"): <a href="$(href cgi avm-$PKG)">$(lang de:"hier klicken" en:"click here")</a></li>
EOF
fi

sec_end
fi
fi
