# Split PATH_INFO into segments at "/"; return the segments in the given
# variables. If there are not more variables than segments, the final variable
# will receive the remaining unsplit PATH_INFO.

path_info() {
	unset -v "$@"
	_path_info "$PATH_INFO" "$@"
}

_path_info() {
	# $1 is empty or starts with a slash
	if [ $# -le 1 -o -z "$1" ]; then
		return
	elif [ $# -eq 2 ]; then
		eval "$2=\$1"
		return
	else
		local __rest=${1#/}
		eval "$2=\${__rest%%/*}"
		shift 2
		case $__rest in
			*/*) _path_info "/${__rest#*/}" "$@" ;;
		esac
	fi
}

# get a single query parameter (unescaped)
cgi_param() {
	local key=$1
	local value="&$QUERY_STRING"
	case $value in
		*"&$key="*)
			value=${value##*"&$key="}
			value=${value%%&*}
			httpd -d "$value"
			;;
	esac
}
