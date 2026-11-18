#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg

check "$RRDSTATS_XCHGUPDOWN" yes:xchgupdown
check "$RRDSTATS_NOTLAZYM" yes:notlazym
check "$RRDSTATS_NOTLAZYS" yes:notlazys
check "$RRDSTATS_DISK_LOGARITHM1" yes:disk_logarithm1
check "$RRDSTATS_DISK_LOGARITHM2" yes:disk_logarithm2
check "$RRDSTATS_DISK_LOGARITHM3" yes:disk_logarithm3
check "$RRDSTATS_DISK_LOGARITHM4" yes:disk_logarithm4
check "$RRDSTATS_LOGARITHM1" yes:logarithm1
check "$RRDSTATS_LOGARITHM2" yes:logarithm2
check "$RRDSTATS_LOGARITHM3" yes:logarithm3
check "$RRDSTATS_LOGARITHM4" yes:logarithm4
check "$RRDSTATS_XCHG_RXTX1" yes:xchg_rxtx1
check "$RRDSTATS_XCHG_RXTX2" yes:xchg_rxtx2
check "$RRDSTATS_XCHG_RXTX3" yes:xchg_rxtx3
check "$RRDSTATS_XCHG_RXTX4" yes:xchg_rxtx4
check "$RRDSTATS_SAVEBACKUP" yes:savebackup
check "$RRDSTATS_END_BACKUP" yes:b_stop "*":b_start
check "$RRDSTATS_START_RESTORE" yes:start_restore
check "$RRDSTATS_DELBACKUP"  yes:delbackup
check "$RRDSTATS_TOBITAG" yes:tobitag
check "$RRDSTATS_SHOWFRAME" yes:showframe
check "$RRDSTATS_DARKMODE" yes:darkmode
check "$RRDSTATS_CPU100PERC" yes:cpu100perc
check "$RRDSTATS_UPTIME_ENB" yes:uptime_enb
check "$RRDSTATS_POWER_ENB" yes:power_enb
check "$RRDSTATS_TEMP_ENB" yes:temp_enb
check "$RRDSTATS_WEBENABLED" yes:webenabled
check "$RRDSTATS_WEB_INETD"  yes:web_inetd
check "$RRDSTATS_WEB_AUTH"   yes:web_auth
check "$RRDSTATS_CABLE_MODEM" thg epc arris dvb "*":no
check "$RRDSTATS_THOMSON_ADV" yes:thomson_adv
check "$RRDSTATS_ARRISTM_ADV" yes:arristm_adv
check "$RRDSTATS_CISCOEPC_FW" _100609 _120225
check "$RRDSTATS_CISCOEPC_UP" yes:ciscoepc_up
check "$RRDSTATS_CISCOEPC_UC" yes:ciscoepc_uc
check "$RRDSTATS_CISCOEPC_DETAILS" yes:ciscoepc_details
check "$RRDSTATS_CABLESEG_ENABLED" yes:cableseg_enabled
check "$RRDSTATS_CABLESEG_MAXBW" yes:cableseg_maxbw
check "$RRDSTATS_CABLESEG_MAXBWSUB" yes:cableseg_maxbwsub
check "$RRDSTATS_AHA_ENB" yes:aha_enb
check "$RRDSTATS_AHA_ALERT" yes:aha_alert
check "$RRDSTATS_AHA_WEBENB" yes:aha_webenb
check "$RRDSTATS_AHA_WEBINETD" yes:aha_webinetd
check "$RRDSTATS_AHA_WEBAUTH" yes:aha_webauth
check "$RRDSTATS_DIGITEMP1W" yes:digitemp1w
check "$RRDSTATS_DIGITEMP_C" yes:digitemp_c "*":digitemp_f
check "$RRDSTATS_DIGITEMP_RETRY85" yes:digitemp_retry85
check "$RRDSTATS_DIGITEMP85" yes:digitemp85
check "$RRDSTATS_DIGITEMP_A" yes:digitemp_a
check "$RRDSTATS_DIGITEMP_HTTP"  yes:digitemp_http
check "$RRDSTATS_DIGITEMP_INETD" yes:digitemp_inetd
check "$RRDSTATS_DIGITEMP_AUTH"  yes:digitemp_auth

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$RRDSTATS_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Anzeigen" en:"Show statistics")"

cat << EOF
<ul>
<li><a href="$(href status rrdstats stats)">$(lang de:"Statistiken anzeigen" en:"Show statistics")</a></li>
EOF

if [ "$FREETZ_PACKAGE_RRDSTATS_DIGITEMP" == "y" -a "$RRDSTATS_DIGITEMP1W" = "yes" ]; then
cat << EOF
<li><a href="$(href status rrdstats rrddt)">$(lang de:"DigiTemp anzeigen" en:"Show DigiTemp")</a></li>
EOF
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_SMARTHOME" == "y" -a "$RRDSTATS_AHA_ENB" = "yes" ]; then
cat << EOF
<li><a href="$(href status rrdstats avmha)">$(lang de:"SmartHome anzeigen" en:"Show SmartHome")</a></li>
EOF
fi

