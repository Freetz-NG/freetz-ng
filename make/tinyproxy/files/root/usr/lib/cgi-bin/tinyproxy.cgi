#!/bin/sh

. /usr/lib/libmodcgi.sh

BUILDIN_SUPPORT=$(tinyproxy -h | sed -n "/proxy support/ s/^[ ]*// ; s/ proxy support// p" | tr '\n' ' ')

check "$TINYPROXY_CATCHALL" yes:catchall
check "$TINYPROXY_CONFSERVER" yes:confserver
check "$TINYPROXY_BINDSAME" yes:bindsame
check "$TINYPROXY_SYSLOG" yes:syslog
check "$TINYPROXY_XTINYPROXY" yes:xtinyproxy
check "$TINYPROXY_UPSTREAM" yes:upstream
check "$TINYPROXY_DISABLEVIAHEADER" yes:disableviaheader
check "$TINYPROXY_FILTERURLS" yes:filterurls
check "$TINYPROXY_FILTEREXTENDED" yes:filterextended
check "$TINYPROXY_FILTERCASESENSITIVE" yes:filtercasesensitive
check "$TINYPROXY_FILTERDEFAULTDENY" yes:filterdefaultdeny
check "$TINYPROXY_REVERSEONLY" yes:reverseonly
check "$TINYPROXY_REVERSEMAGIC" yes:reversemagic

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$TINYPROXY_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Proxy-Grundkonfiguration" en:"Basic proxy configuration")"

cat << EOF
<p>(*): $(lang de:"Optionen mit mehreren m&ouml;glichen Eintr&auml;gen, per Komma getrennt <br>(z.B. \"Allow: 127.0.0.1;192.168.178.0/24\" oder \"ConnectPort: 443;563\") " en:"Multiple entries are separated by \";\" <br>(eg. \"Allow: 127.0.0.1;192.168.178.0/24\" or \"ConnectPort: 443;563\")")</p>
<table>
<tr>
<td>Port:</td><td><input id="id_port" type="text" size="8" name="port" value="$TINYPROXY_PORT"></td>
<td>&nbsp; &nbsp;</td><td>Listen:</td><td><input id="id_listen" type="text" size="8" name="listen" value="$TINYPROXY_LISTEN"></td>
</tr>
<tr>
<td>Timeout:</td><td><input id="id_timeout" type="text" size="8" name="timeout" value="$TINYPROXY_TIMEOUT"></td>
<td>&nbsp; &nbsp;</td><td>MaxClients:</td><td><input id="id_maxclients" type="text" size="8" name="maxclients" value="$TINYPROXY_MAXCLIENTS"></td>
</tr>
<tr>
<td>ViaProxyName:</td><td><input id="id_viaproxyname" type="text" size="8" name="viaproxyname" value="$TINYPROXY_VIAPROXYNAME"></td>
<td>&nbsp; &nbsp;</td><td>DisableViaHeader:</td><td><input type="hidden" name="disableviaheader" value="no"><input id="id_disableviaheader" type="checkbox" name="disableviaheader" value="yes"$disableviaheader_chk></td>
</tr>


<tr>
<td>ConnectPort (*):</td><td><input id="id_connectport" type="text" size="8" name="connectport" value="$TINYPROXY_CONNECTPORT"></td>
<td>&nbsp; &nbsp;</td><td>XTinyproxy:</td><td><input type="hidden" name="xtinyproxy" value="no"><input id="id_xtinyproxy" type="checkbox" name="xtinyproxy" value="yes"$xtinyproxy_chk></td>
</tr>

</table>
</p>


