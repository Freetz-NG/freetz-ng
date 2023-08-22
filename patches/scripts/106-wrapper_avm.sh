
echo1 "preparing avm wrapper"

wrapath="/usr/bin/wrapper"
file="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
# make sure PATH exists
grep -q "^PATH=" "$file" || sed '2 i\PATH=$PATH' -i "$file"
# extend PATH by wrapper
modsed \
  "s#\(^PATH=\)\(.*\)#\1$wrapath:\2#g" \
  "$file" \
  "^PATH=$wrapath:"

for daemon in dsld multid rextd; do
	[ -e "${FILESYSTEM_MOD_DIR}$wrapath/$daemon" ] || continue
	file="${FILESYSTEM_MOD_DIR}/lib/systemd/system/$daemon.service"
	[ -e "$file" ] || continue

	echo1 "preparing $daemon wrapper"
	modsed -r \
	  "s,^(ExecStart *=).*/*($daemon *.*)$,\1$wrapath/\2," \
	  "$file" \
	  "$wrapath/$daemon"
done

