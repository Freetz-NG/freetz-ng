#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$PRIVOXY_GET_ADBLOCKLIST" yes:getadblocklist "*":nix
check "$PRIVOXY_TOGGLE" 1:toggle "*":neutral
check "$PRIVOXY_ENABLE_REMOTE_TOGGLE" 1:remote_toggle_yes "*":remote_toggle_no
check "$PRIVOXY_ENFORCE_BLOCKS" 1:enforce_blocks_yes "*":enforce_blocks_no
check "$PRIVOXY_CGI_CRUNCH" 1:cgi_crunch_yes "*":cgi_crunch_no
select "$PRIVOXY_FORWARD_SOCKS_TYPE" socks5:socks5 socks5t:socks5t "*":socks4a

if [ "$(cgi_param load_adblocklist)" == "yes" -a -n "$(cgi_param alt_path)" ]; then
	csrf_check required
	PRIVOXY_ALT_PATH=$(cgi_param alt_path)
	/mod/etc/default.privoxy/privoxy_loadadblocklist ${PRIVOXY_ALT_PATH}
fi

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$PRIVOXY_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Configuration")"

cat << EOF
<h2>$(lang de:"Der Privoxy Server ist gebunden an" en:"The Privoxy server is listening on")</h2>
<p>$(lang de:"IP Adresse" en:"IP Address"):&nbsp;<input id="address" type="text" size="16" maxlength="16" name="listen_address" value="$(html "$PRIVOXY_LISTEN_ADDRESS")">
$(lang de:"Port" en:"Port"):&nbsp;<input id="port" type="text" size="5" maxlength="5" name="listen_port" value="$(html "$PRIVOXY_LISTEN_PORT")"></p>
EOF

sec_end
sec_begin "$(lang de:"Filter" en:"Content Filter")"

cat << EOF
<h2>$(lang de:"Privoxy soll Inhalte beim Surfen filtern" en:"Privoxy shall filter internet content")</h2>
<p><input id="e3" type="radio" name="toggle" value="1"$toggle_chk><label for="e3"> $(lang de:"Ja" en:"Yes")</label> <input id="e4" type="radio" name="toggle" value="0"$neutral_chk><label for="e4"> $(lang de:"Nein" en:"No")</label></p>
<p>$(lang de:"Externes Verzeichnis f&uuml;r Privoxy Filterdateien:" en:"External directory for privoxy filter files:")  <input id="e11" type="text" name="alt_path" value="$PRIVOXY_ALT_PATH" size="30" maxlength="255"><br />
<span style="font-size:x-small">$(lang de:"Der Flashspeicher der Box ist begrenzt und aktuelle Filterdateien teilweise recht gro&szlig;. Mit dieser Option werden die Dateien <i>user.action</i> und <i>user.filter</i> aus dem angegeben Verzeichnis verwendet (verweist sinnvollerweise auf ein externes Verzeichnis)." en:"Internal flash memory is limited. With this option privoxy loads <i>user.action</i> and <i>user.filter</i> from the given directory (usually outside the flash memory of the box).")</span>
</p>
<p>enable-remote-toggle:  <input id="e5" type="radio" name="enable_remote_toggle" value="1"$remote_toggle_yes_chk><label for="e5"> $(lang de:"Ja" en:"set")</label> <input id="e6" type="radio" name="enable_remote_toggle" value="0"$remote_toggle_no_chk><label for="e6"> $(lang de:"Nein" en:"unset")</label><br />
<span style="font-size:x-small">$(lang de:"Web-based Toggle Feature: Wenn die Option aktiviert ist, kann jeder Nutzer die Privoxy-Filterfunktionen &uuml;ber die Web-Schnittstelle ausschalten, siehe" en:"Whether or not the web-based toggle feature may be used, see") <a href="http://www.privoxy.org/user-manual/config.html#ENABLE-REMOTE-TOGGLE" target=_blank>$(lang de:"hier" en:"here")</a></span>
</p>
<p>enforce-blocks:  <input id="e7" type="radio" name="enforce_blocks" value="1"$enforce_blocks_yes_chk><label for="e7"> $(lang de:"Ja" en:"set")</label> <input id="e8" type="radio" name="enforce_blocks" value="0"$enforce_blocks_no_chk><label for="e8"> $(lang de:"Nein" en:"unset")</label><br />
<span style="font-size:x-small">$(lang de:"Wenn die Option aktiviert ist, k&ouml;nnen Filter nicht umgangen werden ('go there anyway' wird ausgeblendet), siehe" en:"Whether the user is allowed to ignore blocks and can go there anyway, see") <a href="http://www.privoxy.org/user-manual/config.html#ENFORCE-BLOCKS" target=_blank>$(lang de:"hier" en:"here")</a></span>
</p>
<p>allow-cgi-request-crunching:  <input id="e8" type="radio" name="cgi_crunch" value="1"$cgi_crunch_yes_chk><label for="e8"> $(lang de:"Ja" en:"Yes")</label> <input id="e9" type="radio" name="cgi_crunch" value="0"$cgi_crunch_no_chk><label for="e9"> $(lang de:"Nein" en:"No")</label><br />
<span style="font-size:x-small">$(lang de:"Wenn die Option aktiviert ist, sind auch die Privoxy CGIs von den Filterregeln betroffen, siehe" en:"Whether the filters affect Privoxys own CGIs or not, see") <a href="http://www.privoxy.org/user-manual/config.html#ALLOW-CGI-REQUEST-CRUNCHING" target=_blank>$(lang de:"hier" en:"here")</a></span>
</p>
EOF

