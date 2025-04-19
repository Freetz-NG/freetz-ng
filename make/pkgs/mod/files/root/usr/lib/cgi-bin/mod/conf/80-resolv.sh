
sec_begin 'resolv.conf'
cat << EOF

<p>
$(lang
de:"Dies' &auml;ndert den DNS-Server, den die Box selbst zur Namensaufl&ouml;sung benutzt. Es wird weder ein Upstream-Nameserver eines installierten DNS-Servers ver&auml;ndert, noch hat es Auswirkungen auf andere Ger&auml;te im Netzwerk."
en:"This changes the DNS server the box uses itself for name resolution. Neither a upstream name server of a installed dns server will be modified, nor anything of name resolution for other devices at the local network."
)
</p>

<p>
$(lang de:"Diesen DNS-Server in /etc/resolv.conf eintragen" en:"Write this dns server to /etc/resolv.conf"): <input type="text" name="resolv_dns" size="15" maxlength="15" value="$(html "$MOD_RESOLV_DNS")">
</p>

<p>
$(lang de:"Maximale Wartezeit je Versuch" en:"Timeout for each request"): <input type="text" name="resolv_timeout" size="3" maxlength="2" value="$(html "$MOD_RESOLV_TIMEOUT")"> ($(lang de:"leer f&uuml;r default" en:"empty for default"))
</p>

<p>
$(lang de:"Maximale Anzahl Versuche" en:"Maximum number of requests"): <input type="text" name="resolv_attempts" size="2" maxlength="1" value="$(html "$MOD_RESOLV_ATTEMPTS")"> ($(lang de:"leer f&uuml;r default" en:"empty for default"))
</p>


EOF
sec_end
