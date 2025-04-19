
sec_begin 'Shutdown'

cat << EOF
<h2>
$(lang de:"Beenden von Paketen beim Herunterfahren" en:"Stop of packages at shutdown")
$(lang de:" (mit Leerzeichen trennen)" en:" (separate by spaces)").
</h2>
EOF

cgi_print_textline_p "shutdown_first" "$MOD_SHUTDOWN_FIRST" 50/255 "$(lang de:"Zuerst beenden" en:"Stop at first"): "
cgi_print_textline_p "shutdown_last" "$MOD_SHUTDOWN_LAST" 50/255 "$(lang de:"Zuletzt beenden" en:"Stop at last"): "
cgi_print_textline_p "shutdown_ignore" "$MOD_SHUTDOWN_IGNORE" 50/255 "$(lang de:"Nicht beenden" en:"Do not stop"): "

sec_end
