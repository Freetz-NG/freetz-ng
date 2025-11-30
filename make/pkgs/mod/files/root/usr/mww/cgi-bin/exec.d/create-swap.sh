swap_file=$(cgi_param swap_file | tr -d .)
swap_size=$(cgi_param swap_size | tr -d .)
size=$(echo "$swap_size" | sed -re "s/^ *([0-9]+) $/\1/")
error=true

# redirect stderr to stdout so we see output in webif
exec 2>&1

cgi_begin "$(lang de:"Erstellen der Swap-Datei ..." en:"Creation of swapfile ...")"

if [ -z "$swap_size" ]; then
	print_error "$(lang de:"Bitte die Gr&ouml;&szlig;e der Swap-Datei (in MB, zwischen 1 und 2048) angeben" en:"Please specifiy size of swapfile (in MB, between 1 and 2048)")."
elif [ -z "$swap_file" ]; then
	print_error "$(lang de:"Bitte den Pfad der Swap-Datei angeben" en:"Please specify path of swapfile")."
elif [ -e "$swap_file" ]; then
	echo "$(lang de:"Die angegebene Datei existiert bereits" en:"The file specified does already exist.")."
elif [ 1 -gt "$size" -o 2048 -lt "$size" ]; then
	echo "$(lang de:"Die Gr&ouml;&szlig;e der Swap-Datei muss zwischen 1 und 2048 MB liegen" en:"Size of swapfile must be between 1 and 2048 MB")."
else
	echo -n "<pre>"

	echo "$(lang de:"Erstelle leere Datei ..." en:"Creating empty file ...")"
	{
		sleep 2
		while killall -USR1 dd > /dev/null 2>&1; do
			sleep 5
		done
	} &
	sleep 1
	if dd if=/dev/zero of="$swap_file" bs=1M count=$size; then
		echo "$(lang de:"Bereite Datei f&uuml;r Swap-Benutzung vor ..." en:"Preparing file for swap usage ...")"
		if mkswap "$swap_file"; then
			error=false
		else
			echo "$(lang de:"Erstellen der Swap-Datei fehlgeschlagen." en:"Swap file creation failed.")"
		fi
	else
		echo "$(lang de:"Erstellen der Swap-Datei fehlgeschlagen." en:"Swap file creation failed.")"
	fi
	echo '</pre>'
fi

if $error; then
	cat << EOF
<form action="/cgi-bin/exec.cgi/create-swap" method="post">
<p>$(lang de:"Swap-Datei" en:"Swapfile"): <input type="text" name="swap_file" size="50" maxlength="50" value="$swap_file"></p>
<p><input type="text" name="swap_size" size="4" maxlength="4" value="$swap_size" /> MB</p>
<p><input type="button" value="$(lang de:"Swapfile anlegen" en:"Create swapfile")" onclick="location.href='/cgi-bin/exec.cgi/create-swap?swap_file='+encodeURIComponent(document.forms[0].swap_file.value)+'&swap_size='+encodeURIComponent(document.forms[0].swap_size.value)" /></p>
</form>
EOF
else
	echo "<p>$(lang de:"Zum Aktivieren der Swap-Datei m&uuml;ssen die Einstellungen noch gespeichert werden." en:"To activate swapfile, settings must be saved.")</p>"
fi
echo -n "<p><input type='button' value='$(lang de:"Fenster schlie&szlig;en" en:"Close window")' onclick='window.close()'/></p>"

cgi_end

