# validate login, renew "timer"
checklogin() {
SENDSID=""
SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
# SIDs are 32 hex digits
[ "${#SID}" == "32" ] || SID=""
case $SID in *[!0123456789abcdef]*) SID="" ;; esac
local lastacc="$(( 1 + $MOD_HTTPD_SESSIONTIMEOUT ))"
local idfile="/tmp/$SID.webcfg"
[ -f "$idfile" ] && lastacc="$(( $(date +%s) - $(date -r "$idfile" +%s 2>/dev/null) ))"
if [ -z "$SID" ] || [ $lastacc -gt $MOD_HTTPD_SESSIONTIMEOUT ]; then
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

