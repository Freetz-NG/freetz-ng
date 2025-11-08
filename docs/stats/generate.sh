#! /usr/bin/env bash
# generates docs/stats/README.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname $(dirname ${SCRIPT%/*}))"
OUTFILE="$PARENT/docs/stats/README.md"
TMPFILE="$PARENT/.stats"
rm -f "$TMPFILE"*


SPACE='<!-- -->'

empty_line() {
	echo "| ${1:-$SPACE} | ${2:-$SPACE} |"
}

table_head() {
	empty_line "$1" "$2"
	echo '| --- | --- |'
}

spoiler_head() {
#	echo '<details markdown>'
#	echo "  <summary>$(cat "$1" | wc -l | tr -d '\n') $2</summary>"
	echo "??? tip \"$(cat "$1" | wc -l | tr -d '\n') $2\""
	echo
}

spoiler_foot() {
	cat "$1" |  sed -r 's, *\| (.*) \| (.*) \|,    | \2 | \1 |,g'
#	cat "$1" |  sed -r 's, *\| (.*) \| (.*) \|,| \2 | \1 |,g'
#	echo
#	echo '</details>'
	echo
}

get_fw() {
	area='Firmware version'
	file="config/ui/firmware.in"
	(
		table_head "Symbol" "Version"
		empty_line
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(config|bool) " | while read -r line; do
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'  | sed 's/^[^\t ]*[ \t]*/| /g;s/$/ | /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"               | sed 's/^[^\t ]*[ \t]*"//g;s/"/ |/g' && echo > "$TMPFILE.fw.head"
		done | sed 's/ - [^ ]*//g' | grep -Evi "(inhaus|labor|plus)"
	) > "$TMPFILE.fw.body"
}

get_hw() {
	area='Hardware type'
	file="config/ui/firmware.in"
	(
		table_head "Symbol" "Name"
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(comment|config|bool) " | while read -r line; do
			[ "${line#comment}" != "$line" ] && empty_line && echo "$line" | sed "s/^[^\t ]*[ \t]*\"/| $SPACE | **/g;s/\"/** |/g"
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n'  | sed 's/^[^\t ]*[ \t]*/| /g;s/$/ | /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"               | sed 's/^[^\t ]*[ \t]*"//g;s/"/ |/g' && echo > "$TMPFILE.hw.head"
		done | sed 's/ - [^ ]*//g'
	) > "$TMPFILE.hw.body"
}

main() {

	# head
	echo '# Statistiken rund um Freetz-NG'
	echo

	# firmware
	get_fw
	spoiler_head "$TMPFILE.fw.head" "verschieden FRITZ!OS"
	spoiler_foot "$TMPFILE.fw.body"
	rm -f "$TMPFILE.fw."*

	# hardware
	get_hw
	spoiler_head "$TMPFILE.hw.head" "verschieden Geräte"
	spoiler_foot "$TMPFILE.hw.body"
	rm -f "$TMPFILE.hw."*

}
main > "$OUTFILE"


