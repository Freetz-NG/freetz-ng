#!/bin/sh



# include environment variables
. /bin/env.mod.rcconf

notdefined="$(lang de:"unbekannt" en:"unknown")"
divstyle="style='margin-top:6px;'"

getNetworkInfo() {
	ifconfig | sed -ne '
		/^[a-z0-9:]*[ \t]*Link encap:/N
		/inet addr:/N
		/inet addr/s/[ \t]*\n[ \t]*/ /gp
	' | sed -e '
		s/ UP .*//
		s/[ \t]*Link encap:\([^ ]*\).*inet addr:\([0-9.]*\)/ \1 \2/
		s/[ \t]*Mask:[0-9.]*//
		s/[ \t]*Bcast:[0-9.]*//
		s/[ \t]*Scope:.*//
		s/[ \t]*inet6 addr: / /
		s/[ \t]*P-t-P:[0-9.]*//
	' | while read interface itype ipv4 ipv6; do
		hostname=$(sed -ne "/^${ipv4}[ \t][ \t]*/s/[0-9.]*[ \t]*//p" /etc/hosts | sed -e 's/[ \t]/; /g')
		echo "$interface $itype $ipv4 $hostname"
	done
}

if [ -r /var/env ]; then
	while read -r key value; do
		case $key in
			urlader-version)   urladerversion=$value ;;
			bootloaderVersion) loaderversion=$value ;;
			webgui_pass)       defaultpass=$value ;;
			my_ipaddress)      ip_init_address=$value ;;
			maca)              mac_lan=$value ;;
			macdsl)            mac_dsl=$value ;;
			macwlan)           mac_wlan=$value ;;
			macwlan2)          mac_wlan2=$value ;;
			macwlan3)          mac_wlan3=$value ;;
		esac
	done < /var/env
else
	urladerversion=$notdefined
	loaderversion=$notdefined
	defaultpass=$notdefined
	ip_init_address=$notdefined
	mac_lan=$notdefined
	mac_dsl=$notdefined
	mac_wlan=$notdefined
	mac_wlan2=$notdefined
	mac_wlan3=$notdefined
fi
if [ -r /proc/cpuinfo ]; then
	cpu_family=$(sed -ne '/\(system type\|Hardware\)/ s/.*: //p' /proc/cpuinfo | sed 's/ .*//;s/Ikanos/IKS/')
	cpu_model=$(sed -ne '/\(cpu model\|model name\)/ s/.*: //p' /proc/cpuinfo | head -n1)
	cpu_cores=$(grep $'^processor\t*:' /proc/cpuinfo | wc -l)
	cpu_bogom="$(sed -ne '/BogoMIPS/ s/.*: //p' /proc/cpuinfo)"
	cpu_bogom="$(echo $cpu_bogom | sed 's! ! / !g')"

else
	cpu_family=""
	cpu_model=""
	cpu_cores=""
	cpu_bogom=""
fi
if [ -r /etc/version ]; then
	if grep -q FIRMWARE_DATE /etc/version; then
		avm_date=$(sed -ne 's/^export FIRMWARE_DATE\="\(.*\)"/\1/p' /etc/version)
	else
		avm_date=$(date -r /etc/version "+%d.%m.%Y %H:%M:%S")
	fi
else
	avm_date=$notdefined
fi
if [ -r /etc/.revision ]; then
	avm_revision=$(cat /etc/.revision)
elif [ -r /etc/version ]; then
	avm_revision="$(sed -n '/--project)$/{N;s/.*echo //p}' /etc/version)"
else
	avm_revision=$notdefined
fi

if [ -r /proc/sys/urlader/environment ]; then
	flash_size=$(sed -ne "s/^flashsize.\([0-9x].*\)/\1/p" /proc/sys/urlader/environment)
	case "$flash_size" in
		0x*)    flash_size=$(($flash_size / 0x100000));;
		*)      flash_size="";;
	esac
fi
if [ -z "$flash_size" -a "${CONFIG_ROMSIZE#*=}" == "${CONFIG_ROMSIZE%=*}" ]; then
	flash_size="$CONFIG_ROMSIZE"
