if ! [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" \
	-o -r "/mod/etc/default.$PACKAGE/$PACKAGE.save" ]; then
	cgi --id="conf:$PACKAGE"
	cgi_error "$(lang \
		de:"Das Paket '$PACKAGE' ist nicht konfigurierbar." \
		en:"the package '$PACKAGE' is not configurable." \
	)"
	exit
fi

# retrieve metadata
PKG_REG=/mod/etc/reg/pkg.reg
[ -e "$PKG_REG" ] || touch "$PKG_REG"

if [ "$PACKAGE" = mod ]; then
	PACKAGE_TITLE="$(lang de:"Einstellungen" en:"Settings")"
else
	OIFS=$IFS; IFS="|"
	set -- $(grep "^$PACKAGE|" "$PKG_REG")
	IFS=$OIFS
	PACKAGE_TITLE=${2:-$PACKAGE}
fi

help="/packages/$PACKAGE"
if [ -z "$ID" ]; then
	ID=_index
else
	help="$help#$ID"
fi

cgi --id="conf:$PACKAGE/$ID" --help="$help" --style=mod/daemons.css

case $REQUEST_METHOD in
	POST)
		if [ "$(cgi_param freetz_action)" != "1" ]; then
			source "${HANDLER_DIR}/save.sh"
		else
			source "${HANDLER_DIR}/edit.sh"
		fi
		;;
	GET|*)		source "${HANDLER_DIR}/edit.sh" ;;
esac