sec_end
sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cat << EOF
<p>
<input type="hidden" name="webenabled" value="no">
<input id="w1" type="checkbox" name="webenabled" value="yes"$webenabled_chk>
<label for="w1">$(lang de:"Zus&auml;tzlichen Webserver aktivieren auf Port" en:"Activate additional webserver on port")</label>&nbsp;
<input type="text" name="webtcpport" size="4" maxlength="5" value="$(html "$RRDSTATS_WEBTCPPORT")">
</p>
EOF

if [ "$RRDSTATS_WEBENABLED" = "yes" ]; then
if [ "$FREETZ_PACKAGE_INETD" == "y" ]; then
cat << EOF
<p>
<input type="hidden" name="web_inetd" value="no">
<input id="a3" type="checkbox" name="web_inetd" value="yes"$web_inetd_chk>
<label for="a3">$(lang de:"Aktivieren inetd Nutzung" en:"Activate inetd support")</label>
</p>
EOF
fi
cat << EOF
<p>
<input type="hidden" name="web_auth" value="no">
<input id="a1" type="checkbox" name="web_auth" value="yes"$web_auth_chk>
<label for="a1">$(lang de:"Authentifizierung" en:"Authentication").&nbsp;</label>
$(lang de:"Benutzer" en:"User"):
<input type="text" name="web_user" size="15" maxlength="15" value="$(html "$RRDSTATS_WEB_USER")">
$(lang de:"Passwort" en:"Password"):
<input type="password" name="web_pass" size="15" maxlength="15" value="$(html "$RRDSTATS_WEB_PASS")">
</p>
EOF
fi

cat << EOF
<p>$(lang de:"Tempor&auml;res Verzeichnis" en:"Temporary folder"):&nbsp;<input type="text" name="rrdtemp" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDTEMP")"></p>
<p>$(lang de:"Persistentes Verzeichnis" en:"Persistent folder"):&nbsp;<input type="text" name="rrddata" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDDATA")"></p>
<p>$(lang de:"Aufzeichnungsintervall in Sekunden" en:"Log interval in seconds"):&nbsp;<input type="text" name="interval" size="3" maxlength="9" value="$(html "$RRDSTATS_INTERVAL")"></p>
<p>$(lang de:"Breite der zus&auml;tzlichen Webserver" en:"Width of additional webservers"):&nbsp;<input type="text" name="altwidth" size="4" maxlength="4" value="$(html "$RRDSTATS_ALTWIDTH")"></p>
<p>
$(lang de:"Dimensionsverh&auml;ltnis der Graphen" en:"Graph dimensions ratio"):
<input type="text" name="dimensionx" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONX")">
:
<input type="text" name="dimensiony" size="3" maxlength="9" value="$(html "$RRDSTATS_DIMENSIONY")">
</p>
<p>
$(lang de:"Periode der Hauptseite" en:"Period of main graph"):&nbsp;<input type="text" name="periodmain" size="2" maxlength="4" value="$(html "$RRDSTATS_PERIODMAIN")">
$(lang de:"der Unterseiten" en:"sub-pages"):&nbsp;<input type="text" name="periodssub" size="22" maxlength="99" value="$(html "$RRDSTATS_PERIODSSUB")">
</p>
<p>
$(lang de:"Graphen immer neu generieren (not lazy)" en:"Always generate new graphs (not lazy)"):
<input type="hidden" name="notlazym" value="no">
<input id="l1" type="checkbox" name="notlazym" value="yes"$notlazym_chk><label for="l1">$(lang de:"Hauptseite" en:"Home")</label>
<input type="hidden" name="notlazys" value="no">
<input id="l2" type="checkbox" name="notlazys" value="yes"$notlazys_chk><label for="l2">$(lang de:"Unterseiten" en:"Sub-pages")</label>
</p>
<p>
<input type="hidden" name="tobitag" value="no">
<input id="tt" type="checkbox" name="tobitag" value="yes"$tobitag_chk>
<label for="tt">$(lang de:"Zeige den Namen des Autors von rrdtool auf allen Graphen" en:"Show the name of the author of rrdtool on all graphs")</label></p>
<p>
EOF

if [ "$FREETZ_PACKAGE_RRDTOOL_VERSION_CURRENT" == "y" ]; then
cat << EOF
<input type="hidden" name="showframe" value="no">
<input id="sf" type="checkbox" name="showframe" value="yes"$showframe_chk>
<label for="sf">$(lang de:"Zeichne einen Rahmen um die Graphen" en:"Draw a frame around the graphs")</label></p>
<p>
EOF
fi

