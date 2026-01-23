#! /usr/bin/env bash
# generates docs/stats/README.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname $(dirname ${SCRIPT%/*}))"
OUTFILE="$PARENT/docs/stats/README.md"
TMPFILE="$PARENT/.stats"
rm -f "$TMPFILE".??.*


table_head() {
	echo "<table>"
	echo "<caption style='background-color:gray'>${3:-&nbsp;}</caption>"
	echo "<thead><tr><th style='width:450px'>$1</th><th style='width:300px'>$2</th></tr></thead>"
	echo "<tbody>"
}

table_foot() {
	echo "</tbody></table>"
}

spoiler_head() {
	count=$(cat "$1" | wc -l | tr -d '\n')
	echo "<details><summary>${count} $2</summary>"
	echo
}

spoiler_body() {
	cat "$1" | sed 's/|/\\|/g' | sed -r 's, *@ (.*) @ (.*) @,<tr><td>\2</td><td>\1</td></tr>,g'
	table_foot
	echo "</details>"
	echo
}

get_fw() {
	area='Firmware version'
	file="config/ui/firmware.in"
	(
		table_head "Version" "Symbol"
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(config|bool) " | while read -r line; do
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'  | sed 's/^[^\t ]*[ \t]*/@ /g;s/$/ @ /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"               | sed 's/^[^\t ]*[ \t]*"//g;s/"/ @/g' && echo >> "$TMPFILE.fw.head"
		done | sed 's/ - [^ ]*//g' | grep -Evi "(inhaus|labor|plus)"
	) > "$TMPFILE.fw.body"
}

get_hw() {
	area='Hardware type'
	file="config/ui/firmware.in"
	last=0
	(
		first='y'
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(comment|config|bool) " | while read -r line; do
			if [ "${line#comment}" != "$line" ]; then
				[ "$first" == "y" ] && first='n' || table_foot
				let last++
				table_head "Name" "Symbol"  "$(echo "$line"  | sed 's/^[^\t ]*[ \t]*"//;s/".*//') (%%$last%%)"
			fi
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'           | sed 's/^[^\t ]*[ \t]*/@ /g;s/$/ @ /g' && echo >> "$TMPFILE.hw.head$last"
			[ "${line#bool}"    != "$line" ] && echo "$line"                        | sed 's/^[^\t ]*[ \t]*"//g;s/ -.*/"/g;s/"/ @/g' && echo >> "$TMPFILE.hw.head"
		done | sed 's/ - [^ ]*//g'
	) > "$TMPFILE.hw.body"
	for idx in "$TMPFILE.hw.head"*; do
		local kat="${idx#$TMPFILE.hw.head}"
		[ -n "$kat" ] && sed "s/%%${kat}%%/$(cat "$TMPFILE.hw.head${kat}" | wc -l | tr -d '\n')/g" -i "$TMPFILE.hw.body"
	done
}

get_dl() {
	area='Firmware source'
	file="config/mod/dl-firmware.in"
	(
		table_head "Datei(/AVM)" "Symbole"
		cat "$file" | grep "string \"${area}\"" -m1 -A9999 | grep "^config " -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(default) " | grep -v "DETECT_IMAGE_NAME" | while read -r line; do
			echo "$line" | tr -s ' ' | sed -r 's/.*"(.*)".* if (.*)/@ \2 @ \1 @/g' && echo >> "$TMPFILE.dl.head"
		done | sed -r 's/_(inhaus|labor|plus)//gI' | sed 's/&&/\&amp;\&amp;<br>/g;s/||/\&vert;\&vert;<br>/g'
	) > "$TMPFILE.dl.body"
}

