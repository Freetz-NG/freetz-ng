#! /usr/bin/env bash
# generates docs/stats/README.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname $(dirname ${SCRIPT%/*}))"
OUTFILE="$PARENT/docs/stats/README.md"
TMPFILE="$PARENT/.stats"
rm -f "$TMPFILE".??.*

SPACE='&nbsp;'

empty_line() {
	echo "<tr><td>${1:-$SPACE}</td><td>${2:-$SPACE}</td></tr>"
}

table_head() {
	echo "<table>"
	echo "<thead><tr><th>$1</th><th>$2</th></tr></thead>"
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

spoiler_foot() {
	cat "$1" | sed 's/|/\\|/g' | sed -r 's, *@ (.*) @ (.*) @,<tr><td>\2</td><td>\1</td></tr>,g'
	echo "</details>"
	echo
}

get_fw() {
	area='Firmware version'
	file="config/ui/firmware.in"
	(
		table_head "Symbol" "Version"
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(config|bool) " | while read -r line; do
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'  | sed 's/^[^\t ]*[ \t]*/@ /g;s/$/ @ /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"               | sed 's/^[^\t ]*[ \t]*"//g;s/"/ @/g' && echo >> "$TMPFILE.fw.head"
		done | sed 's/ - [^ ]*//g' | grep -Evi "(inhaus|labor|plus)"
		table_foot
	) > "$TMPFILE.fw.body"
}

get_hw() {
	area='Hardware type'
	file="config/ui/firmware.in"
	(
		table_head "Symbol" "Name"
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(comment|config|bool) " | while read -r line; do
			[ "${line#comment}" != "$line" ] && empty_line "<strong>$(echo "$line"  | sed 's/^[^\t ]*[ \t]*"//;s/".*//')</strong>" "&nbsp;"
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'           | sed 's/^[^\t ]*[ \t]*/@ /g;s/$/ @ /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"                        | sed 's/^[^\t ]*[ \t]*"//g;s/"/ @/g' && echo >> "$TMPFILE.hw.head"
		done | sed 's/ - [^ ]*//g'
		table_foot
	) > "$TMPFILE.hw.body"
}

get_dl() {
	area='Firmware source'
	file="config/mod/dl-firmware.in"
	(
		table_head "Symbole" "Datei(/AVM)"
		cat "$file" | grep "string \"${area}\"" -m1 -A9999 | grep "^config " -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(default) " | while read -r line; do
			echo "$line" | tr -s ' ' | sed -r 's/.*"(.*)".* if (.*)/@ \2 @ \1 @/g' && echo >> "$TMPFILE.dl.head"
		done | sed -r 's/_(inhaus|labor|plus)//gI' | grep -v "DETECT_IMAGE_NAME"
		table_foot
	) > "$TMPFILE.dl.body"
}

main() {

	# head
	echo "<h1>Statistiken rund um Freetz-NG</h1>"
	echo

	# firmware
	get_fw
	spoiler_head "$TMPFILE.fw.head" "verschiedene FRITZ!OS"
	spoiler_foot "$TMPFILE.fw.body"
	rm -f "$TMPFILE.fw."*

	# hardware
	get_hw
	spoiler_head "$TMPFILE.hw.head" "verschiedene Geräte"
	spoiler_foot "$TMPFILE.hw.body"
	rm -f "$TMPFILE.hw."*

	# image
	get_dl
	spoiler_head "$TMPFILE.dl.head" "verschiedene Images"
	spoiler_foot "$TMPFILE.dl.body"
	rm -f "$TMPFILE.dl."*

}

main > "$OUTFILE"