sec_end
sec_begin "$(lang de:"AdBlock Plus"  en:"AdBlock Plus")"

if [ "$FREETZ_PACKAGE_PRIVOXY_WITH_ADBLOCK" = "y" ]; then
cat << EOF
<p><input type="hidden" name="get_adblocklist" value="">
<input id="e10" type="checkbox" name="get_adblocklist" value="yes" $getadblocklist_chk><label for="e10"> $(lang de:"Filterliste von AdBlock Plus bei jedem Start importieren" en:"Import AdBlock Plus filter on every startup")</label> <input type="button" value="$(lang en:"Import now" de:"Jetzt importieren")" onclick='tmp="$(href cgi privoxy load_adblocklist=yes alt_path=)"+document.getElementById("e11").value; location.href=csrfUrl(tmp)'><br />
<span style="font-size:x-small">$(lang de:"Wartet bis zu 15 Sekunden auf die Verf&uuml;gbarkeit des Internets; wegen der Gr&ouml;&szlig;e nur mit externem Verzeichnis sinnvoll" en:"Waiting for internet connectivity may delay startup for up to 15 seconds; because of the size only reasonable with external directory")</span>
</p>
<p><label for="e12">$(lang de:"URL zur Adblock Plus Filterliste:" en:"URL to AdBlock Plus filter list:")</label>  <input id="e12" type="text" name="adblock_url" value="$PRIVOXY_ADBLOCK_URL" size="60" maxlength="255" title="https://easylist-downloads.adblockplus.org/easylistgermany+easylist.txt"><br />
<span style="font-size:x-small">$(lang de:"Legt die URL fest, von der die AdBlock Plus Filterliste importiert werden soll." en:"Specifies the url from which the AdBlock Plus filter should be imported from.")</span>
</p>
EOF
else
cat << EOF
<p style="font-size:x-small">Privoxy was built without AdBlock filterlist import.</p>
EOF
fi

sec_end
sec_begin "$(lang de:"Weiterleitung" en:"Forwarding") (optional)"

cat << EOF
<p><label for="socks">$(lang de:"N&auml;chster Proxy-Server:" en:"Next proxy:")</label>  <input id="socks" type="text" size="21" title="Syntax: &lt;ip&gt;:&lt;port&gt;" maxlength="21" name="forward_socks" value="$(html "$PRIVOXY_FORWARD_SOCKS")"><br />
<span style="font-size:x-small">$(lang de:"Privoxy soll alle Anfragen an den angegebenen (socks) Proxy-Server weiter reichen. Das k&ouml;nnte beispielsweise ein Tor-Server sein." en:"Privoxy shall forward all requests to the specified (socks) proxy server. This could be a tor node, for example.")</span></p>
EOF

cat << EOF
<p>
<label for='forward_socks_type'>$(lang de:"Proxy-Server Typ:" en:"Next proxy type:")</label>
<select name='forward_socks_type' id='forward_socks_type'>
<option value='socks4a'$socks4a_sel>socks4a</option>
<option value='socks5'$socks5_sel>socks5</option>
<option value='socks5t'$socks5t_sel>socks5t</option>
</select>
</p>
EOF

sec_end
sec_begin "$(lang de:"Zugriffskontrolle" en:"Access Control") (optional)"

cat << EOF
<p>$(lang de:"Lies das Privoxy Benutzerhandbuch zum Thema <a href='http://www.privoxy.org/user-manual/config.html#ACCESS-CONTROL' target='_blank'>Zugriffskontrolle</a> f&uuml;r eine detailierte Beschreibung." en:"See the Privoxy User Manual about <a href='http://www.privoxy.org/user-manual/config.html#ACCESS-CONTROL' target='_blank'>Access Control</a> for a brief description.")</p>
<p><label for="permit">$(lang de:"Liste erlaubter Clients und Ziele:" en:"List of allowed clients and destinations:")</label><br />
<textarea id="permit" name="permit_access" rows="4" cols="50" maxlength="255">$(html "$PRIVOXY_PERMIT_ACCESS")</textarea><br />
<span style="font-size:x-small">Syntax: &lt;src_addr&gt;[/&lt;mask&gt;] [&lt;dest_addr&gt;[/&lt;mask&gt;]]</span></p>
<p><label for="deny">$(lang de:"Liste verbotener Clients und Ziele:" en:"List of denied clients and destinations:")</label><br />
<textarea id="deny" name="deny_access" rows="4" cols="50" maxlength="255">$(html "$PRIVOXY_DENY_ACCESS")</textarea><br />
<span style="font-size:x-small">Syntax: &lt;src_addr&gt;[/&lt;mask&gt;] [&lt;dest_addr&gt;[/&lt;mask&gt;]]</span></p>
EOF

sec_end
