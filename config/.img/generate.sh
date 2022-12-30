#!/bin/bash
#by cuma, 2019

# this generates config/.img/*.in
# you need all (about 300) firmware image files
# they will take unpacked about 21GB HDD space
# initial unpack takes about 8 minutes
# every analyze needs about 100 seconds

# vars
#DOSHOW=0 min, only images
#DOSHOW=1 dev, hw details
#DOSHOW=2 max, sw details
#DOSHOW=3 all, with unset
#DOSHOW=4 some of useless
DOSHOW=1
DOCONS=1
TPID=$$
SCRIPT="$(readlink -f $0)"
MYPWD="$(dirname $(dirname ${SCRIPT%/*}))"
PDIR="config/.img/separate"
PBIG="$MYPWD/config/.img/Config.in"
FWDU="$MYPWD/tools/fwdu"
DLIN="$MYPWD/config/mod/dl-firmware.in"
PROP="$MYPWD/$PDIR"
CINTMP="$PROP/Config.in"
UNPACK="$HOME/.freetz-props"
IMAGES="$HOME/.freetz-dl/fw"
FWLIST="$UNPACK/.fwlist"
[ "$FREETZ_ENABLEG" != "true" ] && exit 9


# path
[ ! -e "$FWDU" ] && echo "Missing: ${FWDU#$MYPWD/}" && exit 1
[ ! -e "$DLIN" ] && echo "Missing: ${DLIN#$MYPWD/}" && exit 1
readlink "$UNPACK" >/dev/null && mkdir -p "${UNPACK%/*}/$(readlink "$UNPACK")" || mkdir -p "$UNPACK"
echo -n > "$UNPACK/out.txt"


## helpers

die() {
	kill $TPID
	exit 1
}