fi
_CONFIG_TFFS="$(echo $CONFIG_ROMSIZE | sed -ne "s/^.*sflash_size=\([0-9BKMG]*\).*/\1/p" | sed -r 's/([0-9]*)/\1 /' | grep -v '^0 ')"
_CONFIG_NAND="$(echo $CONFIG_ROMSIZE | sed -ne   "s/^.*nand_size=\([0-9BKMG]*\).*/\1/p" | sed -r 's/([0-9]*)/\1 /' | grep -v '^0 ')"
_CONFIG_EMMC="$(echo $CONFIG_ROMSIZE | sed -ne   "s/^.*emmc_size=\([0-9BKMG]*\).*/\1/p" | sed -r 's/([0-9]*)/\1 /' | grep -v '^0 ')"
[ $(which run_clock) ] && run_clock=$(run_clock | sed 's/.*: //')
reboot_status="$(cat /proc/sys/urlader/reboot_status 2>/dev/null)"

sec_begin "$(lang de:"Hardware" en:"Hardware")"

echo "<dl class='info'>"
echo "<dt>$(lang de:"Boxname" en:"Box name")</dt><dd>$CONFIG_PRODUKT_NAME</dd>"
echo "<dt>ANNEX</dt><dd>$ANNEX</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>HWRevision</dt><dd>$HWRevision.$(($HWRevision_ATA)).$((HWRevision_BitFileCount)).$(($HWRevision_Reserved1))</dd>"
echo "<dt>HWSubRevision</dt><dd>$HWSubRevision</dd>"
[ -n "$flash_size" ] && echo "<dt>Flash (ROM)</dt><dd>$flash_size MB</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>RAM</dt><dd>$CONFIG_RAMSIZE MB</dd>"
[ -n "$_CONFIG_TFFS" ] && echo "<dt>TFFS</dt><dd>$_CONFIG_TFFS</dd>"
[ -n "$_CONFIG_NAND" ] && echo "<dt>NAND</dt><dd>$_CONFIG_NAND</dd>"
[ -n "$_CONFIG_EMMC" ] && echo "<dt>EMMC</dt><dd>$_CONFIG_EMMC</dd>"
echo "</dl>"

echo "<dl class='info'>"
[ -n "$cpu_family" ] && echo "<dt>CPU$(lang de:"-Familie" en:" family")</dt><dd>$cpu_family</dd>"
[ -n "$cpu_model"  ] && echo "<dt>CPU$(lang de:"-Modell"  en:" model" )</dt><dd>$cpu_model</dd>"
[ -n "$cpu_cores"  ] && echo "<dt>CPU$(lang de:"-Kerne" en:" cores" )</dt><dd>$cpu_cores</dd>"
echo "</dl>"

