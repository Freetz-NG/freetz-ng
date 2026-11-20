. /mod/etc/conf/mod.cfg

sec_level=1
[ -r /tmp/flash/mod/security ] && let sec_level=$(cat /tmp/flash/mod/security)

_cgi_id() {
	case $1 in
		*[/]*) echo "$1" | sed "s#/#:#g" ;;
		*) echo "$1" ;;
	esac
}

include() {
	source /usr/lib/${2:-mod}/cgi/$1.sh
}

# webif might provide its own version of this module
include_module() {
	include "$1"
	if [ -n "$WEBIF" -a -r "/usr/lib/$WEBIF/cgi/$1.sh" ]; then
		source "/usr/lib/$WEBIF/cgi/$1.sh"
	fi
}

include cache
include html
include form
include links
include page
include stat_bar
include error
include request
include validation
include width
include skin

include_module menu

if [ -n "$REQUEST_METHOD" ] && [ "$MOD_HTTPD_NEWLOGIN" == "yes" ] && [ "$WEBIF" == "mww" ]; then
	include login
	checklogin
	[ "$isauth" == "0" ] && . /usr/mww/cgi-bin/login_page.sh && exit
fi

include csrf
if [ -n "$REQUEST_METHOD" ]; then
	csrf_load
	csrf_check
fi

