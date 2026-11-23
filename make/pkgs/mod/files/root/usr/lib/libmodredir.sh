. /usr/lib/mod/cgi/html.sh

# Try to determine protocol
self_prot() {
	local TARGET_PROT="${HTTP_REFERER%%://*}"
	echo "${TARGET_PROT:-http}"
}

# Try to determine hostname (without port)
self_host() {
	# Use HTTP_REFERER to determine target host (could be a name, an IP(v4), or an IPv6 literal in brackets)
	local TARGET_HOST="$(echo "$HTTP_REFERER" | sed -n -r 's#^[^:]+://(\[[0-9a-fA-F:.]+\]|[^[/:]*)(.*)$#\1#p')"
	# Try HTTP_HOST
	if [ -z "$TARGET_HOST" ]; then
		case $HTTP_HOST in
			"["*)	TARGET_HOST="${HTTP_HOST%]*}]" ;;  # IPv6 literal
			*)	TARGET_HOST="${HTTP_HOST%:*}"  ;;  # decimal IPv4 or name
		esac
	fi
	# Use fritz.box as fallback
	echo "${TARGET_HOST:-fritz.box}"
}

# Try to determine port
self_port() {
	local TARGET_PORT
	if [ -n "$HTTP_REFERER" ]; then
		TARGET_PORT="$(echo "$HTTP_REFERER" | sed -n -r 's#^[^:]+://(\[[0-9a-fA-F:.]+\]|[^[/:]*)(.*)$#\2#p')"
	elif [ -n "$HTTP_HOST" ]; then
		case $HTTP_HOST in
			"["*)	TARGET_PORT="${HTTP_HOST#*]:}" ;;  # IPv6 literal
			*)	TARGET_PORT="${HTTP_HOST#*:}"  ;;  # decimal IPv4 or name
		esac
		[ "$TARGET_PORT" == "$HTTP_HOST" ] && TARGET_PORT="" || TARGET_PORT=":$TARGET_PORT"
	else
		TARGET_PORT=":81"
	fi
	echo "${TARGET_PORT%%/*}"
}

# Redirect: Header 'Status' works with busybox's httpd; for AVM's websrv, we send a small HTML page.
# $1 status code 30x + message
# $2 redirect location
# $3 page title
# $4 function that may produce additional BODY contents.
redirect__int() {
	local status="$1" location="$2" title="${3:-Redirect}" body_func="${4:-true}"
	local CR=$'\r'
	local LF=$'\n'
	case $location in
		*"$CR"*|*"$LF"*) location=/ ;;
		*) ;;
	esac
	case $location in
		/*|http://*|https://*) ;;
		*) location=/ ;;
	esac
	local html_location="$(html "$location")"
	local html_title="$(html "$title")"
	cat << EOF
Status: $status${CR}
Location: $location${CR}
Content-type: text/html; charset=iso-8859-1${CR}
${CR}
<html>
<head>
<title>$html_title</title>
<meta http-equiv="refresh" content="0;url=$html_location">
</head>
<body style="margin: 0px: padding: 0px; color: #b0b0b0; font-size: 10px;">
$("$body_func")
<p>Redirecting ... <a style="color: #b0b0b0;" href="$html_location">$html_title</a></p>
</body>
</html>
EOF
}
redirect_302() { redirect__int "302 Found (Moved Temporarily)" "$@" ; }
redirect_301() { redirect__int "301 Moved Permanently"         "$@" ; }
redirect    () { redirect_301                                  "$@" ; }

