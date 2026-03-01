#!/bin/sh

. /usr/lib/libmodcgi.sh

VERSION="1.1"

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cat << EOF
<div style="float: right;"><font size="1">Version: $VERSION</font></div>
EOF
cgi_print_radiogroup_service_starttype "enabled" "$IPTABLES_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Einstellungen" en:"Settings")"
cat << EOF
<h2>ip_conntrack</h2>
<p>hashsize: <input type="text" name="ip_conntrack_hashsize" size="10" maxlength="255" value="$(html "$IPTABLES_IP_CONNTRACK_HASHSIZE")"></p>
<p><font size="1">$(lang de:"Evtl. ist ein Neustart n&ouml;tig" en:"Reboot may be necessary")</font></p>
EOF
sec_end

sec_begin "$(lang de:"Aktuelle Werte" en:"Running values")"
if lsmod | grep -q "ip_conntrack "; then
	ipct_hashsize=$(cat /sys/module/ip_conntrack/parameters/hashsize)
	ipct_count=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_count)
	ipct_max=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_max)
	ipct_objsize=$(grep "ip_conntrack " /proc/slabinfo  | tr -s " " | cut -d " " -f 4)
cat << EOF
<h2>ip_conntrack</h2>
<p>hashsize: $ipct_hashsize</p>
connections: $ipct_count / $ipct_max</p>
<p>objsize: $ipct_objsize B
<p>$(lang de:"Speicherverbrauch" en:"memory usage"): $(($ipct_count*$ipct_objsize/1024)) / $(($ipct_max*$ipct_objsize/1024)) KiB
EOF
fi
sec_end
