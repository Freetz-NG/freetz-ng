_CGI_CSRF_FILE="/var/run/webcfg/csrf.${_CGI_CSRF_SCOPE:-default}"

modcgi() {
	if [ "$REQUEST_METHOD" == "POST" ] && [ -n "$_CGI_POST_FILE" ]; then
		command modcgi "$@" < "$_CGI_POST_FILE"
	else
		command modcgi "$@"
	fi
}

csrf_input() {
	printf '<input type="hidden" name="csrf_token" value="%s">\n' "$_CGI_CSRF_TOKEN"
}

csrf_error() {
	printf 'Status: %s\r\n' "$1"
	[ -z "$3" ] || printf '%s\r\n' "$3"
	printf 'Content-Type: text/plain; charset=UTF-8\r\nCache-Control: no-store\r\n\r\n%s\n' "$2"
	exit 1
}

csrf_init() (
	umask 077
	mkdir -p /var/run/webcfg
	chmod 700 /var/run/webcfg
	[ -s "$_CGI_CSRF_FILE" ] && exit 0
	local tmp="$_CGI_CSRF_FILE.$$"
	[ -e "$tmp" ] && exit 1
	trap 'rm -f "$tmp"' EXIT
	hexdump -n 32 -v -e '1/1 "%02x"' /dev/urandom > "$tmp"
	[ "$(wc -c < "$tmp")" != "64" ] && exit 1
	ln "$tmp" "$_CGI_CSRF_FILE" 2>/dev/null || [ -s "$_CGI_CSRF_FILE" ]
	# do not replace if race lost !
)

csrf_load() {
	[ -s "$_CGI_CSRF_FILE" ] || csrf_init || csrf_error '503 Service Unavailable' 'Cannot create CSRF token.'
	_CGI_CSRF_TOKEN="$(cat "$_CGI_CSRF_FILE" 2>/dev/null)"
	case $_CGI_CSRF_TOKEN in
		''|*[!0123456789abcdef]*) csrf_error '503 Service Unavailable' 'CSRF token data invalid. Restart webcfg.' ;;
	esac
	[ "${#_CGI_CSRF_TOKEN}" != "64" ] && csrf_error '503 Service Unavailable' 'CSRF token length invalid. Restart webcfg.'
}


csrf_check__read_post() {
	case $CONTENT_LENGTH in
		''|*[!0123456789]*) csrf_error '400 Bad Request' 'Invalid Content-Length.' ;;
	esac
	[ "$CONTENT_LENGTH" -gt 1048576 ] 2>/dev/null && csrf_error '413 Content Too Large' 'Form data too large.'
	[ -n "$_CGI_POST_FILE" ] && return

	_CGI_POST_FILE="/var/run/webcfg/post.$$"
	[ -e "$_CGI_POST_FILE" ] && csrf_error '503 Service Unavailable' 'Cannot read form data.'
	export _CGI_POST_FILE
	trap 'rm -f "$_CGI_POST_FILE"' EXIT
	head -c "$CONTENT_LENGTH" > "$_CGI_POST_FILE"
	[ "$(wc -c < "$_CGI_POST_FILE")" == "$CONTENT_LENGTH" ] || csrf_error '400 Bad Request' 'Incomplete form data.'
}

csrf_check__post_token() {
	case $NAME in
		*:csrf_token=*) _CGI_REQUEST_CSRF_TOKEN=${NAME##*:csrf_token=} ;;
	esac
	[ -n "$_CGI_REQUEST_CSRF_TOKEN" ] && return

	case $CONTENT_TYPE in
		multipart/form-data\;*)
			_CGI_REQUEST_CSRF_TOKEN=$FORM_csrf_token
			;;
		application/x-www-form-urlencoded|application/x-www-form-urlencoded\;*)
			_CGI_REQUEST_CSRF_TOKEN=$FORM_csrf_token
			[ -n "$_CGI_REQUEST_CSRF_TOKEN" ] && return
			csrf_check__read_post
			eval "$(modcgi csrf_token _cgi_request)"
			;;
	esac
}

csrf_check() {
	case $REQUEST_METHOD in
		'')		return ;;
		GET|HEAD)	[ "$1" != "required" ] && return ;;
		POST)		;;
		*)		csrf_error '405 Method Not Allowed' 'Unsupported request method.' 'Allow: GET, HEAD, POST' ;;
	esac
	[ "$_CGI_CSRF_CHECKED" == "yes" ] && return

	local _CGI_REQUEST_CSRF_TOKEN="$HTTP_X_CSRF_TOKEN"
	case $REQUEST_METHOD in
		GET|HEAD)	[ -z "$_CGI_REQUEST_CSRF_TOKEN" ] && _CGI_REQUEST_CSRF_TOKEN="$(cgi_param csrf_token)" ;;
		POST)		csrf_check__post_token ;;
	esac

	[ -n "$_CGI_REQUEST_CSRF_TOKEN" ] && [ "$_CGI_REQUEST_CSRF_TOKEN" == "$_CGI_CSRF_TOKEN" ] || csrf_error '403 Forbidden' 'Invalid CSRF token. Reload the page and try again.'
	export _CGI_CSRF_CHECKED=yes
}

csrf_require_post() {
	[ "$REQUEST_METHOD" == "POST" ] || csrf_error '405 Method Not Allowed' 'This action requires POST.' 'Allow: POST'
}

