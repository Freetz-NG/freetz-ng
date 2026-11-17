frm_begin() {
	cat << EOF
<form method="post" action="$SCRIPT_NAME$PATH_INFO">
$(csrf_input)
EOF
}

frm_end() {
	cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="?default" method="post" onsubmit="return confirm('$(lang de:"Zur&uuml;cksetzen" en:"Reset")?')">
$(csrf_input)
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}

source /usr/lib/mod/service.sh
stat_button() {
	local pkg=$1 daemon=$2 cmd=$3 active=$4
	if ! $active; then disabled=" disabled"; else disabled=""; fi
	echo "<td><form class='btn' action='?$cmd' method='post'> $(csrf_input) <input type='hidden' name='rc' value='${daemon:-$pkg}'> <input type='submit' name='cmd' value='$cmd'$disabled> </form></td>"
}

SERVICE_REG=/mod/etc/reg/daemon.reg
SERVICE_PKG=/mod/etc/reg/pkg.reg
package_services() {
	local selected_pkg=$1 count=0
	while IFS='|' read -r daemon description rcscript disable hide pkg; do
		[ "$pkg" = "$selected_pkg" -a "$hide" = false ] || continue
		let count++
		if [ $count -eq 1 ]; then
			sec_begin "$(lang de:"Status" en:"Status")"
			stat_begin
		fi
		local long="$(sed -n "s/^$daemon|//p" "$SERVICE_PKG")"
		stat_line "$pkg" "$daemon" "${long:-$description}" "$rcscript" "$disable" "$hide"
	done < "$SERVICE_REG"
	if [ $count -gt 0 ]; then
		stat_end
		sec_end
	fi
}

if [ -r "/mod/etc/default.$PACKAGE/$PACKAGE.cfg" ]; then
	. /mod/etc/conf/$PACKAGE.cfg
fi

if [ "$ID" = _index ]; then
	cgi="/mod/usr/lib/cgi-bin/$PACKAGE.cgi"
else
	cgi="/mod/usr/lib/cgi-bin/$PACKAGE/$ID.cgi"
fi

package_services "$PACKAGE"

if [ -x "$cgi" ]; then
	frm_begin "$PACKAGE"
	"$cgi"
	frm_end "$PACKAGE"
else
	print_error "$(lang de:"Kein Skript f&uuml;r" en:"No script for") '$PACKAGE/$ID'."
fi