cat << EOF
<input type="hidden" name="darkmode" value="no">
<input id="dm" type="checkbox" name="darkmode" value="yes"$darkmode_chk>
<label for="dm">$(lang de:"Aktiviere Dark-Mode f&uuml;r die Graphen" en:"Enable dark-mode for the graphs")</label></p>
<p>
<input type="hidden" name="cpu100perc" value="no">
<input id="c1" type="checkbox" name="cpu100perc" value="yes"$cpu100perc_chk>
<label for="c1">$(lang de:"Maximum des Graphen der CPU-Nutzung auf 100 Prozent festlegen" en:"Maximum of the CPU utilization graph always at 100%")</label></p>
<p>
<input type="hidden" name="uptime_enb" value="no">
<input id="u1" type="checkbox" name="uptime_enb" value="yes"$uptime_enb_chk>
<label for="u1">$(lang de:"Uptime aufzeichnen und anzeigen" en:"Uptime logging and graphs")</label></p>
<p>
<input type="hidden" name="power_enb" value="no">
<input id="u2" type="checkbox" name="power_enb" value="yes"$power_enb_chk>
<label for="u2">$(lang de:"Energieverbrauch aufzeichnen und anzeigen" en:"Power Consumption logging and graphs")</label></p>
EOF
if [ "$RRDSTATS_POWER_ENB" == "yes" ]; then
cat << EOF
<p>$(lang de:"Diese Verbraucher &uuml;berwachen" en:"Observe these consumers"):&nbsp;<input type="text" name="power_cfg" size="45" maxlength="255" value="$(html "$RRDSTATS_POWER_CFG")">
EOF
for x in $(ctlmgr_ctl -v u power 2>/dev/null | sed -rn 's/.*rate_(.*)act=.*/\1/p'); do PIT="$PIT $x=$(ctlmgr_ctl r power status/rate_${x}act 2>/dev/null)"; done
[ -n "$PIT" ] && echo "<br /><font size='-2'>$(lang de:"Verf&uuml;gbar" en:"Available"): $PIT</font>"
echo "</p>"
fi


if [ "$FREETZ_PACKAGE_RRDSTATS_TEMPERATURE_SENSOR" == "y" ]; then
cat << EOF
<p>
<input type="hidden" name="temp_enb" value="no">
<input id="f1" type="checkbox" name="temp_enb" value="yes"$temp_enb_chk>
<label for="f1">$(lang de:"Temperatur aufzeichnen und anzeigen (wenn vorhanden, aktueller Wert:" en:"Temperature logging and graphs (if available, current value:") '$(modtemp | sed 's/^$/unknown/')')</label></p>
EOF
fi

sec_end
sec_begin "$(lang de:"Backup" en:"Backup")"

cat << EOF
<p>$(lang de:"Backup Verzeichnis" en:"Backup folder"):&nbsp;<input type="text" name="rrdbackup" size="45" maxlength="255" value="$(html "$RRDSTATS_RRDBACKUP")"></p>
<p>
<input type="hidden" name="savebackup" value="no">
<input id="b1" type="checkbox" name="savebackup" value="yes"$savebackup_chk>
<label for="b1">$(lang de:"Backup anlegen" en:"Backup files")</label>:&nbsp;
<input id="b3" type="radio" name="end_backup" value="no"$b_start_chk><label for="b4">$(lang de:"beim Starten" en:"during start")</label>
<input id="b4" type="radio" name="end_backup" value="yes"$b_stop_chk><label for="b4">$(lang de:"beim Beenden" en:"during stop")</label>
</p>
<p>
<input type="hidden" name="start_restore" value="no">
<input id="b5" type="checkbox" name="start_restore" value="yes"$start_restore_chk>
<label for="b5">$(lang de:"Backup beim Starten zur&uuml;ckspielen" en:"Restore files during startup")</label>
</p>
<p>
<input type="hidden" name="delbackup" value="no">
<input id="b2" type="checkbox" name="delbackup" value="yes"$delbackup_chk>
<label for="b2">$(lang de:"Nicht mehr Backups aufbewahren als" en:"Do not keep more backups than")</label>:&nbsp;
<input type="text" name="maximumbackups" size="3" maxlength="4" value="$(html "$RRDSTATS_MAXIMUMBACKUPS")">
</p>
EOF

sec_end

if [ "$FREETZ_PACKAGE_RRDSTATS_CABLEMODEM" == "y" ]; then
sec_begin "$(lang de:"Kabelmodem" en:"Cable modem")"

cat << EOF
<p>
<input id="modem1" type="radio" name="cable_modem" value="no"$no_chk><label for="modem1">$(lang de:"Keins &uuml;berwachen" en:"Observe none")</label>
</p>

<hr>

<p>
<input id="modem2" type="radio" name="cable_modem" value="thg"$thg_chk><label for="modem2">Thomson THG 520/540</label>
EOF
if [ "$RRDSTATS_CABLE_MODEM" == "thg" ]; then
cat << EOF
<ul>
<p>
<input type="hidden" name="thomson_adv" value="no">
<input id="t1" type="checkbox" name="thomson_adv" value="yes"$thomson_adv_chk>
<label for="t1">$(lang de:"Zus&auml;tzliche Parameter: Downstreamfrequenz, Upstreamkanal und Uptime" en:"More parameters: Downstream frequence, upstream channel and uptime")</label>
</p>
</ul>
EOF
fi
cat << EOF
</p>

<hr>

