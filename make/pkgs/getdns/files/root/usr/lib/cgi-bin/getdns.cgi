#!/bin/sh

. /usr/lib/libmodcgi.sh
check "$GETDNS_LOGLEVEL" 0:loglevel_c0 1:loglevel_c1 2:loglevel_c2 3:loglevel_c3 5:loglevel_c5 6:loglevel_c6 7:loglevel_c7 "*":loglevel_c4

sec_begin "$(lang de:"Starttyp" en:"Start type")" sec_start
cgi_print_radiogroup_service_starttype "enabled" "$GETDNS_ENABLED" "" "" 0
sec_end

sec_begin 'Stubby daemon'

cat << EOT
Log level:<br>
<input id="loglevel0" type="radio" name="loglevel" value="0"$loglevel_c0_chk><label for="loglevel0">EMERG  - System is unusable</label><br>
<input id="loglevel1" type="radio" name="loglevel" value="1"$loglevel_c1_chk><label for="loglevel1">ALERT  - Action must be taken immediately</label><br>
<input id="loglevel2" type="radio" name="loglevel" value="2"$loglevel_c2_chk><label for="loglevel2">CRIT   - Critical conditions</label><br>
<input id="loglevel3" type="radio" name="loglevel" value="3"$loglevel_c3_chk><label for="loglevel3">ERROR  - Error conditions</label><br>
<input id="loglevel4" type="radio" name="loglevel" value="4"$loglevel_c4_chk><label for="loglevel4">WARN   - Warning conditions</label><br>
<input id="loglevel5" type="radio" name="loglevel" value="5"$loglevel_c5_chk><label for="loglevel5">NOTICE - Normal, but significant, condition</label><br>
<input id="loglevel6" type="radio" name="loglevel" value="6"$loglevel_c6_chk><label for="loglevel6">INFO   - Informational message</label><br>
<input id="loglevel7" type="radio" name="loglevel" value="7"$loglevel_c7_chk><label for="loglevel7">DEBUG  - Debug-level message</label><br>
EOT

sec_end
