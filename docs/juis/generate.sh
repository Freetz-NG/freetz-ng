#! /usr/bin/env bash
# generates docs/juis/README.md
SCRIPT="$(readlink -f $0)"
PARENT="$(dirname $(dirname ${SCRIPT%/*}))"
TOOLS="$PARENT/tools"
CACHE="/tmp/.freetz-juis"
CRAP_FILTER="5382169925"


#crc32
[ -e "$TOOLS/crc32" ] && CRC32="$TOOLS/crc32" || CRC32="$(which crc32)"
[ -e "$TOOLS/xxd"   ] && XXD="$TOOLS/xxd"     || XXD="$(which xxd)"
[ ! -x "$CRC32" -o ! -x "$XXD" ] && echo "You have to install 'crc32' and 'xxd' or run 'make tools' first." && exit 1

#rel
echo -e '\n### FOS-Release ################################################'
for x in $(seq 150 333); do  env - $TOOLS/juis_check        HW=$x                                     -a; done | tee fos-rel
#dwn
echo -e '\n### FOS-Downgrade ##############################################'
for x in $(seq 150 333); do  env - $TOOLS/juis_check --down HW=$x                                     -a; done | tee fos-dwn
#add
cat fos-dwn fos-rel | sort -u > fos-xxx
#( cat fos-rel ; cat fos-dwn | while read -s x; do grep -q "^${x%=*}=" fos-rel || echo $x; done ) | sort -u > fos-xxx
#( cat fos-dwn ; cat fos-rel | while read -s x; do grep -q "^${x%=*}=" fos-dwn || echo $x; done ) | sort -u > fos-xxx

#lab
echo -e '\n### FOS-Labor ##################################################'
for x in $(seq 222 333); do  [ "$x" -lt 248 ] 2>/dev/null && m="$(( $x - 72 ))" || m=$x; m="$m.07.50-100000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1001  Version=$m  -a; done | tee fos-lab
for x in $(seq 222 333); do  [ "$x" -lt 248 ] 2>/dev/null && m="$(( $x - 72 ))" || m=$x; m="$m.07.90-111000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1001  Version=$m  -a; done | tee fos-lab -a
for x in $(seq 222 333); do  [ "$x" -lt 248 ] 2>/dev/null && m="$(( $x - 72 ))" || m=$x; m="$m.08.00-115000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1001  Version=$m  -a; done | tee fos-lab -a
#inh
echo -e '\n### FOS-Inhaus #################################################'
for x in $(seq 222 333); do  [ "$x" -lt 248 ] 2>/dev/null && m="$(( $x - 72 ))" || m=$x; m="$m.07.50-100000"
                             env - $TOOLS/juis_check        HW=$x         Buildtype=1000  Version=$m  -a; done | tee fos-inh
#sub
cat fos-xxx | while read -s x; do sed "/^${x//\//\\\/}$/d" -i fos-lab fos-inh; done
#cat fos-xxx | while read -s x; do sed "/\/${x##*/}$/d" -i fos-lab fos-inh; done


#dect-rel
echo -e '\n### Dect-Release ###############################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";
                             env - $TOOLS/juis_check --dect HW=154 DHW=$x                             -a; done | tee dect-rel
#dect-lab
echo -e '\n### Dect-Labor #################################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="226.08.00-115000"
                             env - $TOOLS/juis_check --dect HW=154 DHW=$x Buildtype=1000  Version=$m  -a; done | tee dect-lab
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="226.07.50-100000"
                             env - $TOOLS/juis_check --dect HW=154 DHW=$x Buildtype=1000  Version=$m  -a; done | tee dect-lab -a
#dect-inh
echo -e '\n### Dect-Inhaus ################################################'
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="226.08.00-115000"
                             env - $TOOLS/juis_check --dect HW=154 DHW=$x Buildtype=1001  Version=$m  -a; done | tee dect-inh
