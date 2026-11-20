#!/bin/sh


. /usr/lib/libmodcgi.sh

. /mod/etc/conf/ppp.cfg

if [ -n "$PPP_DIAGTTY" ]; then

eval "$(modcgi branding:pkg:cmd mod_cgi)"
if [ "$REQUEST_METHOD" == "POST" ] && [ -n "$MOD_CGI_CMD" ]; then
	sec_begin "$(lang de:"Hinweis" en:"Remark")"
	echo "<font size=-2 color=red><br>$(lang de:"Aktualisierung wurde angefordert. Dies kann bis zu einer Minute dauern." en:"Refresh initiated. This may take up to one minute.")<br></font>"
	sec_end
	(sleep 1; echo -en "AT+CPIN?\r"  >$PPP_DIAGTTY;)&
	(sleep 2; echo -en "AT+CSQ\r"    >$PPP_DIAGTTY;)&
	(sleep 3; echo -en "at+COPS?\r"  >$PPP_DIAGTTY;)&
	(sleep 4; echo -en "at+COPS=?\r" >$PPP_DIAGTTY;)&
fi

sec_begin "$(lang de:"Status" en:"State")"

local_ALL="<UL>"
RECVALL=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep "^+COPS: (" | tail -n1 | sed 's/.*: (//; s/)$//;s/ /_/g;s/),*(/ /g')
for RECVONE in $RECVALL; do
	if ! echo "$RECVONE" | grep -q ^0; then
		NAME=$(echo -n "$RECVONE" | cut -d "," -f2 | sed 's/\"//g;s/_/ /g')
		RECV=$(echo -n "$RECVONE" | cut -d "," -f5 | sed 's/2$/3G/;s/0$/2G/')
		local_ALL="${local_ALL}<LI>${RECV}: ${NAME}"
	fi
done
local_ALL="${local_ALL}</UL>"

local_PIN=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep -m1 "^+CPIN: "      | sed 's/^+CPIN: //')
local_NET=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep -m1 "^+COPS: [0-9]" | sed 's/.*,"//;s/",/ (/;s/(2/(3G)/;s/(0/(2G)/')
local_SIG=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep -m1 "^+CSQ:"        | sed 's/,.*//;s/.* //')
local_MOD=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep -m1 "^\^MODE:"      | sed 's/.*MODE://; s/5,4/UMTS/;s/5,5/HSDPA/;s/0,0/NONE/;s/3,3/EDGE/;s/3,2/GPRS/')
local_FLW=$(cat /tmp/ppp_logger.tmp 2>/dev/null | grep -m1 "^^DSFLOWRPT:"  | sed 's/.*DSFLOWRPT://;')

let dH=0x0$(echo $local_FLW | cut -d "," -f 1)/3600
let dM=0x0$(echo $local_FLW | cut -d "," -f 1)-3600*dH
let dM=dM/60
[ $dM -le 9 ] && dM=0$dM
conntime=$dH:$dM

let xH=0x0$(echo $local_FLW | cut -d "," -f 4)/1048576
let xL=0x0$(echo $local_FLW | cut -d "," -f 4)-1048576*xH
let xL=xL/1024
[ $xL -le 99 ] && xL=0$xL
[ $xL -le 9 ]  && xL=0$xL
[ $xL -le 0 ]  && xL=000
TXsumMB=$xH,$xL

let TXcurMB=0x0$(echo $local_FLW | cut -d "," -f 2)/128
let TXcurKB=TXcurMB/8
let xH=TXcurMB/1024
let xL=TXcurMB-1024*xH
let xL=xL*1000/1024
[ $xL -le 99 ] && xL=0$xL
[ $xL -le 9 ]  && xL=0$xL
[ $xL -le 0 ]  && xL=000
TXcurMB=$xH,$xL

let xH=0x0$(echo $local_FLW | cut -d "," -f 5)/1048576
let xL=0x0$(echo $local_FLW | cut -d "," -f 5)-1048576*xH
let xL=xL/1024
[ $xL -le 99 ] && xL=0$xL
[ $xL -le 9 ]  && xL=0$xL
[ $xL -le 0 ]  && xL=000
RXsumMB=$xH,$xL

let RXcurMB=0x0$(echo $local_FLW | cut -d "," -f 3)/128
let RXcurKB=RXcurMB/8
let xH=RXcurMB/1024
let xL=RXcurMB-1024*xH
let xL=xL*1000/1024
[ $xL -le 99 ] && xL=0$xL
[ $xL -le 9 ]  && xL=0$xL
[ $xL -le 0 ]  && xL=000
RXcurMB=$xH,$xL

cat << EOF
<table>
<colgroup>
<col width="9999">
<col width="9999">
</colgroup>
<tbody>
<tr>
<td>

<table>
<tbody>
<tr><td>$(lang de:"Verbindungsdauer" en:"Connect time"):</td><td>${conntime} h</td></tr>
<tr><td><font size=-5>&nbsp;</font></td></tr>
<tr><td>Upstream:</td><td>${TXcurMB} MBit/s (${TXcurKB} KB/s)</td></tr>
<tr><td>Downstream:</td><td>${RXcurMB} MBit/s (${RXcurKB} KB/s)</td></tr>
<tr><td>$(lang de:"Hochgeladen" en:"Uploaded"):</td><td>${TXsumMB} MB</td></tr>
<tr><td>$(lang de:"Heruntergeladen" en:"Downloaded"):</td><td>${RXsumMB} MB</td></tr>
<tr><td><font size=-5>&nbsp;</font></td></tr>
<tr><td>$(lang de:"PIN-Status" en:"PIN-state"):</td><td>$local_PIN</td></tr>
<tr><td>$(lang de:"Eingebucht" en:"Connected"):</td><td>$local_NET</td></tr>
<tr><td>$(lang de:"Netzwerkart" en:"Network-mode"):</td><td>$local_MOD</td></tr>
<tr><td>$(lang de:"Signalst&auml;rke" en:"Signal-strength"):</td><td>$local_SIG</td></tr>
</tbody>
</table>

</td>

<td>
<form class="btn" action="$(href status ppp ppplog)" method="post" style="display:inline;">
$(csrf_input)
<input type="hidden" name="cmd" value="refresh">
<input type="submit" value="$(lang de:"aktualisieren" en:"refresh")">
</form>
<br><br>
EOF

[ "$local_ALL" != "<UL></UL> " ] && echo "$(lang de:"Verf&uuml;gbare Netze" en:"Detected networks"):<br>$local_ALL"

cat << EOF
</td>

</tr>
</tbody></table>
EOF
sec_end
echo '<br>'
fi

echo "<h1>$(lang de:"Logdatei" en:"Logfile"): $PPP_LOGFILE</h1>"
echo -n '<pre class="log">'
[ -e $PPP_LOGFILE ] && html < "$PPP_LOGFILE"
echo -n '</pre>'

if [ -e $PPP_FABALOG ]; then
	echo "<h1>$(lang de:"Fallback" en:"Fallback"): $PPP_FABALOG</h1>"
	echo -n '<pre class="log">'
	[ -e $PPP_FABALOG ] && html < "$PPP_FABALOG"
	echo -n '</pre>'
fi