<p>
<input id="modem3" type="radio" name="cable_modem" value="epc"$epc_chk><label for="modem3">Cisco EPC 3212</label>
EOF
if [ "$RRDSTATS_CABLE_MODEM" == "epc" ]; then
cat << EOF
<ul>
<p>
<label >$(lang de:"Firmwaredatum" en:"Firmware date"): </label>
<input id="ciscofw1" type="radio" name="ciscoepc_fw" value="_100609"$_100609_chk><label for="ciscofw1">09.06.2010</label>
<input id="ciscofw2" type="radio" name="ciscoepc_fw" value="_120225"$_120225_chk><label for="ciscofw2">25.02.2012 / 29.01.2014</label>
</p>
EOF

if [ "$RRDSTATS_CISCOEPC_FW" != "_120225" ]; then
cat << EOF
<p>
<input type="hidden" name="ciscoepc_up" value="no">
<input id="t2" type="checkbox" name="ciscoepc_up" value="yes"$ciscoepc_up_chk>
<label for="t2">$(lang de:"&Uuml;berwache zus&auml;tzlich Uptime" en:"Observe uptime too")</label>
</p>
EOF
fi

cat << EOF
<p>
<input type="text" name="ciscoepc_rx" size="1" maxlength="1" value="$(html "$RRDSTATS_CISCOEPC_RX")">&nbsp;$(lang de:"Kan&auml;le im Downstream verf&uuml;gbar" en:"channels for downstream available")<br>
<input type="text" name="ciscoepc_tx" size="1" maxlength="1" value="$(html "$RRDSTATS_CISCOEPC_TX")">&nbsp;$(lang de:"Kan&auml;le im Upstream verf&uuml;gbar" en:"channels for upstream available")<br>
<font size="-2">
$(lang de:"Vorsicht: Die Datenbank muss bei &Auml;nderung der Kan&auml;le manuell angepasst werden" en:"Warning: You have to modify the database by your own after changing the count of channels"),&nbsp;
$(lang de:"siehe" en:"see")&nbsp;<a href='$(html "https://freetz-ng.github.io/freetz-ng/wiki/packages/rrdstats#cable")' target='_blank'>Wiki</a>.
</font>
</p>
<p>
<input type="hidden" name="ciscoepc_details" value="no">
<input id="t4" type="checkbox" name="ciscoepc_details" value="yes"$ciscoepc_details_chk>
<label for="t4">$(lang de:"Unterseiten f&uuml;r die Werte der Hauptseite" en:"Sub pages for the values on the main page")</label>
</p>
</ul>
</p>
EOF
fi
cat << EOF
</p>

<hr>

<p>
<input id="modem4" type="radio" name="cable_modem" value="arris"$arris_chk><label for="modem4">Arris Touchstone TM</label>
EOF
if [ "$RRDSTATS_CABLE_MODEM" == "arris" ]; then
cat << EOF
<ul>
<p>
<input type="hidden" name="arristm_adv" value="no">
<input id="t0" type="checkbox" name="arristm_adv" value="yes"$arristm_adv_chk>
<label for="t0">$(lang de:"Zus&auml;tzliche Parameter: Downstreamfrequenz, Upstreamfrequenz und Uptime" en:"More parameters: Downstream frequency, upstream frequency and uptime")</label>
</p>
</ul>
EOF
fi
cat << EOF
</p>

<hr>

<p>
<input id="modem5" type="radio" name="cable_modem" value="dvb"$dvb_chk><label for="modem5">FRITZ!Box Cable</label>
EOF
if [ "$RRDSTATS_CABLE_MODEM" == "dvb" ]; then

cat << EOF
<p>
<input type="text" name="fritzdvb_rx" size="2" maxlength="2" value="$(html "$RRDSTATS_FRITZDVB_RX")">&nbsp;$(lang de:"Kan&auml;le im Downstream verf&uuml;gbar" en:"channels for downstream available")<br>
<input type="text" name="fritzdvb_tx" size="1" maxlength="1" value="$(html "$RRDSTATS_FRITZDVB_TX")">&nbsp;$(lang de:"Kan&auml;le im Upstream verf&uuml;gbar" en:"channels for upstream available")<br>
<font size="-2">
$(lang de:"Vorsicht: Die Datenbank muss bei &Auml;nderung der Kan&auml;le manuell angepasst werden" en:"Warning: You have to modify the database by your own after changing the count of channels"),&nbsp;
$(lang de:"siehe" en:"see")&nbsp;<a href='$(html "https://freetz-ng.github.io/freetz-ng/wiki/packages/rrdstats#cable")' target='_blank'>Wiki</a>.
</font>
</p>
</ul>
</p>
EOF

#let INIT_WINDOW_WIDTH=$MOD_CGI_WIDTH+78

cat << EOF

<hr>

$(lang de:"Zugangsdaten zum AVM-Webif" en:"Credentials of AVM webif")

<p>
$(lang de:"URL" en:"URL"):
<input type="text" name="fritzdvb_avmhost" size="25" maxlength="45" value="$(html "$RRDSTATS_FRITZDVB_AVMHOST")">
</p>

