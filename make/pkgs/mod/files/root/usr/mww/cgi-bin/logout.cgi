#!/bin/sh

if [ "$AUTH_TYPE" == "Basic" ]; then
	. /usr/lib/libmodredir.sh
	redirect_302 "$(self_prot)://$(sed -n 's/^\/cgi-bin\/invalidate.cgi://p' /mod/etc/webcfg.conf)@$(self_host)$(self_port)/cgi-bin/invalidate.cgi"
else
	SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
	# SIDs are 32 hex digits
	[ "${#SID}" == "32" ] || SID=""
	case $SID in *[!0123456789abcdef]*) SID="" ;; esac
	[ -n "$SID" ] && rm -f "/tmp/$SID.webcfg"
	isauth="0"
	QUERY_STRING=""
	source /usr/mww/cgi-bin/login.cgi
fi

