#
# Easy setting of *_chk and *_sel variables for <input> elements
# depending on configuration variables.
#
#	swap_auto_chk=''
#	swap_man_chk=''
#	if [ "$MOD_SWAP" = "yes" ]; then
#		swap_auto_chk=' checked'
#	else
#		swap_man_chk=' checked'
#	fi
#
# is equivalent to
#
#	check "$MOD_SWAP" yes:swap_auto "*":swap_man
#
_check() {
	local input=$1 alt key val var found=false; shift
	for alt; do
		key=${alt%%:*}; val=${alt#*:}
		var=${val:-$key}${suffix}
		if ! $found; then
			case $input in
				$key) eval "$var=\$checked"; found=true; continue ;;
			esac
		fi
		eval "$var="
	done
}
check()  suffix=_chk checked=" checked" _check "$@"
select() suffix=_sel checked=" selected" _check "$@"

# Print a radiogroup
#   $1: Name of the variable
#   $2: current value, selects checked entry
#   $3: Heading inside <h2>, optional
#   $4: HTML text inside <p>
#   $5..$n: Liste of radio entries as val:id:text
#     val: value for this entry, leading '+' for default entry
#     id: HTML id for this entry, can be empty
#     text: HTML text for this entry
cgi_print_radiogroup()
{
	local name=$1
	local value=$2
	local h2=$3
	local p=$4
	local nr nr_chk val chk id text
	shift 4

	if [ -n "$h2" ]; then
		echo "<h2>$h2</h2>"
	fi
	echo "<p>"
	echo "$p"
	nr_chk=0
	nr=1
	for i; do
		val="${i%%:*}"
		if [ "$val" != ${val#+} ]; then
			nr_chk=$nr
		fi
		if [ "$value" = "$val" ]; then
			nr_chk=$nr
			break;
		fi
		nr=$((nr+1))
	done
	nr=1
	for i; do
		val="${i%%:*}"
		i="${i#*:}"
		id="${i%%:*}"
		i="${i#*:}"
		text=$i
		val=${val#+}
		if [ -z "$id" ]; then
			id="${name}_${val}"
		fi
		if [ $nr = $nr_chk ]; then
			chk=" checked"
		else
			chk=
		fi
		echo "<input id=\"$id\" type=\"radio\" name=\"$name\" value=\"$val\"$chk><label for=\"$id\">$text</label>"
		nr=$((nr+1))
	done
	echo "</p>"
}

# Print a radiogroup for the starttype of a service
#   $1: Name of the variable
#   $2: current value, selects checked entry
#   $3: Heading in <h2>, optional
#   $4: HTML text inside <p>
#   $5: show inetd, if available (0/1)
cgi_print_radiogroup_service_starttype()
{
	local opt_inetd=
	if [ "0$5" -gt 0 -a -e /mod/etc/default.inetd/inetd.cfg ]; then
		opt_inetd="inetd::$(lang de:"Inetd" en:"Inetd")"
	fi
	cgi_print_radiogroup \
		"$1" "$2" "$3" "$4" \
		"yes::$(lang de:"Automatisch" en:"Automatic")" \
		"no::$(lang de:"Manuell" en:"Manual")" \
		$opt_inetd
}

# Print a radiogroup for "Activated"/"Deactivated"
#   $1: Name of the variable
#   $2: current value, selects checked entry
#   $3: Heading in <h2>, optional
#   $4: HTML text inside <p>
cgi_print_radiogroup_active()
{
	cgi_print_radiogroup \
		"$1" "$2" "$3" "$4" \
		"yes::$(lang de:"Aktiviert" en:"Activated")" \
		"no::$(lang de:"Deaktiviert" en:"Deactivated")"
}


# Print a checkbox
#   $1: Name of the variable
#   $2: current value, selects checked entry
#   $3: text inside label
#   $4: text after label, optional
cgi_print_checkbox()
{
	local name=$1
	local value=$2
	local text1=$3
	local text2=$4
	local chk

	if [ "$value" = "yes" ]; then
		chk=" checked"
	else
		chk=
	fi
	echo "<input type=\"hidden\" name=\"$name\" value=\"no\">"
	echo "<input id=\"${name}_yes\" type=\"checkbox\" name=\"$name\" value=\"yes\"$chk><label for=\"${name}_yes\">$text1</label>$text2"
}

# Print a checkbox inside <p>
# See cgi_print_checkbox
cgi_print_checkbox_p()
{
	echo "<p>"
	cgi_print_checkbox "$1" "$2" "$3" "$4"
	echo "</p>"
}

# Print a checkbox, terminate with <br>
# See cgi_print_checkbox
cgi_print_checkbox_br()
{
	cgi_print_checkbox "$1" "$2" "$3" "$4<br>"
}

# Print a one line text input field
#   $1: Name of the variable
#   $2: current value
#   $3: Length, int or size/maxlength
#   $4: Label, optional
#   $5: Text after input field, optional
#   $6: Type of input field, optional (default is "text")
cgi_print_textline()
{
	local name=$1
	local value=$2
	local len=$3
	local label=$4
	local post_text=$5
	local type=${6:-text}
	local size maxlength

	if [ "${len%/*}" = "$len" ]; then
		size=$len
		maxlength=$len
	else
		size=${len%/*}
		maxlength=${len#*/}
	fi
	if [ -n "$label" ]; then
		label="<label for=\"$name\">$label</label>"
	fi
	if [ -n "$size" ]; then
		size=" size=\"$size\""
	fi
	if [ -n "$maxlength" ]; then
		maxlength=" maxlength=\"$maxlength\""
	fi
	if [ -n "$value" ]; then
		value=" value=\"$(html "$value")\""
	fi
	echo "$label<input type=\"$type\" name=\"$name\" id=\"$name\"$size$maxlength$value>$post_text"
}

cgi_print_textline_p()
{
	echo "<p>"
	cgi_print_textline "$1" "$2" "$3" "$4" "$5" "$6"
	echo "</p>"
}

cgi_print_textline_br()
{
	cgi_print_textline "$1" "$2" "$3" "$4" "$5<br>" "$6"
}


# Print a one line password field
#   Parameters: See cgi_print_textline above
cgi_print_password()
{
	cgi_print_textline "$1" "$2" "$3" "$4" "$5" "password"
}

cgi_print_password_p()
{
	cgi_print_textline_p "$1" "$2" "$3" "$4" "$5" "password"
}

cgi_print_password_br()
{
	cgi_print_textline_br "$1" "$2" "$3" "$4" "$5" "password"
}