# $1 key
# $2 value
outp() {
	K="$1${1:+:}"
	V="$2"
[ "$V" == "%" -a $DOSHOW -lt 3 ] && return
	while [ ${#K} -lt 13 ]; do K="$K "; done
	[ "$V" == "available" ] && V="+"
	[ "${V:0:1}" != " " ] && V="$V"
	echo -e "$K$V"
}

# $1 dl-firmware.in definition
get_shorty() {
	echo "$PDIR/$(echo "${line#* if }" | sed 's/ && FREETZ_TYPE_ANNEX_/--X/g;s/ && FREETZ_TYPE_FIRMWARE_/--/g;s/ && FREETZ_AVM_VERSION_/--/g;s/ && FREETZ_TYPE_LANG_/--/g;s/FREETZ_TYPE_//g;s/.* || FON)/FON/g').in"
}

in_i_fancy() { echo -e "config $1\n\tint\n\tdefault ${2}\n"        >> "${propin}"; }
in_b_fancy() { echo -e "config $1\n\tdef_bool ${2:-y}\n"           >> "${propin}"; }
in_s_fancy() { echo -e "config $1\n\tstring\n\tdefault \"${2}\"\n" >> "${propin}"; }

in_i_consi() { echo -e "config $1\tint\tdefault ${2}"              >> "${propin}"; }
in_b_consi() { echo -e "config $1\tdef_bool ${2:-y}"               >> "${propin}"; }
in_s_consi() { echo -e "config $1\tstring\tdefault \"${2}\""       >> "${propin}"; }

# $1 config name
# $2 default int
in_i() { [ "$DOCONS" != "1" ] && in_i_fancy "$@" || in_i_consi "$@"; }

# $1 config name
# $2 default bool (default: y)
in_b() { [ "$DOCONS" != "1" ] && in_b_fancy "$@" || in_b_consi "$@"; }

# $1 config name
# $2 default string
in_s() { [ "$DOCONS" != "1" ] && in_s_fancy "$@" || in_s_consi "$@"; }


## fwlist
fwlist() {
	mkdir -p "$PROP"
	START="$(nl -ba $DLIN | sed -rn 's/^ *(.*)\t*\tconfig FREETZ_DL_SOURCE$/\1/p')"
	COUNT="$(wc -l $DLIN | sed 's/ .*//')"
	TOP="$(( $COUNT - $START ))"
	BOT="$(tail -n$TOP $DLIN | nl -ba | sed -rn 's/^ *(.*)\t*\tconfig .*/\1/p' | head -n1)"
#	cat "$DLIN" | tail -n "$TOP" | head -n "$BOT" | grep -v 'FREETZ_DL_DETECT_IMAGE_NAME' | sed -rn 's/^.*\tdefault //p' | sed 's/"//g;s/  */ /g' \
	cat "$DLIN" | tail -n "$TOP" | head -n "$BOT" | grep -v 'FREETZ_DL_DETECT_IMAGE_NAME' | sed -rn 's/^[^#]*\tdefault //p' | sed 's/"//g;s/  */ /g' \
	  | sed 's/ || FREETZ_TYPE_[0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9]_[^ ][^ ] *//g' \
	  | sed 's/ *|| FREETZ_TYPE_[0-9][0-9][0-9][0-9]_[0-9][0-9][0-9][0-9] *//g' \
	  | sed 's/ || FREETZ_TYPE_[0-9][0-9][0-9][0-9]_V[0-9]_V[0-9] *//g' \
	  | sed 's/ || FREETZ_TYPE_[0-9][0-9][0-9][0-9]_V[0-9]_[0-9][0-9][0-9][0-9]_V[0-9] *//g' \
	  | sed 's/ && ! FREETZ_TYPE_[^ )]*//g' \
	  | sed 's/(\(FREETZ_TYPE_[^ ]*\))/\1/g' \
	  | sed 's/(\(FREETZ_TYPE_[^ ]*\))/\1/g' \
	  | sed 's/FREETZ_TYPE_FIRMWARE_/FREETZ_AVM_VERSION_/' \
	  | sed 's/_INHAUS//;s/_TEST//;s/_LABOR//;s/_BETA//;s/_PLUS//' \
	  | sed 's/\/[^ ]* / /' \
	  > "$FWLIST"
	[ $DOSHOW -ge 0 ] && outp "" "Using $(wc -l "$FWLIST" | sed 's/ .*//g') .image files."
}


## unpack
unpack_() {
	local rmdl='n'
	line="$1"
	file="${line%% *}"
	image="$IMAGES/$file"
	[ -n "$ACTIONS_FWDLURL" ] && echo "SAVING       $file" && wget -q "${ACTIONS_FWDLURL}$file" -O $image >/dev/null 2>&1 && rmdl='y'
	[ ! -s "${image}" ] && image="$HOME/Desktop/$file"
	[ ! -s "${image}" ] && echo "MISSED       ${image##*/}" && die && return 1
	dirname="$UNPACK/${line%.image*}"
	[ -e "$dirname" ] && return && echo "EXISTS    ${image##*/}" && return
	[ $DOSHOW -ge 0 ] && echo -ne "UNPACK       "
	"$FWDU" nfo unpack ${image} 2>&1 | sed -r 's/-a.?.m$//g;s/^[0-9]*\t*//g' | uniq
	[ -e "${dirname}-atom" ] && rm -rf "${dirname}-arm" "${dirname}-arm.nfo"
	for x in ${dirname}-*; do [ -d "$x" ] && mv "$x" "${dirname}" && mv "$x.nfo" "${dirname}.nfo"; done
	[ "$rmdl" == 'y' ] && echo "DELETE       $file" && rm -f $image
}
unpack() {
	cd "$UNPACK"
		if [ -z "$1" ]; then
			cat "$FWLIST" | while read line; do unpack_ "$line"; done
		else
			unpack_ "$(sed -n "s/^${1%.image}\.image *if .*/&/p" "$FWLIST")"
		fi
	cd "$MYPWD"
}


## creatin
creatin_V1() {
	echo -n > "$CINTMP"
	cat "$FWLIST" | while read line; do
		propin="$(get_shorty)"
		echo "source \"${propin}\"" >> "$CINTMP"
	done
	sort -o "$CINTMP" "$CINTMP"
	[ $DOSHOW -ge 0 ] && outp "" "Created .in list."
}
creatin_V2() {
	echo -n > "$CINTMP"
	for X in $PDIR/*.in; do
		[ -e "$X" -a "${X%/Config.in}" == "$X" ] || continue
		echo "source \"${X/}\"" >> "$CINTMP"
	done
	sort -o "$CINTMP" "$CINTMP"
	[ $DOSHOW -ge 0 ] && echo && outp "" "Created .in list."
}


## determine
determine_() {
	[ -n "$1" ] && line="$1" || return

	[ $DOSHOW -ge 0 ] && echo

	dirname="${line%%.image*}"
	[ $DOSHOW -ge 1 ] && outp "image" "${dirname}"

	propin="$(get_shorty)"
	[ $DOSHOW -ge 2 ] && outp "short" "${propin}"
	[ $DOSHOW -ge 0 ] && outp "short" "$(echo ${propin} | sed 's/.*.\///;s/\..*//')"

	echo "if ${line#* if }" > "${propin}"
	[ "$DOCONS" != "1" ] && echo >> "$propin"
	unpacked="$UNPACK/$dirname"
	[ ! -d "$unpacked" ] && echo "Directory missing: $dirname" && die && return 1


	#NAME
	if [ -e "$unpacked/etc/init.d/rc.init" ]; then
		X="$(grep ' _PRODUKT_NAME=' $unpacked/etc/init.d/rc.init | sed -rn 's/^HW=[^a][^ ]* OEM=all _PRODUKT_NAME=//p' | sed 's/\#/ /g')"
	else
		X="$(sed -rn 's/^export CONFIG_PRODUKT_NAME=\"?([^\"]*)\"?$/\1/p' $unpacked/etc/init.d/rc.conf | head -n1)"
	fi
	in_s FREETZ_AVM_PROP_NAME "${X// /$(printf '\342\200\212')}"
	[ -z "$X" ] && echo "ERROR-01" 1>&2 && X=ERROR
	[ $DOSHOW -ge 2 ] && outp "name" "$X"

	#MAJOR
	if [ -e "$unpacked/etc/init.d/rc.init" ]; then
		X="$(grep '^HW=[^a]' $unpacked/etc/init.d/rc.init | sed -rn 's/.* VERSION_MAJOR=//p')"
	else
		X="$(sed -rn 's/^export CONFIG_VERSION_MAJOR=\"?([^\"]*)\"?$/\1/p' $unpacked/etc/init.d/rc.conf | tail -n1)"
	fi
	in_s FREETZ_AVM_PROP_MAJOR "$X"
	[ -z "$X" ] && echo "ERROR-22" 1>&2 && X=ERROR
	[ $DOSHOW -ge 2 ] && outp " major" "$X"
	Y="$X"
	#HWREV
	if [ -e "$unpacked/etc/init.d/rc.init" ]; then
		X="$(grep '^HW=[^a]' $unpacked/etc/init.d/rc.init | tail -n1 | sed -rn 's/^HW=([^ ]*) .*/\1/p')"
	else
		X="$(sed -rn 's/^export CONFIG_PRODUKT=.*_HW([^\"x]*)x?\"?$/\1/p' $unpacked/etc/init.d/rc.conf | tail -n1)"
	fi
	if [ -z "$X" ]; then
		if   [ "${Y##0}" -le  30 ]; then X="$(( ${Y##0} + 65 ))"
		elif [ "${Y##0}" -le  54 ]; then X="$(( ${Y##0} + 68 ))"
		elif [ "${Y##0}" -le  60 ]; then X="$(( ${Y##0} + 69 ))"
		elif [ "${Y##0}" -le  67 ]; then X="$(( ${Y##0} + 70 ))"
		elif [ "${Y##0}" -le  75 ]; then X="$(( ${Y##0} + 71 ))"
		elif [ "${Y##0}" -le 150 ]; then X="$(( ${Y##0} + 72 ))"
		else                                 X="${Y##0}"
		fi
	fi
	in_s FREETZ_AVM_PROP_HWREV "$X"
	[ -z "$X" ] && echo "ERROR-23" 1>&2 && X=ERROR
	[ $DOSHOW -ge 2 ] && outp " hwrev" "$X"


	#SIGNED
	X=
	if [ -e "$unpacked/etc/avm_firmware_public_key1" ]; then
		if [ "$(wc -l "$unpacked/etc/avm_firmware_public_key1" | sed 's/ .*//')" != "2" ]; then
			X="%"
		elif [ "$(tail -n1 "$unpacked/etc/avm_firmware_public_key1")" == "010001" ]; then
			X=available
			PK1="$(tail -n1 $unpacked/etc/avm_firmware_public_key1)x$(head -n1 $unpacked/etc/avm_firmware_public_key1)"
			grep -q "default \"${PK1}\"  if " config/avm/signature.in || echo -e "PUBKEY missing for $dirname: $PK1" 1>&2
			#[ $DOSHOW -ge 3 ] && echo ":$PK1" | fold -w133
		fi
	fi
	[ -z "$X" ] && echo "ERROR-02" 1>&2 && X=ERROR
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_SIGNATURE"
	[ $DOSHOW -ge 2 ] && outp "signed" "$X"


	#PRODUKT
	if [ -e "$unpacked/etc/init.d/rc.init" ]; then
		X="$(grep 'OEM=all' $unpacked/etc/init.d/rc.init | grep ' PRODUKT=' | sed 's/.* PRODUKT=//;s/#/ /g' | tail -n1)"
	else
		X="$(sed -rn 's/^export CONFIG_PRODUKT=\"?([^\"]*)\"?$/\1/p' $unpacked/etc/init.d/rc.conf)"
	fi
#	in_s FREETZ_AVM_PROP_PRODUKT "$X"
	[ -z "$X" ] && echo "ERROR-03" 1>&2 && X=ERROR
	[ $DOSHOW -ge 2 ] && outp "product" "$X"
	PRODUKT="$X"

	#BRANDINGS
	X=
	G=0
	C=0
	for x in $unpacked/etc/default.$PRODUKT/*; do
		[ -d $x ] || continue
		[ "${x##*/}" == "avm" -o "${x##*/}" == "avme" ] && G="$(( $G + 1 ))"
		C="$(( $C + 1 ))"
		X="$X${X:+ }${x##*/}"
	done
	[ "$C" == "0" ] && echo "ERROR-04" 1>&2 && X=ERROR
	[ "$G" == "2" ] && in_b "FREETZ_AVM_PROP_ALL_REGIONS"
	[ "$C" != "1" ] && in_b "FREETZ_AVM_HAS_MULTIPLE_BRANDINGS"
	for x in $X; do in_b "FREETZ_AVM_HAS_BRANDING_${x}"; done
	[ -z "$X" ] && echo "ERROR-05" 1>&2 && X=ERROR
	[ "$G" == "2" ] && G="available" || G="%"
	[ $DOSHOW -ge 0 ] && outp "multi" "$G"
	[ $DOSHOW -ge 2 ] && outp "brandings" "$X"
	[ $DOSHOW -ge 3 ] && outp " count" "$C"


	#LANGUAGES
	X=
	P="$(sed 's/.* //' $unpacked/etc/default.language 2>/dev/null)"
	F="$(sed 's/.* //' $unpacked/etc/fallback.language 2>/dev/null)"
	C=0
	for x in $unpacked/etc/htmltext_*.db; do
		[ -f $x ] || continue
	#	du -sh $x 2>/dev/null
		C="$(( $C + 1 ))"
		X="$X $(echo $x | sed 's/\.db//;s/.*htmltext_//')"
	done
	[ -z "$P" ] && echo "ERROR-06" 1>&2 && X=ERROR
	if [ $C -ge 2 ]; then
		in_b "FREETZ_AVM_HAS_MULTIPLE_LANGUAGES"
		for x in $X; do in_b "FREETZ_AVM_HAS_LANGUAGE_${x}"; done
	fi
	[ $C == "0" ] && X=" $P"
	[ -z "$F" ] && F="%"
	[ $DOSHOW -ge 2 ] && outp "languages" "$C - $(echo "${X# }" | sed "s/$F/{$F}/;s/$P/[$P]/")"
	#[ $DOSHOW -ge 4 ] && outp "languages" "${X# }"
	#[ $DOSHOW -ge 4 ] && outp " count" "$C"
	#[ $DOSHOW -ge 4 ] && outp " default" "$P"
	#[ $DOSHOW -ge 4 ] && outp " fallback" "$F"


	#PLUGINS
	X=
	I=0
	C=0
	if [ -d "$unpacked/plugins" ]; then
		for x in $unpacked/plugins/plugin-*; do
			[ -d $x ] || continue
			I="$(( $I + 1 ))"
			[ "$(find "$x" -type f | wc -l)" != "1" ] || continue
			C="$(( $C + 1 ))"
			X="$X ${x#*/plugins/plugin-}"
		done
	fi
	if [ "$I" != "0" ]; then
		in_b "FREETZ_AVM_HAS_PLUGINS_UPDATE"
		for x in $X; do
			in_b "FREETZ_AVM_HAS_PLUGIN_${x^^}"
		done
	fi
	[ "$C" == "0" -a "$I" != "0" ] && echo "ERROR-07" 1>&2 && X=ERROR
	[ -z "$X" ] && X="%"
	[ $DOSHOW -ge 2 ] && outp "plugins" "$X"
	X="$C/$I"
	[ "$C" == "$I" ] && X="$C"
	[ "$C" == "0" -a "$I" == "0" ] && X="%"
	[ $DOSHOW -ge 2 ] && outp " count" "$X"


	#TTY
	X="$(sed -rn 's/^(\/dev\/)*([^#]+)::.*/\/dev\/\2/p' "$unpacked/etc/inittab" | sort -u)"
	case "$X" in
		/dev/ttyAMA0)	X="$X"		Y="ARM" ;;
		/dev/ttyS1)	X="$X"		Y="AR9" ;;
		/dev/ttyLTQ0)	X="$X"		Y="MIPS" ;; # GRX5
		/dev/ttyMSM0)	X="$X"		Y="ARM" ;; # IPQ40xx
		
		/dev/ttyS0)	X="/dev/ttyS0"; Y="default" ;;
		/dev/console)	X="/dev/ttyS0"; Y="console" ;;
		"")		X="/dev/ttyS0"; Y="null" ;;
		
		*)		X="%";		Y="ERROR" ;;
	esac
	[ "$X" != "%" ] && in_s "FREETZ_AVM_SERIAL_CONSOLE_DEVICE" "$X" || echo "ERROR-08" 1>&2
	[ $DOSHOW -ge 1 ] && outp "tty" "${X#/dev/} ($Y)"
	TTY="$Y"

	#HW
	X="$(sed -rn "s/^export CONFIG_INSTALL_TYPE=\"?([^\"]*)\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | tail -n1)"
	[ -z "$X" ] && X="$(sed -rn 's/^HW=.* INSTALL_TYPE=([^ ]*) ?.*$/\1/p' "$unpacked/etc/init.d/rc.init" | tail -n1)"
	[ $DOSHOW -ge 1 ] && outp "install" "$X"
	CPU=""
	case "$X" in
		*_ar10_*)			CPU="MIPS_34Kc"			&& X="AR10" ;;
		*_grx5_*)			CPU="MIPS_interAptiv"		&& X="GRX5" ;;
		*_2GB_*_kabel_*)		CPU="X86_ATOM"			&& X="PUMA6_X86" ;;
		*_4GB_*_kabel_*)		CPU="X86_ATOM"			&& X="PUMA7_X86" ;;
		*_cortexa9_*)			CPU="ARM_cortex_a9"		&& X="IPQ40xx" ;;
		brcm_*)				CPU="ARM_cortex_a9"		&& X="BCM63138" ;;
		*_qcaarmv8_*)			CPU="ARM_cortex_a53"		&& X="QCAARMv8" ;;
		ur8_*)				CPU="MIPS_4KEc"			&& X="UR8" ;;
		ar7_*)				CPU="MIPS_4KEc"
				[ -d "$unpacked/lib/modules/2.6.13.1-ohio" ]	&& X="AR7_OHIO"
				[ -d "$unpacked/lib/modules/2.6.13.1-ar7" ]	&& X="AR7_SANGAM"
				;;
		iks_16MB_*)			CPU="MIPS_24KEc"		&& X="IKS_VX180" ;;
		iks_128MB_*)			CPU="MIPS_34Kc"			&& X="IKS_VX185" ;;
		mips24_*)			CPU="MIPS_24Kc"
