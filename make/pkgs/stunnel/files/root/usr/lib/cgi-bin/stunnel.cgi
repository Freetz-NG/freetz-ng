#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

for i in crit err warning notice info debug; do
	select "$STUNNEL_VERBOSE" "$i":verbose_${i}
done

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$STUNNEL_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
[ "$FREETZ_PACKAGE_STUNNEL_BOXCERT" == y ] && \
cgi_print_radiogroup \
	"use_box_cert" "$STUNNEL_USE_BOX_CERT" "" "$(lang de:"Standard-Zertifikat f&uuml;r Server-Dienste" en:"Default certificate for non-client services"):&nbsp;" \
		"yes::$(lang de:"Ger&auml;te-Zertifikat" en:"Device certificate")" \
		"no::$(lang de:"Eigenes Zertifikat" en:"Own certificate")"
cat << EOF
<h2>$(lang de:"Erweiterte Einstellungen" en:"Advanced settings"):</h2>
EOF
cgi_print_textline_p "ssloptions" "$STUNNEL_SSLOPTIONS" 20/255 "$(lang de:"OpenSSL Optionen" en:"OpenSSL options"): "
cat << EOF
<p>$(lang de:"Log-Level" en:"Verbosity level"):
<select name='verbose'>
<option value="crit"$verbose_crit_sel>0</option>
<option value="err"$verbose_err_sel>1</option>
<option value="warning"$verbose_warning_sel>2</option>
<option value="notice"$verbose_notice_sel>3</option>
<option value="info"$verbose_info_sel>4</option>
<option value="debug"$verbose_debug_sel>5</option>
</select>
</p>
EOF
sec_end

