# A list of extra CSS stylesheets
_cgi_print_extra_styles() {
	local style
	for style in $_CGI_STYLES; do
		echo "<link rel='stylesheet' type='text/css' href='$(html "$style")'>"
	done
}

#
# Set options for the following CGI page
#
_cgi_option() {
	local opt=$1 value=$2 uri
	case $opt in
		style)
			case $value in
				/*|*:*) uri=$value ;;
				*) uri="/style/$value" ;;
			esac
			export _CGI_STYLES="$_CGI_STYLES $uri"
			;;
		id)
			export _CGI_ID=$(_cgi_id "$value") ;;
		width)
			cgi_width_at_least "$value" ;;
		help)
			local _BNT="$(sed -rn 's/.*-(ng[^-]*)$/\1/p' /etc/.freetz-version)"
			export _CGI_HELP="https://github.com/Freetz-NG/freetz-ng/blob/${_BNT:-master}/make/pkgs/README.md#$(echo $value | sed 's,.*/,,;s,_,-,g;s,#.*,,')"
			;;
		*)
			cgi_error "cgi: Unknown option '$opt'"
			exit 1
			;;
	esac
}

#
# User frontend
# cgi --opt1=value1 --opt2 value2
#
cgi() {
	local opt value
	while [ $# -gt 0 ]; do
		case $1 in
			--*=*)
				opt=${1#--}; opt=${opt%%=*}
				value=${1#--*=}
				shift
				_cgi_option "$opt" "$value"
				;;
			--*)
				opt=${1#--}
				value=$2
				shift 2
				_cgi_option "$opt" "$value"
				;;
			*)
				cgi_error "cgi: Illegal argument '$1'"
				exit 1
				;;
		esac
	done
}

cgi_begin() {
	# disable functions
	cgi() {
		cgi_error "cgi must be called before cgi_begin"; exit 1
	}
	local title=$1 id=${2:+$(_cgi_id "$2")}
	if [ -n "$_CGI_ID" ]; then
		id=$_CGI_ID
	fi
	local CRet=$'\r'
	cat << EOF
Content-Type: text/html; charset=UTF-8${CRet}
Content-Language: $(lang de:"de" en:"en")${CRet}
Expires: 0${CRet}
Pragma: no-cache${CRet}
X-UA-Compatible: IE=edge${CRet}
${CRet}
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
EOF
	site_refresh
	cgi_width_setup
	skin_head "$title" "$id"
	cat << EOF
</head>
<body${id:+ id='$id'}>
EOF
	skin_body_begin "$title" "$id"
}

cgi_end() {
	skin_body_end
	cat << EOF
</body>
</html>
EOF
}

sec_begin() {
	local title=$1 id=$2
	echo "<div class='section' ${id:+ id='$id'}>"
	skin_sec_begin "$title"
}
sec_end() {
	skin_sec_end
	echo "</div>"
}

site_refresh() {
	local refresh="$(cgi_param refresh | tr -d .)"
	[ -n "$refresh" ] && echo "<meta http-equiv='refresh' content='$refresh'>"
}

#
# Simplistic versions of the functions to be overridden by skins
#
skin_head() {
	local title=$1 id=$2
	echo "<title>$title</title>"
	_cgi_print_extra_styles
}
skin_body_begin() {
	local title=$1 id=$2
	echo "<h1>$title</h1>"
	_cgi_print_menu "$id"
}
skin_body_end() {
	:
}
skin_sec_begin() {
	echo "<div class='sec'><h2>$1</h2>"
}
skin_sec_end() {
	echo "</div>"
}
