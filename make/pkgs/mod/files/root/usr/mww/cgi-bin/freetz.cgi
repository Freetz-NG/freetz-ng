#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz

false && \
  (svn log --quiet | grep '^r' | sed -rn 's/^r[^|]*.([^|]*).*/\1/p' ; echo -e 'Er4twXz\nMcBane87\nTobjasR\nL3P3\nhermann72pb\njohnbock\nM66B\nmagenbrot\nreiffert\nsf3978') \
  | sed 's/(.*)//g;s/ //g' | sort -u | grep -vE '^(root|administrator|github-actions|github-actions\[bot\]|dependabot\[bot\]|fda77|oliver|derheimi|sfritz|SvenLuebke)$' \
  | sed -r 's/([äöüÄÜÖ])/\&\1uml\;/g;y/äöüÄÖÜ/aouAOU/;s/\ß/\&szlig\;/g'

cgi_begin "$(lang de:"&Uuml;ber" en:"About")"
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<p>
<h1>$(lang de:"Unterst&uuml;tzer" en:"Supporters")</h1>
abraXxl
aholler
AldoB.
Alex
asmcc
berndy2001
Bodenseematze
BojanSofronievski
BoxenLuther
buehmann
BugReporter-ilKY
cawidtu
ChihabDjaidja
cinereous
cm8
Conan179
cuma
dionysius
Dirk
e6e7e8
EnricoGhera
er13
Er4twXz
f-666
feedzapper
fesc2000
fidelio-dev
flosch-dev
forenuser
FriederBluemle
GlennStrauss
Greg57070
GregoryAUZANNEAU
Grische
GulDukat
Hadis
harryboo
HerbertNowak
hermann72pb
Himan2001
hippie2000
horle
id1508
idealist1508
Ircama
JanpieterSollie
JasperMichalke
JBBgameich
Jens
jer194
johnbock
J&ouml;rgBerkel
kamasudo
kriegaex
L3P3
leo22
lherschi
LizenzFass78851
M66B
magenbrot
ManfredMueller
Marcel
markuschen
MartenRingwelski
martinkoehler
Maurits
MaxBuchholz
MaxMuster
maz
McBane87
McNetic
michael0815000
MichaelHeimpold
mickey
mike
milahu
MilanHauth
M.Koehler
mrtnmtth
Oliver
openfnord
PeterFichtner
PeterKowalsky
PeterMeiser
PeterPawn
Rainer
ralf
ralfhartmann
reiffert
RolfLeggewie
SaMMy-lacht
SebastianErtz
sf3978
sfritz2
smischke
stblassitude
SvenL&uuml;bke
telsch
thiloms
TobjasR
uwes-ufo
Whoopie
WileC
wmhdhm
</p>

</center>
EOF
cgi_end

