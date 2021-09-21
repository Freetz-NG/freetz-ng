#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz

# (svn log --quiet | sed -rn 's/^r[^|]*.([^|]*).*/\1/p' ; echo -e 'hermann72pb\njohnbock\nM66B\nmagenbrot\nreiffert\nsf3978') | sort -u | sed 's/ //g' | grep -vE '^(root|administrator|fda77|oliver|sfritz)$'
cgi_begin "$(lang de:"&Uuml;ber" en:"About")"
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<p>
<h1>Supporters</h1>
abraXxl
aholler
Alex
berndy2001
buehmann
BugReporter-ilKY
cawidtu
cinereous
cm8
Conan179
cuma
derheimi
Dirk
er13
f-666
feedzapper
fidelio-dev
flosch-dev
forenuser
friederbluemle
Greg57070
GregoryAUZANNEAU
Hadis
harryboo
hermann72pb
hippie2000
horle
id1508
idealist1508
JasperMichalke
JBBgameich
johnbock
kriegaex
leo22
M66B
magenbrot
Marcel
markuschen
martinkoehler
Maurits
MaxMuster
maz
McNetic
mickey
mike
mrtnmtth
Oliver
PeterPawn
ralf
reiffert
RolfLeggewie
sf3978
sfritz2
smischke
stblassitude
telsch
thiloms
Whoopie
WileC
</p>

</center>
EOF
cgi_end
