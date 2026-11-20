[ "$FREETZ_CUSTOM_ETCSERVICES" == "y" ] || return 0
echo1 "customizing etc/services"

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/services

avm-contfiltd	82/tcp
avm-telefon1	1011/tcp
avm-telefon2	1012/tcp
avm-rtp		7077/udp	# Telefonie RTCP
avm-usermand	8080/tcp
kids-locked	8182/tcp	# Kindersicherung
avm-update	8183/tcp	# Updatehinweis
kids-ticket	8184/tcp	# Ticketeingabe
guest-nag	8185/tcp	# Gasthinweise
guest-login	8186/tcp	# Gastanmeldung
avm-telefon3	8888/tcp
avm-upnp	49000/udp	# Universal Plug and Play
avm-mesh	53805/udp	# Mesh Discovery

freetz		81/tcp
nhipt		83/tcp
wol		84/tcp
digitemp	85/tcp
rrdstats	86/tcp
vnstat		87/tcp
lcd4linux	89/tcp
aha		90/tcp
rudi		91/tcp
stunnel		4433/tcp
pyload-remote	7227/tcp
pyload-webif	8000/tcp
lighttpd	8008/tcp
privoxy		8118/tcp
tor		9050/tcp
xmail		10025/tcp

EOF

