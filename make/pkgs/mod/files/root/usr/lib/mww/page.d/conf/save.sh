cgi_begin "$PACKAGE_TITLE: $(lang de:"Speichern" en:"Saving") ..."

echo "<div id='result'>"
( source "$HANDLER_DIR/save_body.sh" )
echo "</div>"

if [ "$PACKAGE" != mod ] || [ "$MOD_HTTPD_NEWLOGIN" == "$(modconf value MOD_HTTPD_NEWLOGIN mod)" ]; then
	( source "$HANDLER_DIR/edit_body.sh" )
fi

cgi_end

