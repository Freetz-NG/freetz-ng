#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$HTPDATE_ENABLED" yes:auto "*":man

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cat << EOF
<p>
<input id="auto" type="radio" name="enabled" value="yes"$auto_chk><label for="auto"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="manual" type="radio" name="enabled" value="no"$man_chk><label for="manual"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
<font size="1">
$(lang de:"Htpdate l&auml;uft nicht als Dienst, da es die Zeit nach einem IP-Wechsel, beim Systemstart und in den eingestellten Intervallen aktualisiert." en:"Htpdate doesn't run as a daemon, it updates the time after an IP change, during system startup and the given intervals automatically.")
</font>
EOF
sec_end

sec_begin "$(lang de:"Optionen" en:"Options")"
cat << EOF
<p>$(lang de:"Parameter" en:"Parameters"): <input type="text" name="parameters" size="55" maxlength="250" value="$(html "$HTPDATE_PARAMETERS")"></p>
<p>$(lang de:"Server" en:"Servers"): <input type="text" name="servers" size="75" maxlength="250" value="$(html "$HTPDATE_SERVERS")"></p>
EOF
sec_end

sec_begin "$(lang de:"Cron" en:"Cron")"
cat << EOF
<p>$(lang de:"Intervall" en:"Interval"): <input type="text" name="cron_int" size="15" maxlength="20" value="$(html "$HTPDATE_CRON_INT")"></p>
EOF
sec_end

