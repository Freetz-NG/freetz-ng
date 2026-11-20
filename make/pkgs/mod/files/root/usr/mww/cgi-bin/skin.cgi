#!/bin/sh
# Helper for switching skins
# "skin.cgi?name=foo": select skin "foo"
# "skin.cgi?reset=1": reset to default

. /usr/lib/libmodcgi.sh

SKIN_DIR=/usr/share/skin
CR=$'\r'

invalid_skin() {
	local name=$1
	cgi --id=skin
	cgi_begin 'Skins'
	[ $# -gt 0 ] && print_error "$(lang \
	  de:"'$name' ist kein g&uuml;ltiger Skin." \
	  en:"'$name' is not a valid skin." \
	)"
	echo "<p>$(lang \
	  de:"Es stehen folgende Skins zur Auswahl (ben&ouml;tigt Cookies):" \
	  en:"Please choose from the following skins (cookies required):" \
	)"
	echo "<ul>"
	local skin
	for skin in $(ls "$SKIN_DIR"); do
		echo "<li><a href='?name=$skin' onclick=\"return csrfPost(this.href,{name:'$skin'})\">$skin</a></li>"
	done
	echo "</ul>"
	echo "<p><a href='?reset=1' onclick=\"return csrfPost(this.href,{reset:'1'})\">$(lang \
	  de:"Zur&uuml;ck zum Standard-Skin" \
	  en:"Switch back to default skin" \
	)</a></p>"
	cgi_end
	exit
}

default_skin=cuma
set_skin() {
	local name=$1
	cookie_redir "skin=$name; Path=/; Max-Age=$((20*365*24*3600))"
}

reset_skin() {
	cookie_redir "skin=${default_skin}; Path=/; Max-Age=0"
}

redir_target=/cgi-bin/skin.cgi
cookie_redir() {
	cat << EOF
Status: 302 Found${CR}
Set-Cookie: $1${CR}
Location: ${redir_target}${CR}
${CR}
EOF
	exit
}

[ "$REQUEST_METHOD" == "POST" ] || invalid_skin

eval "$(modcgi name:reset skin)"
[ -n "${SKIN_RESET+1}" ] && reset_skin
[ -z "${SKIN_NAME+1}" ] && invalid_skin

case $SKIN_NAME in
	""|*[^A-Za-z0-9_]*) invalid_skin "$SKIN_NAME" ;;
	*) [ ! -d "$SKIN_DIR/$SKIN_NAME" ] && invalid_skin "$SKIN_NAME" ;;
esac

set_skin "$SKIN_NAME"

