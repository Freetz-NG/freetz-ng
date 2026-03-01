#!/bin/sh


. /etc/freetz_info.cfg

# FREETZ_INFO_EXTERNAL_FILES may be very large. If exported, every external
# command can fail with "Argument list too long" due oversized CGI env.
if [ -n "$FREETZ_INFO_EXTERNAL_FILES" ]; then
	_freetz_info_external_files="$FREETZ_INFO_EXTERNAL_FILES"
	unset FREETZ_INFO_EXTERNAL_FILES
	FREETZ_INFO_EXTERNAL_FILES="$_freetz_info_external_files"
	unset _freetz_info_external_files
fi

divstyle="style='margin-top:6px;'"

sec_begin "$(lang de:"Firmware-Informationen" en:"Information about firmware")"

cat << EOF
<dl class="info">
<dt>$(lang de:"Boxtyp" en:"Box type")</dt><dd>$FREETZ_INFO_BOXTYPE</dd>
<dt>$(lang de:"AVM-Firmwareversion" en:"AVM firmware version")</dt><dd>$FREETZ_INFO_FIRMWAREVERSION</dd>
<dt>$(lang de:"Region" en:"Region")</dt><dd>$(echo "$FREETZ_INFO_LANG" | sed 's/^de$/ger/;s/^en$/int/;s/^xx$/all/;s/^a-ch$/ach/;s/^it$/ita/')</dd>
</dl>
EOF
unset -v _kernelversion
if [ -r /proc/version ]; then
	_kernelversion=$(cat /proc/version | sed -e 's/Linux version //;s/#.*//;s/.collect2:.*//')
fi
if [ -n "$_kernelversion" ]; then
	echo "<dl class='info'><dt>Kernel $(lang de:"Version" en:"version")</dt><dd>$_kernelversion</dd></dl>"
fi
echo "<dl class='info'><dt>Freetz $(lang de:"Version" en:"version")</dt><dd>$FREETZ_INFO_VERSION</dd></dl>"
date_de_format=$(echo "$FREETZ_INFO_MAKEDATE" \
  | sed -re 's/([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2})([0-9]{2})([0-9]{2})(.*)/\3.\2.\1 \4\:\5\:\6/')
[ "$date_de_format" != "reproducible" ] && \
  echo "<dl class='info'><dt>$(lang de:"Erstellungsdatum" en:"Creation date")</dt><dd>$date_de_format</dd></dl>"
echo "<dl class='info'><dt>$(lang de:"Urspr&uuml;nglicher Dateiname" en:"Initial file name")</dt><dd>$FREETZ_INFO_IMAGE_NAME</dd></dl>"
if [ ! -z "$FREETZ_INFO_COMMENT" ]; then
	echo "<dl class='info'><dt>$(lang de:"Benutzerdefinierte Informationen" en:"User defined information")</dt><dd>$FREETZ_INFO_COMMENT</dd></dl>"
fi
sec_end