<p>
$(lang de:"Benutzername" en:"User"):
<input type="text" name="fritzdvb_avmuser" size="15" maxlength="25" value="$(html "$RRDSTATS_FRITZDVB_AVMUSER")">
($(lang de:"optional" en:"optional"))
</p>

<p>
$(lang de:"Passwort" en:"Password"):
<input type="password" name="fritzdvb_avmpass" size="15" maxlength="25" value="$(html "$RRDSTATS_FRITZDVB_AVMPASS")">
</p>

EOF

fi
cat << EOF
</p>
EOF

sec_end
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_SEGMENTLOAD" == "y" ]; then
sec_begin "$(lang de:"Kabelsegment" en:"Cable segment")"
cat << EOF

<p>
<input type="hidden" name="cableseg_enabled" value="no">
<input id="k1" type="checkbox" name="cableseg_enabled" value="yes"$cableseg_enabled_chk>
<label for="k1">$(lang de:"&Uumlberwachung des Kabelsegmentes aktivieren" en:"Observe cable segment load")</label>
</p>

<p>$(lang de:"Frequenzen" en:"Frequencies"):&nbsp;<input type="text" name="cableseg_frq" size="45" maxlength="255" value="$(html "$RRDSTATS_CABLESEG_FRQ")"></p>
<p>$(lang de:"Symbolrate" en:"Symbol rate"):&nbsp;<input type="text" name="cableseg_srate" size="5" maxlength="4" value="$(html "$RRDSTATS_CABLESEG_SRATE")"></p>
<p>$(lang de:"Ab dieser Frequenz 64 QAM nutzen, darunter 256 QAM" en:"Use 256 QAM below this frequency, otherwise 64 QAM."):&nbsp;<input type="text" name="cableseg_qam" size="4" maxlength="3" value="$(html "$RRDSTATS_CABLESEG_QAM")"></p>
<p>$(lang de:"Wartezeit nach jeder Frequenz" en:"Wait after each frequency"):&nbsp;<input type="text" name="cableseg_sleep" size="3" maxlength="2" value="$(html "$RRDSTATS_CABLESEG_SLEEP")">&nbsp;($(lang de:"Sekunden" en:"seconds"))</p>
<p>
<input type="hidden" name="cableseg_maxbw" value="no">
<input id="k2" type="checkbox" name="cableseg_maxbw" value="yes"$cableseg_maxbw_chk>
<label for="k2">$(lang de:"Maximale Bandbreite auf Hauptseite anzeigen" en:"Show maximum bandwidth on main page")</label>
</p>
<input type="hidden" name="cableseg_maxbwsub" value="no">
<input id="k3" type="checkbox" name="cableseg_maxbwsub" value="yes"$cableseg_maxbwsub_chk>
<label for="k3">$(lang de:"Maximale Bandbreite auf Unterseiten anzeigen" en:"Show maximum bandwidth on sub pages")</label>
</p>

<i>$(lang de:"Umgebung f&uuml;r DVB-Programme" en:"Environment for DVB programs")</i>
<p>$(lang de:"vorher" en:"before"):&nbsp;<input type="text" name="cableseg_pre" size="45" maxlength="255" value="$(html "$RRDSTATS_CABLESEG_PRE")"></p>
<p>$(lang de:"nachher" en:"after"):&nbsp;<input type="text" name="cableseg_post" size="45" maxlength="255" value="$(html "$RRDSTATS_CABLESEG_POST")"></p>

EOF
sec_end
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_STORAGE" == "y" ]; then
sec_begin "$(lang de:"Disks" en:"Disks")"

cat << EOF

<table>
<tr>
	<td>&nbsp;</td>
	<td>$(lang de:"Bezeichnung" en:"Disk label")</td>
	<td>$(lang de:"Device" en:"Device")</td>
	<td>$(lang de:"Maximal" en:"Maximum")</td>
	<td>&nbsp;$(lang de:"Logarithm." en:"Logarithm.")</td>
</tr>
<tr>
	<td>Disk 1:</td>
	<td><input type="text" name="disk_name1" size="15" maxlength="99" value="$(html "$RRDSTATS_DISK_NAME1")"></td>
	<td><input type="text" name="disk_dev1" size="8" maxlength="99" value="$(html "$RRDSTATS_DISK_DEV1")"></td>
	<td><input type="text" name="max_disk_graph1" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_DISK_GRAPH1")"></td>
	<td><input type="hidden" name="disk_logarithm1" value="no"><input id="i1" type="checkbox" name="disk_logarithm1" value="yes"$disk_logarithm1_chk><label for="i1">$(lang de:"aktiviert" en:"activated")</label></td>
</tr>
<tr>
	<td>Disk 2:</td>
	<td><input type="text" name="disk_name2" size="15" maxlength="99" value="$(html "$RRDSTATS_DISK_NAME2")"></td>
	<td><input type="text" name="disk_dev2" size="8" maxlength="99" value="$(html "$RRDSTATS_DISK_DEV2")"></td>
	<td><input type="text" name="max_disk_graph2" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_DISK_GRAPH2")"></td>
	<td><input type="hidden" name="disk_logarithm2" value="no"><input id="i2" type="checkbox" name="disk_logarithm2" value="yes"$disk_logarithm2_chk><label for="i2">$(lang de:"aktiviert" en:"activated")</label></td>
