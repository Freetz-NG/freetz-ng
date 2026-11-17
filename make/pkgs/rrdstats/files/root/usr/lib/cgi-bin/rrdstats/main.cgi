#!/bin/sh

# initially by ramik, extended by cuma


. /mod/etc/conf/rrdstats.cfg
[ -r /etc/options.cfg ] && . /etc/options.cfg

RRDTOOL="rrdtool-freetz"

DATESTRING=$(date -R)
[ -n "$_cgi_width" ] && let WIDTH=_cgi_width-145 || let WIDTH=500
GROUP_PERIOD="$(cgi_param group | tr -d .)"
ALL_GRAPHS="$(cgi_param graph | tr -d .)"
while [ $# -gt 0 ]; do
	case "$1" in
		-graph=*)
			ALL_GRAPHS="$ALL_GRAPHS ${1#*=}"
			;;
		-group=*)
			GROUP_PERIOD="${1#*=}"
			;;
		-width=*)
			WIDTH="${1#*=}"
			;;
		-period=*)
			PERIOD_ARG="$PERIOD_ARG ${1#*=}"
			;;
		-not-lazy)
			NOTLAZY="1"
			;;
	esac
	shift
done
[ -z "$ALL_GRAPHS" ] && ALL_GRAPHS="mainpage"

if [ "$FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON" == "y" ]; then
	NBSP="$(echo -e  '\240')"
	GRAD="$(echo -en '\260')"
	IMAGETYPE='png'
	GRAPHARGS=''
	HTMLWIDTH=''
else
	NBSP="$(echo -e  '\xC2\xA0')"
	GRAD="$(echo -en '\xC2\xB0')"
	IMAGETYPE='svg'
	GRAPHARGS='--imgformat SVG'
	HTMLWIDTH="width=\"$(( $WIDTH + 100 ))\""
fi
let HEIGHT=$WIDTH*$RRDSTATS_DIMENSIONY/$RRDSTATS_DIMENSIONX
PERIODE="24h"
RED=#EA644A
DARKRED=#FF0000
YELLOW=#ECD748
GREEN=#54EC48
BLUE=#48C4EC
LRED=#FF7F7F
LYELLOW=#DCDC00
LGREEN=#7FFF7F
LBLUE=#7F7FFF
PURPLE=#A349A4
LPURPLE=#4A6997
RED_D=#CC3118
ORANGE_D=#CC7016
BLACK=#000000
GREY=#7F7F7F
MAXIM=#ADF235
AUNI="$(printf '\xC3\xA4')"
AUML="$(echo -e '\344')"
GRD="$(echo -en '\260')"
NOCACHE="?nocache=$(date -Iseconds | sed 's/T/_/g;s/+.*$//g;s/:/-/g')"
_NICE=$(which nice)
[ "$RRDSTATS_DARKMODE" != "yes" ] \
  && DEFAULT_COLORS="-c SHADEA#cccccc -c SHADEB#7f7f7f  -c BACK#ffffff -c CANVAS#eeeeee80" \
  || DEFAULT_COLORS="-c SHADEA#181818 -c SHADEB#555555  -c BACK#333333 -c CANVAS#222222  -c FONT#DDDDDD  -c GRID#AAAAAA77 -c MGRID#AAAAAA77  -c AXIS#00000000 -c ARROW#00000000  -c FRAME#111111"
if [ "$FREETZ_PACKAGE_RRDTOOL_VERSION_CURRENT" == "y" ]; then
[ "$RRDSTATS_SHOWFRAME" != "yes" ] && DEFAULT_COLORS="$DEFAULT_COLORS --border 0"
fi
[ "$RRDSTATS_TOBITAG" != "yes" ] && GRAPHARGS="$GRAPHARGS --disable-rrdtool-tag"

len15() {
	local x="$*"
	while [ "${#x}" -lt 15 ]; do x="$x "; done
	echo -n "${x// /$NBSP}"
}
mamc() {
	len15 "  ${1:+[$1]}"
	echo -n '\t\t   min        avg       max       cur\n'
}

