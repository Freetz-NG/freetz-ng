#!/bin/sh



cgi_width=560
. /usr/lib/libmodcgi.sh
csrf_require_post

eval "$(modcgi mac:interf:prog wol)"

[ -z "$WOL_PROG" ] && WOL_PROG=ether-wake

if [ -z "$WOL_MAC" ]; then
	cgi_error "$(lang de:"Keine MAC Adresse angegeben" en:"no MAC address given")"
	exit 1
fi

case $WOL_PROG in
	ether-wake|wol) ;;
	*) cgi_error "$(lang de:"Ung&uuml;ltiges WOL-Programm" en:"Invalid WOL program")"; exit 1 ;;
esac
case $WOL_MAC in
	[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]) ;;
	*) cgi_error "$(lang de:"Ung&uuml;ltiges MaC-Adresse" en:"Invalid MAC address")"; exit 1 ;;
esac
case $WOL_INTERF in
	-*|*[!a-zA-Z0-9_.:-]*) cgi_error "$(lang de:"Ung&uuml;ltiges WOL-Interface" en:"Invalid WOL interface")"; exit 1 ;;
esac

cgi_begin "$(lang de:"Wecke '\"$WOL_MAC\"' auf ..." en:"Wake up '\"$WOL_MAC\"' ...")"

echo -n '<pre>sending magic frame ... '

if [ -z "$WOL_INTERF" ]; then
	"$WOL_PROG" "$WOL_MAC" >/dev/null 2>&1
elif [ "$WOL_PROG" == "wol" ]; then
	WOL_BCAST=$( set -- $( ifconfig "$WOL_INTERF" | grep Bcast: ); echo ${3#*:} )
	[ -z $WOL_BCAST ] && WOL_BCAST=$( set -- $( ifconfig lan | grep Bcast: ); echo ${3#*:} )
	[ -z $WOL_BCAST ] && WOL_BCAST=$( set -- $( ifconfig eth0 | grep Bcast: ); echo ${3#*:} )
	"$WOL_PROG" -h "$WOL_BCAST" "$WOL_MAC" >/dev/null 2>&1
else
	"$WOL_PROG" -i "$WOL_INTERF" "$WOL_MAC" >/dev/null 2>&1
fi
exitval=$?
if [ "$exitval" -eq 0 ]; then
	echo 'done.'
else
	echo 'failed.'
fi
echo '</pre>'
echo "<form action='/cgi-bin/index.cgi'><input type='submit' value='$(lang de:"Zur&uuml;ck" en:"Back")'></form>"

cgi_end

