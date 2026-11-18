#!/bin/sh

trap 'touch /tmp/fw_update.done' EXIT

(
# link FIFO to stdin
exec < "$1"

. /usr/lib/libmodcgi.sh
csrf_check required

[ -r /etc/options.cfg ] && . /etc/options.cfg

footer() {
	echo "<p>"
	back_button --title="$(lang de:"Zur&uuml;ck zur &Uuml;bersicht" en:"Back to main page")" mod status
	echo "</p>"

	cgi_end
}
pre_begin() {
	local id="${1:+ id='$1'}"
	echo "<pre class='log'$id>"
	exec 3>&2 2>&1
}
pre_end() {
	exec 2>&3 3>&-
	echo "</pre>"
}
html_do() {
	local exit
	eval $({
		{ "$@"; echo exit=$? >&4; } | html
	} 4>&1 >&9)
	return $exit
} 9>&1

do_exit() {
	footer
	cat > /dev/null # consume stdin until FIFO is empty
	exit "$@"
}
status() {
	local status msg=$2
	case $1 in
		"done") status="$(lang de:"ERLEDIGT" en:"DONE")" ;;
		"failed") status="$(lang de:"FEHLGESCHLAGEN" en:"FAILED")" ;;
	esac
	echo -n "<p><span class='status'>$status</span>"
	[ -n "$msg" ] && echo -n " &ndash; $msg"
	echo "</p>"
}

cgi_begin "$(lang de:"Firmware-Update" en:"Firmware update")"

#system_lfs
for X in /tmp/.lfs.wrapper /tmp/.lfs.reserve; do
	while [ -d $X ]; do
		umount $X
		rmdir $X
	done
	rm -rf /tmp/.lfs.fitdump
done
rm -f /tmp/.lfs.caching

if [ "${FILENAME##*.}" != "image" ]; then
	echo "<h1>$(lang de:"Update vorbereiten" en:"Prepare update")</h1>"
	pre_begin
	echo "$FILENAME is not an .image file."
	pre_end
	status "failed"
	do_exit 1
fi

cat << EOF
<h1>$(lang \
  de:"Firmware extrahieren, Update vorbereiten" \
  en:"Extract firmware, prepare update" \
)</h1>
EOF

stop=${NAME%%:*}
downgrade=false
rebootbox=true
delete_jffs2=false
case $NAME in
	*:downgrade*) downgrade=true ;;
	*:delete_jffs2*) delete_jffs2=true ;;
esac


if $downgrade; then
	echo "<p>$(lang \
	  de:"Downgrade vorbereiten" \
	  en:"Prepare downgrade" \
	) ... </p>"
	pre_begin
	/usr/bin/prepare-downgrade | html
	pre_end
	status "done"
fi

if [ "$stop" = stop_avm ]; then
	echo "<p>$(lang \
	  de:"AVM-Dienste anhalten, Teil 1" \
	  en:"Stopping AVM services, part 1" \
	) (prepare_fwupgrade start) ... </p>"
	pre_begin
	prepare_fwupgrade start 2>&1 | html
	pre_end
	status "done"
fi

if [ "$stop" = semistop_avm ]; then
	echo "<p>$(lang \
	  de:"Einige der AVM-Dienste anhalten, Teil 1" \
	  en:"Stopping some of the AVM services, part 1" \
	) (prepare_fwupgrade start_from_internet) ... </p>"
	pre_begin
	prepare_fwupgrade start_from_internet 2>&1 | html
	pre_end
	status "done"
fi

echo "<p>$(lang \
  de:"Firmware-Archiv extrahieren" \
  en:"Extracting firmware archive" \
) ... </p>"
pre_begin
untar() {
	tar -C / -xv 2>&1
}
html_do untar
result=$?
pre_end
if [ $result -ne 0 ]; then
	status "failed"
	do_exit 1
fi
status "done"

if [ "$stop" != nostop_avm ]; then
	echo "<p>$(lang \
	  de:"AVM-Dienste anhalten, Teil 2" \
	  en:"Stopping AVM services, part 2" \
	) (prepare_fwupgrade end) ... </p>"
	pre_begin
	prepare_fwupgrade end 2>&1 | html
	pre_end
	status "done"
fi