generate_graph() {
	TITLE=""
	[ $# -ge 4 ] && TITLE=$4
	IMAGENAME=$3
	[ $# -ge 5 ] && IMAGENAME="$3$5"
	PERIODE=$2
	case $1 in
		cpu)
			FILE=$RRDSTATS_RRDDATA/cpu_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				[ "$RRDSTATS_CPU100PERC" = "yes" ] && CPU100PERC=" -u 100 -r "
				$_NICE $RRDTOOL graph $GRAPHARGS                           \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                    \
				--title "$TITLE"                                           \
				--start now-$PERIODE                                       \
				--width $WIDTH --height $HEIGHT                            \
				--vertical-label "CPU usage [percent]"                     \
				$DEFAULT_COLORS                                            \
				-l 0 $CPU100PERC $LAZY                                     \
				-W "Generated on: $DATESTRING"                             \
				                                                           \
				DEF:user=$FILE:user:AVERAGE                                \
				DEF:nice=$FILE:nice:AVERAGE                                \
				DEF:syst=$FILE:syst:AVERAGE                                \
				DEF:wait=$FILE:wait:AVERAGE                                \
				DEF:idle=$FILE:idle:AVERAGE                                \
				CDEF:cpu=user,nice,syst,wait,+,+,+                         \
				                                                           \
				AREA:wait$RED:"CPU wait\t"                                 \
				AREA:syst$GREEN:"CPU system\t":STACK                       \
				AREA:nice$YELLOW:"CPU nice\t":STACK                        \
				AREA:user$BLUE:"CPU user\n":STACK                          \
				                                                           \
				COMMENT:"$(mamc "percent")"                                \
				                                                           \
				LINE1:cpu$BLACK                                            \
				COMMENT:"CPU usage\t\t"                                    \
				GPRINT:cpu:MIN:"%2.1lf%s\t"                                \
				GPRINT:cpu:AVERAGE:"%2.1lf%s\t"                            \
				GPRINT:cpu:MAX:"%2.1lf%s\t"                                \
				GPRINT:cpu:LAST:"%2.1lf%s\n"                               > /dev/null
			fi
			;;
		mem)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				let RAM=$(grep MemTotal /proc/meminfo | tr -s [:blank:] " " | cut -d " " -f 2)*1024
				$_NICE $RRDTOOL graph $GRAPHARGS                                       \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                                \
				--title "$TITLE"                                                       \
				--start now-$PERIODE -u $RAM -r -l 0 $LAZY                             \
				--width $WIDTH --height $HEIGHT                                        \
				--vertical-label "Allocation [bytes]"                                  \
				$DEFAULT_COLORS                                                        \
				--base 1024 --units=si                                                 \
				-W "Generated on: $DATESTRING"                                         \
				                                                                       \
				COMMENT:"$(mamc "bytes")"                                              \
				                                                                       \
				DEF:used=$FILE:used:AVERAGE                                            \
				DEF:buff=$FILE:buff:AVERAGE                                            \
				DEF:cached=$FILE:cached:AVERAGE                                        \
				DEF:free=$FILE:free:AVERAGE                                            \
				                                                                       \
				AREA:used$RED:"Used memory\t\t"                                        \
				LINE1:used$RED_D                                                       \
				GPRINT:used:MIN:"%3.0lf%s\t"                                           \
				GPRINT:used:AVERAGE:"%3.0lf%s\t"                                       \
				GPRINT:used:MAX:"%3.0lf%s\t"                                           \
				GPRINT:used:LAST:"%3.0lf%s\n"                                          \
				                                                                       \
				AREA:buff$BLUE:"Buffer memory\t\t":STACK                               \
				GPRINT:buff:MIN:"%3.0lf%s\t"                                           \
				GPRINT:buff:AVERAGE:"%3.0lf%s\t"                                       \
				GPRINT:buff:MAX:"%3.0lf%s\t"                                           \
				GPRINT:buff:LAST:"%3.0lf%s\n"                                          \
				                                                                       \
				AREA:cached$YELLOW:"Cache memory\t\t":STACK                            \
				GPRINT:cached:MIN:"%3.0lf%s\t"                                         \
				GPRINT:cached:AVERAGE:"%3.0lf%s\t"                                     \
				GPRINT:cached:MAX:"%3.0lf%s\t"                                         \
				GPRINT:cached:LAST:"%3.0lf%s\n"                                        \
				                                                                       \
				AREA:free$GREEN:"Free memory\t\t":STACK                                \
				GPRINT:free:MIN:"%3.0lf%s\t"                                           \
				GPRINT:free:AVERAGE:"%3.0lf%s\t"                                       \
				GPRINT:free:MAX:"%3.0lf%s\t"                                           \
				GPRINT:free:LAST:"%3.0lf%s\n"                                          > /dev/null
			fi
			;;
		upt)
			FILE=$RRDSTATS_RRDDATA/upt_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                           \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                    \
				--title "$TITLE"                                           \
				--start -1-$PERIODE -l 0 -r                                \
				--width $WIDTH --height $HEIGHT $LAZY                      \
				--vertical-label "Uptime [hours]" -X 1                     \
				$DEFAULT_COLORS                                            \
				-W "Generated on: $DATESTRING"                             \
				                                                           \
				COMMENT:"$(mamc "hours")"                                  \
				                                                           \
				DEF:uptime=$FILE:uptime:MAX                                \
				                                                           \
				AREA:uptime$YELLOW:"Uptime\t\t"                            \
				GPRINT:uptime:MIN:"%3.2lf\t"                               \
				GPRINT:uptime:AVERAGE:"%3.2lf\t"                           \
				GPRINT:uptime:MAX:"%3.2lf\t"                               \
				GPRINT:uptime:LAST:"%3.2lf\n"                              > /dev/null
			fi
			;;
		pow)
			FILE=$RRDSTATS_RRDDATA/pow_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				for sourceitem in $RRDSTATS_POWER_CFG; do
					case $sourceitem in
						sum)		DCOL=$DARKRED  ; DNAME="Gesamtsystem"    ;;
						system)		DCOL=$LBLUE    ; DNAME="Hauptprozessor"  ;;
						wlan)		DCOL=$PURPLE   ; DNAME="Funknetzwerk"    ;;
						dsp)		DCOL=$BLUE     ; DNAME="Signalprozessor" ;;
						ab)		DCOL=$YELLOW   ; DNAME="Analogtelefonie" ;;
						usbhost)	DCOL=$GREEN    ; DNAME="USB-System"      ;;
						eth)		DCOL=$ORANGE_D ; DNAME="Kabelnetzwerk"   ;;
						dect)		DCOL=$LBLUE    ; DNAME="Funktelefonie"   ;;
						battcharge)	DCOL=$BLACK    ; DNAME="Akkuladung"      ;;
						lte)		DCOL=$BLACK    ; DNAME="LTE-Funkmodul"   ;;
						*)		DCOL=$BLACK    ; DNAME="$sourceitem"     ;;
					esac
					local DSDEFS="$DSDEFS DEF:$sourceitem=$FILE:$sourceitem:MAX"
					local LINE3S="$LINE3S LINE3:$sourceitem$DCOL:$(len15 $DNAME)\t \
					GPRINT:$sourceitem:MIN:%3.0lf%s\t \
					GPRINT:$sourceitem:AVERAGE:%3.0lf%s\t \
					GPRINT:$sourceitem:MAX:%3.0lf%s\t \
					GPRINT:$sourceitem:LAST:%3.0lf%s\n \
					"
				done
				$_NICE $RRDTOOL graph $GRAPHARGS                          \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                   \
				--title "$TITLE"                                          \
				--start -1-$PERIODE -l 0 -u 100 -r                        \
				--width $WIDTH --height $HEIGHT $LAZY                     \
				--vertical-label "Energieverbrauch [Prozent]" -X 1        \
				$DEFAULT_COLORS                                           \
				-W "Generated on: $DATESTRING"                            \
				COMMENT:"$(mamc "Prozent")"                               \
				$DSDEFS                                                   \
				$LINE3S                                                   \
				                                                          > /dev/null
			fi
			;;
		temp)
			FILE=$RRDSTATS_RRDDATA/temp_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                                    \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                             \
				--title "$TITLE"                                                    \
				--start -1-$PERIODE -l 0 -r                                         \
				--width $WIDTH --height $HEIGHT $LAZY                               \
				--vertical-label "Temperature [${GRAD}C]" -X 1                      \
				$DEFAULT_COLORS                                                     \
				-W "Generated on: $DATESTRING"                                      \
				                                                                    \
				COMMENT:"$(mamc "${GRAD}C")"                                        \
				                                                                    \
				DEF:temperature=$FILE:temperature:MAX                               \
				                                                                    \
				AREA:temperature$RED:"Temperature\t\t"                              \
				GPRINT:temperature:MIN:"%3.0lf\t"                                   \
				GPRINT:temperature:AVERAGE:"%3.0lf\t"                               \
				GPRINT:temperature:MAX:"%3.0lf\t"                                   \
				GPRINT:temperature:LAST:"%3.0lf\n"                                  > /dev/null
			fi
			;;
		epc0|dvb)
			if [ "$1" == "dvb" ]; then
				FILE=$RRDSTATS_RRDDATA/dvb_$RRDSTATS_INTERVAL.rrd
				TXCT=$RRDSTATS_FRITZDVB_TX
				RXCT=$RRDSTATS_FRITZDVB_RX
				MENR="MSE"
			else
				FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
				TXCT=$RRDSTATS_CISCOEPC_TX
				RXCT=$RRDSTATS_CISCOEPC_RX
				MENR="SNR"
			fi
			if [ -e $FILE ]; then
				local DS_DEF=''

				count=0
				local GPRINT_TXDB=''
				local GPRINT_TXFQ=''
				while [ $count -lt $TXCT ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:txdb$count=$FILE:txdb$count:LAST "
#					DS_DEF="$DS_DEF \
#						DEF:txfq$count=$FILE:txfq$count:LAST \
#						DEF:txdb$count=$FILE:txdb$count:LAST "
					COLOR_DB=$GREEN && COLOR_FQ=$RED
					GPRINT_TXDB="$GPRINT_TXDB \
						LINE2:txdb$count$COLOR_DB:Upstream${NBSP}SIG\t[dBmV]\:\t \
						GPRINT:txdb$count:MIN:%4.1lf\t \
						GPRINT:txdb$count:AVERAGE:%4.1lf\t \
						GPRINT:txdb$count:MAX:%4.1lf\t \
						GPRINT:txdb$count:LAST:%4.1lf\n "
#					GPRINT_TXFQ="$GPRINT_TXFQ \
#						LINE2:txfq$count$COLOR_FQ:Upstream${NBSP}Frequency${NBSP}#${count}\t[MHz]\t \
#						GPRINT:txfq$count:MIN:%4.1lf\t \
#						GPRINT:txfq$count:AVERAGE:%4.1lf\t \
#						GPRINT:txfq$count:MAX:%4.1lf\t \
#						GPRINT:txfq$count:LAST:%4.1lf\n "
				done

				count=0
				local GPRINT_RXSN=''
				local GPRINT_RXDB=''
				while [ $count -lt $RXCT ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:rxsn$count=$FILE:rxsn$count:LAST \
						DEF:rxdb$count=$FILE:rxdb$count:LAST "
					COLOR_SN=$YELLOW && COLOR_DB=$BLUE
					GPRINT_RXSN="$GPRINT_RXSN \
						LINE2:rxsn$count$COLOR_SN:Downstream${NBSP}${MENR}${NBSP}#${count}\t[dB]\:\t\t \
						GPRINT:rxsn$count:MIN:%4.1lf\t \
						GPRINT:rxsn$count:AVERAGE:%4.1lf\t \
						GPRINT:rxsn$count:MAX:%4.1lf\t \
						GPRINT:rxsn$count:LAST:%4.1lf\n "
					GPRINT_RXDB="$GPRINT_RXDB \
						LINE2:rxdb$count$COLOR_DB:Downstream${NBSP}SIG${NBSP}#${count}\t[[BmV]\:\t\t \
						GPRINT:rxdb$count:MIN:%4.1lf\t \
						GPRINT:rxdb$count:AVERAGE:%4.1lf\t \
						GPRINT:rxdb$count:MAX:%4.1lf\t \
						GPRINT:rxdb$count:LAST:%4.1lf\n "
				done

				$_NICE $RRDTOOL graph $GRAPHARGS                                                               \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                                                        \
				--title "$TITLE"                                                                               \
				--start now-$PERIODE                                                                           \
				--width $WIDTH --height $HEIGHT                                                                \
				--vertical-label "values"                                                                      \
				$DEFAULT_COLORS                                                                                \
				$LAZY                                                                                          \
				-W "Generated on: $DATESTRING"                                                                 \
				                                                                                               \
				COMMENT:"$(mamc "values")"                                                                     \
				$DS_DEF                                                                                        \
				$GPRINT_RXSN                                                                                   \
				LINE:4$GREY:"Downstream SIG Optimum 256-QAM\: 4 dBmV\t\t  --------------------------------\n"  \
				$GPRINT_RXDB                                                                                   \
				LINE:-2$GREY:"Downstream SIG Optimum 64-QAM\: -2 dBmV\t\t  --------------------------------\n" \
				$GPRINT_TXDB                                                                                   \
				LINE:44$GREY:"Upstream SIG Optimum 16-QAM\: 44 dBmV\t\t\t  --------------------------------\n" \
				$GPRINT_TXFQ                                                                                   \
				                                                                                               > /dev/null
			fi
			;;
		epcA)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxsn$count=$FILE:rxsn$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$GREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$RED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$BLUE
					GPRINT="$GPRINT \
						LINE3:rxsn$count$COLOR_VAR:Downstream${NBSP}SNR${NBSP}#${count}\t[dB]\t \
						GPRINT:rxsn$count:MIN:%4.1lf\t \
						GPRINT:rxsn$count:AVERAGE:%4.1lf\t \
						GPRINT:rxsn$count:MAX:%4.1lf\t \
						GPRINT:rxsn$count:LAST:%4.1lf\n "
				done
				$_NICE $RRDTOOL graph $GRAPHARGS                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                  \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "values"                                \
				-Y                                                       \
				$DEFAULT_COLORS                                          \
				$LAZY                                                    \
				-A                                                       \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				COMMENT:"$(mamc "values")"                               \
				$DS_DEF                                                  \
				$GPRINT                                                  \
				                                                         > /dev/null
			fi
			;;
		epcB)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxdb$count=$FILE:rxdb$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$LGREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$LYELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$LRED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$LBLUE
					GPRINT="$GPRINT \
						LINE3:rxdb$count$COLOR_VAR:Downstream${NBSP}SIG${NBSP}#${count}\t[dBmV]\t \
						GPRINT:rxdb$count:MIN:%4.1lf\t \
						GPRINT:rxdb$count:AVERAGE:%4.1lf\t \
						GPRINT:rxdb$count:MAX:%4.1lf\t \
						GPRINT:rxdb$count:LAST:%4.1lf\n "
				done
				$_NICE $RRDTOOL graph $GRAPHARGS                                                             \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                                                      \
				--title "$TITLE"                                                                             \
				--start now-$PERIODE                                                                         \
				--width $WIDTH --height $HEIGHT                                                              \
				--vertical-label "values"                                                                    \
				$DEFAULT_COLORS                                                                              \
				$LAZY                                                                                        \
				-W "Generated on: $DATESTRING"                                                               \
				                                                                                             \
				COMMENT:"$(mamc "values")"                                                                   \
				$DS_DEF                                                                                      \
				LINE:4$GREY:"Downstream SIG Optimum 256-QAM\: 4 dBmV\t   -------------------------------\n"  \
				$GPRINT                                                                                      \
				LINE:-2$GREY:"Downstream SIG Optimum 64-QAM\: -2 dBmV\t   -------------------------------\n" \
				                                                                                             > /dev/null
			fi
			;;
		epcC)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT_FQ=''
				local GPRINT_DB=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_TX ]; do
					let count++
					DS_DEF="$DS_DEF \
						DEF:txfq$count=$FILE:txfq$count:LAST \
						DEF:txdb$count=$FILE:txdb$count:LAST"
					COLOR_MOD=$((count%2))
					[ $COLOR_MOD == 1 ] && COLOR_DB=$BLUE    && COLOR_FQ=$RED
					[ $COLOR_MOD == 2 ] && COLOR_DB=$GREEN   && COLOR_FQ=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_DB=$LGREEN  && COLOR_FQ=$LYELLOW
					[ $COLOR_MOD == 0 ] && COLOR_DB=$LBLUE   && COLOR_FQ=$LRED
					GPRINT_DB="$GPRINT_DB \
						LINE3:txdb$count$COLOR_DB:Upstream${NBSP}SIG${NBSP}#${count}\t[dBmV]\t\t \
						GPRINT:txdb$count:MIN:%4.1lf\t \
						GPRINT:txdb$count:AVERAGE:%4.1lf\t \
						GPRINT:txdb$count:MAX:%4.1lf\t \
						GPRINT:txdb$count:LAST:%4.1lf\n "
					GPRINT_FQ="$GPRINT_FQ \
						LINE3:txfq$count$COLOR_FQ:Upstream${NBSP}Frequency${NBSP}#${count}\t[MHz]\t \
						GPRINT:txfq$count:MIN:%4.1lf\t \
						GPRINT:txfq$count:AVERAGE:%4.1lf\t \
						GPRINT:txfq$count:MAX:%4.1lf\t \
						GPRINT:txfq$count:LAST:%4.1lf\n "
				done

				$_NICE $RRDTOOL graph $GRAPHARGS                                                               \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                                                        \
				--title "$TITLE"                                                                               \
				--start now-$PERIODE                                                                           \
				--width $WIDTH --height $HEIGHT                                                                \
				--vertical-label "values"                                                                      \
				$DEFAULT_COLORS                                                                                \
				$LAZY                                                                                          \
				-Y                                                                                             \
				-W "Generated on: $DATESTRING"                                                                 \
				                                                                                               \
				COMMENT:"$(mamc "values")"                                                                     \
				$DS_DEF                                                                                        \
				$GPRINT_FQ                                                                                     \
				$GPRINT_DB                                                                                     \
				LINE:44$GREY:"Upstream SIG Optimum 16-QAM\: 44 dBmV\t\t\t  --------------------------------\n" \
				                                                                                               > /dev/null
			fi
			;;
		epc1)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                  \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "hours"                                 \
				$DEFAULT_COLORS                                          \
				-l 0 $LAZY                                               \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				COMMENT:"$(mamc "hours")"                                \
				                                                         \
				DEF:up=$FILE:up:LAST                                     \
				                                                         \
				AREA:up$YELLOW:"Uptimet"                                 \
				GPRINT:up:MIN:"%3.2lf\t"                                 \
				GPRINT:up:AVERAGE:"%3.2lf\t"                             \
				GPRINT:up:MAX:"%3.2lf\t"                                 \
				GPRINT:up:LAST:"%3.2lf\n"                                > /dev/null
			fi
			;;
		epc2)
			FILE=$RRDSTATS_RRDDATA/epc_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				local DS_DEF=''
				local GPRINT=''
				count=0
				while [ $count -lt $RRDSTATS_CISCOEPC_RX ]; do
					let count++
					DS_DEF="$DS_DEF DEF:rxfq$count=$FILE:rxfq$count:LAST"
					COLOR_MOD=$((count%4))
					[ $COLOR_MOD == 1 ] && COLOR_VAR=$GREEN
					[ $COLOR_MOD == 2 ] && COLOR_VAR=$YELLOW
					[ $COLOR_MOD == 3 ] && COLOR_VAR=$RED
					[ $COLOR_MOD == 0 ] && COLOR_VAR=$BLUE
					GPRINT="$GPRINT \
						LINE3:rxfq$count$COLOR_VAR:Downstream${NBSP}Frequency${NBSP}#${count}\t\
						GPRINT:rxfq$count:MIN:%3.0lf\t \
						GPRINT:rxfq$count:AVERAGE:%3.0lf\t \
						GPRINT:rxfq$count:MAX:%3.0lf\t \
						GPRINT:rxfq$count:LAST:%3.0lf\n "
				done
				$_NICE $RRDTOOL graph $GRAPHARGS                                       \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                                \
				--title "$TITLE"                                                       \
				--start now-$PERIODE                                                   \
				--width $WIDTH --height $HEIGHT                                        \
				--vertical-label "MHz"                                                 \
				$DEFAULT_COLORS                                                        \
				$LAZY                                                                  \
				-W "Generated on: $DATESTRING"                                         \
				                                                                       \
				COMMENT:"$(mamc "MHz")"                                                \
				$DS_DEF                                                                \
				$GPRINT                                                                \
				                                                                       > /dev/null
			fi
			;;
		thg0)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                          \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                   \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "values"                                 \
				$DEFAULT_COLORS                                           \
				$LAZY                                                     \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				DEF:rx=$FILE:rx:LAST                                      \
				DEF:sn=$FILE:sn:LAST                                      \
				DEF:tx=$FILE:tx:LAST                                      \
				DEF:ip=$FILE:ip:LAST                                      \
				                                                          \
				COMMENT:"$(mamc "values")"                                \
				                                                          \
				LINE3:tx$GREEN:"Upstream\t[dBmV]\t"                       \
				GPRINT:tx:MIN:"%5.1lf%s\t"                                \
				GPRINT:tx:AVERAGE:"%5.1lf%s\t"                            \
				GPRINT:tx:MAX:"%5.1lf%s\t"                                \
				GPRINT:tx:LAST:"%5.1lf%s\n"                               \
				                                                          \
				LINE3:sn$YELLOW:"S-N Ratio\t[dB]\t"                       \
				GPRINT:sn:MIN:"%3.0lf%s\t"                                \
				GPRINT:sn:AVERAGE:"%3.0lf%s\t"                            \
				GPRINT:sn:MAX:"%3.0lf%s\t"                                \
				GPRINT:sn:LAST:"%3.0lf%s\n"                               \
				                                                          \
				LINE3:rx$RED:"Downstream\t[dBmV]\t"                       \
				GPRINT:rx:MIN:"%5.1lf%s\t"                                \
				GPRINT:rx:AVERAGE:"%5.1lf%s\t"                            \
				GPRINT:rx:MAX:"%5.1lf%s\t"                                \
				GPRINT:rx:LAST:"%5.1lf%s\n"                               \
				                                                          \
				LINE3:ip$BLUE:"Computers\t[count]\t"                      \
				GPRINT:ip:MIN:"%3.0lf%s\t"                                \
				GPRINT:ip:AVERAGE:"%3.0lf%s\t"                            \
				GPRINT:ip:MAX:"%3.0lf%s\t"                                \
				GPRINT:ip:LAST:"%3.0lf%s\n"                               > /dev/null
			fi
			;;
		thg1)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                  \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "hours"                                 \
				$DEFAULT_COLORS                                          \
				-l 0 $LAZY                                               \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				COMMENT:"$(mamc "hours")"                                \
				                                                         \
				DEF:up=$FILE:up:LAST                                     \
				                                                         \
				AREA:up$YELLOW:"System Uptime\t\t"                       \
				GPRINT:up:MIN:"%3.2lf\t"                                 \
				GPRINT:up:AVERAGE:"%3.2lf\t"                             \
				GPRINT:up:MAX:"%3.2lf\t"                                 \
				GPRINT:up:LAST:"%3.2lf\n"                                > /dev/null
			fi
			;;
		thg2)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                                  \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                           \
				--title "$TITLE"                                                  \
				--start now-$PERIODE                                              \
				--width $WIDTH --height $HEIGHT                                   \
				--vertical-label "MHz"                                            \
				$DEFAULT_COLORS                                                   \
				$LAZY                                                             \
				-W "Generated on: $DATESTRING"                                    \
				                                                                  \
				COMMENT:"$(mamc "MHz")"                                           \
				                                                                  \
				DEF:if=$FILE:if:LAST                                              \
				                                                                  \
				LINE3:if$GREEN:"Downstream Frequency\t"                           \
				GPRINT:if:MIN:"%3.0lf\t"                                          \
				GPRINT:if:AVERAGE:"%3.0lf\t"                                      \
				GPRINT:if:MAX:"%3.0lf\t"                                          \
				GPRINT:if:LAST:"%3.0lf\n"                               > /dev/null
			fi
			;;
		thg3)
			FILE=$RRDSTATS_RRDDATA/thg_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                            \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                     \
				--title "$TITLE"                                            \
				--start now-$PERIODE                                        \
				--width $WIDTH --height $HEIGHT                             \
				--vertical-label "ID"                                       \
				$DEFAULT_COLORS                                             \
				-l 0 -u 5 $LAZY                                             \
				-W "Generated on: $DATESTRING"                              \
				                                                            \
				COMMENT:"$(mamc "ID")"                                      \
				                                                            \
				DEF:uc=$FILE:uc:LAST                                        \
				                                                            \
				LINE3:uc$BLUE:"Upstream Channel\t"                          \
				GPRINT:uc:MIN:"%3.0lf\t"                                    \
				GPRINT:uc:AVERAGE:"%3.0lf\t"                                \
				GPRINT:uc:MAX:"%3.0lf\t"                                    \
				GPRINT:uc:LAST:"%3.0lf\n"                                   > /dev/null
			fi
			;;
		arris0)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                          \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                   \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "values"                                 \
				$DEFAULT_COLORS                                           \
				$LAZY                                                     \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				COMMENT:"$(mamc "values")"                                \
				                                                          \
				DEF:rx=$FILE:rx:LAST                                      \
				DEF:sn=$FILE:sn:LAST                                      \
				DEF:tx=$FILE:tx:LAST                                      \
				DEF:ip=$FILE:ip:LAST                                      \
				                                                          \
				LINE3:tx$GREEN:"Upstream\t[dBmV]\t"                       \
				GPRINT:tx:MIN:"%3.0lf\t"                                  \
				GPRINT:tx:AVERAGE:"%3.0lf\t"                              \
				GPRINT:tx:MAX:"%3.0lf\t"                                  \
				GPRINT:tx:LAST:"%3.0lf\n"                                 \
				                                                          \
				LINE3:sn$YELLOW:"S-N Ratio\t[dB]\t"                       \
				GPRINT:sn:MIN:"%3.0lf\t"                                  \
				GPRINT:sn:AVERAGE:"%3.0lf\t"                              \
				GPRINT:sn:MAX:"%3.0lf\t"                                  \
				GPRINT:sn:LAST:"%3.0lf\n"                                 \
				                                                          \
				LINE3:rx$RED:"Downstream\t[dBmV]\t"                       \
				GPRINT:rx:MIN:"%3.0lf\t"                                  \
				GPRINT:rx:AVERAGE:"%3.0lf\t"                              \
				GPRINT:rx:MAX:"%3.0lf\t"                                  \
				GPRINT:rx:LAST:"%3.0lf\n"                                 \
				                                                          \
				LINE3:ip$BLUE:"Computers\t[count]\t"                      \
				GPRINT:ip:MIN:"%3.0lf\t"                                  \
				GPRINT:ip:AVERAGE:"%3.0lf\t"                              \
				GPRINT:ip:MAX:"%3.0lf\t"                                  \
				GPRINT:ip:LAST:"%3.0lf\n"                                 > /dev/null
			fi
			;;
		arris1)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                  \
				--title "$TITLE"                                         \
				--start now-$PERIODE                                     \
				--width $WIDTH --height $HEIGHT                          \
				--vertical-label "hours"                                 \
				$DEFAULT_COLORS                                          \
				-l 0 $LAZY                                               \
				-W "Generated on: $DATESTRING"                           \
				                                                         \
				COMMENT:"$(mamc "hours")"                                \
				                                                         \
				DEF:up=$FILE:up:LAST                                     \
				                                                         \
				AREA:up$YELLOW:"Uptime\t\t"                              \
				GPRINT:up:MAX:"%3.2lf\t"                                 \
				GPRINT:up:AVERAGE:"%3.2lf\t"                             \
				GPRINT:up:MAX:"%3.2lf\t"                                 \
				GPRINT:up:LAST:"%3.2lf\n"                                > /dev/null
			fi
			;;
		arris2)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                        \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                 \
				--title "$TITLE"                                        \
				--start now-$PERIODE                                    \
				--width $WIDTH --height $HEIGHT                         \
				--vertical-label "MHz"                                  \
				$DEFAULT_COLORS                                         \
				$LAZY                                                   \
				-W "Generated on: $DATESTRING"                          \
				                                                        \
				COMMENT:"$(mamc "MHz")"                                 \
				                                                        \
				DEF:if=$FILE:if:LAST                                    \
				                                                        \
				LINE3:if$GREEN:"Downstream Freq\t\t"                    \
				GPRINT:if:MIN:"%5.1lf\t"                                \
				GPRINT:if:AVERAGE:"%5.1lf\t"                            \
				GPRINT:if:MAX:"%5.1lf\t"                                \
				GPRINT:if:LAST:"%5.1lf\n"                               > /dev/null
			fi
			;;
		arris3)
			FILE=$RRDSTATS_RRDDATA/arris_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                          \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                   \
				--title "$TITLE"                                          \
				--start now-$PERIODE                                      \
				--width $WIDTH --height $HEIGHT                           \
				--vertical-label "MHz"                                    \
				$DEFAULT_COLORS                                           \
				$LAZY                                                     \
				-W "Generated on: $DATESTRING"                            \
				                                                          \
				COMMENT:"$(mamc "MHz")"                                   \
				                                                          \
				DEF:uf=$FILE:uf:LAST                                      \
				                                                          \
				LINE3:uf$BLUE:"Upstream Freq\t\t"                         \
				GPRINT:uf:MIN:"%5.1lf\t"                                  \
				GPRINT:uf:AVERAGE:"%5.1lf\t"                              \
				GPRINT:uf:MAX:"%5.1lf\t"                                  \
				GPRINT:uf:LAST:"%5.1lf\n"                                 > /dev/null
			fi
			;;
		csl0) #all
			csl_graph 0 $RRDSTATS_CABLESEG_FRQ
			;;
		csl1) #lower
			local sum=0
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do let sum++; done
			local cnt=0
			local _VISIBLE_FRQ=''
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do
				let cnt++
				[ $cnt -le $(($sum/2)) ] && _VISIBLE_FRQ="$_VISIBLE_FRQ $_CURRENT_FRQ"
			done
			[ -n "$_VISIBLE_FRQ" ] && csl_graph 1 $_VISIBLE_FRQ
			;;
		csl2) #upper
			local sum=0
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do let sum++; done
			local cnt=0
			local _VISIBLE_FRQ=''
			for _CURRENT_FRQ in $RRDSTATS_CABLESEG_FRQ; do
				let cnt++
				[ $cnt -gt $(($sum/2)) ] && _VISIBLE_FRQ="$_VISIBLE_FRQ $_CURRENT_FRQ"
			done
			[ -n "$_VISIBLE_FRQ" ] && csl_graph 2 $_VISIBLE_FRQ
			;;
		swap)
			FILE=$RRDSTATS_RRDDATA/mem_$RRDSTATS_INTERVAL.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                                      \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                               \
				--title "$TITLE"                                                      \
				--start -1-$PERIODE -l 0 -u 100 -r                                    \
				--width $WIDTH --height $HEIGHT	$LAZY                                 \
				--vertical-label "Swap usage [percent]"                               \
				$DEFAULT_COLORS                                                       \
				-W "Generated on: $DATESTRING"                                        \
				                                                                      \
				COMMENT:"$(mamc "percent")"                                           \
				                                                                      \
				DEF:total=$FILE:swaptotal:AVERAGE                                     \
				DEF:free=$FILE:swapfree:AVERAGE                                       \
				CDEF:used=total,free,-                                                \
				CDEF:usedpct=100,used,total,/,*                                       \
				CDEF:freepct=100,free,total,/,*                                       \
				                                                                      \
				AREA:usedpct#0000FF:"Used swap\t\t"                                   \
				GPRINT:usedpct:MIN:"%5.1lf%s\t"                                       \
				GPRINT:usedpct:AVERAGE:"%5.1lf%s\t"                                   \
				GPRINT:usedpct:MAX:"%5.1lf%s\t"                                       \
				GPRINT:usedpct:LAST:"%5.1lf%s\n"                                      \
				                                                                      \
				AREA:freepct#00FF00:"Free swap\t\t":STACK                             \
				GPRINT:freepct:MIN:"%5.1lf%s\t"                                       \
				GPRINT:freepct:AVERAGE:"%5.1lf%s\t"                                   \
				GPRINT:freepct:MAX:"%5.1lf%s\t"                                       \
				GPRINT:freepct:LAST:"%5.1lf%s\n"                                      > /dev/null
			fi
			;;
		diskio1|diskio2|diskio3|diskio4)
			case $1 in
				diskio1)
					DISK=$RRDSTATS_DISK_DEV1
					LG=$RRDSTATS_DISK_LOGARITHM1
					MX=$RRDSTATS_MAX_DISK_GRAPH1
					;;
				diskio2)
					DISK=$RRDSTATS_DISK_DEV2
					LG=$RRDSTATS_DISK_LOGARITHM2
					MX=$RRDSTATS_MAX_DISK_GRAPH2
					;;
				diskio3)
					DISK=$RRDSTATS_DISK_DEV3
					LG=$RRDSTATS_DISK_LOGARITHM3
					MX=$RRDSTATS_MAX_DISK_GRAPH3
					;;
				diskio4)
					DISK=$RRDSTATS_DISK_DEV4
					LG=$RRDSTATS_DISK_LOGARITHM4
					MX=$RRDSTATS_MAX_DISK_GRAPH4
					;;
			esac

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$DISK.rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                               \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                        \
				--title "$TITLE"                                               \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW              \
				--width $WIDTH --height $HEIGHT                                \
				--vertical-label "Throughput [bytes/s]"                        \
				$DEFAULT_COLORS                                                \
				--units=si                                                     \
				-W "Generated on: $DATESTRING"                                 \
				                                                               \
				DEF:read=$FILE:read:AVERAGE                                    \
				DEF:write=$FILE:write:AVERAGE                                  \
				                                                               \
				COMMENT:"$(mamc "bytes/s")"                                    \
				                                                               \
				AREA:read$GREEN:"Read\t\t\t"                                   \
				GPRINT:read:MIN:"%3.0lf%s\t"                                   \
				GPRINT:read:AVERAGE:"%3.0lf%s\t"                               \
				GPRINT:read:MAX:"%3.0lf%s\t"                                   \
				GPRINT:read:LAST:"%3.0lf%s\n"                                  \
				                                                               \
				AREA:write#0000FF80:"Write\t\t\t"                              \
				GPRINT:write:MIN:"%3.0lf%s\t"                                  \
				GPRINT:write:AVERAGE:"%3.0lf%s\t"                              \
				GPRINT:write:MAX:"%3.0lf%s\t"                                  \
				GPRINT:write:LAST:"%3.0lf%s\n"                                 > /dev/null
			fi
			;;
		if1|if2|if3|if4)
			case $1 in
				if1)
					IF=$RRDSTATS_INTERFACE1
					XG=$RRDSTATS_XCHG_RXTX1
					LG=$RRDSTATS_LOGARITHM1
					MX=$RRDSTATS_MAX_GRAPH1
					;;
				if2)
					IF=$RRDSTATS_INTERFACE2
					XG=$RRDSTATS_XCHG_RXTX2
					LG=$RRDSTATS_LOGARITHM2
					MX=$RRDSTATS_MAX_GRAPH2
					;;
				if3)
					IF=$RRDSTATS_INTERFACE3
					XG=$RRDSTATS_XCHG_RXTX3
					LG=$RRDSTATS_LOGARITHM3
					MX=$RRDSTATS_MAX_GRAPH3
					;;
				if4)
					IF=$RRDSTATS_INTERFACE4
					XG=$RRDSTATS_XCHG_RXTX4
					LG=$RRDSTATS_LOGARITHM4
					MX=$RRDSTATS_MAX_GRAPH4
					;;
			esac

			if [ "$XG" = "yes" ]; then
				NET_RX="out"
				NET_TX="in"
			else
				NET_RX="in"
				NET_TX="out"
			fi

			if [ "$LG" = "yes" ]; then
				LOGARITHMIC=" -o "
			else
				LOGARITHMIC=" -l 0 "
			fi

			if [ -z "$MX" -o "$MX" -eq 0 ]; then
				MAXIMALBW=""
			else
				let MAXIMALBW=$MX*1000*1000/8
				MAXIMALBW=" -r -u $MAXIMALBW "
			fi

			FILE=$RRDSTATS_RRDDATA/$1_$RRDSTATS_INTERVAL-$(echo $IF | sed 's/\:/_/g').rrd
			if [ -e $FILE ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS                             \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                      \
				--title "$TITLE"                                             \
				--start -1-$PERIODE $LOGARITHMIC $LAZY $MAXIMALBW            \
				--width $WIDTH --height $HEIGHT                              \
				--vertical-label "bytes/s"                                   \
				$DEFAULT_COLORS                                              \
				--units=si                                                   \
				-W "Generated on: $DATESTRING"                               \
				                                                             \
				COMMENT:"$(mamc "bytes/s")"                                  \
				                                                             \
				DEF:in=$FILE:$NET_RX:AVERAGE                                 \
				DEF:out=$FILE:$NET_TX:AVERAGE                                \
				                                                             \
				AREA:in$GREEN:"Incoming\t\t"                                 \
				GPRINT:in:MIN:"%3.0lf%s\t"                                   \
				GPRINT:in:AVERAGE:"%3.0lf%s\t"                               \
				GPRINT:in:MAX:"%3.0lf%s\t"                                   \
				GPRINT:in:LAST:"%3.0lf%s\n"                                  \
				                                                             \
				AREA:out#0000FF80:"Outgoing\t\t"                             \
				GPRINT:out:MIN:"%3.0lf%s\t"                                  \
				GPRINT:out:AVERAGE:"%3.0lf%s\t"                              \
				GPRINT:out:MAX:"%3.0lf%s\t"                                  \
				GPRINT:out:LAST:"%3.0lf%s\n"                                 > /dev/null
			fi
			;;

		one)
			_SENSOR_GEN=""
			_SENSOR_CUR=0
			[ "$RRDSTATS_DIGITEMP_C" = yes ] && _SENSOR_UOM=Celsius || _SENSOR_UOM=Fahrenheit
			[ -n "$RRDSTATS_DIGITEMP_L" -o -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="-r "
			[ -n "$RRDSTATS_DIGITEMP_L" ] && _SENSOR_LOW="$_SENSOR_LOW -l $RRDSTATS_DIGITEMP_L"
			[ -n "$RRDSTATS_DIGITEMP_U" ] && _SENSOR_LOW="$_SENSOR_LOW -u $RRDSTATS_DIGITEMP_U"

			if [ $# -ge 5 ]; then
				_SENSOR_ALI=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.group | tr -s " " | cut -d" " -f1-2 | grep $5$ | cut -d " " -f1)
				_SENSOR_HEX=$(grep -vE "^#|^ |^$|^//" /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d" " -f 1,3 | grep -E "$(echo $_SENSOR_ALI | sed 's/ /\$|/g')$" | cut -d " " -f1)
			else
				_SENSOR_HEX=$(grep "^ROM " /tmp/flash/rrdstats/digitemp.conf 2>/dev/null | sed 's/^ROM .//g;s/ 0x//g')
			fi

			for _CURRENT_HEX in $_SENSOR_HEX; do
				FILE=$RRDSTATS_RRDDATA/one_${RRDSTATS_INTERVAL}-${_CURRENT_HEX}_${_SENSOR_UOM:0:1}.rrd
				if [ -e $FILE ]; then
					_ALIAS=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f3)
					[ -z "$_ALIAS" ] && _ALIAS=$_CURRENT_HEX
					_COLOR=$(grep ^$_CURRENT_HEX /tmp/flash/rrdstats/digitemp.alias | tr -s " " | cut -d " " -f2)
					[ -z "$_COLOR" ] && _COLOR="#999999"
					_SENSOR_GEN=" $_SENSOR_GEN \
					 DEF:temp$_SENSOR_CUR=$FILE:temp:AVERAGE \
					 LINE3:temp$_SENSOR_CUR$_COLOR:${_ALIAS// /$NBSP}\t\t \
					 GPRINT:temp$_SENSOR_CUR:MIN:%8.3lf\t \
					 GPRINT:temp$_SENSOR_CUR:AVERAGE:%8.3lf\t \
					 GPRINT:temp$_SENSOR_CUR:MAX:%8.3lf\t \
					 GPRINT:temp$_SENSOR_CUR:LAST:%8.3lf\n "
				fi
				let _SENSOR_CUR=_SENSOR_CUR+1
			done
			if [ -n "$_SENSOR_GEN" ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE  \
				--title "$TITLE"                         \
				--start now-$PERIODE                     \
				--width $WIDTH --height $HEIGHT          \
				--vertical-label "${GRAD}$_SENSOR_UOM"   \
				$DEFAULT_COLORS                          \
				--slope-mode HRULE:0#000000              \
				$LAZY $_SENSOR_LOW                       \
				-W "Generated on: $DATESTRING"           \
				COMMENT:"$(mamc "${GRAD}$_SENSOR_UOM")"  \
				$_SENSOR_GEN                             > /dev/null
			fi
			;;
		aha*)
			kind=${1#aha_}
			DECMAL=1
			case $kind in
				pdev|watt|sein|blnd)	DNAME="Leistung";           DESCR="Watt"; RANGE="-l 0" ;;
				volt)			DNAME="Spannung";           DESCR="Volt"; RANGE="-l 215 -u 245" ;;
				kilo)			DNAME="Energie";            DESCR="Wh"; DECMAL=3 ;;
				grad)			DNAME="Temperatur";         DESCR="${GRAD}C" ;;
				curr)			DNAME="Stromst${AUNI}rke";  DESCR="Ampere"; RANGE="-l 0 -u 1"; DECMAL=2 ;;
				fact)			DNAME="Leistungsfaktor";    DESCR="Wirkfaktor"; RANGE="-l 0 -u 1"; DECMAL=3 ;;
			esac

			_SENSOR_GEN=""
			_SENSOR_CUR=0


			pdev="$(cgi_param pdev | tr -d .)"
			[ "$pdev" == "x" ] && pdev=""
			IMAGENAME=$IMAGENAME$pdev
			if [ -n "$pdev" ]; then
				case $pdev in
					s) V1="blnd"; V2="watt" ; C1=$RED; C2=$BLUE ; D1="Blindleistung\t"; D2="Wirkleistung\t" ; D3="Scheinmaximum\t" ;;
					w) V1="watt"; V2="blnd" ; C1=$BLUE; C2=$RED ; D1="Wirkleistung\t"; D2="Blindleistung\t" ; D3="Wirkmaximum\t" ; RPN=",fact_max,*" ;;
				esac
				_CURRENT_HEX=$5
				FILE=$RRDSTATS_RRDDATA/aha_${RRDSTATS_INTERVAL}-${_CURRENT_HEX//:/}.rrd
				if [ -e $FILE ]; then
					_ALIAS=$(sed -rn "s/^$_CURRENT_HEX\|//p" /tmp/flash/rrdstats/smarthome.alias 2>/dev/null)
					[ -z "$_ALIAS" ] && _ALIAS=$_CURRENT_HEX
					_SENSOR_GEN=" $_SENSOR_GEN \
						DEF:volt=$FILE:volt:AVERAGE \
						DEF:curr=$FILE:curr:AVERAGE \
						DEF:fact=$FILE:fact:AVERAGE \
						DEF:volt_max=$FILE:volt:MAX \
						DEF:curr_max=$FILE:curr:MAX \
						DEF:fact_max=$FILE:fact:MAX \
						CDEF:sein_max=volt_max,curr_max,*$RPN \
						CDEF:sein=volt,curr,* \
						CDEF:watt=sein,fact,* \
						CDEF:blnd=sein,watt,- \
						AREA:$V1$C1:$D1\t \
						GPRINT:$V1:MIN:%5.${DECMAL}lf\t \
						GPRINT:$V1:AVERAGE:%5.${DECMAL}lf\t \
						GPRINT:$V1:MAX:%5.${DECMAL}lf\t \
						GPRINT:$V1:LAST:%5.${DECMAL}lf\n \
						AREA:$V2$C2:$D2\t:STACK \
						GPRINT:$V2:MIN:%5.${DECMAL}lf\t \
						GPRINT:$V2:AVERAGE:%5.${DECMAL}lf\t \
						GPRINT:$V2:MAX:%5.${DECMAL}lf\t \
						GPRINT:$V2:LAST:%5.${DECMAL}lf\n \
						COMMENT:$NBSP${NBSP}Scheinleistung\t \
						GPRINT:sein:MIN:%5.${DECMAL}lf\t \
						GPRINT:sein:AVERAGE:%5.${DECMAL}lf\t \
						GPRINT:sein:MAX:%5.${DECMAL}lf\t \
						GPRINT:sein:LAST:%5.${DECMAL}lf\n \
						LINE1:sein_max$MAXIM:$D3\t \
						GPRINT:sein_max:MIN:%5.${DECMAL}lf\t \
						GPRINT:sein_max:AVERAGE:%5.${DECMAL}lf\t \
						GPRINT:sein_max:MAX:%5.${DECMAL}lf\t \
						GPRINT:sein_max:LAST:%5.${DECMAL}lf\n "
				fi
			else
				_SENSOR_HEX=$(sed -rn 's/\|.*//p'  /tmp/flash/rrdstats/smarthome.alias 2>/dev/null)
				for _CURRENT_HEX in $_SENSOR_HEX; do
					local art="$(sed -n "s/^$_CURRENT_HEX|//p" /tmp/flash/rrdstats/smarthome.kinds)"
					if [ "$kind" == "grad" ]; then
						[ "$art" != "AKT" -a "$art" != "HKR" ] && continue
					else
						[ "$art" != "AKT" -a "$art" != "PLC" ] && continue
					fi
					FILE=$RRDSTATS_RRDDATA/aha_${RRDSTATS_INTERVAL}-${_CURRENT_HEX//:/}.rrd
					if [ -e $FILE ]; then
						_ALIAS=$(sed -rn "s/^$_CURRENT_HEX\|//p" /tmp/flash/rrdstats/smarthome.alias 2>/dev/null)
						[ -z "$_ALIAS" ] && _ALIAS=$_CURRENT_HEX
						_COLOR=$(sed -rn "s/\|$_ALIAS$//p" /tmp/flash/rrdstats/smarthome.color 2>/dev/null)
						[ -z "$_COLOR" ] && _COLOR="#999999"

						case "$kind" in
							watt)
								_SOURCE=" \
									DEF:volt$kind$_SENSOR_CUR=$FILE:volt:AVERAGE \
									DEF:curr$kind$_SENSOR_CUR=$FILE:curr:AVERAGE \
									DEF:fact$kind$_SENSOR_CUR=$FILE:fact:AVERAGE \
									CDEF:$kind$_SENSOR_CUR=volt$kind$_SENSOR_CUR,curr$kind$_SENSOR_CUR,fact$kind$_SENSOR_CUR,*,* "
								;;
							sein)
								_SOURCE=" \
									DEF:volt$kind$_SENSOR_CUR=$FILE:volt:AVERAGE \
									DEF:curr$kind$_SENSOR_CUR=$FILE:curr:AVERAGE \
									CDEF:$kind$_SENSOR_CUR=volt$kind$_SENSOR_CUR,curr$kind$_SENSOR_CUR,* "
								;;
							blnd)
								_SOURCE=" \
									DEF:volt$kind$_SENSOR_CUR=$FILE:volt:AVERAGE \
									DEF:curr$kind$_SENSOR_CUR=$FILE:curr:AVERAGE \
									DEF:fact$kind$_SENSOR_CUR=$FILE:fact:AVERAGE \
									CDEF:$kind$_SENSOR_CUR=volt$kind$_SENSOR_CUR,curr$kind$_SENSOR_CUR,1,fact$kind$_SENSOR_CUR,-,*,* "
								;;
							*)
								_SOURCE="DEF:$kind$_SENSOR_CUR=$FILE:$kind:AVERAGE"
								;;
						esac

						_SENSOR_GEN=" $_SENSOR_GEN \
							$_SOURCE \
							LINE3:$kind$_SENSOR_CUR$_COLOR:$(len15 $_ALIAS)\t \
							GPRINT:$kind$_SENSOR_CUR:MIN:%5.${DECMAL}lf\t \
							GPRINT:$kind$_SENSOR_CUR:AVERAGE:%5.${DECMAL}lf\t \
							GPRINT:$kind$_SENSOR_CUR:MAX:%5.${DECMAL}lf\t \
							GPRINT:$kind$_SENSOR_CUR:LAST:%5.${DECMAL}lf\n "
					fi
					let _SENSOR_CUR=_SENSOR_CUR+1
				done
			fi
			if [ -n "$_SENSOR_GEN" ]; then
				$_NICE $RRDTOOL graph $GRAPHARGS         \
				$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE  \
				--title "$TITLE"                         \
				--start now-$PERIODE                     \
				--width $WIDTH --height $HEIGHT          \
				--vertical-label "$DNAME [$DESCR]"       \
				$DEFAULT_COLORS                          \
				--slope-mode HRULE:0#000000              \
				$LAZY  $RANGE                            \
				-W "Generated on: $DATESTRING"           \
				COMMENT:"$(mamc "$DESCR")"               \
				$_SENSOR_GEN                             > /dev/null
			fi
			;;
		*)
			echo "unknown graph"
			;;
	esac
	return 1
}

