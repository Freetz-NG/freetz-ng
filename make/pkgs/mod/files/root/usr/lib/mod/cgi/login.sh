# validate login, renew "timer"
checklogin() {
SENDSID=""
SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
# SIDs are 32 hex digits
[ "${#SID}" == "32" ] || SID=""
case $SID in *[!0123456789abcdef]*) SID="" ;; esac
local lastacc=0
local idfile="/tmp/.webcfg.${_CGI_CSRF_SCOPE:-default}.$SID.sid"
[ "$MOD_HTTPD_TIMEOUT" -gt 0 ] 2>/dev/null && [ -f "$idfile" ] && lastacc="$(( $(date +%s) - $(date -r "$idfile" +%s 2>/dev/null) ))"
if [ -z "$SID" ] || [ ! -f "$idfile" ] || { [ "$MOD_HTTPD_TIMEOUT" -gt 0 ] 2>/dev/null && [ $lastacc -gt $(( ${MOD_HTTPD_TIMEOUT#"${MOD_HTTPD_TIMEOUT%%[!0]*}"} * 60 )) ]; }; then
	isauth="0";
	[ -n "$SID" ] && [ -e "$idfile" ] && rm "$idfile"
	SENDSID="$( (date "+%s";echo "$$";cat /etc/.freetz-ng-version /proc/avm/calib/avmzertifikate /proc/sys/urlader/environment 2>/dev/null) | md5sum | sed 's/ *-//')"
	return 1;
else
	touch "$idfile"
	isauth="1"
fi
return 0
}

