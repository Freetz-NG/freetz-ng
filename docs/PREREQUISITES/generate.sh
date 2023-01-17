#!/bin/bash
# generates docs/PREREQUISITES/README.md
MDPWD="$(dirname $(realpath $0))"
LIMIT=80

cat "$MDPWD/template.md" > "$MDPWD/README.md"
for x in "$MDPWD/packages/"*; do
	sort -u -o "$x" "$x"
	vals="\\\\\n "
	c=0
	for v in $(sed 's/[\t ]*#.*//g' "$x" | sort | tr '\n' ' '); do
		c=$(( ${c} + ${#v} ))
		[ $c -gt $LIMIT ] && c=0 && vals="$vals \\\\\n "
		vals="$vals $v"
	done
	sed -i "s!%%${x##*/}%%!${vals% }!" "$MDPWD/README.md"
done