</tr>
<tr>
	<td>Disk 3:</td>
	<td><input type="text" name="disk_name3" size="15" maxlength="99" value="$(html "$RRDSTATS_DISK_NAME3")"></td>
	<td><input type="text" name="disk_dev3" size="8" maxlength="99" value="$(html "$RRDSTATS_DISK_DEV3")"></td>
	<td><input type="text" name="max_disk_graph3" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_DISK_GRAPH3")"></td>
	<td><input type="hidden" name="disk_logarithm3" value="no"><input id="i3" type="checkbox" name="disk_logarithm3" value="yes"$disk_logarithm3_chk><label for="i3">$(lang de:"aktiviert" en:"activated")</label></td>
</tr>
<tr>
	<td>Disk 4:</td>
	<td><input type="text" name="disk_name4" size="15" maxlength="99" value="$(html "$RRDSTATS_DISK_NAME4")"></td>
	<td><input type="text" name="disk_dev4" size="8" maxlength="99" value="$(html "$RRDSTATS_DISK_DEV4")"></td>
	<td><input type="text" name="max_disk_graph4" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_DISK_GRAPH4")"></td>
	<td><input type="hidden" name="disk_logarithm4" value="no"><input id="i4" type="checkbox" name="disk_logarithm4" value="yes"$disk_logarithm4_chk><label for="i4">$(lang de:"aktiviert" en:"activated")</label></td>
</tr>

</table>

<font size="-2">
$(lang de:"Devices: sda, sda1, sda2, sdb, ..." en:"Devices: sda, sda1, sda2, sdb,  ...")
<br />
$(lang de:"Maximal: Maximale Bandbreite in MegaByte/Sekunde, '0' f&uuml;r automatische Zuweisung" en:"Maximum: Maximum bandwidth megabytes per second, '0' for automatic allocation")
</font>

EOF

sec_end
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_NETWORK" == "y" ]; then
sec_begin "$(lang de:"Interfaces" en:"Interfaces")"

cat << EOF

<table>
<tr>
	<td>&nbsp;</td>
	<td>$(lang de:"Bezeichnung" en:"Interface label")</td>
	<td>$(lang de:"Interface" en:"Interface")</td>
	<td>$(lang de:"Maximal" en:"Maximum")</td>
	<td>&nbsp;$(lang de:"Logarithm." en:"Logarithm.")</td>
	<td>&nbsp;$(lang de:"Up/Down" en:"Up/Down")</td>
</tr>
<tr>
	<td>Interface 1:</td>
	<td><input type="text" name="nice_name1" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME1")"></td>
	<td><input type="text" name="interface1" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE1")"></td>
	<td><input type="text" name="max_graph1" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH1")"></td>
	<td><input type="hidden" name="logarithm1" value="no"><input id="s1" type="checkbox" name="logarithm1" value="yes"$logarithm1_chk><label for="s1">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx1" value="no"><input id="x1" type="checkbox" name="xchg_rxtx1" value="yes"$xchg_rxtx1_chk><label for="x1">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 2:</td>
	<td><input type="text" name="nice_name2" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME2")"></td>
	<td><input type="text" name="interface2" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE2")"></td>
	<td><input type="text" name="max_graph2" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH2")"></td>
	<td><input type="hidden" name="logarithm2" value="no"><input id="s2" type="checkbox" name="logarithm2" value="yes"$logarithm2_chk><label for="s2">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx2" value="no"><input id="x2" type="checkbox" name="xchg_rxtx2" value="yes"$xchg_rxtx2_chk><label for="x2">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 3:</td>
	<td><input type="text" name="nice_name3" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME3")"></td>
	<td><input type="text" name="interface3" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE3")"></td>
	<td><input type="text" name="max_graph3" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH3")"></td>
	<td><input type="hidden" name="logarithm3" value="no"><input id="s3" type="checkbox" name="logarithm3" value="yes"$logarithm3_chk><label for="s3">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx3" value="no"><input id="x3" type="checkbox" name="xchg_rxtx3" value="yes"$xchg_rxtx3_chk><label for="x3">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
<tr>
	<td>Interface 4:</td>
	<td><input type="text" name="nice_name4" size="15" maxlength="99" value="$(html "$RRDSTATS_NICE_NAME4")"></td>
	<td><input type="text" name="interface4" size="8" maxlength="99" value="$(html "$RRDSTATS_INTERFACE4")"></td>
	<td><input type="text" name="max_graph4" size="4" maxlength="99" value="$(html "$RRDSTATS_MAX_GRAPH4")"></td>
	<td><input type="hidden" name="logarithm4" value="no"><input id="s4" type="checkbox" name="logarithm4" value="yes"$logarithm4_chk><label for="s4">$(lang de:"aktiviert" en:"activated")</label></td>
	<td><input type="hidden" name="xchg_rxtx4" value="no"><input id="x4" type="checkbox" name="xchg_rxtx4" value="yes"$xchg_rxtx4_chk><label for="x4">$(lang de:"tauschen" en:"inverted")</label></td>