for x in $(seq  10 109); do [ ${#x} != 3 ] && x="0$x"; x="${x::-1}.0${x:2}";             m="226.07.50-100000"
                             env - $TOOLS/juis_check --dect HW=154 DHW=$x Buildtype=1001  Version=$m  -a; done | tee dect-inh -a
#dect-sub
cat dect-rel | while read -s x; do sed "/\/${x##*/}$/d" -i dect-lab dect-inh; done
cat dect-lab | while read -s x; do sed "/\/${x##*/}$/d" -i          dect-inh; done


#bpjm
echo -e '\n### BPjM #######################################################'
                             env - $TOOLS/juis_check --bpjm HW=259                                    -a       | tee bpjm
[ ! -s bpjm ] || curl -sS "$(sed -n 's/.*=//p' bpjm)" -o bpjm.out
read="$(head -c4 bpjm.out | $XXD -p)"
calc="$($CRC32 <( tail -c +$((1 + 4)) bpjm.out ))"
[ "$read" != "${calc%% *}" ] && comp="mismatch $read/$calc" || comp="$read"
sed -i "s/.*=/$comp=/" bpjm


#cache
TEMPS="$(mktemp -d)"
OLD="$TEMPS/old"
NEW="$TEMPS/new"
mkdir -p "$CACHE" "$OLD" "$NEW"
for x in fos-xxx fos-rel fos-dwn fos-lab fos-inh  dect-rel dect-lab dect-inh; do
	cat "$CACHE/$x" > "$OLD/$x" 2>/dev/null
	cat        "$x" > "$NEW/$x" 2>/dev/null
	for hw in $(sort -u "$OLD/$x" "$NEW/$x" | sed -n 's/=.*/=/p' | uniq); do
		sort -u "$OLD/$x" "$NEW/$x" | grep "^$hw" | grep -vE "$CRAP_FILTER" | tail -n1
	done > "$CACHE/$x"
	ln -s -f "$CACHE/$x" $x
done
rm -rf "$TEMPS"


#duplicates
cat fos-xxx  | while read -s x; do sed "/^${x////\\/}$/d" -i fos-inh  fos-lab  ; done
cat fos-lab  | while read -s x; do sed "/^${x////\\/}$/d" -i fos-inh           ; done
cat dect-rel | while read -s x; do sed "/^${x////\\/}$/d" -i dect-inh dect-lab ; done
cat dect-lab | while read -s x; do sed "/^${x////\\/}$/d" -i dect-inh          ; done


#gen
(
echo -e '[//]: # ( Do not edit this file! Run generate.sh to create it. )'
echo -n "Content: "
echo -e "FOS-Release\nFOS-Labor\nFOS-Inhaus\nDect-Release\nDect-Labor\nDect-Inhaus\nBPjM" \
  | while read cat; do echo -n "[$cat](#$(echo ${cat,,} | sed 's/ /-/g')) - "; done | sed 's/...$//'
echo
echo -e '# Links von AVM-Juis für FOS ab HWR 150 sowie Dect und BPjM'
echo -e '  - AVM nutzt unsichere http:// Links, daher muss die Signatur der Dateien vor Verwendung geprüft werden.'
echo -e '  - Sollten verschieden Links für ein Gerät angezeigt werden sind die Angaben von Juis inkonsistent.'
echo -e '  - Labor machen mit personenbezogenen Daten ganz tolle Dinge denen man zuerst elektronisch zustimmen muss.'
echo -e '  - Inhaus sind dazu so etwas besonderes dass sie ausserhalb von AVM nicht verwendet werden sollten.'
echo -e '  - Außerdem werden hier alle Links zu AVM verstümmelt um AVMs Privatsphäre und so zu wahren.'
echo -e '  - Diese Liste ist weder vollständig, korrekt noch aktuell.'
echo -e '\n### FOS-Release'  ; cat fos-xxx  | while read -s x; do echo "  - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### FOS-Labor'    ; cat fos-lab  | while read -s x; do echo "  - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### FOS-Inhaus'   ; cat fos-inh  | while read -s x; do echo "  - HWR ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Release' ; cat dect-rel | while read -s x; do echo "  - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Labor'   ; cat dect-lab | while read -s x; do echo "  - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### Dect-Inhaus'  ; cat dect-inh | while read -s x; do echo "  - MHW ${x%=*}: [${x##*/}](${x#*=})"; done
echo -e '\n### BPjM'         ; cat bpjm     | while read -s x; do echo "  - CRC ${x%=*}: [${x##*/}](${x#*=})"; done
) | sed 's/_-/-/' > $PARENT/docs/juis/README.md

#tmp
rm -f fos-xxx fos-rel fos-dwn fos-lab fos-inh  dect-rel dect-lab dect-inh  bpjm bpjm.out