EOF
/usr/sbin/iptables -t nat -A PREROUTING -i lan -p tcp --dport 80 -j REDIRECT --to-port 8080 --help > /dev/null 2>&1
if [ 0 -eq $? ] && echo "$BUILDIN_SUPPORT" | grep -q -i transparent ; then
cat << EOF
<p><input id="catchall1" type="hidden" name="catchall" value="no" />
<input id="catchall2" type="checkbox" name="catchall" value="yes"$catchall_chk><label for="catchall2">
$(lang de:"Proxy f&uuml;r HTTP erzwingen (mit iptables)" en:"Force HTTP redirection to proxy (with iptables)")</label></p>
EOF
else
echo '<input type="hidden" name="catchall" value="no">'
fi

sec_end
sec_begin "$(lang de:"Konfigurationsserver Einstellungen" en:"Configure a HTTP server to deliver a PAC file")"

cat << EOF
<p>
<input id="confserver1" type="hidden" name="confserver" value="no" />
<input id="confserver2" type="checkbox" name="confserver" value="yes"$confserver_chk>
<label for="confserver2">Konfigurationsserver aktivieren</label>
&nbsp; auf Port:
<input id="confserverport" type="text" name="confserverport" size="3" value="$TINYPROXY_CONFSERVERPORT">
&nbsp; externer Hostname:
<input id="hostname" type="text" name="hostname" size="12" value="$TINYPROXY_HOSTNAME">
</p>
EOF

sec_end
sec_begin "$(lang de:"Sicherheit und Filter" en:"Security and filter configuration")"

cat << EOF
<table>
<tr>
<td>Allow (*):</td><td colspan="4"><input id="id_allow" type="text" size="45" name="allow" value='$TINYPROXY_ALLOW'></td>
</tr>
<tr>
<td>Deny (*):</td><td colspan="4"><input id="id_deny" type="text" size="45" name="deny" value='$TINYPROXY_DENY'></td>
</tr>
<tr>
<td>Anonymous (*):</td><td colspan="4"><input id="id_anonymous" type="text" size="45" name="anonymous" value='$TINYPROXY_ANONYMOUS'></td>
</tr>
</table>
<p>$(lang de:"Inhalt der Filterdatei" en:"content of filter file"):
<textarea id="id_filter" style="width: 550px;" name="filter" rows="15" cols="80" wrap="off" >$TINYPROXY_FILTER</textarea></p>

<table>
<tr>
<td>FilterDefaultDeny:</td><td><input type="hidden" name="filterdefaultdeny" value="no"><input id="id_filterdefaultdeny" type="checkbox" name="filterdefaultdeny" value="yes"$filterdefaultdeny_chk></td>
<td>&nbsp; &nbsp;</td><td>FilterCaseSensitive:</td><td><input type="hidden" name="filtercasesensitive" value="no"><input id="id_filtercasesensitive" type="checkbox" name="filtercasesensitive" value="yes"$filtercasesensitive_chk></td>
</tr>
<tr>
<td>FilterExtended:</td><td><input type="hidden" name="filterextended" value="no"><input id="id_filterextended" type="checkbox" name="filterextended" value="yes"$filterextended_chk></td>
<td>&nbsp; &nbsp;</td><td>FilterURLs:</td><td><input type="hidden" name="filterurls" value="no"><input id="id_filterurls" type="checkbox" name="filterurls" value="yes"$filterurls_chk></td>
</tr>
</table>
EOF
sec_end

sec_begin "$(lang de:"weitere Proxy Konfiguration" en:"Extended proxy configuration")"

cat << EOF
<table>
<tr>
<td>Bind:</td><td><input id="id_bind" type="text" size="8" name="bind" value="$TINYPROXY_BIND"></td>
<td>&nbsp; &nbsp;</td><td>BindSame:</td><td><input type="hidden" name="bindsame" value="no"><input id="id_bindsame" type="checkbox" name="bindsame" value="yes"$bindsame_chk></td>
</tr>
EOF

