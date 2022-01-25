[ "$FREETZ_REMOVE_KIDS" == "y" ] || return 0
echo1 "removing kids files (userman/contfiltd)"

list='';file='';path=''
while read; do
	case "${REPLY}" in
		('') path=; file= ;;
		(*'/'*':') path="${REPLY%:}" ;;
		('userlist'*|'useradd'*) file="${REPLY}" ;;
		(*) file= ;;
	esac
	if test -n "${path}" && test -n "${file}"; then
		list="${list} ${path}/${file}"
	fi
done <<-EOF
	$(ls -1R ${HTML_LANG_MOD_DIR})
EOF

rm_files ${list} \
  ${FILESYSTEM_MOD_DIR}/bin/userman* \
  ${HTML_LANG_MOD_DIR}/internet/kids*.lua \
  ${FILESYSTEM_MOD_DIR}/sbin/contfiltd \
  ${FILESYSTEM_MOD_DIR}/etc/bpjm.data \
  ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libuser.so

# Prevent continous reboots on 3170 with replace kernel
if [ "$FREETZ_REMOVE_DSLD" = "y" ] || ! ( [ "$FREETZ_SYSTEM_TYPE_AR7_OHIO" = "y" -a "$FREETZ_REPLACE_KERNEL" = "y" ] ); then
list='';path=''
while read; do
	case "${REPLY}" in
		('') path= ;;
		(*'/userman'*':') path="${REPLY%:}" ;;
		(*) path='' ;;
	esac
	if test -n "${path}"; then
		list="${list} ${path}"
	fi
done <<-EOF
	$(ls -1R ${FILESYSTEM_MOD_DIR}/lib/modules)
EOF

	test -n "${list}" &&
	rm_files ${list} # removes dir of userman_mod.ko
else
	modsed "s/^modprobe kdsldmod$/modprobe kdsldmod\nmodprobe userman_mod/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	# patcht Uebersicht (by removing HasRestriction() function)
	modsed '/^function HasRestriction() {$/,/^}$/d' "${HTML_LANG_MOD_DIR}/html/de/home/home.js"
fi

# avoid reboot problem, see https://trac.boxmatrix.info/freetz-ng/ticket/1716
if isFreetzType 3170 && [ "$FREETZ_REPLACE_KERNEL" = "y" ] ; then
	# removing userman segfaults
	modsed "s/^rmmod userman$/# rmmod userman # segfaults/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.dsl.sh"
	modsed "s/^rmmod userman$/# rmmod userman # segfaults/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
	# subsequent removal of kdsldmod hangs forever
	modsed "s/^rmmod kdsldmod/# rmmod kdsldmod # hangs forever/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.dsl.sh"
	modsed "s/^  rmmod kdsldmod$/  :# rmmod kdsldmod # hangs forever/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
fi

# patcht Internet > Filter > Kindersicherung
[ "$FREETZ_AVM_VERSION_06_5X_MIN" != "y" ] && menulua_remove kids

# patcht Heimnetz > Netzwerk > Bearbeiten > Kindersicherung
[ -e "${HTML_LANG_MOD_DIR}/net/edit_device.lua" ] && modsed '/<.lua show_kisi_content() .>/d' "${HTML_LANG_MOD_DIR}/net/edit_device.lua"

# patcht Uebersicht > Komfortfunktionen
modsed '/ id="trKids" /{N;N;N;N;//d}' "${HTML_SPEC_MOD_DIR}/home/home.html"

# patcht Internet > Filter > Listen > Filterlisten
#lua
[ -e "${HTML_LANG_MOD_DIR}/internet/trafapp.lua" ] && file="trafapp.lua" || file="trafficappl.lua"
if [ -e "${HTML_LANG_MOD_DIR}/internet/$file" ]; then
	modsed '/^<hr>$/{N;N;N;N;N;N;N;/^<hr>\n.*385:981.*/d}' "${HTML_LANG_MOD_DIR}/internet/$file"
	modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:767.*/d}' "${HTML_LANG_MOD_DIR}/internet/$file"
	modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:122.*/d}' "${HTML_LANG_MOD_DIR}/internet/$file"
	modsed '/^<p>$/{N;N;N;N;N;/^<p>\n.*385:925.*/d}' "${HTML_LANG_MOD_DIR}/internet/$file"
fi
#html
if [ -e "${HTML_SPEC_MOD_DIR}/internet/trafficappl.html" ]; then
	modsed '/^<hr>$/{N;N;N;N;/^.*\n.*55:721.*/d}' "${HTML_SPEC_MOD_DIR}/internet/trafficappl.html"
	modsed '/^<div class="ml25">$/{N;N;N;N;N;/.*\n.*55:566.*/d}' "${HTML_SPEC_MOD_DIR}/internet/trafficappl.html"
	modsed '/^<div class="ml25 mb10">$/{N;N;N;N;N;/.*\n.*55:421.*/d}' "${HTML_SPEC_MOD_DIR}/internet/trafficappl.html"
fi

# patcht WLAN > Gastzugang > Gastzugang (privater Hotspot) aktivieren
modsed '/^<div>$/{N;N;N;/^.*\n.*2031:1282.*/d}' "${HTML_LANG_MOD_DIR}/wlan/guest_access.lua"

# redirect on webif to prio settings
list='';path='';file=''
for j in home.html menu2_internet.html; do
	while read; do
		case "${REPLY}" in
			('') path=; file= ;;
			(*'/'*':') path="${REPLY%:}" ;;
			('home.html'|'menu2_internet.html')
				file="$REPLY"
			;;
			(*) file= ;;
		esac
		if test -d "${path}" && test -n "${file}"; then
			list="${list} ${path}/${file}"
		fi
	done <<-EOF
	$(ls -1R "${HTML_LANG_MOD_DIR}")
	EOF
	for i in ${list}; do
		modsed "s/'userlist'/'trafficprio'/g" $i
	done
done

path='';file=''
for j in userlist useradd; do
	while read; do
		case "${REPLY}" in
			('') path=; file= ;;
			(*'/'*':') path="${REPLY%:}" ;;
			(*'.html') file="$REPLY" ;;
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
					i=$(grep -l $j ${link})
				else
					warn1 "${link} missing"
				fi
			else
				i=$(grep -l $j ${path}/${file})
			fi
			test -f "$i" &&
			modsed "/$j/d" $i
		fi
	done <<-EOF
	$(ls -1R "${HTML_LANG_MOD_DIR}")
	EOF
done

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_KIDS=.*$/CONFIG_KIDS=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
	modsed "s/CONFIG_KIDS_CONTENT=.*$/CONFIG_KIDS_CONTENT=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi
