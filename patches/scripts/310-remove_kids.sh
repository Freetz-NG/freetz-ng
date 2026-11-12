[ "$FREETZ_REMOVE_KIDS" == "y" ] || return 0
echo1 "removing kids files (userman/contfiltd)"

rm_files \
  ${FILESYSTEM_MOD_DIR}/bin/userman* \
  $(find ${HTML_LANG_MOD_DIR} -name 'userlist*' -o -name 'useradd*') \
  ${HTML_LANG_MOD_DIR}/internet/kids*.lua \
  ${FILESYSTEM_MOD_DIR}/sbin/contfiltd \
  ${FILESYSTEM_MOD_DIR}/etc/bpjm.data \
  ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libuser.so

# Prevent continous reboots on 3170 with replace kernel
if [ "$FREETZ_REMOVE_DSLD" = "y" ] || ! ( [ "$FREETZ_SYSTEM_TYPE_AR7_OHIO" = "y" -a "$FREETZ_REPLACE_KERNEL" = "y" ] ); then
	rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name userman -type d)	# removes dir of userman_mod.ko
else
	modsed "s/^modprobe kdsldmod$/modprobe kdsldmod\nmodprobe userman_mod/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	# patcht Uebersicht (by removing HasRestriction() function)
	modsed '/^function HasRestriction() {$/,/^}$/d' "${HTML_LANG_MOD_DIR}/html/de/home/home.js"
fi

# avoid reboot problem, see Ticket #1716
if isFreetzType 3170 && [ "$FREETZ_REPLACE_KERNEL" = "y" ] ; then
	# removing userman segfaults
	modsed "s/^rmmod userman$/# rmmod userman # segfaults/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.dsl.sh"
	modsed "s/^rmmod userman$/# rmmod userman # segfaults/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
	# subsequent removal of kdsldmod hangs forever
	modsed "s/^rmmod kdsldmod/# rmmod kdsldmod # hangs forever/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.dsl.sh"
	modsed "s/^  rmmod kdsldmod$/  :# rmmod kdsldmod # hangs forever/g" "${FILESYSTEM_MOD_DIR}/bin/prepare_fwupgrade"
fi

# patcht Internet > Filter > Kindersicherung
[ "$FREETZ_AVM_VERSION_06_5X_MIN" != "y" ] && menulua_remove "kids"

# patcht Internet > Filter > Kindersicherung
htmltab_remove "/js3/views/internet/filter/filter.html" "/filter"
# patcht Internet > Filter > Tickets für Online-Zeit
htmltab_remove "/js3/views/internet/filter/filter.html" "/filter/tickets"

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
for j in home.html menu2_internet.html; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name $j); do
		modsed "s/'userlist'/'trafficprio'/g" $i
	done
done

for j in userlist useradd; do
	for i in $(find "${HTML_LANG_MOD_DIR}" -type f -name '*.html' | xargs grep -l $j); do
		modsed "/$j/d" $i
	done
done

if [ -e "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init" ]; then
	modsed "s/KIDS=y/KIDS=n/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.init"
else
	modsed "s/CONFIG_KIDS=.*$/CONFIG_KIDS=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
	modsed "s/CONFIG_KIDS_CONTENT=.*$/CONFIG_KIDS_CONTENT=\"n\"/g" "$FILESYSTEM_MOD_DIR/etc/init.d/rc.conf"
fi