if echo "$BUILDIN_SUPPORT" | grep -q -i upstream ; then
cat << EOF
<tr>
<td>Upstream (*):</td><td colspan="4"><input id="id_upstream" type="text" size="45" name="upstream" value='$TINYPROXY_UPSTREAM'></td>
</tr>
<tr>
<td>No Upstream (*):</td><td colspan="4"><input id="id_noupstream" type="text" size="45" name="noupstream" value='$TINYPROXY_NOUPSTREAM'></td>
</tr>
EOF
fi
if echo "$BUILDIN_SUPPORT" | grep -q -i reverse ; then
i=0
j=0
while [ $j -lt 10 ]; do
REVERSE_PATH=$(eval echo '$TINYPROXY_REVERSEPATH'_$j)
if [ -n "$REVERSE_PATH" ]; then
cat << EOF
<tr>
<td>ReversePath ($i):</td><td colspan="4"><input id="id_reversepath_$i" type="text" size="45" name="reversepath_$i" value='$REVERSE_PATH'</td>
</tr>
EOF
let i++
fi
let j++
done
if [ $i -lt 10 -a -z "$REVERSE_PATH" ]; then
cat << EOF
<tr>
<td>ReversePath ($i):</td><td colspan="4"><input id="id_reversepath_$i" type="text" size="45" name="reversepath_$i" value='$REVERSE_PATH'</td>
</tr>
EOF
fi
cat << EOF
<tr>
<td>ReverseBaseURL:</td><td colspan="4"><input id="id_reversebaseurl" type="text" size="45" name="reversebaseurl" value='$TINYPROXY_REVERSEBASEURL'></td>
</tr>
<tr>
<td>ReverseOnly:</td><td><input type="hidden" name="reverseonly" value="no"><input id="id_reverseonly" type="checkbox" name="reverseonly" value="yes"$reverseonly_chk></td>
<td>&nbsp; &nbsp;</td><td>ReverseMagic:</td><td><input type="hidden" name="reversemagic" value="no"><input id="id_reversemagic" type="checkbox" name="reversemagic" value="yes"$reversemagic_chk></td>
</tr>
EOF
fi

cat << EOF
<tr>
<td>DefaultErrorFile:</td><td colspan="4"><input id="id_defaulterrorfile" type="text" size="45" name="defaulterrorfile" value='$TINYPROXY_DEFAULTERRORFILE'></td>
</tr>
<tr>
<td>ErrorFile (*):</td><td colspan="4"><input id="id_errorfile" type="text" size="45" name="errorfile" value='$TINYPROXY_ERRORFILE'></td>
</tr>

<tr>
<td>AddHeader:</td><td colspan="4">
<input id="id_addheader_name" type="text" size="20" name="addheader_name" value="$TINYPROXY_ADDHEADER_NAME">
<input id="id_addheader_value" type="text" size="20" name="addheader_value" value="$TINYPROXY_ADDHEADER_VALUE">
</td>
</tr>

<tr>
<td>LogFile:</td><td colspan="4"><input id="id_logfile" type="text" size="45" name="logfile" value="$TINYPROXY_LOGFILE"></td>
</tr>
<tr>
<td>Use Syslog:</td><td colspan="4"><input type="hidden" name="syslog" value="no"><input id="id_syslog" type="checkbox" name="syslog" value="yes"$syslog_chk> &nbsp; &nbsp;<small>$(lang de:"Hinweis: Datei-Log wird abgeschaltet" en:"Note: Disables logging to file")</small></td>
</tr>
<tr>
<td>LogLevel:</td><td colspan="4">
<select id="id_loglevel" name="loglevel" value="$TINYPROXY_LOGLEVEL">
<option value="Critical">Critical(least verbose)</option>
<option value="Error">Error</option><option value="Warning">Warning</option>
<option value="Notice">Notice</option>
<option value="Connect">Connect (log connections without Info's noise)</option>
<option value="Info">Info (most verbose)</option></select></td>
</tr>
</table>
<script>document.getElementById("id_loglevel").value = "$TINYPROXY_LOGLEVEL";</script>
EOF
sec_end
