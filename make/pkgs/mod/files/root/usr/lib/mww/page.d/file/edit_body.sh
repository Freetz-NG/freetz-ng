echo "<h1>$CAPTION</h1>"
[ -n "$DESCRIPTION" ] && echo "<p>$DESCRIPTION</p>"

if ! allowed; then
	print_access_denied
elif $readonly; then
	print_info "$(lang \
		de:"Datei ist nur lesbar und kann nicht ge&auml;ndert werden." \
		en:"Read-only file. It may not be modified." \
	)"
fi

eval "$CONFIG_PREPARE"
case $CONFIG_TYPE in
	text)
		echo "<form method='post'>"
		csrf_input
		echo -n "<div class='textwrapper'><textarea name='content' rows='$TEXT_ROWS' cols='60' wrap='off' $($readonly && echo "readonly")>"
		[ -n "$CONFIG_CMD" ] && $CONFIG_CMD | html
		[ -r "$CONFIG_FILE" ] && html < "$CONFIG_FILE"
		echo '</textarea></div>'
		if ! $readonly; then
			echo "<div class='btn'><input type='submit' value='$(lang de:"&Uuml;bernehmen" en:"Apply")'></div>"
		fi
		echo '</form>'
		;;
	list)
		;;
	*)
		print_error "$(lang de:"Unbekannter Typ" en:"unknown type") '$CONFIG_TYPE'"
		;;
esac