csl_graph() {
	local _CURRENT_PAGE=$1
	shift
	local _VISIBLE_FRQ="$*"
	local STACK=''
	local DS_DEF=''
	local GPRINT=''
	local FRQ_COUNT=$(echo $_VISIBLE_FRQ | wc -w)
	local RPN_O=''
	local RPN_MIN=''
	local RPN_AVG=''
	local RPN_MAX=''
	count=0

	for _CURRENT_FRQ in $_VISIBLE_FRQ; do
		FILE=$RRDSTATS_RRDDATA/csl_${RRDSTATS_INTERVAL}-${_CURRENT_FRQ}000000.rrd
		if [ -e $FILE ]; then
			let count++
			DS_DEF="$DS_DEF DEF:loadMIN$count=$FILE:load:MIN"
			DS_DEF="$DS_DEF DEF:loadAVG$count=$FILE:load:AVERAGE"
			DS_DEF="$DS_DEF DEF:loadMAX$count=$FILE:load:MAX"

			if [ -n "$RPC_MIN$RPN_AVG$RPN_MAX" ]; then
				RPN_O="${RPN_O},+"
				RPN_MIN="${RPN_MIN},"
				RPN_AVG="${RPN_AVG},"
				RPN_MAX="${RPN_MAX},"
			fi
			RPN_MIN="${RPN_MIN}loadMIN$count"
			RPN_AVG="${RPN_AVG}loadAVG$count"
#			RPN_MAX="${RPN_MAX}loadMAX$count"  # 0 if NaN !
			RPN_MAX="${RPN_MAX}loadMAX$count,UN,0,loadMAX$count,IF"

			MULTIP=0
			[ $_CURRENT_PAGE -ne 0 ] && MULTIP=$(($_CURRENT_PAGE-1))
			COLOR_MOD=$(($count+$MULTIP*$FRQ_COUNT % $FRQ_COUNT+$MULTIP*$FRQ_COUNT))
			[ $COLOR_MOD ==  1 ] && COLOR_VAR=#ffff00
			[ $COLOR_MOD ==  2 ] && COLOR_VAR=#ccff00
			[ $COLOR_MOD ==  3 ] && COLOR_VAR=#66ff00
			[ $COLOR_MOD ==  4 ] && COLOR_VAR=#00ff66
			[ $COLOR_MOD ==  5 ] && COLOR_VAR=#00ffcc
			[ $COLOR_MOD ==  6 ] && COLOR_VAR=#00ccff
			[ $COLOR_MOD ==  7 ] && COLOR_VAR=#0099ff
			[ $COLOR_MOD ==  8 ] && COLOR_VAR=#0066ff
#			[ $COLOR_MOD == 1 ] && COLOR_VAR=#fffc00
#			[ $COLOR_MOD == 2 ] && COLOR_VAR=#ffc600
#			[ $COLOR_MOD == 3 ] && COLOR_VAR=#ffa200
#			[ $COLOR_MOD == 4 ] && COLOR_VAR=#ff6c00
#			[ $COLOR_MOD == 5 ] && COLOR_VAR=#00c6ff
#			[ $COLOR_MOD == 6 ] && COLOR_VAR=#0090ff
#			[ $COLOR_MOD == 7 ] && COLOR_VAR=#0066ff
#			[ $COLOR_MOD == 8 ] && COLOR_VAR=#0042ff
			[ $COLOR_MOD ==  9 ] && COLOR_VAR=#0033ff
			[ $COLOR_MOD == 10 ] && COLOR_VAR=#6600ff
			[ $COLOR_MOD == 11 ] && COLOR_VAR=#9900ff
			[ $COLOR_MOD == 12 ] && COLOR_VAR=#cc00ff
			[ $COLOR_MOD == 13 ] && COLOR_VAR=#ff00ff
			[ $COLOR_MOD == 14 ] && COLOR_VAR=#ff00cc
			[ $COLOR_MOD == 15 ] && COLOR_VAR=#ff0066
			[ $COLOR_MOD == 16 ] && COLOR_VAR=#ff0033

			GPRINT="$GPRINT \
			AREA:loadAVG$count$COLOR_VAR:$_CURRENT_FRQ${NBSP}MHz\t\t$STACK \
			GPRINT:loadMIN$count:MIN:%4.1lf\t \
			GPRINT:loadAVG$count:AVERAGE:%4.1lf\t \
			GPRINT:loadMAX$count:MAX:%4.1lf\t \
			GPRINT:loadAVG$count:LAST:%4.1lf\n "
			[ -z "$STACK" ] && STACK=":STACK"
		fi
	done
	if [ -n "$DS_DEF" ]; then

		local fql=0
		local fqu=0
		for _CURRENT_FRQ in $_VISIBLE_FRQ; do
			[ $_CURRENT_FRQ -lt ${RRDSTATS_CABLESEG_QAM} ] && let fql++
			[ $_CURRENT_FRQ -lt ${RRDSTATS_CABLESEG_QAM} ] || let fqu++
		done
		MAXSPEEDC=$(awk "BEGIN{print $fql*50.0 + $fqu*37.5}")

		MAXSPEED="0"
		GPRINT="${GPRINT} COMMENT:${NBSP}${NBSP}Bandwidth${NBSP}available\:${NBSP}$MAXSPEEDC${NBSP}MBit/s\t${NBSP}----------------------------------------\n"
		if [ "$_CURRENT_PAGE" == "0" ]; then
			[ "$RRDSTATS_CABLESEG_MAXBW" == "yes" ] && MAXSPEED="1"
		else
			[ "$RRDSTATS_CABLESEG_MAXBWSUB" == "yes" ] && MAXSPEED="1"
		fi
		if [ "$MAXSPEED" == "1" ]; then
			GPRINT="${GPRINT} LINE2:$MAXSPEEDC$GREY"
			local MAXSPEEDP="-u $MAXSPEEDC"
			#local TOPVALUE="VDEF:top=rpn_AVG,MAXIMUM LINE1:top#FF0000"
		fi

		case "$PERIODE" in
			*minutes|*hours|*days|*weeks|1months) SHADE="LINE1:rpn_AVG$BLACK" ;;
			*) SHADE="" ;;
		esac
		OVERALL=" \
		CDEF:rpn_MIN=$RPN_MIN$RPN_O \
		CDEF:rpn_AVG=$RPN_AVG$RPN_O \
		CDEF:rpn_MAX=$RPN_MAX$RPN_O \
		CDEF:rpn_TOP=rpn_MAX,rpn_MAX,UNKN,IF \
		$SHADE \
		LINE1:rpn_TOP$BLACK \
		COMMENT:${NBSP}${NBSP}Summary\t\t \
		GPRINT:rpn_MIN:MIN:%4.1lf\t \
		GPRINT:rpn_AVG:AVERAGE:%4.1lf\t \
		GPRINT:rpn_MAX:MAX:%4.1lf\t \
		GPRINT:rpn_AVG:LAST:%4.1lf\n "
		#LINE2:rpn_MAX$GREY
		#LINE2:rpn_MIN$GREEN

		$_NICE $RRDTOOL graph $GRAPHARGS                         \
		$RRDSTATS_RRDTEMP/$IMAGENAME.$IMAGETYPE                  \
		--title "$TITLE"                                         \
		--start now-$PERIODE -l 0 $MAXSPEEDP -r                  \
		--width $WIDTH --height $HEIGHT                          \
		--vertical-label "MBit/s"                                \
		-Y                                                       \
		$DEFAULT_COLORS                                          \
		$LAZY                                                    \
		-A                                                       \
		-W "Generated on: $DATESTRING"                           \
		                                                         \
		COMMENT:"$(mamc "MBit/s")"                               \
		$DS_DEF $GPRINT $OVERALL $TOPVALUE                       \
		                                                         > /dev/null
	fi
}

