<%
. /usr/lib/libmodcgi.sh
if [ "$_CGI_CSRF_SCOPE" != "rudi" ] || [ "$MOD_RUDI_CSRF_LEGACY" != "yes" ] || [ "$REQUEST_METHOD" != "GET" ] || [ "$SCRIPT_NAME" != "/cgi-bin/shell/cmd.cgi" ]; then
	csrf_require_post
fi

pid1=$(cgi_param pid)
pid2=$(cat /var/run/rudi_shell.pid)
unset error
if [ "$pid1" != "$pid2" ] || [ ! -f /var/run/rudi_shell.pid ]; then
	error="$(lang de:"Falsches Token" en:"Wrong token")"
elif [ "$sec_level" -gt 0 ]; then
	error="$(lang \
	  de:"Sicherheitsstufe erlaubt keinen Shell-Zugriff" \
	  en:"Security level does not allow shell access" \
	)"
fi
if [ -n "$error" ]; then
	echo -n 'Content-Type: text/html; charset=ISO-8859-1'$'\r\n\r\n'
	echo -n "<html><body><script type='text/javascript'>alert('$(lang de:"Zugriff verweigert!" en:"Access denied!") $error');</script></body></html>"
	exit 1
fi
%>