#										&& X="???"
#outp ">mips24" "$X"
				;;
		mips34_*)			CPU="MIPS_34Kc"
				[ "$TTY" == "AR9" ]				&& X="AR9"
				[ "$TTY" != "AR9" ]				&& X="VR9"
				;;
		mips74_*)			CPU="MIPS_74Kc"
#										X="AR934x"
#										X="FREETZ_SYSTEM_TYPE_QCA955x"
#										X="FREETZ_SYSTEM_TYPE_QCA956x"
#outp ">mips74" "$X"
				;;
		*)
			Y="$(readelf -A "$unpacked/usr/bin/ctlmgr" | sed -rn 's/.*Tag_CPU_name: "*([^"]*)"*/\1/p')"
			Z="$(readelf -A "$unpacked/usr/bin/ctlmgr" | sed -rn 's/.*Tag_.*arch: .* for //p' | uniq)"
			if [ -n "$Y$Z" ]; then
						CPU="$Y"			&& X="$Z"
			else
				echo "ERROR-09" 1>&2 &&	\
						CPU="ERROR $X"			&& X="ERROR: $X"
			fi
			;;
	esac
#	[ "$X" != "%" ] && in_b "FREETZ_AVM_HAS_..."
	[ $DOSHOW -ge 1 ] && outp " type" "$X"
	[ $DOSHOW -ge 1 ] && outp " cpu" "$CPU"


	#SENDARP
	P=SENDARP
	[ -L "$unpacked/usr/sbin/sendarp" ] && X="available" || X="%"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#REBOOT
	X=
	[ -f "$unpacked/sbin/reboot" ] && X="file"
	[ -L "$unpacked/sbin/reboot" ] && X="LINK"
	[ -z "$X" ] && echo "ERROR-10" 1>&2 && X=ERROR
	[ "$X" == "file" ] && in_b "FREETZ_AVM_HAS_REBOOT_SCRIPT"
	[ $DOSHOW -ge 2 ] && outp "reboot" "$X"

	#IP
	X=%
	[ -f "$unpacked/sbin/ip" ] && X="file"
	[ -L "$unpacked/sbin/ip" ] && X="LINK"
	[ "$X" == "file" ] && in_b "FREETZ_AVM_HAS_IP_BINARY"
	[ $DOSHOW -ge 2 ] && outp "ip" "$X"


	#NOEXEC
	P=NOEXEC
	X="$(grep -E ",noexec|-o noexec" "$unpacked/etc/init.d/S15-filesys" "$unpacked/etc/hotplug/udev-mount-sd" 2>/dev/null)"
	[ -z "$X" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"


	#VERSION
	P=VERSION
	V="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "${#V}" != "5" ] && V="$(cat "$unpacked/etc/.version")"
	[ -z "$V" ] && V="0000" || V="${V/.}"
	#in_i "FREETZ_AVM_PROP_${P^^}" "$V"
	#[ $DOSHOW -ge 2 ] && outp "${P,,}" "$V"

	#REVERSION
	P=REVERSION
	R="$(cat "$unpacked/etc/.revision" 2>/dev/null)"
	[ -z "$R" ] && R="00000"
	#in_i "FREETZ_AVM_PROP_${P^^}" "$R"
	#[ $DOSHOW -ge 2 ] && outp "${P,,}" "$R"

	#CVE_2014_9727
	P=CVE_2014_9727
	[ $V -ge 0455 -a $R -lt 27349 ] && in_b "FREETZ_AVM_HAS_${P^^}" && \
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "YES"


	#ANNEX_SELECT (avme is ignored by patch, just for consolodation)
	X="$(grep -c "get_annex_checked" "$unpacked/usr/www/avm/internet/dsl_line_settings.lua" 2>/dev/null)"
	[ -z "$X" ] && X="$(grep -c "get_annex_checked" "$unpacked/usr/www/avme/internet/dsl_line_settings.lua" 2>/dev/null)"
	[ "$X" -gt 1 2>/dev/null ] && X="available" || X="%"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_ANNEX_SELECTION"
	[ $DOSHOW -ge 2 ] && outp "annsel" "$X"

	#AHA
	X="$(sed -rn "s/^export CONFIG_HOME_AUTO=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_AHA"
	[ $DOSHOW -ge 2 ] && outp "aha" "$X"

	#DECT
	P=DECT
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#FHEM
	P=FHEM
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#MYFRITZ
	P=MYFRITZ
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#NAS
	P=NAS
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#NTFS
	P=NTFS
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"


	#AURA
	X="$(sed -rn "s/^export CONFIG_AURA=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_AURA_USB"
	[ $DOSHOW -ge 2 ] && outp "aura" "$X"


	#WEBDAV
	P=WEBDAV
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#WLAN
	P=WLAN
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ -z "$X" ] && X="$(sed -rn "s/^HW=.* ${P}=([yn ])[ $].*/\1/p" "$unpacked/etc/init.d/rc.init" | tail -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#CHRONY
	X="$(sed -rn "s/^export CONFIG_CHRONY=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_CHRONYD"
	[ $DOSHOW -ge 2 ] && outp "chrony" "$X"

	#INETD
	P=INETD
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"


	#AHCI (AVM [USB] Host Controller Interface, no support for "low speed" devices)
	X="%$(find $unpacked/lib/modules/ -type f -name usbahcicore.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_USB_HOST_AHCI"
	[ $DOSHOW -ge 2 ] && outp "ahci" "$X"
	HOST_AHCI="$X"

	#USB_HOST
	P=USB_HOST
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$HOST_AHCI" == "available" ] && X="y"
	#if [ "$X" != "y" ]; then
	#	P2=USB_HOST_AVM
	#	X2="$(sed -rn "s/^export CONFIG_$P2=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	#	[ "$X2" == "y" ] && X="$X2"
	#fi
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"


	#TAM
	P=TAM
	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	[ "$X" != "y" ] && X="%" || X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#PHONE
	X="%"
	[ -e "$unpacked/usr/bin/telefon" ] && X="available" && in_b "FREETZ_AVM_HAS_PHONE"
	[ $DOSHOW -ge 2 ] && outp "phone" "$X"


	#TR064
	P=TR064
	grep -q "^export CONFIG_$P=" "$unpacked/etc/init.d/rc.conf" && X="available" || X="%"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"

	#TR069
	X="%"
	[ -e "$unpacked/usr/share/ctlmgr/libtr069.so" ] && X="available" && in_b "FREETZ_AVM_HAS_TR069"
	[ $DOSHOW -ge 2 ] && outp "tr069" "$X"

	##TR069
	#X="%"
	#[ -e "$unpacked/bin/tr069starter" ] && X="available" && in_b "FREETZ_AVM_HAS_TR069"
	#[ $DOSHOW -ge 2 ] && outp "tr069fwu" "$X"

	##TR069
	#P=TR069
	#X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"])\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	#[ -z "$X" ] && X="$(sed -rn "s/^HW=.* ${P}=([yn ])[ $].*/\1/p" "$unpacked/etc/init.d/rc.init" | tail -n1)"
	#[ "$X" != "y" ] && X="%" || X="available"
	#[ "$X" == "available" ] && in_b "FREETZ_AVM_HAS_${P^^}"
	#[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"


	#TR069_FWUPDATE
	X="%"
	[ -e "$unpacked/usr/bin/tr069fwupdate" ] && X="available" && in_b "FREETZ_AVM_HAS_TR069_FWUPDATE"
	[ $DOSHOW -ge 2 ] && outp "tr069fwu" "$X"


	#LEDPAGE
	X="%"
	[ -e $unpacked/usr/www/avm/system/led_display.lua ] && X="available" && in_b "FREETZ_AVM_HAS_LEDPAGE"
	[ $DOSHOW -ge 2 ] && outp "ledpage" "$X"

	#DDNSD
	X="%"
	[ -e "$unpacked/sbin/ddnsd" ] && X="available" && in_b "FREETZ_AVM_HAS_DDNSD"
	[ $DOSHOW -ge 2 ] && outp "ddnsd" "$X"

	#KMOD
	X="%"
	[ -e "$unpacked/usr/bin/kmod" ] && X="available" && in_b "FREETZ_AVM_HAS_KMOD"
	[ $DOSHOW -ge 2 ] && outp "kmod" "$X"


	#MINID
	X="%"
	[ -e "$unpacked/bin/minid" -o -L "$unpacked/bin/minid" ] && X="available" && in_b "FREETZ_AVM_HAS_MINID"
	[ $DOSHOW -ge 2 ] && outp "minid" "$X"

	#TELNETD
	X="%"
	[ -e "$unpacked/usr/sbin/telnetd" -o -L "$unpacked/usr/sbin/telnetd" ] && X="available" && in_b "FREETZ_AVM_HAS_TELNETD"
	[ $DOSHOW -ge 2 ] && outp "telnetd" "$X"

	#UMTS
	X="%"
	[ -e "$unpacked/usr/bin/umtsd" -o -e "$unpacked/bin/mobiled" ] && X="available" && in_b "FREETZ_AVM_HAS_UMTS"
	[ $DOSHOW -ge 2 ] && outp "umts" "$X"

	#FAX
	X="%"
	find $unpacked/usr/www/*/fon_devices/fax_send.lua >/dev/null 2>&1 && X="available" && in_b "FREETZ_AVM_HAS_FAX"
	[ $DOSHOW -ge 2 ] && outp "fax" "$X"


	#UDEV
	X="%"
	[ -e "$unpacked/sbin/udevd" ] && X="available" && in_b "FREETZ_AVM_HAS_UDEV"
	[ $DOSHOW -ge 2 ] && outp "udev" "$X"

	#LSOF
	X="%"
	[ -e "$unpacked/bin/lsof" ] && X="available" && in_b "FREETZ_AVM_HAS_LSOF"
	[ $DOSHOW -ge 2 ] && outp "lsof" "$X"

	#SOCAT
	X="%"
	[ -e "$unpacked/sbin/socat" ] && X="available" && in_b "FREETZ_AVM_HAS_SOCAT"
	[ $DOSHOW -ge 2 ] && outp "socat" "$X"

	#TC
	X="%"
	[ -e "$unpacked/sbin/tc" ] && X="available" && in_b "FREETZ_AVM_HAS_TC"
	[ $DOSHOW -ge 2 ] && outp "tc" "$X"

	#IPTABLES
	X="%"
	[ -e "$unpacked/bin/xtables-multi" ] && X="available" && in_b "FREETZ_AVM_HAS_IPTABLES"
	[ $DOSHOW -ge 2 ] && outp "iptables" "$X"


	#SMBD
	X="%"
	[ -e "$unpacked/sbin/smbd" ] && X="available" && in_b "FREETZ_AVM_HAS_SAMBA_SMBD"
	[ $DOSHOW -ge 2 ] && outp "smbd" "$X"

	#NMBD
	#X="%"
	#[ -e "$unpacked/sbin/nmbd" ] && X="available" && in_b "FREETZ_AVM_HAS_SAMBA_NMBD"
	#[ $DOSHOW -ge 2 ] && outp "nmbd" "$X"

	#NQCS (Network Quick CIFS Service) -  https://www.visualitynq.com/de/nqe-german
	X="%"
	[ -e "$unpacked/sbin/nqcs" ] && X="available" && in_b "FREETZ_AVM_HAS_SAMBA_NQCS"
	[ $DOSHOW -ge 2 ] && outp "nqcs" "$X"


	#DSL_CONTROL
	X="%"
	[ -e "$unpacked/usr/sbin/dsl_control" -o -e "$unpacked/usr/sbin/vr10/dsl_control" ] && X="available" && in_b "FREETZ_AVM_HAS_DSL_CONTROL"
	[ $DOSHOW -ge 2 ] && outp "dslctl" "$X"

	#SHOWDSLDSTAT
	X="%"
	[ -e "$unpacked/sbin/showdsldstat" -o -e "$unpacked/bin/showdsldstat" ] && X="available" && in_b "FREETZ_AVM_HAS_SHOWDSLDSTAT"
	[ $DOSHOW -ge 2 ] && outp "sdslds" "$X"
	
	#DSLD
	X="%"
	[ -e "$unpacked/sbin/dsld" ] && X="available" && in_b "FREETZ_AVM_HAS_DSLD"
	[ $DOSHOW -ge 2 ] && outp "dsld" "$X"

	#VPN
	X="%"
	[ -e "$unpacked/bin/avmike" ] && X="available" && in_b "FREETZ_AVM_HAS_VPN"
	[ $DOSHOW -ge 2 ] && outp "vpn" "$X"

	#WIREGUARD
	X="%"
	[ -e "$unpacked/lib/libwireguard.so" ] && X="available" && in_b "FREETZ_AVM_HAS_WIREGUARD"
	[ $DOSHOW -ge 2 ] && outp "wireguard" "$X"

	#AVMCOUNTERD
	X="%"
	[ -e "$unpacked/sbin/avmcounterd" ] && X="available" && in_b "FREETZ_AVM_HAS_AVMCOUNTERD"
	[ $DOSHOW -ge 2 ] && outp "avmcounterd" "$X"

	#WEBSRV
	X="%"
	[ -e "$unpacked/sbin/websrv" ] && X="available" && in_b "FREETZ_AVM_HAS_WEBSRV"
	[ $DOSHOW -ge 2 ] && outp "websrv" "$X"

	#DTRACE
	X="%"
	[ -e "$unpacked/usr/bin/dtrace" ] && X="available" && in_b "FREETZ_AVM_HAS_DTRACE"
	[ $DOSHOW -ge 2 ] && outp "dtrace" "$X"

	#PRINTSERV
	X="%"
	[ -e "$unpacked/sbin/printserv" ] && X="available" && in_b "FREETZ_AVM_HAS_PRINTSERV"
	[ $DOSHOW -ge 2 ] && outp "printserv" "$X"

	#NEXUS
	X="%"
	[ -e "$unpacked/bin/avmnexusd" -o -e "$unpacked/sbin/avmnexusd" ] && X="available" && in_b "FREETZ_AVM_HAS_NEXUS"
	[ $DOSHOW -ge 2 ] && outp "nexus" "$X"

	#UNTRUSTEDD
	X="%"
	[ -e "$unpacked/usr/bin/untrustedd" ] && X="available" && in_b "FREETZ_AVM_HAS_UNTRUSTEDD"
	[ $DOSHOW -ge 2 ] && outp "untrustedd" "$X"

	#PLCD
	X="%"
	[ -e "$unpacked/usr/sbin/plcd" -o -e "$unpacked/sbin/plcd" ] && X="available" && in_b "FREETZ_AVM_HAS_PLCD"
	[ $DOSHOW -ge 2 ] && outp "plcd" "$X"


	#MEDIASRV
	X="%"
	[ -e "$unpacked/sbin/mediasrv" ] && X="available" && in_b "FREETZ_AVM_HAS_MEDIASRV"
	[ $DOSHOW -ge 2 ] && outp "mediasrv" "$X"

	#RPCBIND
	X="%"
	[ -e "$unpacked/usr/sbin/rpcbind" ] && X="available" && in_b "FREETZ_AVM_HAS_RPCBIND"
	[ $DOSHOW -ge 2 ] && outp "rpcbind" "$X"

	#ETCSERVICES
	X="%"
	[ -e "$unpacked/etc/services" ] && X="available" && in_b "FREETZ_AVM_HAS_ETCSERVICES"
	[ $DOSHOW -ge 2 ] && outp "etcservies" "$X"

	#NSSWITCH
	X="%"
	[ -e "$unpacked/etc/nsswitch.conf" ] && X="available" && in_b "FREETZ_AVM_HAS_NSSWITCH"
	[ $DOSHOW -ge 2 ] && outp "nsswitch" "$X"


	#LIBFUSE
	X="%"
	[ -e "$unpacked/lib/libfuse.so" -o -L "$unpacked/lib/libfuse.so" ] && X="available" && in_b "FREETZ_AVM_HAS_LIBFUSE"
	[ $DOSHOW -ge 2 ] && outp "libfuse" "$X"


	#OPENSSL
	#X="$([ -e "$unpacked/lib/libssl.so" ] && realpath "$unpacked/lib/libssl.so" 2>/dev/null | sed 's/.*\/lib\/libssl\.so\.//')"
	X="$( strings "${unpacked}/lib/libssl.so" 2>/dev/null | sed -nr 's/^@?OpenSSL ([10]\.[0-9a-z\.]*).*/\1/p' )"
	[ -z "$X" ] && X="%"
	[ $DOSHOW -ge 2 ] && outp "openssl" "$X"
	if [ "$X" != "%" ]; then
		in_b "FREETZ_AVM_HAS_OPENSSL"
		X="${X:0:1}"
		[ "$X" != "0" -a "$X" != "1" ] && echo "ERROR-11" 1>&2 && X=ERROR
		in_b FREETZ_AVM_HAS_OPENSSL_VERSION_${X}
	fi


	#KIDS
	X="%$(find $unpacked/sbin $unpacked/bin -maxdepth 1 -type f -name usermand -o -name contfiltd)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_KIDS"
	[ $DOSHOW -ge 2 ] && outp "kids" "$X"

	#E2FSPROGS
	X="%$(find $unpacked/sbin/ $unpacked/usr/sbin/ -maxdepth 1 -type f \( -name e2fsck -o -name blkid \))"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_E2FSPROGS"
	[ $DOSHOW -ge 2 ] && outp "e2fs" "$X"


	#CDROM
	X="%$(find $unpacked/lib/modules/ -type f -name cdrom.iso)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_CDROM_ISO"
	[ $DOSHOW -ge 2 ] && outp "cdrom.iso" "$X"


	#ETHERNET_OVER_USB
	X="%$(find $unpacked/lib/modules/ -type f -name avalanche_usb.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_ETHERNET_OVER_USB"
	[ $DOSHOW -ge 2 ] && outp "netusb" "$X"

	#EXT2
	X="%$(find $unpacked/lib/modules/ -type f -name ext2.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_EXT2_MODULE"
	[ $DOSHOW -ge 2 ] && outp "ext2.ko" "$X"

	#FAT
	X="%$(find $unpacked/lib/modules/ -type f -name fat.ko -o -name vfat.ko -o -name msdos.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_FAT_MODULE"
	[ $DOSHOW -ge 2 ] && outp "fat.ko" "$X"

	#NLS
	X="%$(find $unpacked/lib/modules/ -type f -name nls_*.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_NLS_MODULE"
	[ $DOSHOW -ge 2 ] && outp "nls.ko" "$X"

	#RAMZSWAP
	X="%$(find $unpacked/lib/modules/ -type f -name ramzswap.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_RAMZSWAP_MODULE"
	[ $DOSHOW -ge 2 ] && outp "ramzswap.ko" "$X"

	#ISOFS
	X="%$(find $unpacked/lib/modules/ -type f -name isofs.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_ISOFS_MODULE"
	[ $DOSHOW -ge 2 ] && outp "isofs.ko" "$X"

	#JFFS2
	X="%$(find $unpacked/lib/modules/ -type f -name jffs2.ko)"
	[ "$X" != "%" ] && X="available" && in_b "FREETZ_AVM_HAS_JFFS2_MODULE"
	[ $DOSHOW -ge 2 ] && outp "jffs2.ko" "$X"


	#CYCLE
	#X="$(sed -rn 's/^Releasecycle=//p' "$unpacked.nfo")"
	#[ -z "$X" ] && X="%" || in_s "FREETZ_AVM_PROP_CYCLE" "$X"
	#[ $DOSHOW -ge 1 ] && outp "cycle" "$X"


	#CPIO
	if grep -q 'no squashfs' "$unpacked.nfo"; then
		X="$(sed -rn 's/^(INNER-).*/\1/p' "$unpacked.nfo")"
		X="$(sed -rn "s/^${X}Filesystem on .* is ([^ ]* [^ ]*).*/\1/p" "$unpacked.nfo")"
		[ -z "$X" ] && echo "ERROR-21" 1>&2 && X=ERROR
		[ "$X" != "${X% archived}" ] && X="${X% *}" && in_b "FREETZ_AVM_PROP_INNER_FILESYSTEM_TYPE_${X^^}"
		[ $DOSHOW -ge 1 ] && outp "Archive" "${X^^}"
	else

	#SQVER
	X="$(sed -rn 's/^(INNER-).*/\1/p' "$unpacked.nfo")"
	X="$(sed -rn "s/^${X}Filesystem on .* is .* compressed \(([:0-9]*)\)$/\1/p" "$unpacked.nfo")"
	[ -z "$X" ] && echo "ERROR-12" 1>&2 && X=ERROR
	in_b "FREETZ_AVM_PROP_SQUASHFS_VERSION_${X:0:1}"
	[ $DOSHOW -ge 1 ] && outp "SquashV" "${X/:/.}"

	#SQPAK
	X="$(sed -rn 's/^(INNER-).*/\1/p' "$unpacked.nfo")"
	X="$(sed -rn "s/^${X}Filesystem on .* is ([^ ]*) compressed .*/\1/p" "$unpacked.nfo")"
	[ -z "$X" ] && echo "ERROR-13" 1>&2 && X=ERROR
	in_b "FREETZ_AVM_PROP_SQUASHFS_COMPRESSION_${X^^}"
	[ $DOSHOW -ge 1 ] && outp "SquashC" "${X/:/.}"

	fi


	#NMI
	X="$(sed -rn 's/^NMI vector v([0-9]) found.*/\1/p' "$unpacked.nfo")"
	[ -z "$X" ] && X="%" || in_b "FREETZ_AVM_PROP_NMI_V$X"
	[ "$X" != "%" ] && X="v$X"
	[ $DOSHOW -ge 1 ] && outp "nmi" "$X"


	#LAYOUT
	X="$(sed -rn 's/^firmware layout v([0-9])/\1/p' "$unpacked.nfo")"
	[ -z "$X" ] && echo "ERROR-14" 1>&2 && X=ERROR
	[ "$X" == "3" -o "$X" == "4" -o "$X" == "5" -o "$X" == "6" ] && in_b "FREETZ_AVM_PROP_SEPARATE_FILESYSTEM_IMAGE"
	[ "$X" == "5" -o "$X" == "6" ] && in_b "FREETZ_AVM_HAS_FWLAYOUT_$X"
	X="$(echo $X | sed 's/1/&-old/;s/2/&-most/;s/3/&-nand/;s/4/&-docsis/;s/5/&-uimg/;s/6/&-fit/')"
	[ $DOSHOW -ge 1 ] && outp "layout" "v$X"

	#RAMSIZE
	#if [ "${X:0:1}" == "3" ]; then
	#	P=RAMSIZE
	#	X="$(sed -rn "s/^export CONFIG_$P=\"?([^\"]*)\"?.*$/\1/p" "$unpacked/etc/init.d/rc.conf" | head -n1)"
	#	[ "$X" -gt 0 2>/dev/null ] || X="%"
	#	in_s "FREETZ_AVM_PROP_${P^^}" "$X"
	#	[ $DOSHOW -ge 2 ] && outp "${P,,}" "$X"
	#fi


	#WRAPPER
	X="%"
	grep -q '^INNER-Filesystem on ' "$unpacked.nfo" && X="available"
	[ "$X" == "available" ] && in_b "FREETZ_AVM_PROP_INNER_OUTER_FILESYSTEM"
	[ $DOSHOW -ge 1 ] && outp "wrapper" "$X"

	#WRAPFS
	if [ "$X" == "available" ]; then
	X="$(sed -rn 's/^Filesystem on .* is ([^ ]* [^ ]*).*/\1/p' "$unpacked.nfo")"
	[ -z "$X" ] && echo "ERROR-15" 1>&2 && X=ERROR
	[ "$X" != "${X% formated}" ] && X="${X% *}" && in_b "FREETZ_AVM_PROP_OUTER_FILESYSTEM_TYPE_${X^^}"
	[ "$X" != "${X% compressed*}" ] && X="squashfs (${X% *})"
	[ $DOSHOW -ge 1 ] && outp " wrapfs" "$X"
	fi


	#KERNEL
	X="$(find "$unpacked/lib/modules" -maxdepth 1 -type d -regex '.*/lib/modules/[0-9]\..*')"
	[ -z "$X" ] && echo "ERROR-19" 1>&2 && X=ERROR
	X="${X#$unpacked/lib/modules/}"
	[ $DOSHOW -ge 1 ] && outp "kernel" "$X"
	X="$(echo $X | sed 's/\./_/g;s/^2_6_13_.*/2_6_13/;s/^2_6_19_.*/2_6_19/;s/^2_6_28_.*/2_6_28/')"
	in_b "FREETZ_AVM_PROP_KERNEL_$X"


	if [ "${X:0:1}" != "2" ]; then
	#AVM_KERNEL_CONFIG
	X="$(sed -rn 's/^avm_kernel_config size is (.*)/\1/p' "$unpacked.nfo")"
	[ -z "$X" ] && X="0"
	in_b "FREETZ_AVM_PROP_KERNEL_CONFIG_AREA_SIZE_${X% *}"
	[ $DOSHOW -ge 1 ] && outp "akc_size" "$X"

	#AVM_KERNEL_CONFIG.2ND
	#X="$(sed -rn 's/^avm_kernel_config.2ND size is ([0-9]*) KB$/\1/p' "$unpacked.nfo")"
	#[ -z "$X" ] && X="%" || in_b "FREETZ_AVM_PROP_KERNEL_CONFIG_AREA_SIZE_2ND_${X% *}"
	#[ $DOSHOW -ge 1 ] && outp "akc2_size" "$X"
	fi


	#ENDIAN
	X="$(readelf -h "$unpacked/bin/busybox" 2>/dev/null | grep -E 'Data:' | sed 's/.*complement, big endian/BE/;s/.*complement, little endian/LE/')"
	[ -z "$X" -o -n "$(echo $X | sed 's/^BE$//;s/^LE$//')" ] && echo "ERROR-16" 1>&2 && X=ERROR
	[ $DOSHOW -ge 1 ] && outp "endian" "$X"
	in_b "FREETZ_AVM_PROP_ARCH_$X"

	#ARCH
	X="$(readelf -h "$unpacked/bin/busybox" 2>/dev/null | grep -E 'Machine:' | sed 's/ *Machine: *//;s/MIPS R3000/MIPS/;s/Intel 80386/X86/')"
	[ -z "$X" -o -n "$(echo $X | sed 's/^MIPS$//;s/^X86$//;s/^ARM$//g')" ] && echo "ERROR-17" 1>&2 && X=ERROR
	[ $DOSHOW -ge 1 ] && outp "arch" "$X"
	in_b "FREETZ_AVM_PROP_ARCH_$X"


	#GCC
	X="$(strings "$unpacked/sbin/multid" "$unpacked/sbin/rextd" 2>/dev/null | grep 'GCC:' | grep -v '3.3.2' | sort -u | sed 's/.* //' | tail -n1)"
	[ -z "$X" ] && echo "ERROR-18" 1>&2 && X=ERROR
	[ $DOSHOW -ge 1 ] && outp "gcc" "$X"
	X="$(echo ${X:0:3} | sed 's/\./_/g')"
	[ "${X:0:1}" -ge 5 ] && X=${X:0:1}
	in_b "FREETZ_AVM_PROP_GCC_$X"
#	[ "${X:0:1}" -gt 5 ] && in_b "FREETZ_AVM_PROP_GCC_5"


	#LIBC
#	X="$(ls $unpacked/lib/libuClibc-*.so 2>/dev/null | sed 's/.*\/lib\/libuClibc-//;s/\.so$//')"
	X="$(readlink $unpacked/lib/libc.so.? | sed 's/\.so$//' | head -n1)"
	Z=1
	# uclibc
	if [ "$X" != "${X#libuClibc-}" ]; then
		X="${X#lib}"
		Y="$(echo -n "${X#uClibc-}" | sed 's/\(......\).*/\1/')"
		case $Y in
			0.9.*)	Z=0  ;;
			1.0.14)	Z=0  ;;
		esac
	# glibc
	elif [ "$X" != "${X#libc-}" ]; then
		X="g$X"
		Y="${X#*-}"
	# musl
	elif [ -f $unpacked/lib/libc.so -a -n "$(strings $unpacked/lib/libc.so | grep '^musl libc')" ]; then
		X="musl-$(strings $unpacked/lib/libc.so | grep '^[0-1]\.[0-9]\.[0-9][0-9]*$')"
		Y="${X#*-}"
	# shit
	else
		in_b "FREETZ_AVM_PROP_LIBC_ERROR" && echo "ERROR-20 $X" 1>&2 && X=ERROR
	fi
#	in_b "FREETZ_AVM_PROP_$(echo -n ${X^^} | sed 's/-.*//')_${Y//\./_}"
	[ $DOSHOW -ge 1 ] && outp "${X%-*}" "${X#*-}"
	in_b "FREETZ_AVM_PROP_LIBC_$(echo -n ${X^^} | sed 's/-.*//')"

	if [ "$Z" == "0" ]; then
in_b "FREETZ_AVM_PROP_UCLIBC_${Y//\./_}"
		#XLOCALE
		X="$(strings $unpacked/lib/libuClibc-*.so 2>/dev/null | grep '^uselocale$')"
		[ -z "$X" ] && X="%" || X=available
		[ $DOSHOW -ge 1 ] && outp " xlocale" "$X"
		[ "$X" != "%" ] && in_b "FREETZ_AVM_PROP_UCLIBC_XLOCALE"
		#NPTL (hardcoded: .33+1.)
		#X="$(strings $unpacked/lib/libuClibc-*.so 2>/dev/null | grep '^NPTL' | sed 's/ .*//')"
		#[ -z "$X" ] && X="%" || X=available
		#[ $DOSHOW -ge 1 ] && outp " nptl" "$X"
		#[ "$X" != "%" ] && in_b "FREETZ_AVM_PROP_UCLIBC_NPTL"
	else
		in_b "FREETZ_AVM_PROP_UCLIBC_SEPARATE"
#		in_b "FREETZ_AVM_PROP_UCLIBC_1_0_14"
#		in_b "FREETZ_AVM_PROP_UCLIBC_XLOCALE"
	fi


	#
	echo "endif" >> "$propin"
	[ "$DOCONS" != "1" ] && echo >> "$propin"
}
determine() {
	if [ -z "$1" ]; then
		cat "$FWLIST" | while read line; do determine_ "$line"; done
	else
		determine_ "$(sed -n "s/^${1%.image}\.image *if .*/&/p" "$FWLIST")"
	fi
}


## consolidate
consolidate() {
	consolidate_L1
	consolidate_L2
}
consolidate_L1() {
	[ $DOSHOW -le 2 ] && echo -en "\nConsolidating: ."
	rm -rf $PDIR/_*.in
	for dev in $(for X in $PROP/*.in; do [ "${X##*/}" != "Config.in" ] && echo "${X##*/}" | sed 's/--.*//;s/\.in$//'; done | sort -u); do

		# all files of device
		cnt=0
		fos=
		for X in $PROP/$dev--*.in; do
			[ -e "$X" ] || continue
			fos="$fos${fos:+ }${X##*/}"
			let cnt++
		done
		if [ $cnt -eq 1 ] && [ ! -e "$PROP/$dev.in" ]; then
			mv $PROP/$dev--*.in "$PROP/$dev.in"
			sed -r 's/(^if FREETZ_TYPE_[^ ]*).*/\1/' -i "$PROP/$dev.in"
		fi
		[ $cnt -le 1 ] && continue
		[ $DOSHOW -le 2 ] && echo -n "$cnt." || echo -e "\n$dev := $cnt"

		# all symbols of device
		newin="$PDIR/$dev.in"
		rm -rf "$newin"
		syms=a
		cat $PDIR/$dev--*.in | grep "^config " | sort -u | while read X; do
			#[ $DOSHOW -le 2 ] && echo -n "-"
			[ "$cnt" != "$(grep "$X" $PDIR/$dev--*.in | wc -l)" ] && continue
			#echo "symbol = ${X%%\\t*}"
			[ -e "$newin" ] || cat $PDIR/$dev--*.in | head -n1 | sed 's/ && .*//' > "$newin"
			echo "$X" >> "$newin"
			#for Z in $PDIR/$dev--*.in; do sed -i "/^${X}$/d" "$Z"; done
			X="$(echo "$X" | sed 's/\//\\\//g')"
			sed "/^${X}$/d" -i $PDIR/$dev--*.in
		done

		[ -e "$newin" ] && echo "endif" >> "$newin"

	done
	for X in $PROP/*.in; do [ "$(wc -l "$X" | sed 's/ .*//')" == "2" ] && rm "$X"; done
	for X in $PROP/*.in; do [ "${X##*/}" != "Config.in" ] && sed 's/\t/\n\t/g;s/$/\n/' -i "$X"; done
	[ $DOSHOW -le 2 ] && echo " done"
}
consolidate_L2() { :; }


## args
while [ $# -gt 0 ]; do
	case $1 in
		c|consolidate)
			DOCONS=0
			;;
		f|force)
			dirname="$UNPACK/${2%.image*}"
			[ -n "$2" -a -d "$dirname" -a "$dirname" != "$UNPACK/" ] && rm -rf "$dirname"
			;;
		*)
			single="$1"
			;;
	
	esac
	shift
done

## main
# default usage: No args!
# possible args: c|consolidate (in) OFF
# possible args: f|force (re-)unpack
# possible args: .image (single file) [und]
[ $DOSHOW -ge 0 ] && echo                   | tee -a "$UNPACK/out.txt"
[ "$DOCONS" == "1" ] && rm -rf "$PROP"      | tee -a "$UNPACK/out.txt"
fwlist                                      | tee -a "$UNPACK/out.txt"
unpack $single                              | tee -a "$UNPACK/out.txt"
[ "$DOCONS" != "1" ] && creatin_V1          | tee -a "$UNPACK/out.txt"
determine $single                           | tee -a "$UNPACK/out.txt"
[ "$DOCONS" == "1" ] && consolidate         | tee -a "$UNPACK/out.txt"
[ "$DOCONS" == "1" ] && creatin_V2          | tee -a "$UNPACK/out.txt"
[ $DOSHOW -ge 0 ] && echo                   | tee -a "$UNPACK/out.txt"
grep -vE "^($|source )" $PROP/* -h > $PBIG

exit 0
