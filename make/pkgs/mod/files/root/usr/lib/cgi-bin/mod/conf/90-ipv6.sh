
sec_begin 'IPv6'

cat << EOF
<p>
$(lang de:"Schnittstellen IPv6-Adressen zuweisen" en:"Assign IPv6 adresses to interfaces").<br>
$(lang de:"Syntax" en:"Syntax"): &lt;interface&gt; &lt;IPv6&gt;<br>
$(lang de:"Beispiel" en:"Example"): lan fd21:23c2:dd2f::1/64<br>
</p>
<p><textarea name="ipv6_assign" rows="5" cols="50" maxlength="255">$(html "$MOD_IPV6_ASSIGN")</textarea></p>
EOF

cgi_print_checkbox_p "ipv6_forward" "$MOD_IPV6_FORWARD" \
	"$(lang de:"Weiterleitung aktivieren." en:"Enable forwarding.")"

sec_end