</tr>
</table>

<font size="-2">
$(lang de:"Interfaces: cpmac0 (DSL-Modem), wan (ATA-Modus), lan (Netzwerk), usbrndis (USB), ..." en:"Interfaces: cpmac0 (DSL-Modem), wan (ATA-module), lan (Network), usbrndis (USB), ...")
<br />
$(lang de:"Maximal: Maximale Bandbreite in Megabit/Sekunde, '0' f&uuml;r automatische Zuweisung" en:"Maximum: Maximum bandwidth megabits per second, '0' for automatic allocation")
</font>

EOF

sec_end
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_SMARTHOME" == "y" ]; then
sec_begin 'SmartHome'

cat << EOF

<p>
<input type="hidden" name="aha_enb" value="no">
<input id="h1" type="checkbox" name="aha_enb" value="yes"$aha_enb_chk>
<label for="h1">$(lang de:"&Uuml;berwachung von Aktoren aktivieren" en:"Enable observation of actors")</label>
</p>

<p>
<input type="hidden" name="aha_alert" value="no">
<input id="h2" type="checkbox" name="aha_alert" value="yes"$aha_alert_chk>
<label for="h2">$(lang de:"Aktiviere Alarmierungs&uuml;berwachung" en:"Activate alert observer")</label>
</p>

<p>
<input type="button" value="SmartHome aktualisieren" onclick="if (confirm('$(lang de:"Fortfahren?" en:"Proceed?")')==true) csrfPost('$(href extra rrdstats sh-init)',null,'Aktualisieren_von_SmartHome','menubar=no,width=$INIT_WINDOW_WIDTH,height=600,toolbar=no,resizable=yes,scrollbars=yes');" /> &nbsp;&nbsp;
<br><font size="-2">$(lang de:"Vor dem ersten Aktivieren und nach Ver&auml;nderungen oder Umbenennung der Ger&auml;te ausf&uuml;hren" en:"Run this before the first start and if you change or rename your devices")</font>
</p>

<hr>

<p>
<input type="hidden" name="aha_webenb" value="no">
<input id="h3" type="checkbox" name="aha_webenb" value="yes"$aha_webenb_chk>
<label for="h3">$(lang de:"Webserver aktivieren auf Port" en:"Activate webserver on port")</label>&nbsp;
<input type="text" name="aha_webport" size="4" maxlength="5" value="$(html "$RRDSTATS_AHA_WEBPORT")">
</p>

EOF

if [ "$RRDSTATS_AHA_WEBENB" = "yes" ]; then
if [ "$FREETZ_PACKAGE_INETD" == "y" ]; then
cat << EOF
<p>
<input type="hidden" name="aha_webinetd" value="no">
<input id="h4" type="checkbox" name="aha_webinetd" value="yes"$aha_webinetd_chk>
<label for="h4">$(lang de:"Aktivieren inetd Nutzung" en:"Activate inetd support")</label>
</p>
EOF
fi
cat << EOF
<p>
<input type="hidden" name="aha_webauth" value="no">
<input id="h5" type="checkbox" name="aha_webauth" value="yes"$aha_webauth_chk>
<label for="h5">$(lang de:"Authentifizierung" en:"Authentication").&nbsp;</label>
$(lang de:"Benutzer" en:"User"):
<input type="text" name="aha_webuser" size="15" maxlength="15" value="$(html "$RRDSTATS_AHA_WEBUSER")">
$(lang de:"Passwort" en:"Password"):
<input type="password" name="aha_webpass" size="15" maxlength="15" value="$(html "$RRDSTATS_AHA_WEBPASS")">
</p>
EOF
fi

let INIT_WINDOW_WIDTH=$MOD_CGI_WIDTH+78

cat << EOF

<hr>

$(lang de:"Zugangsdaten zum AVM-Webif" en:"Credentials of AVM webif")

<p>
$(lang de:"Hostname" en:"Host"):
<input type="text" name="aha_avmhost" size="25" maxlength="45" value="$(html "$RRDSTATS_AHA_AVMHOST")">
</p>

<p>
$(lang de:"Benutzername" en:"User"):
<input type="text" name="aha_avmuser" size="15" maxlength="25" value="$(html "$RRDSTATS_AHA_AVMUSER")">
($(lang de:"optional" en:"optional"))
</p>

<p>
$(lang de:"Passwort" en:"Password"):
<input type="password" name="aha_avmpass" size="15" maxlength="25" value="$(html "$RRDSTATS_AHA_AVMPASS")">
</p>

EOF

sec_end
fi

if [ "$FREETZ_PACKAGE_RRDSTATS_DIGITEMP" == "y" ]; then
sec_begin 'DigiTemp'

cat << EOF

<p>
<input type="hidden" name="digitemp1w" value="no">
<input id="d1" type="checkbox" name="digitemp1w" value="yes"$digitemp1w_chk>
<label for="d1">$(lang de:"Temperatur&uuml;berwachung von 1-wire Adaptern mit DigiTemp aktivieren" en:"Observe 1-wire adapters with DigiTemp")</label>
</p>