set_lazy() {
	LAZY=" "
	[ -z "$NOTLAZY" -a "$1" = "no" ] && LAZY=" -z "
}

set_period() {
	periodA=$(echo $1 | sed 's/[0-9]\+h$/hour/g;s/[0-9]\+d$/day/g;s/[0-9]\+w$/week/g;s/[0-9]\+m$/month/g;s/[0-9]\+y$/year/g')
	period0=$(echo $1 | sed 's/[a-zA-Z]//g')
	periodG=${period0}${periodA}s
	if [ $period0 -gt 1 ]; then
		periodA=" $periodA"s
	else
		period0=""
	fi
	periodnn=$period0$periodA
}

gen_main() {
	SNAME=$1
	FNAME=$2
	LAPSE=$3
	GROUP=$4
	[ $# -ge 4 ] && GROUP_URL="&group=$4"
	[ $# -ge 5 ] && GROUP_URL="&pdev=$5$GROUP_URL"
	sec_begin "$FNAME"
	generate_graph "$SNAME" "$CURRENT_PERIOD" "$SNAME" "" $GROUP $5
	echo "<center><a href=\"$SCRIPT_NAME?graph=$SNAME$GROUP_URL\" class=\"image\">"
	echo "<img src=\"/statpix/$SNAME$GROUP$5.$IMAGETYPE$NOCACHE\" alt=\"$FNAME stats for last $LAPSE\" border=\"0\" $HTMLWIDTH />"
	echo "</a></center>"
	sec_end
}

graphit() {
	graph=$1
	#graph=$(cgi_param graph | tr -d .)
	case $graph in
		cpu|mem|swap|upt|pow|temp|thg0|thg1|thg2|thg3|epc0|epcA|epcB|epcC|epc1|epc2|arris0|arris1|arris2|arris3|dvb|csl0|csl1|csl2|diskio1|diskio2|diskio3|diskio4|if1|if2|if3|if4|one|aha*)
			set_lazy "$RRDSTATS_NOTLAZYS"
			#GROUP_PERIOD=$(cgi_param group | tr -d .)
			if [ -z "$GROUP_PERIOD" ]; then
				heading=$(echo $graph | sed "s/^upt$/Uptime/;s/^pow$/Power/;s/^temp$/Temperature/;s/^cpu$/Processor/;s/^mem$/Memory/;s/^swap$/Swapspace/;\
				  s/^thg0$/Thomson THG - basic/;s/^thg1$/Thomson THG - System Uptime/;s/^thg2/Thomson THG - Downstream Frequency/;s/^thg3$/Thomson THG - Upstream Channel/;\
				  s/^epc0$/Cisco EPC - Overview/;\
				  s/^epcA$/Cisco EPC - Downstream Signal-Noise-Ratio/;s/^epcB$/Cisco EPC - Downstream Signal-Power-Level/;s/^epcC/Cisco EPC - Upstream Signal-Power-Level \& Frequency/;\
				  s/^epc1$/Cisco EPC - System Uptime/;s/^epc2/Cisco EPC - Downstream Frequency/;\
				  s/^dvb$/FRITZ!Box Cable/;\
				  s/^csl0$/Cable segment load/;s/^csl1$/Cable segment load - lower frequencies/;s/^csl2$/Cable segment load - upper frequencies/;\
				  s/^arris0$/Arris TM - basic/;s/^arris1$/Arris TM - System Uptime/;s/^arris2/Arris TM - Downstream Frequency/;s/^arris3$/Arris TM - Upstream Frequency/;\
				  s/^diskio1$/$RRDSTATS_DISK_NAME1/;s/^diskio2$/$RRDSTATS_DISK_NAME2/;s/^diskio3$/$RRDSTATS_DISK_NAME3/;s/^diskio4$/$RRDSTATS_DISK_NAME4/;\
				  s/^if1$/$RRDSTATS_NICE_NAME1/;s/^if2$/$RRDSTATS_NICE_NAME2/;s/^if3$/$RRDSTATS_NICE_NAME3/;s/^if4$/$RRDSTATS_NICE_NAME4/;s/^one$/DigiTemp/;s/^aha.*$/SmartHome/")
			else
				heading="$(echo $GROUP_PERIOD | sed "s/StromstXrke/Stromst${AUML}rke/")"
				[ "$graph" == "aha_pdev" ] && heading="$(sed -n "s/^$GROUP_PERIOD|//p" /tmp/flash/rrdstats/smarthome.alias 2>/dev/null)"
			fi
			echo "<center><font size=+1><br><b>$heading stats</b></font></center>"

			if [ "$(echo "$graph" | sed 's/^thg./yes/')" = yes -a "$RRDSTATS_THOMSON_ADV" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"THG basics\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg0')\" /> \
				<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg1')\" /> \
				<input type=\"button\" value=\"Downstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg2')\" /> \
				<input type=\"button\" value=\"Upstream Channel\" onclick=\"window.location=('$SCRIPT_NAME?graph=thg3')\" /> \
				</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^epc./yes/')" = yes ]; then
				echo "<br><center>"
				echo "<input type=\"button\" value=\"Overview\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc0')\" />"
				echo "<input type=\"button\" value=\"Downstream FRQ\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc2')\" />"
				if [ "$RRDSTATS_CISCOEPC_DETAILS" == "yes" ]; then
					echo "<input type=\"button\" value=\"Downstream SNR\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcA')\" />"
					echo "<input type=\"button\" value=\"Downstream SIG\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcB')\" />"
					echo "<input type=\"button\" value=\"Upstream SIG & FRQ\" onclick=\"window.location=('$SCRIPT_NAME?graph=epcC')\" />"
				fi
				[ "$RRDSTATS_CISCOEPC_UP" == "yes" ] && echo "<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=epc1')\" />"
				echo "</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^arris./yes/')" = yes -a "$RRDSTATS_ARRISTM_ADV" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"Arris TM basics\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris0')\" /> \
				<input type=\"button\" value=\"System Uptime\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris1')\" /> \
				<input type=\"button\" value=\"Downstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris2')\" /> \
				<input type=\"button\" value=\"Upstream Frequency\" onclick=\"window.location=('$SCRIPT_NAME?graph=arris3')\" /> \
				</center>"
			fi
			if [ "$(echo "$graph" | sed 's/^csl./yes/')" = yes ]; then
				echo "<br><center> \
				<input type=\"button\" value=\"lower frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl1')\" /> \
				&nbsp; \
				<input type=\"button\" value=\"all frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl0')\" /> \
				&nbsp; \
				<input type=\"button\" value=\"upper frequencies\" onclick=\"window.location=('$SCRIPT_NAME?graph=csl2')\" /> \
				</center>"
			fi


			[ -n "$PERIOD_ARG" ] && CURRENT_PERIOD="$PERIOD_ARG" || CURRENT_PERIOD="$RRDSTATS_PERIODSSUB"
			for period in $CURRENT_PERIOD; do
				set_period $period
				sec_begin "last $periodnn"
				generate_graph "$graph" "$periodG" "$graph-$period" "" $GROUP_PERIOD
				echo "<center><a href=\"$SCRIPT_NAME\" class=\"image\">"
				echo "<img src=\"/statpix/$graph-$period$GROUP_PERIOD$(cgi_param pdev | tr -d .).$IMAGETYPE$NOCACHE\" alt=\"$heading stats for last $periodnn\" border=\"0\" $HTMLWIDTH />"
				echo "</a></center>"
				sec_end
			done
			[ -n "$HTTP_REFERER" ] && backdest="history.go(-1)" || backdest="window.location.href='$SCRIPT_NAME'"
			echo "<br><center><input type=\"button\" value=\"Back\" onclick=\"javascript:$backdest\" /></center>"
			;;
		*)
			set_lazy "$RRDSTATS_NOTLAZYM"
			[ -n "$PERIOD_ARG" ] && CURRENT_PERIOD="$PERIOD_ARG" || CURRENT_PERIOD="$RRDSTATS_PERIODMAIN"
			set_period "$CURRENT_PERIOD"
			[ "$(cgi_param pdev | tr -d .)" == "z" ] && echo "<br>" || echo "<center><font size=+1><br><b>Stats for last $periodnn</b></font></center>"
			case $RRD_DISPLAY_TYPE in
				rrddt)
					ALL_GROUPS=$(grep -vE "^#|^$|^ " /var/tmp/flash/rrdstats/digitemp.group 2>/dev/null | tr -s " " | cut -d " " -f2 | uniq)
					[ -z "$ALL_GROUPS" ] && gen_main "one" "$curgroup" "$periodnn"
					for curgroup in $ALL_GROUPS; do
						gen_main "one" "$curgroup" "$periodnn" "$curgroup"
					done
					;;
				avmha)
					pdev="$(cgi_param pdev | tr -d .)"
					[ -z "$pdev" ] && pdev=x

					refresh="$(cgi_param refresh | tr -d .)"
					[ -n "$refresh" ] && refresh="&refresh=$refresh"

					if [ -n "$(cgi_param ain | tr -d .)" ]; then
						csrf_check required
						echo "<center><br><b>Processing ...</b><br><br><font size=1>"
						/usr/bin/aha.sh docmd "$(cgi_param ain | tr -d .)" "$(cgi_param state | tr -d .)" >/dev/null
						sleep 1
						echo '<font style="opacity:0">'
						. /usr/lib/libmodredir.sh
						redirect "$SCRIPT_NAME?pdev=$pdev$refresh" 2>/dev/null
						exit
					fi

					echo -n "<center><br>"
					[ "$pdev" == w ] && echo -n "<u>"
					echo -n "<a href=$SCRIPT_NAME?pdev=w>Wirkleistung</a>"
					[ "$pdev" == w ] && echo -n "</u>"
					echo -n "&nbsp;&ndash;&nbsp;"
					[ "$pdev" == x ] && echo -n "<u>"
					echo -n "<a href=$SCRIPT_NAME?pdev=x>Sensoren</a>"
					[ "$pdev" == x ] && echo -n "</u>"
					echo -n "&nbsp;&ndash;&nbsp;"
					[ "$pdev" == s ] && echo -n "<u>"
					echo -n "<a href=$SCRIPT_NAME?pdev=s>Scheinleistung</a>"
					[ "$pdev" == s ] && echo -n "</u>"


					local modusAKT=''
					local modusGRP=''
					local modusPLC=''
					local modusHKR=''

					while IFS='|' read ain blob; do
						case "$(sed -n "s/^$ain|//p" /tmp/flash/rrdstats/smarthome.kinds)" in
							AKT)    modusAKT="$modusAKT$ain|$blob\n" ;;
							GRP)    modusGRP="$modusGRP$ain|$blob\n" ;;
							PLC)    modusPLC="$modusPLC$ain|$blob\n" ;;
							HKR)    modusHKR="$modusHKR$ain|$blob\n" ;;
						esac
					done << EOF