print_entry() {
	local type=$1 name=$2 sub=$3
	if [ -n "$sub" ]; then
		if [ "$name" = "$open_entry" ]; then
			echo "<small>&nbsp;&nbsp;&nbsp;&gt; $sub</small><br>"
		else
			print_entry "$type" "${name}_$sub"
		fi
	else
		[ "$type" = "cgi" ] && name="${name}_cgi"
		if [ "$type" = "cgi" ] || [ "$type" = "pkg" ]; then
			name_dotted="$(echo "$name" | tr '_' '.')"
			ver="$(cut /etc/packages.lst -d ' ' -f 3,4 | sed -n "s/^${name_dotted} / /p")"
		else
			ver=''
		fi
		echo "$name$ver<br>"
		open_entry=$name
	fi
}
#
# Read (and print) all following entries with the desired type.
# Leave the last line read for the next invocation.
# Types START and END are used as markers.
#
read_entries() {
	local sel=$1 open_entry=
	while [ "$type" = "$sel" -o "$type" = START ]; do
		if [ "$type" = "$sel" ]; then
			print_entry "$type" "$entry" "$subentry"
		fi
		read -r sort type entry subentry || type=END
	done
}
#
# Preprocess, classify and sort configuration variables
# Output format: "$sortkey $type $entry [$sub_entry]"
# Examples:      "20 pkg dropbear disable_host_lookup"
#                "50 rem assistant"
# Entries with the same $type shall have the same $sortkey.
#
preprocess_conf() {
	local file=$1
	local lowercase="y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/;"
	sed -nr "
		s/=y$//
		s/^FREETZ_//
		/^EXTERNAL/ d
		/^(PATCH|USBSTORAGE|AUTOMOUNT|AUTORUN)_/ {
			s/^(USBSTORAGE|PATCH)_//
			s/_/ / # separate sub-option
			$lowercase
			s/^/10 pat /; p; d
		}
		/^REMOVE_/ {
			s/^REMOVE_//
			s/_/ /
			$lowercase
			s/^/20 rem /; p; d
		}
		/^MODULES_OWN/ {
			s/^MODULES_OWN=\" */ /g;s/ *\"$//;s/  */ /g
			s/ /\n50 mod /g; p; d
		}
		/^MODULE_/ {
			s/^MODULE_//
			s/^/50 mod /; p; d
		}
		/^LIB_/ {
			s/LIB_//
			s/_/ /
			$lowercase
			s/libusb 0_?/libusb_0 /
			s/^/60 lib /; p; d
		}
		/^PACKAGE_.*_CGI$/ {
			s/^PACKAGE_(.*)_CGI$/\1/
			/_/ d # why?
			$lowercase
			s/^/30 cgi /; p; d
		}
		/^PACKAGE/ {
			s/^PACKAGE_//
			s/_/ /
			$lowercase
			s/proxychains ng_?/proxychains_ng /
			s/decrypt fritzos_cfg_?/decrypt_fritzos_cfg /
			s/^/40 pkg /; p; d
		}
	" "$file" | sed 's/ _$//g' | sort -u | grep -v '^$'
}
#
# Format output; the order in which read_entries is called must match the sort
# order above
#
format_conf() {
	type=START
	sec_begin "$(lang de:"FREETZ-Konfiguration" en:"FREETZ configuration")"
	cat <<- 'EOF'
	<table id="freetz-conf" style="width:100%">
	<tr>

	<td>
	<table>
		<tr><th>Patches:</th></tr>
		<tr><td>
		EOF
		read_entries pat
		cat <<- 'EOF'
		</td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><th>Removes:</th></tr>
		<tr><td>
		EOF
		read_entries rem
		cat <<- 'EOF'
		</td></tr>
	</table>
	</td>

	<td>
	<table>
		<tr><th>CGI-Webifs:</th></tr>
		<tr><td>
		EOF
		read_entries cgi
		cat <<- 'EOF'
		</td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><th>Packages:</th></tr>
		<tr><td>
		EOF
		read_entries pkg
		cat <<- 'EOF'
		</td></tr>
	</table>
	</td>

	<td>
	<table>
		<tr><th>Modules:</th></tr>
		<tr><td>
		EOF
		read_entries mod
		cat <<- 'EOF'
		</td></tr>
		<tr><td>&nbsp;</td></tr>
		<tr><th>Libraries:</th></tr>
		<tr><td>
		EOF
		read_entries lib
		cat <<- 'EOF'
		</td></tr>
	</table>
	</td>

	</tr>
	</table>
	EOF
	cat <<- EOF
	<div $divstyle><br><a href="$(href extra mod do_download_config)"><b>.config:</b></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="$(href extra mod do_download_config)">$(lang de:"Herunterladen als Textdatei" en:"Download as text file")</a></div>
	EOF
	width=$((_cgi_width - 30))
	echo -n "<pre style='width: ${width}px; max-height: 100px;'>"
	html < /etc/.config
	echo '</pre>'
	sec_end
}
#
# Put everything together
#
if [ -r /etc/.config ]; then
#	echo "<pre>"; preprocess_conf /etc/.config | html; echo "</pre>"
	preprocess_conf /etc/.config | format_conf
fi

if [ -n "$FREETZ_INFO_EXTERNAL_FILES" ]; then
	sec_begin "$(lang de:"Ausgelagerte Dateien" en:"Externalised files")"
		width=$((_cgi_width - 30))
		echo -n "<pre style='width: ${width}px; max-height: 100px;'>"
		echo -n "$FREETZ_INFO_EXTERNAL_FILES" | sort
		echo '</pre>'
	sec_end
fi
