
sec_begin 'Udevmount'

case "$(echo usbhost.volume_labels | usbcfgctl -s)" in
	yes) METHOD='LABEL' ;;
	no)  METHOD='DEVICE' ;;
	*)   METHOD='UNKNOWN' ;;
esac

cat <<EOF
<p>
$(lang de:"Methode zur Ermittlung des Mountpoints" en:"Current method to generate mount point"):
<ul><li>
$(lang de:"AVM leitet aktuell den Namen vom ${METHOD} ab. Siehe Hilfe zum &Auml;ndern." en:"AVM generates the name by ${METHOD} currently. See help to change.")
</li></ul>
</p>
EOF

cgi_print_checkbox_p "stor_killblocker" "$MOD_STOR_KILLBLOCKER" \
	"$(lang de:"Alle Programme beenden, die das Aush&auml;ngen verhindern." en:"Kill all programs blocking unmount.")"

cgi_print_checkbox_p "stor_autorunend" "$MOD_STOR_AUTORUNEND" \
	"$(lang de:"Automatisch autorun.sh und autoend.sh ausf&uuml;hren." en:"Run autorun.sh and autoend.sh automatically.")"

sec_end