[ "$stop" = semistop_avm ] && ( sleep 30; reboot )&

cat << EOF
<p>$(lang \
  de:"Ausf&uuml;hren des Firmware-Installationsskripts" \
  en:"Executing firmware installation script" \
) /var/install ... </p>
EOF
if [ ! -x /var/install ]; then
	status "failed" "$(lang \
	  de:"Installationsskript nicht gefunden oder nicht ausf&uuml;hrbar." \
	  en:"Installation script not found or not executable." \
	)"
	cat << EOF
<p>$(lang \
  de:"Weiter ohne Neustart. Sie sollten bei Bedarf noch die extrahierten Dateien l&ouml;schen." \
  en:"Resuming without reboot. You may want to clean up the extracted files." \
)</p>
EOF
	do_exit 1
fi

pre_begin "var-install"
install() {
	# Remove no-op original from var.tar
	rm -f /var/post_install
	# Delete jffs2
	if $delete_jffs2; then
		# set image size to max
		sed -i -e 's|kernel_update_len=$Kernel_without_jffs2_size|kernel_update_len=$kernel_mtd_size|' /var/install
		# unset jffs2_size env var
		echo jffs2_size > /proc/sys/urlader/environment
	fi
	(
		set -o pipefail
		. /bin/env.mod.rcconf avm
		cd /
		/var/install 2>&1 | tee /tmp/var-install.out
	)
}
html_do install
result=$?
pre_end

if [ ! -s /tmp/var-install.out ]; then
	echo '<script>document.getElementById("var-install").setAttribute("hidden","hidden")</script>'
	echo '<p>$(lang de:"HINWEIS: Das Script hat keine Ausgabe generiert." en:"NOTE: The script has not generated any output.")</p>'
fi

case $result in
	0) result_txt="INSTALL_SUCCESS_NO_REBOOT" ;;
	1) result_txt="INSTALL_SUCCESS_REBOOT" ;;
	2) result_txt="INSTALL_WRONG_HARDWARE" ;;
	3) result_txt="INSTALL_KERNEL_CHECKSUM" ;;
	4) result_txt="INSTALL_FILESYSTEM_CHECKSUM" ;;
	5) result_txt="INSTALL_URLADER_CHECKSUM" ;;
	6) result_txt="INSTALL_OTHER_ERROR" ;;
	7) result_txt="INSTALL_FIRMWARE_VERSION" ;;
	8) result_txt="INSTALL_DOWNGRADE_NEEDED" ;;
	*) result_txt="$(lang de:"unbekannter Fehlercode" en:"unknown error code")" ;;
esac

[ $result -ne 1 ] 2>/dev/null && rebootbox=false;

[ $result -le 1 ] 2>/dev/null && color=green || color=red

status "done" "$(lang \
  de:"R&uuml;ckgabewert des Installationsskripts" \
  en:"Installation script return code" \
): <B>$result (<FONT COLOR=$color>$result_txt</FONT>)</B>"

if [ -x /var/post_install ]; then
	echo "<p>$(lang de:"Von" en:"Generated content of") /var/post_install$(lang de:" generierter Inhalt:" en:":")</p>"
	pre_begin
	html < /var/post_install
	pre_end
	echo "<p>$(lang de:"Das Nach-Installationsskript wird beim Neustart ausgef&uuml;hrt." en:"The post-installation script will be executed upon reboot.")</p>"
else
	echo "<p>$(lang de:"HINWEIS: Es gibt kein ausf&uuml;hrbares Nach-Installationsskript." en:"NOTE: There is no executable post-installation script.")</p>"
fi

burner() {
	(
		. /bin/env.mod.rcconf avm
		burnuimg /var/firmware-update.uimg && aicmd pumaglued uimg switchandreboot
	)
}
if [ -f /var/firmware-update.uimg ]; then
	pre_begin
	html_do burner
	retval=$?
	pre_end
	[ "$retval" != "0" ] && status "failed" && do_exit $retval
fi

if $rebootbox; then
	echo "<b>$(lang de:"Das Ger&auml;t startet jetzt neu" en:"The device will reboot now") ... </b>"
	[ ! -f /var/firmware-update.uimg ] && (sleep 3; reboot)&
fi

do_exit 0

)