if [ -e /proc/clocks -o -e /proc/sys/urlader/environment ]; then
	echo "<dl class='info'>"
	echo "<dt>$(lang de:"Taktfrequenzen" en:"Clock frequencies")</dt><dl>"
	if [ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies ]; then
		_CPU_FQZ="$(sed 's!...[ $]! MHz !g;s! *$!!;;s!MHz !MHz, !g' /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies)"
		echo "<dt>$(lang de:"Verf&uuml;gbar" en:"Available")</dt><dd>$_CPU_FQZ</dd>"
		echo "</dl>"
		echo "</dl>"
		echo "<dl class='info'>"
		echo "<dt>$(lang de:"Prozessor" en:"Processor")</dt><dl>"
		_CPU_TMP="$(sed -rn 's!^Channel .: ([0-9.]*) .*!\1!p' /proc/chip_temperature 2>/dev/null | sort -r | head -n1)"
		[ -z "$_CPU_TMP" ] && _CPU_TMP="$(sed 's/^../&./' /sys/devices/virtual/thermal/thermal_zone0/temp 2>/dev/null)"
		[ -z "$_CPU_TMP" ] && _CPU_TMP="$(sed 's/ .*//g' /proc/avm/powermanagmentressourceinfo/powerdevice_temperature | grep -v '^0$' 2>/dev/null)"
		[ -z "$_CPU_TMP" ] && _CPU_TMP="$(sed -rn 's!^cpu-thermal *: ([0-9.]*) .*!\1!p' /proc/avm/temp_sensors 2>/dev/null)"
		[ -n "$_CPU_TMP" ] && echo "<dt>$(lang de:"Temperatur" en:"Temperature")</dt><dd>${_CPU_TMP%%.} $(echo -e '\260')C</dd>"
	elif [ -e /proc/clocks ]; then
		sed 's/ [ ]*/ /g;s/^Clocks: //;s/^[A-Z0-9 ]*Clock: //;s/\([A-Za-z0-9]*\):[ ]*\([0-9,.]*\)[ ]*\([a-zA-Z]*\) */<dt>\1<\/dt><dd>\2 \3<\/dd>/g;' /proc/clocks 2>/dev/null
	else
		_CPU_FRQ="$(sed -n 's/^cpufrequency\t//p' /proc/sys/urlader/environment | awk '{ printf "%.0f", $1 /1000/1000 }')"
		_SYS_FRQ="$(sed -n 's/^sysfrequency\t//p' /proc/sys/urlader/environment | awk '{ printf "%.0f", $1 /1000/1000 }')"
		[ -z "$_CPU_FRQ" ] && _CPU_FRQ="$(sed 's/000$//' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)"
		[ -z "$_SYS_FRQ" ] && _SYS_FRQ="$(sed 's/000$//' /sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq)"
		[ -n "$_CPU_FRQ" ] && echo "<dt>CPU</dt><dd>$_CPU_FRQ MHz</dd>"
		[ -n "$_SYS_FRQ" ] && echo "<dt>SYSTEM</dt><dd>$_SYS_FRQ MHz</dd>"
	fi
	[ -n "$cpu_bogom" ] && echo "<dt>BogoMIPS</dt><dd>$cpu_bogom</dd>"
	echo "</dl>"
	echo "</dl>"
fi

sec_end

sec_begin "$(lang de:"Bootenvironment" en:"Boot environment")"

echo "<dl class='info'>"
[ -n "$loaderversion" ]  && echo "<dt>$(lang de:"Bootloaderversion" en:"Version of bootloader")</dt><dd>$loaderversion</dd>"
[ -n "$urladerversion" ] && echo "<dt>$(lang de:"Urladerversion" en:"Version of urlader")</dt><dd>$urladerversion</dd>"
[ -n "$loaderversion$urladerversion" -a -n "$defaultpass$reboot_status" ] && echo "</dl>"&& echo "<dl class='info'>"
[ -n "$defaultpass" ]    && echo "<dt>$(lang de:"AVM-Standardpasswort" en:"AVM default password")</dt><dd>" && \
  echo -e "<a title='$defaultpass' style='background-color:#000000;color:#000000;text-decoration:none'>$defaultpass</a>\n</dd>"
[ -n "$reboot_status" ]  && echo "<dt>$(lang de:"Rebootursache" en:"Reboot cause")</dt><dd>$reboot_status</dd>"
echo "</dl>"
if [ -n "$run_clock" ]; then
	echo "<dl class='info'>"
	echo "<dt>$(lang de:"Betriebsstundenz&auml;hler" en:"Operating hours counter")</dt><dd>$run_clock</dd>"
	echo "</dl>"
fi

sec_end

donet_val="$(cgi_param net)"
if [ "$donet_val" != "0" ]; then
sec_begin "$(lang de:"Netzwerk" en:"Network")"

if [ "${donet_val%1}" == "$donet_val" ]; then
donet_arg='?net=1'
donet_msg="$(lang de:"Sektion anzeigen" en:"Show section")"
else
donet_msg="$(lang de:"Sektion ausblenden" en:"Hide section")"