get_lg() {
#	file="config/.img/separate/*.in"
	(
		first='y'
		lastgen='x'
		"$PARENT/tools/layoutGens.sh" "stats" | while read -r line; do
			if [ "${line#\# }" != "$line" ]; then
				[ "$first" == "y" ] && first='n' || table_foot
				[ "$line" != "{line##*Gen}" ] && lastgen="${line: -1}"
				case "${line##*Gen}" in
					1) gen="single" ;;
					2) gen="ram" ;;
					3) gen="dual" ;;
					4) gen="uimg" ;;
					5) gen="fit" ;;
					*) gen="undef" ;;
				esac
				table_head "Name" "Symbol"  "${line##* }: $gen-boot (%%${line##*Gen}%%)"
				echo >> "$TMPFILE.lg.head"
			else
				echo "$line" | sed -rn 's/(.*) - (.*)/@ \1 @ \2 @/p'
				echo >> "$TMPFILE.lg.head$lastgen"
			fi
		done | sed 's/ - [^ ]*//g'
	) > "$TMPFILE.lg.body"
	for idx in "$TMPFILE.lg.head"*; do
		local gen="${idx#$TMPFILE.lg.head}"
		[ -n "$gen" ] && sed "s/%%${gen}%%/$(cat "$TMPFILE.lg.head${gen}" | wc -l | tr -d '\n')/g" -i "$TMPFILE.lg.body"
	done
}

get_tc_int() {
		table_head "Name" "Symbole" "$1 Toolchains (%%$3%%)"
		cat "$PARENT/out.$2" | grep "^dl" | sort -u | while read -r file; do
			cat "$PARENT/out.$2" | grep "^$file$" -m1 -A1 | while read -r line; do
				if [ "${line#dl\/}" != "$line" ]; then
					name="${line%-freetz-*}"
				else
					echo "@ ${line##* if } @ ${name:3} @"
					echo >> "$TMPFILE.tc.head$3"
				fi
			done
		done | sed 's/  */ /g;s/&&/\&amp;\&amp;<br>/g;s/||/\&vert;\&vert;<br>/g'
}
get_tc() {
#	file="tools/dl-toolchains_make"
	(
		"$PARENT/tools/dl-toolchains_eval" "" "stats" >/dev/null 2>&1
		table_head "Target" "Kernel" "Kombinierte Toolchains (%%0%%)"
		cat "$PARENT/out.kernel" | grep "^# " | while read -r comb; do
			t="$(grep "^$comb$" -m1 -A1 "$PARENT/out.target" | sed -n 's|^dl/||p' | sed 's|-freetz-.*||')"
			k="$(grep "^$comb$" -m1 -A1 "$PARENT/out.kernel" | sed -n 's|^dl/||p' | sed 's|-freetz-.*||')"
			echo "@ $k @ $t @"
			echo >> "$TMPFILE.tc.head"
		done | sort
		get_tc_int "Target" "target" "1"
		get_tc_int "Kernel" "kernel" "2"
		rm -f "$PARENT"/out.{raw,kernel,target}
	) > "$TMPFILE.tc.body"
	for idx in 0 1 2; do
		sed "s/%%${idx}%%/$(cat "$TMPFILE.tc.head${idx/0}" | wc -l | tr -d '\n')/g" -i "$TMPFILE.tc.body"
	done
}


main() {

	echo "# Statistiken rund um Freetz-NG"
	echo

	echo "firmware" >&2
	get_fw
	spoiler_head "$TMPFILE.fw.head" "verschiedene FRITZ!OS"
	spoiler_body "$TMPFILE.fw.body"
	rm -f "$TMPFILE.fw."*

	echo "hardware" >&2
	get_hw
	spoiler_head "$TMPFILE.hw.head" "verschiedene Geräte"
	spoiler_body "$TMPFILE.hw.body"
	rm -f "$TMPFILE.hw."*

	echo "image" >&2
	get_dl
	spoiler_head "$TMPFILE.dl.head" "verschiedene Images"
	spoiler_body "$TMPFILE.dl.body"
	rm -f "$TMPFILE.dl."*

	echo "layout" >&2
	get_lg
	spoiler_head "$TMPFILE.lg.head" "verschiedene Layouts"
	spoiler_body "$TMPFILE.lg.body"
	rm -f "$TMPFILE.lg."*

	echo "toolchain" >&2
	get_tc
	spoiler_head "$TMPFILE.tc.head" "verschiedene Toolchains"
	spoiler_body "$TMPFILE.tc.body"
	rm -f "$TMPFILE.tc."*

}

main > "$OUTFILE"
exit 0

