[ "$FREETZ_CUSTOM_ETCSERVICES" == "y" ] || return 0
echo1 "customizing etc/services"

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/services

avm-contfiltd	82/tcp		# Kindersicherung Internetseitenfilter
avm-tel-atif	1011/tcp	# Telefonie AT-Interface
avm-tel-moni	1012/tcp	# Telefonie Anrufmonitor
avm-aura	2066/tcp	# USB-Fernanschluss
ipsec-natt	4500/udp	# IPsec NAT-T
avm-iperf	4711/tcp	# Iperf-Server
avm-iperf	4711/udp	# Iperf-Server
avm-iperf-bidi	4712/udp	# Bidirektionaler Iperf-UDP-Test
avm-capi	5031/tcp	# CAPI over TCP
avm-capi	5031/udp	# CAPI
avm-rtp		7077/udp	# Telefonie RTP/RTCP
avm-usermand	8080/tcp	# Kindersicherung Zugangssteuerung
avm-tr069	8089/tcp	# TR-069 Connection Request
kids-blocked	8181/tcp	# Kindersicherung Internetseite gesperrt
kids-locked	8182/tcp	# Kindersicherung Internetzugang gesperrt
avm-update	8183/tcp	# Updatehinweis
kids-ticket	8184/tcp	# Kindersicherung Ticketeingabe
guest-nag	8185/tcp	# Gast Hinweise
guest-login	8186/tcp	# Gast Anmeldung
avm-telefon	8888/tcp	# Telefonie (prähistorisch)
avm-upnp	49000/tcp	# Universal Plug and Play
avm-mediaserver	49200/tcp	# Mediaserver HTTP AVM
avm-media-1und1	49300/tcp	# Mediaserver HTTP 1&1
avm-media-tkom	49400/tcp	# Mediaserver HTTP Telekom
avm-tr064-ssl	49443/tcp	# TR-064 HTTPS
avm-dtrace	51111/tcp	# DECT-Diagnose
avm-dtrace-log	51112/tcp	# DECT-Debugausgabe
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
tinyproxy	92/tcp
nhipt		93/tcp
stunnel		4433/tcp
pyload-remote	7227/tcp
pyload-webif	8000/tcp
lighttpd	8008/tcp
privoxy		8118/tcp
tor		9050/tcp
xmail		10025/tcp

EOF