host_name=$(hostname)
ext_name="$(sed 's/.*[ \t]//g' /var/tmp/ddnsstat.txt 2>/dev/null | sort -u)"
act_ip=$(hostname -i)
pubip="$(/usr/bin/get_ip)"
echo "<table width="100%"><tr><td><b>$(lang de:"Netze" en:"Networks"):</b></td>"
echo "<td><b><small>IP-$(lang de:"Adresse" en:"Address")</small></b></td>"
echo '<td><b><small>Hostname</small></b></td></tr>'
if [ -n "$pubip" ]; then
	echo "<tr><td><b><small>$(lang de:"&Ouml;ffentlich" en:"Public")</small></b></td>"
	echo "<td>$pubip</td>"
	[ -n "$ext_name" ] && ping_ip=$(ping -c 1 -W 1 "$ext_name" 2>/dev/null | sed -n 's/^PING .*(\(.*\)).*/\1/p')
	[ "$pubip" = "$ping_ip" ] && echo "<td>$ext_name</td>"
	echo '</tr>'
fi
echo "<tr><td><b><small>$(lang de:"Intern" en:"Internal")</small></b></td>"
echo "<td>$act_ip</td><td>$host_name</td></tr>"
echo "<tr><td><b><small>$(lang de:"Urloader" en:"Boot loader")</small></b></td>"
echo "<td>$ip_init_address</td></tr></table>"

echo "<table width="100%"><tr><td><b>$(lang de:"Schnittstellen" en:"Interfaces"):&nbsp;&nbsp;</b></td><td><b><small>$(lang de:"Protokoll" en:"Protocol")</small></b></td>"
echo "<td><b><small>$(lang de:"IP-Adresse" en:"IP address")</small></b></td><td><b><small>$(lang de:"Namen" en:"Names")</small></b></td></tr>"
getNetworkInfo | while read i p a n; do
	[ -z "$(echo "$a" | grep -E '169.|127.')" ] && echo "<tr><td>$i</td><td>$p</td><td>$a</td><td><small>$n</small></td></tr>"
done
echo '</table>'

echo "<dl class='info'>"
echo "<dt>MAC$(lang de:"-Adressen" en:" address")</dt><dd><dl>"
echo "<dt>DSL</dt><dd><small>$mac_dsl</small></dd>"
echo "<dt>LAN</dt><dd><small>$mac_lan</small></dd>"
[ -n "$mac_wlan3" ] && echo "<br>"
echo "<dt>WLAN</dt><dd><small>$mac_wlan</small></dd>"
[ -n "$mac_wlan2" ] && echo "<dt>WLAN2</dt><dd><small>$mac_wlan2</small></dd>"
[ -n "$mac_wlan3" ] && echo "<dt>WLAN3</dt><dd><small>$mac_wlan3</small></dd>"
echo "</dl></dd></dl>"

fi
[ "${donet_val#0}" == "$donet_val" ] && echo "<form class='btn' method='post'><input type='reset' value='$donet_msg' onclick='window.location=\"$(href status mod box_info)$donet_arg\" '></form>"

sec_end
fi

avsar_ver=/proc/avalanche/avsar_ver
if [ -r "$avsar_ver" ]; then
	sec_begin "$(lang de:"DSL-Treiber und -Hardware" en:"DSL drivers and hardware")"
		echo "<pre class='plain'>$(cat "$avsar_ver")</pre>"
	sec_end
fi

sec_begin "$(lang de:"Firmware" en:"Firmware")"

echo "<dl class='info'>"
echo "<dt>Firmware$(lang de:"" en:" ")version</dt><dd>${CONFIG_VERSION_MAJOR}.${CONFIG_VERSION}"
echo "<dt>AVM-Revision</dt><dd>$avm_revision</dd>"
echo "<dt>$(lang de:"Sprache" en:"Language")</dt><dd>$Language</dd>"
echo "</dl>"

echo "<dl class='info'>"
echo "<dt>$(lang de:"Erstellungsdatum" en:"Compilation date") (AVM)</dt><dd>$avm_date</dd>"
echo "</dl>"

sec_end

sec_begin "$(lang de:"Eigenschaften" en:"Properties")"
	echo -n '<div class="textwrapper"><textarea style="margin-top:6px;" name="content" rows="5" cols="10" wrap="off" readonly>'
	sed -e "s/^export //g" /var/env.mod.rcconf | html
	echo -n '</textarea></div>'
sec_end