<p>
<input type="hidden" name="digitemp_http" value="no">
<input id="d4" type="checkbox" name="digitemp_http" value="yes"$digitemp_http_chk>
<label for="d4">$(lang de:"Webserver aktivieren auf Port" en:"Activate webserver on port")</label>&nbsp;
<input type="text" name="digitemp_port" size="4" maxlength="5" value="$(html "$RRDSTATS_DIGITEMP_PORT")">
</p>

EOF

if [ "$RRDSTATS_DIGITEMP_HTTP" = "yes" ]; then
if [ "$FREETZ_PACKAGE_INETD" == "y" ]; then
cat << EOF
<p>
<input type="hidden" name="digitemp_inetd" value="no">
<input id="a4" type="checkbox" name="digitemp_inetd" value="yes"$digitemp_inetd_chk>
<label for="a4">$(lang de:"Aktivieren inetd Nutzung" en:"Activate inetd support")</label>
</p>
EOF
fi
cat << EOF
<p>
<input type="hidden" name="digitemp_auth" value="no">
<input id="a2" type="checkbox" name="digitemp_auth" value="yes"$digitemp_auth_chk>
<label for="a2">$(lang de:"Authentifizierung" en:"Authentication").&nbsp;</label>
$(lang de:"Benutzer" en:"User"):
<input type="text" name="digitemp_user" size="15" maxlength="15" value="$(html "$RRDSTATS_DIGITEMP_USER")">
$(lang de:"Passwort" en:"Password"):
<input type="password" name="digitemp_pass" size="15" maxlength="15" value="$(html "$RRDSTATS_DIGITEMP_PASS")">
</p>
EOF
fi

let INIT_WINDOW_WIDTH=$MOD_CGI_WIDTH+78

cat << EOF

<p>
$(lang de:"Ma&szlig;einheit" en:"Unit of measure"):
<input id="m1" type="radio" name="digitemp_c" value="yes"$digitemp_c_chk><label for="m1">Celsius</label>
<input id="m2" type="radio" name="digitemp_c" value="no"$digitemp_f_chk><label for="m2">Fahrenheit</label>
</p>

<p>
$(lang de:"Serieller Port" en:"Serial port"):
<input type="text" name="digitemprs" size="10" maxlength="25" value="$(html "$RRDSTATS_DIGITEMPRS")">
$(lang de:"zB /dev/ttyS0 - leer lassen f&uuml;r USB" en:"eg /dev/ttyS0 - leave empty for USB")
</p>

<p>
$(lang de:"Bereich der Y-Achse" en:"Y-axis range"):
min:<input type="text" name="digitemp_l" size="3" maxlength="4" value="$(html "$RRDSTATS_DIGITEMP_L")">
max:<input type="text" name="digitemp_u" size="3" maxlength="4" value="$(html "$RRDSTATS_DIGITEMP_U")">
&nbsp;$(lang de:"leer lassen f&uuml;r automatisch" en:"leave empty for autoscaling")
</p>

<p>
<input type="hidden" name="digitemp85" value="no">
<input id="d2" type="checkbox" name="digitemp85" value="yes"$digitemp85_chk>
<label for="d2">$(lang de:"Unterdr&uuml;cke 85,000000&deg;C (Fehler und Werte)" en:"Ignore 185.000000&deg;F (errors and values)")</label>
</p>

<p>
<input type="hidden" name="digitemp_a" value="no">
<input id="d3" type="checkbox" name="digitemp_a" value="yes"$digitemp_a_chk>
<label for="d3">$(lang de:"Aktiviere Alarmierungs&uuml;berwachung" en:"Activate alert observer")</label>
</p>

<p>
$(lang de:"Anzahl Wiederholungen, falls ein Sensor keinen Wert zur&uuml;ckliefert" en:"Count of retries, if a sensorc does not return a value"):
<input type="text" name="digitemp_retries" size="2" maxlength="3" value="$(html "$RRDSTATS_DIGITEMP_RETRIES")">
</p>

<p>
<input type="hidden" name="digitemp_retry85" value="no">
<input id="d5" type="checkbox" name="digitemp_retry85" value="yes"$digitemp_retry85_chk>
<label for="d5">$(lang de:"Wiederhole auch bei 85,000000&deg;C (Fehler und Werte)" en:"Retry also with 185.000000&deg;F (errors and values)")</label>
</p>

<p>
<input type="button" value="DigiTemp initialisieren" onclick="if (confirm('$(lang de:"Fortfahren?" en:"Proceed?")')==true) csrfPost('$(href extra rrdstats dt-init)',null,'Initialisieren_von_DigiTemp','menubar=no,width=$INIT_WINDOW_WIDTH,height=600,toolbar=no,resizable=yes,scrollbars=yes');" /> &nbsp;&nbsp;
<br><font size="-2">$(lang de:"Vor dem ersten Aktivieren oder nach Ver&auml;nderungen der Ger&auml;te ausf&uuml;hren" en:"Run this before the first start of if you change your devices")</font>
</p>


EOF

sec_end
fi

