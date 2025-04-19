sec_begin 'Swap'

cgi_print_radiogroup_active \
	"swap" "$MOD_SWAP" "$(lang de:"Swap-Starttyp" en:"swap start type")" ""

cat << EOF
<h2>$(lang de:"Swap-Datei" en:"Swap file")</h2>
EOF
cgi_print_textline_p "swap_file" "$MOD_SWAP_FILE" 50/255 "$(lang de:"Pfad" en:"Path"): " \
	"<br>($(lang de:"Beispiel:" en:"e.g.") /var/media/ftp/uStor01/swapfile $(lang de:"oder" en:"or") /dev/sda1)"
echo "<p>"
cgi_print_textline "swap_size" "" "" "$(lang de:"Gr&ouml;&szlig;e" en:"Size"): " " MB "
cat << EOF
<input type="button" value="$(lang de:"Swap-Datei anlegen" en:"Create swap file")" onclick="window.open('/cgi-bin/exec.cgi/create-swap?swap_file='+encodeURIComponent(document.getElementById('swap_file').value)+'&amp;swap_size='+encodeURIComponent(document.getElementById('swap_size').value),'swapfilepopup','menubar=no,width=800,height=600,toolbar=no,resizable=yes,scrollbars=yes')">
</p>
EOF
cgi_print_textline_p "swap_swappiness" "$MOD_SWAP_SWAPPINESS" 3/4 '<a href="http://lwn.net/Articles/83588/">$(lang de:"Swappiness" en:"Swappiness")</a> (0-100): '

sec_end
