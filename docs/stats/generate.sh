#! /usr/bin/env bash
# generates docs/stats/README.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname $(dirname ${SCRIPT%/*}))"
OUTFILE="$PARENT/docs/stats/README.md"
TMPFILE="$PARENT/.stats"
rm -f "$TMPFILE"*
 

empty_line() {
#	echo '| <!-- --> | <!-- --> |'
	echo '| &nbsp; | &nbsp; |'
}

table_head() {
	empty_line
	echo '|----------|----------|'
}

spoiler_head() {
	echo '<br>'
	echo
	echo '<details>'
	echo -n '  <summary>'
	echo -n "$(cat "$1" | wc -l  | tr -d '\n') $2"
	echo '</summary>'
	echo
}

spoiler_foot() {
	cat "$1"
	echo
	echo '</details>'
	echo
}

get_fw() {
	area='Firmware version'
	file="config/ui/firmware.in"
	(
		table_head
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(config|bool) " | while read -r line; do
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n' | sed 's/^[^\t ]*[ \t]*/| /g;s/$/ | /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"              | sed 's/^[^\t ]*[ \t]*"//g;s/"/ |/g' && echo >> "$TMPFILE.fw.head"
		done | sed 's/ - [^ ]*//g' | grep -Evi "(inhaus|labor|plus)"
	) > "$TMPFILE.fw.body"
}

get_hw() {
	area='Hardware type'
	file="config/ui/firmware.in"
	(
		table_head
		cat "$file" | grep "prompt \"${area}\"" -m1 -A9999 | grep "^endchoice" -m1 -B9999 | sed 's/^[ \t]*//g' | grep -E "^(comment|config|bool) " | while read -r line; do
			[ "${line#comment}" != "$line" ] && empty_line && echo "$line" | sed 's/^[^\t ]*[ \t]*"/| xx/g;s/"/xx | \&nbsp; |/g'
			[ "${line#config}"  != "$line" ] && echo "$line" | tr -d '\n' | sed 's/^[^\t ]*[ \t]*/| /g;s/$/ | /g'
			[ "${line#bool}"    != "$line" ] && echo "$line"              | sed 's/^[^\t ]*[ \t]*"//g;s/"/ |/g' && echo >> "$TMPFILE.hw.head"
		done | sed 's/ - [^ ]*//g' | grep -Evi "(inhaus|labor|plus)"
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


