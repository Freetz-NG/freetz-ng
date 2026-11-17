#!/bin/sh


. /usr/lib/libmodcgi.sh

eval "$(modcgi branding:pkg:number:message:flash mod_cgi)"
if [ -n "$MOD_CGI_NUMBER" -a "$MOD_CGI_NUMBER" != "+49" ]; then
	csrf_check required
	sec_begin "$(lang de:"Hinweis" en:"Remark")"
	echo "<font color=red><br>"
	/mod/etc/init.d/rc.smstools3 sendsms $MOD_CGI_FLASH $MOD_CGI_NUMBER $MOD_CGI_MESSAGE
	echo "</font>"
	sec_end
fi

list_sms() {
	/mod/etc/init.d/rc.smstools3 listsms $1 | sed 's/$/<br>/g'
}

sec_begin "$(lang de:"SMS versenden" en:"Send SMS")"
cat << EOF
<form class="btn" action="$(href status smstools3)" method="post" style="display:inline;">
$(csrf_input)
<p><textarea name="message" cols="51" rows="3" maxlength="159"></textarea></p>
<p>
<input type="text"     value="+49" name="number" size="25" maxlength="35">
<input type="checkbox" value="flash" name="flash"> als Flash&nbsp;
<input type="submit"   value="senden">
</p>
</form>
EOF
sec_end

if [ $(find /var/spool/sms/checked/ /var/spool/sms/outgoing/ -type f | wc -l) -gt 0 ]; then
sec_begin "$(lang de:"Zu versendende SMS" en:"Transmitting SMS")"
list_sms outgoing
list_sms checked
sec_end
fi

sec_begin "$(lang de:"Empfangene SMS" en:"Received SMS")"
list_sms incoming
sec_end

if [ $(find /var/spool/sms/conveyed/ -type f | wc -l) -gt 0 ]; then
sec_begin "$(lang de:"Versendete SMS" en:"Conveyed SMS")"
list_sms conveyed
sec_end
fi
