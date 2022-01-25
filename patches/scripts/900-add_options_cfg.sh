
echo1 "creating options.cfg"

OPTIONS_CFG="${FILESYSTEM_MOD_DIR}/etc/options.cfg"
if [ "$FREETZ_CREATE_SEPARATE_OPTIONS_CFG" != "y" ]; then
	echo2 "by symlinking it to .config"
	ln -snf .config $OPTIONS_CFG
else
	OPTIONS_FILES="$(ls make/*/files/root/etc/init.d/rc.* make/*/files/root/etc/default.*/*_conf)"

	path=;file=;
	while read; do
		case "${REPLY}" in
			('') path=; file= ;;
			(*'/'*':') path="${REPLY%:}" ;;
			(*'.cgi'|*'.sh') file="$REPLY" ;;
			(*) file= ;;
		esac
		if test -d "${path}" && test -n "${file}"; then
			if test -L "${path}/${file}"; then
				link=$(realpath -m ${path}/${file})
				case "${link}" in
					('/'?*) link=${FILESYSTEM_MOD_DIR}/${link} ;;
					([!/]*) link=$(realpath ${path}/${file}) ;;
					(*) continue ;;
				esac
				if test -e "${link}"; then
					OPTIONS_FILES="${OPTIONS_FILES} ${link}"
				else
					warn1 "${link} missing"
				fi
			else
				OPTIONS_FILES="${OPTIONS_FILES} ${path}/${file}"
			fi
		fi
	done <<-EOF
	$(ls -R make/*/files/root/usr/)
	EOF
	OPTIONS_NAMES="$(grep -hoE "FREETZ_REPLACE_KERNEL|FREETZ_TYPE_[A-Z0-9_]*|FREETZ_AVMDAEMON_DISABLE_[A-Z0-9]*|FREETZ_AVM_HAS_[A-Z0-9_]*|FREETZ_AVM_VERSION_[X0-9_]*(_MIN)?|FREETZ_(TARGET|BUSYBOX)_[A-Z0-9_]*|EXTERNAL_DYNAMIC[a-zA-Z0-9_]*|(EXTERNAL_)?FREETZ_(PACKAGE|LIB|PATCH|CUSTOM|LANG)[a-zA-Z0-9_]*" $OPTIONS_FILES | sort -u)"

	for OPTIONS_CURRENT in $OPTIONS_NAMES; do
		OPTIONS_VALUE="$(eval echo \$$OPTIONS_CURRENT)"
		if [ "$OPTIONS_VALUE" != "n" -a "$OPTIONS_VALUE" != "" ]; then
			echo2 "adding $OPTIONS_CURRENT"
			echo "$OPTIONS_CURRENT='$OPTIONS_VALUE'" >> $OPTIONS_CFG
		fi
	done
fi