$(/usr/bin/aha.sh gradc)
EOF

					modusAKT="$modusAKT$modusPLC"
					[ -n "$modusAKT" ] && modusAKT="BR\n$modusAKT"
					[ -n "$modusGRP" ] && modusGRP="BR\n$modusGRP"
					[ -n "$modusHKR" ] && modusHKR="BR\n$modusHKR"

					#echo -e $modusAKT$modusGRP$modusHKR | while IFS='|' read ain name state lock celsius tsoll; do
					echo -e $modusAKT$modusHKR | while IFS='|' read ain name state lock celsius tsoll; do
						[ -z "$ain" ] && continue
						[ "$ain" = "BR" ] && echo -n "<font size=-2><br><br><font>" && continue
						[ "$state" == 1 ] && buttstate=lightgreen || buttstate=mediumvioletred
						[ "$lock" == 1 ] && buttlock=disabled || buttlock=enabled
						[ -z "$state" ] && buttstate=yellow
						butact="onclick=\"if (confirm('$name schalten?')==true) window.location=csrfUrl('$SCRIPT_NAME?pdev=$pdev$refresh&ain=$ain&state=$(( ($state+1)%2 ))')\""
						[ -z "$state" ] && butact="onclick=\"val = prompt('Solltemperatur (8-28|253|254):');if (val) window.location=csrfUrl('$SCRIPT_NAME?pdev=$pdev$refresh&ain=$ain&state='+(parseFloat(val) < 253 ? parseFloat(val.replace(',','.'))*2 : parseFloat(val)))\""
						if [ -n "$celsius" ]; then
							grad="$(echo $celsius | sed 's/.$/,&/g')"
							if [ -n "$tsoll" ]; then
								soll="$(echo $(( ${tsoll}0 / 2)) | sed 's/.$/,&/g')"
								[ "$soll" == 126,5 ] && soll="AUS"
								[ "$soll" == 127,0 ] && soll="EIN"
								temps=" (${grad%,0}${GRD}C->${soll%,0})"
							else
								temps=" (${grad%,0}${GRD}C)"
							fi
						else
							temps=""
						fi
						echo "&nbsp;<input type=\"button\" class=\"btn-colored_$buttlock\" style=\"background-color:$buttstate\" value=\"&nbsp;$name$temps&nbsp;\" $butact $buttlock />&nbsp"
					done
					echo -n "<br></center>"

					if [ "$pdev" != x ]; then
						if [ "$pdev" == w -o "$pdev" == s ]; then
							grep -vE "^[ \t]*$|^#" /tmp/flash/rrdstats/smarthome.alias 2>/dev/null | while IFS='|' read ain name; do
								case "$(sed -n "s/^$ain|//p" /tmp/flash/rrdstats/smarthome.kinds)" in
									AKT|PLC) ;;
									*) continue ;;
								esac
								gen_main "aha_pdev" "$name" "$periodnn" "$ain" "$pdev"
							done
						fi
					else
						gen_main "aha_grad" "Temperatur"         "$periodnn" "Temperatur"
						gen_main "aha_volt" "Spannung"           "$periodnn" "Spannung"
						gen_main "aha_blnd" "Blindleistung"      "$periodnn" "Blindleistung"
						gen_main "aha_watt" "Wirkleistung"       "$periodnn" "Wirkleistung"
						gen_main "aha_sein" "Scheinleistung"     "$periodnn" "Scheinleistung"
						gen_main "aha_curr" "Stromst${AUML}rke"  "$periodnn" "StromstXrke"
						gen_main "aha_fact" "Leistungsfaktor"    "$periodnn" "Leistungsfaktor"
					#	gen_main "aha_kilo" "Energiemenge"       "$periodnn" "Energiemenge"
					fi
					;;
				*)
					gen_main "cpu" "Processor" "$periodnn"
					gen_main "mem" "Memory" "$periodnn"
					[ "$(free | grep "Swap:" | awk '{print $2}')" != "0" ] && gen_main "swap" "Swapspace" "$periodnn"
					[ "$RRDSTATS_UPTIME_ENB" = yes ] && gen_main "upt" "Uptime" "$periodnn"
					[ "$RRDSTATS_POWER_ENB" = yes ] && gen_main "pow" "Power" "$periodnn"
					if [ "$FREETZ_PACKAGE_RRDSTATS_TEMPERATURE_SENSOR" == "y" ]; then
						[ "$RRDSTATS_TEMP_ENB" = yes ] && gen_main "temp" "Temperature" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_CABLEMODEM" == "y" ]; then
						[ "$RRDSTATS_CABLE_MODEM" = thg ] && gen_main "thg0" "Thomson THG" "$periodnn"
						[ "$RRDSTATS_CABLE_MODEM" = epc ] && gen_main "epc0" "Cisco EPC" "$periodnn"
						[ "$RRDSTATS_CABLE_MODEM" = arris ] && gen_main "arris0" "Arris TM" "$periodnn"
						[ "$RRDSTATS_CABLE_MODEM" = dvb ] && gen_main "dvb" "FRITZ!Box Cable" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_SEGMENTLOAD" == "y" ]; then
						[ "$RRDSTATS_CABLESEG_ENABLED" = yes ] && gen_main "csl0" "Cable segment load" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_STORAGE" == "y" ]; then
						[ -n "$RRDSTATS_DISK_DEV1" ] && gen_main "diskio1" "$RRDSTATS_DISK_NAME1" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV2" ] && gen_main "diskio2" "$RRDSTATS_DISK_NAME2" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV3" ] && gen_main "diskio3" "$RRDSTATS_DISK_NAME3" "$periodnn"
						[ -n "$RRDSTATS_DISK_DEV4" ] && gen_main "diskio4" "$RRDSTATS_DISK_NAME4" "$periodnn"
					fi
					if [ "$FREETZ_PACKAGE_RRDSTATS_NETWORK" == "y" ]; then
						[ -n "$RRDSTATS_INTERFACE1" ] && gen_main "if1" "$RRDSTATS_NICE_NAME1" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE2" ] && gen_main "if2" "$RRDSTATS_NICE_NAME2" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE3" ] && gen_main "if3" "$RRDSTATS_NICE_NAME3" "$periodnn"
						[ -n "$RRDSTATS_INTERFACE4" ] && gen_main "if4" "$RRDSTATS_NICE_NAME4" "$periodnn"
					fi
					;;
			esac
			;;
	esac
}

for single_graph in $ALL_GRAPHS; do
	graphit $single_graph
done

