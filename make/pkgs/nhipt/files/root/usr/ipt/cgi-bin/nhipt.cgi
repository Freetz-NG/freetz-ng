#!/bin/sh

post_string=""
# rc.nhipt also sources this script for local configuration.
if [ "$NHIPT_CONFIG" != "box" ] && [ -n "$REQUEST_METHOD" ]; then
	_CGI_CSRF_SCOPE=nhipt
	. /usr/lib/libmodcgi.sh
	if [ "$REQUEST_METHOD" = "POST" ]; then
		# The CSRF check may already have consumed stdin; replay its body.
		csrf_check__read_post
		post_string=$(cat "$_CGI_POST_FILE")
	fi
fi
for INPUT_INTERFACE in $(ifconfig | grep ^[a-z] | cut -f1 -d ' '); do
	x=$x+"$INPUT_INTERFACE"
done
lanip="$(ifconfig | grep -v lan:0 | grep -A 2 lan | awk -F'[ :]+' '/inet addr/{print $4}')"
###POSTBACK INTERFACE
# GET/HEAD only render the interface, including legacy action URLs.
if [ "$REQUEST_METHOD" = "POST" ] || [ "$NHIPT_CONFIG" = "box" ]; then

# Ermitteln der Log Datei vom syslogd:
	logfile="$(ps | grep -v "grep" | grep -e "syslogd" | awk '{i=1; while (i<=20){ if ($i == "-O"){ print $(i+1)}; i++;}}')"

# awk Error Lines + 20 = Real Line
	(awk -v SYSLOGDFILE="$logfile" -v IFCS="$x" -v PSTR="$post_string" -v QSTR="$QUERY_STRING" -v LANIP="$lanip" 'BEGIN {
		myIP = ENVIRON["REMOTE_ADDR"];
		changed = 0; 		# FW CONFIGURATION CHANGED
		dirchanged = 0; 	# DIRECTORIES CHANGED
		cfgchanged = 0; 	# CONFIGURATION SETTINGS CHANGED
		flashmodified =0; 	# WRITE TO FLASH NECESSARY
		noloadmodules =0;	# PREVENT MODULE CHANGES ON EXTERNAL CONFIG
		logtarget=0;
		loadSettings();
		if (ENVIRON["NHIPT_CONFIG"] == "box") {dirchanged=1; cfgchanged=1; login=1}
		RCOD=myConf["ADMINIP"];
		Boot=myConf["BOOT"]; Bootstrap=myConf["BOOTSTRAP"];
		if (Boot=="flash"){BootTarget="/tmp/flash/";}
		if (Boot=="usb"){if (myConf["BOOTDIR"] == ""){BootTarget=myConf["ROOT"] "/";} else {BootTarget=myConf["BOOTDIR"] "/";}}
		BootTargetOld = BootTarget;
		gsub(/ /,"",RCOD);
		if (RCOD > ""){
			i = split(RCOD,ipadr,"/");
			if (i > 1) {ip = ipadr[1]; mask=ipadr[2];} else {ip = ipadr[1]; mask="255.255.255.255";}
			if (index(mask,".") == 0) {
				sm = "";
				ma[8]=255; ma[7]=127; ma[6]=63; ma[5]=31;
				ma[4]=15; ma[3]=7; ma[2]=3; ma[1]=1; ma[0]=0;
				for (i=1;i<=4;i++){if (mask >=8) {sm = sm "255.";mask=mask-8;} else {sm = sm ma[mask] ".";mask=0;}}
				mask=sm;
			}
			split(myIP,mpar,".");	split(ip,ipar,"."); split(mask,maskar,".");
			if ((and(mpar[1],maskar[1]) == and(ipar[1],maskar[1])) && (and(mpar[2],maskar[2]) == and(ipar[2],maskar[2])) && (and(mpar[3],maskar[3]) == and(ipar[3],maskar[3])) && (and(mpar[4],maskar[4]) == and(ipar[4],maskar[4]))) { login=1} else {login=0}
		} else { login = 1;}
		if (login==1) {
			if(myConf["LOGTARGET"] == "syslog"){ logtarget = 1; } else { logtarget = 0; }
			if (ENVIRON["REQUEST_METHOD"] == "POST" || ENVIRON["NHIPT_CONFIG"] == "box") {
				readParams(PSTR);
				if (ENVIRON["NHIPT_CONFIG"] == "box") {
					delete Param;
					Param["AIRBAG"] = myConf["AIRBAG"]
					Param["BACDIR"] = ENVIRON["NHIPT_BACK"]
					Param["LOGDIR"] = ENVIRON["NHIPT_LOGD"]
					Param["PORT"] = ENVIRON["NHIPT_PORT"]
					Param["ROOT"] = ENVIRON["NHIPT_ROOT"]
					Param["SERVERIP"] = ENVIRON["NHIPT_SERVERIP"]
					Param["ADMIP"] = ENVIRON["NHIPT_ADMINIP"]
					Param["LOGTO"] = ENVIRON["NHIPT_LOGTARGET"]
					Param["BOOT"] = ENVIRON["NHIPT_BOOT"]
					Param["DELAY"] = ENVIRON["NHIPT_DELAY"]
					Param["DSLDOFF"] = ENVIRON["NHIPT_DSLDOFF"]
					Param["BOOTDIR"] = ENVIRON["NHIPT_BOOTDIR"]
					Param["BOOTSTRAP"] = ENVIRON["NHIPT_BOOTSTRAP"]
					Param["SESAV"] = "save"
					Param["SETIP"] = "set"
					myConf["PORT"] = Param["PORT"]
					if (ENVIRON["NHIPT_START_LOG"] == "start") {Param["STRTLOG"] = "start";}
					noloadmodules=1;
				}
				validateParams();
				if (Param["IPV6"] == 1){myCmdPrefix = "ip6";} else {myCmdPrefix = "ip";}
				table	   = Param["TABLE"];
				targetSet  = 0;
				if (Param["CUTSYSLOG"] > ""){ret = system("> " myConf["LOGD"] "/system.log"); myCmd = "syslog truncated";}
				if (Param["CUTFWLOG"] > "") {ret = system("> " myConf["LOGD"] "/fw.log"); myCmd = "firewall log truncated";}
				if (Param["SAVSYSLOG"] > ""){ret = system("mv " myConf["LOGD"] "/system.log " myConf["LOGD"] "/\"$(date +\"%Y-%m-%d-%H-%M-%S\")\"-system.log"); myCmd = "syslog saved";}
				if (Param["SAVFWLOG"] > "") {ret = system("mv " myConf["LOGD"] "/fw.log " myConf["LOGD"] "/\"$(date +\"%Y-%m-%d-%H-%M-%S\")\"-fw.log" ); myCmd = "firewall log saved";}
				if (Param["PERSIST"] > "")	{ret = persist("all"); myCmd = "Rules & services written to " BootTarget "nhipt.cfg\nold nhipt.cfg saved in " myConf["BACK"];}
				if (Param["STRTLOG"] > "")	{ret = startLogging(); myCmd = "Logging started...";}
				if (Param["STOPLOG"] > "")	{ret = stopLogging(); myCmd = "Logging stopped";}
				if (Param["GETSTAT"] > "")	{checkConfig(); hs["0"] = "...PASSED"; hs["1"] = "...FAILED!"; hs["2"] = "...NOT SAVED!"; for (x in check){ print "STATUS_" x "=" hs[check[x]]; ret += check[x];} myCmd = "Installation Status";}
				if (logtarget == 1) {
					# Use System Log
					if (SYSLOGDFILE > "") {
						if (Param["GETFWLOG"] > "")	{myCmd = "grep 'SRC=' " SYSLOGDFILE ".2 " SYSLOGDFILE ".1 " SYSLOGDFILE ".0 " SYSLOGDFILE " | tail -n 50"; ret = system(myCmd);}
						if (Param["GETSYSLOG"] > ""){myCmd = "grep -v -E \"DECT|DCT|dect|SRC=\" " SYSLOGDFILE ".2 " SYSLOGDFILE ".1 " SYSLOGDFILE ".0 " SYSLOGDFILE " | tail -n 50"; ret = system(myCmd);}
					}
				} else {
					if (Param["GETSYSLOG"] > "")	{myCmd = "tail -n 50 " myConf["LOGD"] "/system.log"; ret = system(myCmd);}
					if (Param["GETFWLOG"] > "")	{myCmd = "tail -n 50 " myConf["LOGD"] "/fw.log"; ret = system(myCmd);}
				}
#				if (Param["GETFWLOG"] > "")	{myCmd = "tail -n 50 " myConf["LOGD"] "/fw.log"; ret = system(myCmd);}
#				if (Param["GETSYSLOG"] > "")	{myCmd = "tail -n 50 " myConf["LOGD"] "/system.log"; ret = system(myCmd);}
				if (Param["SESAV"] > "")	{
					if (Param["DSLDOFF"] == "") {Param["DSLDOFF"] = 0;}
					if (myConf["BOOT"] != Param["BOOT"] ||  myConf["BACK"] != Param["BACDIR"] || Param["ROOT"] > "" || Param["BOOTSTRAP"] > "" || myConf["LOGD"] != Param["LOGDIR"] || myConf["BOOTDIR"] != Param["BOOTDIR"]){dirchanged=1; myCmd = "Saving Settings to " BootTarget "nhipt.par...";	myConf["BOOT"] = Param["BOOT"];  myConf["BACK"] = Param["BACDIR"]; myConf["LOGD"] = Param["LOGDIR"]; if (myConf["BOOTDIR"] != Param["BOOTDIR"]) {myConf["BOOTDIR"] = Param["BOOTDIR"]; Boot="newdir";} if (myConf["ROOT"] != Param["ROOT"] && Param["ROOT"] > "") {myConf["ROOT"] = Param["ROOT"];} if (myConf["BOOTSTRAP"] != Param["BOOTSTRAP"] && Param["BOOTSTRAP"] > "") {myConf["BOOTSTRAP"] = Param["BOOTSTRAP"];}}
					if (myConf["AIRBAG"] != Param["AIRBAG"]) { cfgchanged=1; if (Param["AIRBAG"] == "1") { ret = startAirbag(); myCmd = "Fasten your Seatbelts..."; } else {ret = stopAirbag(); myCmd = "You are now a big boy...";}}
					if (myConf["DELAY"] != Param["DELAY"] || myConf["DSLDOFF"] != Param["DSLDOFF"]){ cfgchanged=1; myCmd = "Changing Delay Settings for " BootTarget "nhipt.par..."; myConf["DELAY"] = Param["DELAY"]; myConf["DSLDOFF"] = Param["DSLDOFF"];}
					if (myConf["LOGTARGET"] != Param["LOGTO"]) { cfgchanged=1; if(myConf["LOGTARGET"] == "syslog"){ logtarget = 1; } else { logtarget = 0; stopLogging();}; myConf["LOGTARGET"] = Param["LOGTO"]; }
					ret = loadModules();
					ret = persist("settings");}
				if (Param["SETIP"] == "set")    {cfgchanged=1; myCmd = ""; myConf["ADMINIP"] = Param["ADMIP"]; persist("settings");}
				if (Param["EXEC"] == "execute") {myCmd = expertCommand(Param["EXPERT"]);  	ret = system(myCmd);  if (ret==0){changed=1;}; }
				if (Param["MODE"] == "New")     {myCmd = myCmdPrefix "tables -t " table " -N " Param["CHAIN"];	ret = system(myCmd);  if (ret==0){changed=1;}}
				if (Param["DOIT"] == "Insert")  {myCmd = "";
					iprange    = "-m iprange ";
					multiport  = "-m multiport ";
					state      = "-m state ";
					esp		   = "-m esp ";
					ah		   = "-m ah ";
					comment	   = "-m comment ";
					gsub(/ /,"",Param["S"]); gsub(/ /,"",Param["D"]);      gsub(/ /,"",Param["I"]);     gsub(/ /,"",Param["O"]);
					gsub(/ /,"",Param["P"]); gsub(/ /,"",Param["MODULE"]); gsub(/ /,"",Param["SPORT"]); gsub(/ /,"",Param["DPORT"]);
					if (Param["ROW"] == "A") { myCmd = myCmdPrefix "tables -t " table " -A " Param["CHAIN"] " ";} else {myCmd = myCmdPrefix "tables -t " table " -I " Param["CHAIN"] " " Param["ROW"] " ";}
					if (myConf["AIRBAG"] == 1 && Param["ROW"] == 1){myCmd = "### AIRBAG FIRED ###" myCmd;}
					if (index(Param["S"],"!") > 0) { x = "! "; gsub(/!/,"",Param["S"]);} else { x = ""; }
					if (Param["S"] > "" && index(Param["S"],"-") == 0) {myCmd = myCmd "-s " x Param["S"] " ";}
					if (Param["S"] > "" && index(Param["S"],"-") > 0)  {myCmd = myCmd iprange x "--src-range " Param["S"] " "; iprange="";}
					if (index(Param["D"],"!") > 0) { x = "! "; gsub(/!/,"",Param["D"]);} else { x = ""; }
					if (Param["D"] > "" && index(Param["D"],"-") == 0) {myCmd = myCmd "-d " x Param["D"] " ";}
					if (Param["D"] > "" && index(Param["D"],"-") > 0)  {myCmd = myCmd iprange x "--dst-range " Param["D"] " "; iprange="";}
					if (index(Param["I"],"!") > 0) { x = "! "; gsub(/!/,"",Param["I"]);} else { x = ""; }
					if (Param["I"] > "") {myCmd = myCmd "-i " x Param["I"] " ";}
					if (index(Param["O"],"!") > 0) { x = "! "; gsub(/!/,"",Param["O"]);} else { x = ""; }
					if (Param["O"] > "") {myCmd = myCmd "-o " x Param["O"] " ";}
					if (index(Param["P"],"!") > 0) { x = "! "; gsub(/!/,"",Param["P"]);} else { x = ""; }
					if (Param["P"] == "icmp" && Param["EXTRA"] > "") {myCmd = myCmd "-p " x Param["P"] " --icmp-type " shellquote(Param["EXTRA"]) " ";} else if (Param["P"] > "") {myCmd = myCmd "-p " x Param["P"] " ";}

					if (Param["MODULE"] == "state") { myCmd = myCmd state "--state " shellquote(Param["EXTRA"]) " "; state="";}
						else if (Param["MODULE"] == "comment") { system("modprobe ipt_comment"); myCmd = myCmd comment "--comment " shellquote(Param["EXTRA"]) " "; comment="";}
						else if (Param["MODULE"] == "ah") { system("modprobe xt_ah"); myCmd = myCmd ah "--ahspi " shellquote(Param["EXTRA"]) " "; ah="";}
						else if (Param["MODULE"] == "esp") { system("modprobe xt_esp"); myCmd = myCmd esp "--espspi " shellquote(Param["EXTRA"]) " "; esp="";}
					if (index(Param["SPORT"],"!") > 0) { x = "! "; gsub(/!/,"",Param["SPORT"]);} else { x = ""; }
					if (Param["SPORT"] > "" &&  index(Param["SPORT"],",") == 0  && index(Param["SPORT"],":") == 0)  {myCmd = myCmd "--sport " x Param["SPORT"] " ";}
					if (Param["SPORT"] > "" && (index(Param["SPORT"],",") > 0   || index(Param["SPORT"],":") >  0)) {myCmd = myCmd multiport x "--sports " Param["SPORT"] " "; multiport="";}
					if (index(Param["DPORT"],"!") > 0) { x = "! "; gsub(/!/,"",Param["DPORT"]);} else { x = ""; }
					if (Param["DPORT"] > "" &&  index(Param["DPORT"],",") == 0  && index(Param["DPORT"],":") == 0)  {myCmd = myCmd "--dport " x Param["DPORT"] " ";}
					if (Param["DPORT"] > "" && (index(Param["DPORT"],",") > 0   || index(Param["DPORT"],":") >  0)) {myCmd = myCmd multiport x "--dports " Param["DPORT"] " "; multiport="";}
					if (Param["ACTION"] == "LOG" && Param["EXTRA"] >  "") {myCmd = myCmd "-j LOG --log-prefix " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "LOG" && Param["EXTRA"] == "") {myCmd = myCmd "-j LOG --log-prefix \"[IPT] \"";targetSet=1;}
					if (Param["ACTION"] == "LOG" && Param["EXTRA"] == "") {myCmd = myCmd "-j LOG --log-prefix \"[IPT] \"";targetSet=1;}
					if (Param["ACTION"] == "DNAT" && Param["EXTRA"] >  "") {myCmd = myCmd "-j DNAT --to-destination " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "SNAT" && Param["EXTRA"] >  "") {myCmd = myCmd "-j SNAT --to-source " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "MASQUERADE" && Param["EXTRA"] >  "") {system("modprobe ipt_MASQUERADE");myCmd = myCmd "-j MASQUERADE --to-ports " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "CONNMARK" && Param["EXTRA"] >  "") {myCmd = myCmd "-j CONNMARK --set-mark " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "REDIRECT" && Param["EXTRA"] >  "") {system("modprobe ipt_REDIRECT"); myCmd = myCmd "-j REDIRECT --to-ports " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "MARK" && Param["EXTRA"] >  "") {system("modprobe xt_MARK\nmodprobe xt_mark"); myCmd = myCmd "-j MARK --set-mark " shellquote(Param["EXTRA"])  " ";targetSet=1;}
					if (Param["ACTION"] == "NOTRACK") {system("modprobe xt_NOTRACK"); myCmd = myCmd "-j NOTRACK " Param["EXTRA"]  " ";targetSet=1;}
					if (targetSet==0) {myCmd = myCmd "-j " Param["ACTION"];}

					ret = system(myCmd);
					if (ret==0){changed=1;}
				}
			}
			# Links now submit POST; keep their query parameters for the action.
			if (ENVIRON["REQUEST_METHOD"] == "POST" && ENVIRON["NHIPT_CONFIG"] != "box") {
				readParams(QSTR); validateParams();
				table	   = Param["TABLE"];
				if (Param["IPV6"] == 1){myCmdPrefix = "ip6";} else {myCmdPrefix = "ip";}
				if (Param["MODE"] != "UP" || Param["MODE"] != "DN") {
					if (Param["MODE"] == "POL" && Param["POL"] == "DEL")    {myCmd = myCmdPrefix "tables -t " table " -X " Param["CHAIN"];			ret = system(myCmd);if (ret==0){changed=1;}}
					if (Param["MODE"] == "POL" && Param["POL"] == "ACCEPT") {myCmd = myCmdPrefix "tables -t " table " -P " Param["CHAIN"] " ACCEPT"; 	ret = system(myCmd);if (ret==0){changed=1;}}
					if (Param["MODE"] == "POL" && Param["POL"] == "DROP")   {myCmd = myCmdPrefix "tables -t " table " -P " Param["CHAIN"] " DROP";	ret = system(myCmd);if (ret==0){changed=1;}}
					if (Param["MODE"] == "DEL")				{myCmd = myCmdPrefix "tables -t " table " -D " Param["CHAIN"] " " Param["IDX"];			ret = system(myCmd);if (ret==0){changed=1;}}
					if (Param["MODE"] == "POL" && Param["POL"] == "PURGE")  {myCmd = myCmdPrefix "tables -t " table " -F " Param["CHAIN"];			ret = system(myCmd);if (ret==0){changed=1;}}
					if (Param["MODE"] == "UP"  && Param["IDX"] > 1)
					{
						myCmd = "(" myCmdPrefix "tables -t " table " -S " Param["CHAIN"] " " Param["IDX"] ") | awk \47{gsub(/-A/,\"" myCmdPrefix "tables -t " table " -I\",$1);gsub($2,\"& " Param["IDX"]-1 "\",$2); print $0}\47 | sh";
						ret = system(myCmd); if (ret==0){changed=1;}
						print "Exit Code " ret " - " myCmd;
						if (ret ==0) {myCmd = myCmdPrefix "tables -t " table " -D " Param["CHAIN"] " " Param["IDX"]+1;	ret = system(myCmd);if (ret==0){changed=1;}} else {myCmd="";}
					}
					if (Param["MODE"] == "DN")
					{
						myCmd = "(" myCmdPrefix "tables -t " table " -S " Param["CHAIN"] " " Param["IDX"] ") | awk \47{gsub(/-A/,\"" myCmdPrefix "tables -t " table " -I\",$1);gsub($2,\"& " Param["IDX"]+2 "\",$2); print $0}\47 | sh";
						ret = system(myCmd); if (ret==0){changed=1;}
						print "Exit Code " ret " - " myCmd;
						if (ret ==0) {myCmd = myCmdPrefix "tables -t " table " -D " Param["CHAIN"] " " Param["IDX"]; ret = system(myCmd); if (ret==0){changed=1;}} else {myCmd="";}
					}
				}
			}
			if (myConf["AIRBAG"]==1){ checkAirbag();}
			if (changed==1) {myConf["CHANGED"] = 2; saveSettings(myConf);}
			print "Exit Code " ret " - " myCmd;
			if (flashmodified == 1){system("modsave flash");}

#for (x in myConf){print "CONFIG_" x " = " myConf[x];}
#DEBUG			for (x in myConf) {print x "=" myConf[x];}
#DEBUG			print "QUERY_STRING = " QSTR;
#DEBUG			print "POST_PARAMS = " PSTR;
		} else { print "ACCESS DENIED"; }
} # end BEGIN

function startAirbag(){myConf["AIRBAG"] = 1; if (RCOD > ""){print "...USING " RCOD;} else {RCOD = myConf["ADMINIP"] = myConf["MYIP"];} saveSettings(myConf); return checkAirbag(); }
function stopAirbag(){myConf["AIRBAG"] = 0; saveSettings(myConf); return 0; }

function checkAirbag(){
# filter INPUT, OUTPUT
	ret=0;
	if (myConf["AIRBAG"] == 1) {
		tst = system("iptables -S INPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
		if (tst != 0) { system("iptables -t filter -I INPUT 1 -s " RCOD " -j ACCEPT");}
		if (myModules["ip_conntrack"] == 1){
			tst = system("iptables -S OUTPUT 1 | grep " RCOD " | grep \"RELATED,ESTABLISHED\" | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t filter -I OUTPUT 1 -d " RCOD " -m state --state RELATED,ESTABLISHED -j ACCEPT");}
		} else {
			tst = system("iptables -S OUTPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t filter -I OUTPUT 1 -d " RCOD " -j ACCEPT");}
		}
		if (myModules["iptable_raw"] == 1){
			tst = system("iptables -t raw -S PREROUTING 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t raw -I PREROUTING 1 -s " RCOD " -j ACCEPT");}
			tst = system("iptables -t raw -S OUTPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t raw -I OUTPUT 1 -d " RCOD " -j ACCEPT");}
		}
		if (myModules["iptable_mangle"] == 1){
			tst = system("iptables -t mangle -S PREROUTING 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t mangle -I PREROUTING 1 -s " RCOD " -j ACCEPT");}
			tst = system("iptables -t mangle -S INPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t mangle -I INPUT 1 -s " RCOD " -j ACCEPT");}
			tst = system("iptables -t mangle -S OUTPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t mangle -I OUTPUT 1 -d " RCOD " -j ACCEPT");}
			tst = system("iptables -t mangle -S POSTROUTING 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t mangle -I POSTROUTING 1 -d " RCOD " -j ACCEPT");}
		}
		if (myModules["iptable_nat"] == 1){
			tst = system("iptables -t nat -S PREROUTING 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t nat -I PREROUTING 1 -s " RCOD " -j ACCEPT");}
			tst = system("iptables -t nat -S OUTPUT 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t nat -I OUTPUT 1 -d " RCOD " -j ACCEPT");}
			tst = system("iptables -t nat -S POSTROUTING 1 | grep " RCOD " | grep \"ACCEPT\" 1> /dev/null");
			if (tst != 0) {ret += system("iptables -t nat -I POSTROUTING 1 -d " RCOD " -j ACCEPT");}
		}
	}
	return ret;
}

function loadModules(){
	if (noloadmodules==0){
		y["main"] = "";	y["ftp"] = "_ftp"; y["h323"] = "_h323"; y["irc"] = "_irc";  y["pptp"] = "_pptp";  y["tftp"] = "_tftp";
		ret=0; nat=0; conntrack=0; mangle=0; raw=0;
		for (x in Param) {if (index(Param[x], "ip_conntrack") > 0) {conntrack=1;} if (index(Param[x], "ip_nat") > 0) {nat=1;} if (index(Param[x], "iptable_mangle") > 0) {mangle=1;} if (index(Param[x], "iptable_raw") > 0) {raw=1;}}
		if (conntrack==1){Param["ip_conntrack"] = "ip_conntrack";}
		if (nat==1)		{Param["ip_nat"] = "ip_nat"; if (myModules["iptable_nat"] != 1) {system("modprobe iptable_nat"); changed=1;}} else { if (myModules["iptable_nat"] == 1){ system("rmmod ipt_REDIRECT\nrmmod iptable_nat"); changed=1;}}
		if (mangle==1)	{if (myModules["iptable_mangle"] != 1) {system("modprobe iptable_mangle"); changed=1;}} else { if (myModules["iptable_mangle"] == 1){ system("rmmod iptable_mangle"); changed=1;}}
		if (raw==1)		{if (myModules["iptable_raw"] != 1) {system("modprobe iptable_raw"); changed=1;}} else { if (myModules["iptable_raw"] == 1){ system("rmmod iptable_raw"); changed=1;}}
		for (x in y){
			if (Param["ip_conntrack" y[x]] == ("ip_conntrack" y[x]) && myModules["ip_conntrack" y[x]] != 1) {ret = system("modprobe ip_conntrack" y[x]); print "Loading " x " ..."; changed=1;}
			else if (Param["ip_conntrack" y[x]] == "" && myModules["ip_conntrack" y[x]] == 1) {ret = system("rmmod ip_conntrack" y[x]); print "Un-Load " x "..."; changed=1;}
			if (Param["ip_nat" y[x]] == ("ip_nat" y[x]) && myModules["ip_nat" y[x]] != 1) {ret = system("modprobe ip_nat" y[x]); print "Loading " x " ..."; changed=1;}
			else if (Param["ip_nat" y[x]] == "" && myModules["ip_nat" y[x]] == 1) {ret = system("rmmod ip_nat" y[x]); print "Un-Load " x "..."; changed=1;}
		}
	}
	return ret;
}
function checkConfig(){
	if (RCOD > "") {check["admin_set"] = 0; } else {check["admin_set"] = 1;}
	check["changed"] = myConf["CHANGED"];
	check["iptables"] = system("iptables -S INPUT 1 1> /dev/null");
	if (logtarget == 0) {
		check["directory_log"] = system("ls " myConf["LOGD"] " 1> /dev/null");
		check["log_running"] = system("ps | grep -v grep | grep iptlogger 1> /dev/null");
		check["log_x_flag"] = system("ls -l /var/tmp/iptlogger.sh | grep x 1> /dev/null");
		check["watchdog_file"] = system("ls -l /var/tmp/logfw.sh 1> /dev/null");
		check["watchdog_x_flag"] = system("ls -l /var/tmp/logfw.sh | grep x 1> /dev/null");
		check["watchdog_running"] = system("ps | grep -v grep | grep logfw 1> /dev/null");
	}
	if (myConf["BACK"]==""){check["directory_backup"] = 0;} else {check["directory_backup"] = system("ls " myConf["BACK"] " 1> /dev/null");}
	print "modules loaded :";
	system("lsmod \| grep \"^ip_\\\|^ipt_\\\|^iptable\\\|^x_\\\|^xt_\" \| awk \47{print $1}\47 \| sort");
}
function createWatchdog(){
	print "creating watchdog...";
	ret = system("(cat <<EOF > /var/tmp/logfw.sh \n#!/bin/sh\n\nrunning=\\$(ps | grep -v grep | grep -o iptlogger)\
if [ -z \\$running ]\nthen\necho \"starting log deamon\"\nsh /var/tmp/iptlogger.sh\
myexit=0\nwhile [ \\$myexit -eq 0 ]\ndo\nsleep 15\nrunning=\\$(ps | grep -v grep | grep -o iptlogger)\
if [ -z \\$running ]\nthen\necho \"terminating log deamon\"\nmyexit=1\
else\ngrep -E -v \"<4>|DECT|DCT|^$\" /var/tmp/system.log | sed \"s/^/\\$(date +\47%Y-%m-%d %H:%M:%S\47) /\" >> " myConf["LOGD"] "/system.log\
grep \"<4>\" /var/tmp/system.log | sed \"s/^/\\$(date +\47%Y-%m-%d %H:%M:%S\47) /\" >> " myConf["LOGD"] "/fw.log\
echo \"\" > /var/tmp/system.log\ nmyexit=0\nfi\ndone\nelse\necho \"already running, giving up\"\nfi\nEOF\n\n)");
ret += system("chmod +x /var/tmp/logfw.sh");
	return ret;
}
function createIptlogger(){
	ret = system("(cat <<EOF > /var/tmp/iptlogger.sh \
#!/bin/sh\n\nrunning=\\$(ps | grep -v grep | grep -o iptlogger)\nif [ -n \\$running ]\nthen\nexit 1\nfi\
running=\\$(ps | grep -v grep | grep -o logfw)\nif [ -z \\$running ]\nthen\nexit 2\nfi\
cat /dev/debug > /var/tmp/system.log & \nEOF\n\nchmod +x  /var/tmp/iptlogger.sh\n\)");
	return ret;
}
function createStartSequence(logtarget){
if (logtarget == 0) {
if (myConf["BACK"] == ""){ myBackUp = ""; } else { myBackUp = "cat " BootTargetOld "nhipt.cfg > " myConf["BACK"] "/\"$(date +\"%Y-%m-%d-%H-%M-%S\")\"-nhipt.cfg\n";}
ret = system("(" myBackUp "cat <<EOF > /var/tmp/nhipt.cfg \n#!/bin/sh\n\n" dsldoff bootdelay dsldon "\n\
echo \"#!/bin/sh\" > /var/tmp/logfw.sh\necho \"\" >> /var/tmp/logfw.sh\
echo \47running=\\$(ps | grep -v grep | grep -o iptlogger)\47 >> /var/tmp/logfw.sh\
echo \47if [ -z \\$running ]\47 >> /var/tmp/logfw.sh\
echo \47then\47 >> /var/tmp/logfw.sh\
echo \47echo \"starting log deamon\"\47 >> /var/tmp/logfw.sh\
echo \47sh /var/tmp/iptlogger.sh\47 >> /var/tmp/logfw.sh\
echo \47myexit=0\47 >> /var/tmp/logfw.sh\
echo \47while [ \\$myexit -eq 0 ]\47 >> /var/tmp/logfw.sh\
echo \47do\47 >> /var/tmp/logfw.sh\
echo \47sleep 15\47 >> /var/tmp/logfw.sh\
echo \47running=\\$(ps | grep -v grep | grep -o iptlogger)\47 >> /var/tmp/logfw.sh\
echo \47if [ -z \\$running ]\47 >> /var/tmp/logfw.sh\
echo \47then\47 >> /var/tmp/logfw.sh\
echo \47echo \"terminating log deamon\"\47 >> /var/tmp/logfw.sh\
echo \47myexit=1\47 >> /var/tmp/logfw.sh\
echo \47else\47 >> /var/tmp/logfw.sh\
echo \47grep -E -v \"<4>|DECT|DCT|^$\" /var/tmp/system.log | sed \"s/^/\\$(date +\47\\\47\47%Y-%m-%d %H:%M:%S\47\\\47\47) /\" >> " myConf["LOGD"] "/system.log\47 >> /var/tmp/logfw.sh\
echo \47grep \"<4>\" /var/tmp/system.log | sed \"s/^/\\$(date +\47\\\47\47%Y-%m-%d %H:%M:%S\47\\\47\47) /\" >> " myConf["LOGD"] "/fw.log\47 >> /var/tmp/logfw.sh\
echo \47echo \"\" > /var/tmp/system.log\47 >> /var/tmp/logfw.sh\
echo \47myexit=0\47 >> /var/tmp/logfw.sh\
echo \47fi\47 >> /var/tmp/logfw.sh\
echo \47done\47 >> /var/tmp/logfw.sh\
echo \47else\47 >> /var/tmp/logfw.sh\
echo \47echo \"already running, giving up\"\47 >> /var/tmp/logfw.sh\
echo \47fi\47 >> /var/tmp/logfw.sh\
\nchmod +x  /var/tmp/logfw.sh\
cat  " BootTarget "nhipt.par > /var/tmp/nhipt.par\n\
echo \"#!/bin/sh\" > /var/tmp/iptlogger.sh\necho \"\" >> /var/tmp/iptlogger.sh\
echo \47running=\\$(ps | grep -v grep | grep -o iptlogger)\47 >> /var/tmp/iptlogger.sh\
echo \47if [ -n \\$running ]\47 >> /var/tmp/iptlogger.sh\
echo \47then\47 >> /var/tmp/iptlogger.sh\
echo \47exit 1\47 >> /var/tmp/iptlogger.sh\
echo \47fi\47 >> /var/tmp/iptlogger.sh\
echo \47running=\\$(ps | grep -v grep | grep -o logfw)\47 >> /var/tmp/iptlogger.sh\
echo \47if [ -z \\$running ]\47 >> /var/tmp/iptlogger.sh\
echo \47then\47 >> /var/tmp/iptlogger.sh\
echo \47exit 2\47 >> /var/tmp/iptlogger.sh\
echo \47fi\47 >> /var/tmp/iptlogger.sh\
echo \"cat /dev/debug > /var/tmp/system.log & \" >> /var/tmp/iptlogger.sh\n\
iptables -P INPUT  ACCEPT\niptables -P OUTPUT ACCEPT\niptables -F\niptables -X\
date > /var/tmp/system.log\n\nchmod 777 /var/tmp/system.log \
chmod +x  /var/tmp/iptlogger.sh\n\
sh /var/tmp/logfw.sh & \n\
\nEOF\n)\n");
} else {
if (myConf["BACK"] == ""){ myBackUp = ""; } else { myBackUp = "cat " BootTargetOld "nhipt.cfg > " myConf["BACK"] "/\"$(date +\"%Y-%m-%d-%H-%M-%S\")\"-nhipt.cfg\n";}
ret = system("(" myBackUp "cat <<EOF > /var/tmp/nhipt.cfg \n#!/bin/sh\n\n" dsldoff bootdelay dsldon "\n\
. /mod/etc/conf/mod.cfg\
echo \"/:\\$MOD_HTTPD_USER:\\$MOD_HTTPD_PASSWD\" > /mod/etc/httpd.conf\n\
httpd -P /var/run/nhipd.pid -p " LANIP ":" myPort " -h " myRoot " -c /mod/etc/httpd.conf -r Freetz\n \
\nEOF\n)\n");
}
return ret;
}
function appendRules(){
ret = system("(cat <<EOF >> /var/tmp/nhipt.cfg \n\
###FIREWALL###\n" bootModules() "\n\n \
\nEOF\n)\
if [ -n \"$(iptables -S -t filter  | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (iptables -t filter -S  2> /dev/null) | awk \47{print \"iptables -t filter \" $0}\47  >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(iptables -S -t nat     | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (iptables -t nat -S     2> /dev/null) | awk \47{print \"iptables -t nat \" $0}\47     >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(iptables -S -t mangle  | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (iptables -t mangle -S  2> /dev/null) | awk \47{print \"iptables -t mangle \" $0}\47  >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(iptables -S -t raw     | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (iptables -t raw -S     2> /dev/null) | awk \47{print \"iptables -t raw \" $0}\47     >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(ip6tables -S -t filter | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (ip6tables -t filter -S 2> /dev/null) | awk \47{print \"ip6tables -t filter \" $0}\47 >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(ip6tables -S -t mangle | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (ip6tables -t mangle -S 2> /dev/null) | awk \47{print \"ip6tables -t mangle \" $0}\47 >> /var/tmp/nhipt.cfg; fi\
if [ -n \"$(ip6tables -S -t raw    | grep -e \47^Table does not exist\47)\" ]; then touch /var/tmp/iptfilter.tmp; else (ip6tables -t raw -S    2> /dev/null) | awk \47{print \"ip6tables -t raw \" $0}\47    >> /var/tmp/nhipt.cfg; fi\
cat /var/tmp/nhipt.cfg > " BootTarget "nhipt.cfg");
return ret;
}
function startLogging(){
	if (logtarget == 1) {return 0;}
	ret = system("ps | grep -v \"grep\" | grep \"iptlogger\"");
	if (ret == 0) { print "Sevice already running"; return 0;}
	else {
		ret = 0;
		print "Starting Service...";
		if (system("test -f /var/tmp/iptlogger.sh") == 0 ) { print "...starting existing service..."; } else { print "...creating iptlogger.sh..."; ret = createIptlogger(); }
		if (system("test -f /var/tmp/logfw.sh") == 0 ) { print "...starting watchdog"; } else { print "...creating watchdog"; ret = createWatchdog(); }
		return ret += system("sh /var/tmp/logfw.sh&");
	}
}
function stopLogging()
{	print "Stopping deamon iptlogger.sh";
	ret = system("ps | grep -v grep | grep iptlogger | awk \47{print $1}\47 | xargs kill");
	ret += system("ps | grep -v grep | grep logfw | awk \47{print $1}\47 | xargs kill");
	return ret;
}
function persist(mode){
	if (dirchanged==1){
		ret = system("ls " myConf["LOGD"] " 1> /dev/null");
		if (ret != 0){ system("mkdir " myConf["LOGD"]); print "creating " myConf["LOGD"]; }
		if (myConf["BACK"] != "") {	ret = system("ls " myConf["BACK"] " 1> /dev/null"); 	if (ret != 0){ system("mkdir " myConf["BACK"]); print "creating " myConf["BACK"];}}
		ret = system("ls " myConf["BOOTDIR"] " 1> /dev/null");
		if (ret != 0){ system("mkdir " myConf["BOOTDIR"]); print "creating " myConf["BOOTDIR"]; }
	}
	if (Boot!=myConf["BOOT"] || Bootstrap!=myConf["BOOTSTRAP"]){
		if (myConf["BOOTSTRAP"] == "freetz"){myBootstrap="/tmp/flash/nhiptboot.cfg"; flashmodified=1;} else {myBootstrap="/var/flash/debug.cfg";}
		flashmodified = 1;
		if (myConf["BOOT"]=="flash"){BootTarget="/tmp/flash/";myDelay="";}
		if (myConf["BOOT"]=="usb"){
			if (myConf["BOOTDIR"] == ""){BootTarget=myConf["ROOT"] "/"; myConf["BOOTDIR"]=myConf["ROOT"]} else {BootTarget=myConf["BOOTDIR"] "/";}
			myDelay= "for i in 1 2 3 4 5 6 7 8\ndo\n sleep 5\necho \"retry $i times\"\n  if [ -r " BootTarget "nhipt.par ]\n  then\n echo \"usb stick connected\"\n	break\n  fi \ndone\n\n";
		}
		myCmd = "Saving Settings to " BootTarget "...";
		printed=0;
		system("rm /var/tmp/debug.cfg")
		if( system("grep \"#NHIPT-START#\" " myBootstrap) == 0) {
			found = 0;
			while ((ret = getline test < myBootstrap) > 0) {
				if (test == "###NHIPT-START###" && found==0){print "###NHIPT-START###\n\n" myDelay "\ncat " BootTarget "nhipt.cfg > /var/tmp/nhipt.cfg\ncat " BootTarget "nhipt.par > /var/tmp/nhipt.par\nchmod +x /var/tmp/nhipt.cfg\n/bin/sh /var/tmp/nhipt.cfg &\n###NHIPT-END###\n" >> "/var/tmp/debug.cfg";printed=1;found=1;}
				if (found==0 || found==3 ){print test >> "/var/tmp/debug.cfg";}
				if (found==2){found=3};
				if (test == "###NHIPT-END###"){found = 2;print "Found Footer";}
				}
			if (ret==0) {close (myBootstrap);}
		}
		if (printed==0) {print "###NHIPT-START###\ncat " BootTarget "nhipt.cfg > /var/tmp/nhipt.cfg\ncat " BootTarget "nhipt.par > /var/tmp/nhipt.par\nchmod +x /var/tmp/nhipt.cfg\n/bin/sh /var/tmp/nhipt.cfg\n###NHIPT-END###\n" >> "/var/tmp/debug.cfg";printed=1;}
		system("cat /var/tmp/debug.cfg > " myBootstrap);
		mode="all";
		print "STAGE0 - bootstrap reconfigured"
	}
	if (myConf["DSLDOFF"] == 1) {dsldoff = "dsld -s\n"; dsldon = "dsld -i -n\n";} else {dsldoff=""; dsldon=""; }
	if (myConf["DELAY"] > 0) 	{bootdelay = "sleep " myConf["DELAY"] "\n";} else {bootdelay = ""; dsldoff=""; dsldon="";}
	if (mode=="all"){
		# SAVE ALL
		cfgchanged=1;
		ret = createStartSequence(logtarget);
		ret += appendRules();
		print "STAGE1 - complete bootfile written";
		if (ret==0){myConf["CHANGED"]=0; ret=saveSettings(myConf);}
		if (myConf["BOOT"] == "flash") {flashmodified=1;}
	} else if(cfgchanged == 1 || dirchanged == 1) {
		#SAVE CONFIG AND BOOTLOADER
		ret = createStartSequence(logtarget);
		print "STAGE2 - bootloader only written";
		# APPEND SAVED FIREWALL RULES
		found = 0;
		while ((ret = getline test < "" BootTargetOld "nhipt.cfg") > 0) {
			if (test == "###FIREWALL###"){found = 1;}
			if (found == 1){print test >> "/var/tmp/nhipt.cfg";}
		}
		if (ret==0) {close ("" BootTargetOld "nhipt.cfg");}
		ret = system("cat /var/tmp/nhipt.cfg > " BootTarget "nhipt.cfg");
		print "STAGE3 - preserved rules appended";
		tmpCnfChg = myConf["CHANGED"]; myConf["CHANGED"]=0; cfgchanged=1;
		ret += saveSettings(myConf);
		myConf["CHANGED"] = tmpCnfChg;
		saveSettings(myConf);
		if (myConf["BOOT"] == "flash") {flashmodified=1;}
	} else {
		myCmd = "Nothing to save"; ret=0;
	}
	return ret;
}
function bootModules(){
	strRet = ""
	system("lsmod \| grep \"^ip_\\\|^ipt_\\\|^iptable\\\|^x_\\\|^xt_\" \| awk \47{print $1}\47 \| sort > /var/tmp/nhipt.yyy");
	system("lsmod \| grep \"^ip6_\\\|^ip6t_\\\|^ip6table\" \| awk \47{print $1}\47 \| sort >> /var/tmp/nhipt.yyy");
	while((stat = getline test < "/var/tmp/nhipt.yyy") > 0) { strRet = strRet "modprobe " test "\n"	;}
	if (stat==0) { close("/var/tmp/nhipt.yyy");}
	return strRet;
}
function loadSettings(){
	system("lsmod \| grep \"^ip_\\\|^ipt_\\\|^iptable\\\|^x_\\\|^xt_\" \| awk \47{print $1}\47 \| sort > /var/tmp/nhipt.yyy");
	while((stat = getline test < "/var/tmp/nhipt.yyy") > 0) { myModules[test] = 1; }
	if (stat==0) { close("/var/tmp/nhipt.yyy");}
	while ((stat = getline test < "/var/tmp/nhipt.par") > 0) { split(test ,par,"=");myConf[par[1]] = par[2]; }
	if (stat==-1) {print "Parameter file not found in RAM-disk, loading boot settings"; system("cat " BootTarget "nhipt.par > /var/tmp/nhipt.par");
		while ((stat = getline test < "/var/tmp/nhipt.par") > 0) { split(test ,par,"=");myConf[par[1]] = par[2]; }
	}
	if (stat==0) { close("/var/tmp/nhipt.par");}
	if (myConf["PORT"] > "") { myPort = myConf["PORT"]} else {myPort = substr(ENVIRON["HTTP_REFERER"],index(ENVIRON["HTTP_REFERER"],".")); myPort = substr(myPort, index(myPort,":")+1); myPort = substr(myPort,1,index(myPort,"/")-1); myConf["PORT"] = myPort;}
	if (myConf["ROOT"] > "") { myRoot = myConf["ROOT"]} else {myRoot = substr(ENVIRON["SCRIPT_FILENAME"],1,index(ENVIRON["SCRIPT_FILENAME"],"cgi-bin")-2);; myConf["ROOT"] = myRoot;}
#	if (myConf["BACK"] == "") { myConf["BACK"] = myRoot;}
	if (myConf["LOGD"] == "") { myConf["LOGD"] = myRoot;}
	myConf["MYIP"] = myIP;
	# These saved/fallback values are interpolated into shell commands as well.
	validateValue("PORT", myConf["PORT"]);
	validateValue("ROOT", myConf["ROOT"]);
	validateValue("LOGDIR", myConf["LOGD"]);
	validateValue("BACDIR", myConf["BACK"]);
	validateValue("BOOTDIR", myConf["BOOTDIR"]);
	validateValue("ADMIP", myConf["ADMINIP"]);
	validateValue("DELAY", myConf["DELAY"]);
	return stat;
}
function saveSettings(Settings){
	ret = system("rm /var/tmp/nhipt.par");
	for (s in Settings){ret += system("echo \"" s "=" Settings[s] "\" >> /var/tmp/nhipt.par"); }
	if (flashmodified == 1 || dirchanged == 1 || cfgchanged == 1){
		ret += system("cat /var/tmp/nhipt.par > " BootTarget "nhipt.par");
		print "STAGE4 - settings saved";
		if (dirchanged == 1 && logtarget == 0) {
			logDeamonIsRunning = system("ps | grep -v grep | grep iptlogger 1> /dev/null");
			if (logDeamonIsRunning == 0) { ret=stopLogging(); ret=createIptlogger(); ret+=createWatchdog();	ret+=startLogging(); print "STAGE5 - fw and system log reconfigured";}
		}
		## Remove orphaned boot files
		if (BootTargetOld != BootTarget){ system("rm " BootTargetOld "/nhipt.*"); print "STAGE5 - housekeeping after transfer";}
		dirchanged=0; cfgchanged=0;
	}
	return ret;
}
# Request values reach system() and generated boot scripts. Validate both
# POST fields and action-URL fields; EXTRA must also survive rules replay.
# EXPERT is restricted separately to one iptables/ip6tables invocation.
function invalidParam() {
	print "Invalid NHIPT parameter." > "/dev/stderr";
	exit 1;
}
function validateValue(key, value) {
	if (value == "") return;
	if (key == "TABLE" && value !~ /^(filter|nat|mangle|raw|security)$/) invalidParam();
	if ((key == "CHAIN" || key == "ACTION") && value !~ /^[a-zA-Z0-9_][a-zA-Z0-9_.:+-]*$/) invalidParam();
	if ((key == "P" || key == "MODULE") && value !~ /^!?[a-zA-Z0-9_][a-zA-Z0-9_-]*$/) invalidParam();
	if ((key == "I" || key == "O") && value !~ /^!?[a-zA-Z0-9_.:][a-zA-Z0-9_.:+-]*$/) invalidParam();
	if ((key == "S" || key == "D") && value !~ /^!?[a-zA-Z0-9_.:][a-zA-Z0-9_.:\/-]*$/) invalidParam();
	if ((key == "SPORT" || key == "DPORT") && value !~ /^!?[a-zA-Z0-9_][a-zA-Z0-9_:,-]*$/) invalidParam();
	if ((key == "IDX" || key == "J" || key == "PORT" || key == "DELAY") && value !~ /^[0-9]+$/) invalidParam();
	if (key == "ROW" && value != "A" && value !~ /^[0-9]+$/) invalidParam();
	if ((key == "IPV6" || key == "AIRBAG" || key == "DSLDOFF") && value !~ /^[01]$/) invalidParam();
	if (key == "ADMIP" && value !~ /^[0-9.\/]+$/) invalidParam();
	if (key == "SERVERIP" && value !~ /^[a-fA-F0-9.:]+$/) invalidParam();
	if ((key == "BACDIR" || key == "LOGDIR" || key == "ROOT" || key == "BOOTDIR") && value !~ /^\/[a-zA-Z0-9_.\/:+-]*$/) invalidParam();
	if (key == "BOOT" && value !~ /^(usb|flash)$/) invalidParam();
	if (key == "BOOTSTRAP" && value !~ /^(freetz|debug)$/) invalidParam();
	if (key == "LOGTO" && value !~ /^(internal|syslog)$/) invalidParam();
	if (key == "EXTRA" && value !~ /^[a-zA-Z0-9_.,:\/ +!@%=-]*$/) invalidParam();
}
function validateParams(    key) {
	for (key in Param) validateValue(key, Param[key]);
	# NOTRACK has no target arguments; do not accept additional iptables options.
	if (Param["ACTION"] == "NOTRACK" && Param["EXTRA"] != "") invalidParam();
}
function readParams(encoded,    count, fields, field, pos, key) {
	# Split first, then decode each field exactly once (including encoded &/=).
	count = split(encoded, fields, "&");
	for (field=1; field<=count; field++) {
		pos = index(fields[field], "=");
		if (pos) {
			key = urldecode(substr(fields[field], 1, pos-1));
			Param[key] = urldecode(substr(fields[field], pos+1));
		}
	}
}
function shellquote(value) {
	gsub(/\47/, "\47\42\47\42\47", value);
	return "\47" value "\47";
}
function expertCommand(value,    words, count, word, quoted, active, i, c, option, arg, pos, named, j, k, needsname, rename, command) {
	# Rules are later replayed as shell scripts: reject substitutions and controls
	# even inside quoted values. Keep quotes/spaces and IPv6/LOG brackets usable.
	if (value ~ /[^][a-zA-Z0-9_.,:\/ +!@%=\42\47\t-]/) invalidParam();
	for (i=1; i<=length(value); i++) {
		c = substr(value, i, 1);
		if (quoted != "") {
			if (c == quoted) quoted = ""; else word = word c;
		} else if (c == "\42" || c == "\47") {
			quoted = c; active = 1;
		} else if (c == " " || c == "\t") {
			if (active) {words[++count] = word; word = ""; active = 0;}
		} else {word = word c; active = 1;}
	}
	if (quoted != "") invalidParam();
	if (active) words[++count] = word;
	if (words[1] != "iptables" && words[1] != "ip6tables") invalidParam();
	command = words[1];
	split("match jump goto protocol new-chain rename-chain", named, " ");
	for (i=2; i<=count; i++) {
		option = words[i]; pos = index(option, "=");
		arg = pos ? substr(option, pos+1) : words[i+1];
		if (pos) option = substr(option, 1, pos-1);
		# Allow no-argument short options together (-nvL), but keep values separate.
		if (option ~ /^-[^-]./) {
			for (k=2; k<length(option); k++)
				if (index("nvxfV046", substr(option, k, 1)) == 0) invalidParam();
			option = "-" substr(option, length(option), 1);
		}
		# getopt_long also accepts abbreviated --modprobe options, e.g. --mo.
		if (option == "-M" ||
		    (length(option) > 2 && index("--modprobe", option) == 1)) invalidParam();
		needsname = (option ~ /^-[mjgpNE]$/); rename = (option == "-E");
		for (j in named) {
			if (length(option) > 2 && index("--" named[j], option) == 1) {
				needsname = 1;
				if (named[j] == "rename-chain") rename = 1;
			}
		}
		# Match/target/protocol and new chain names can trigger shared-library loads.
		if (needsname && arg !~ /^[a-zA-Z0-9_][a-zA-Z0-9_.:+-]*$/) invalidParam();
		if (rename && words[i+(pos ? 1 : 2)] !~ /^[a-zA-Z0-9_][a-zA-Z0-9_.:+-]*$/) invalidParam();
		command = command " " shellquote(words[i]);
	}
	return command;
}
function urldecode (s) {
	hextab["0"] = 0; hextab["8"] = 8;
	hextab["1"] = 1; hextab["9"] = 9;
	hextab["2"] = 2; hextab["A"] = hextab["a"] = 10;
	hextab["3"] = 3; hextab["B"] = hextab["b"] = 11;
	hextab["4"] = 4; hextab["C"] = hextab["c"] = 12;
	hextab["5"] = 5; hextab["D"] = hextab["d"] = 13;
	hextab["6"] = 6; hextab["E"] = hextab["e"] = 14;
	hextab["7"] = 7; hextab["F"] = hextab["f"] = 15;
 	decoded = "";
	i = 1;
	len = length (s);
	while ( i <= len ) {
		c = substr (s, i, 1);
		if ( c == "%" ) {
			if ( i+2 <= len ) {
				c1 = substr (s, i+1, 1);
				c2 = substr (s, i+2, 1);
				if ( hextab[c1] == "" || hextab[c2] == "" ) {
					print "WARNING: invalid hex encoding: %" c1 c2 | "cat >&2";
				} else {
					code = 0 + hextab[c1] * 16 + hextab[c2] + 0;
					if (code == 0) invalidParam();
					c = sprintf ("%c", code);
					i = i + 2;
				}
			} else {
				print "WARNING: invalid % encoding: " substr (s, i, len - i) | "cat >&2";
			}
		} else if ( c == "+" ) {
				c = " ";
			}
		decoded = decoded c;
		i++;
	}
	return decoded;
} # end urldecode
	{
	} # end main
	END {
	}' 2>&1) >> /var/tmp/nhipt.log
fi

if [ "$NHIPT_CONFIG" = "box" ]; then
	echo "iptables reconfigured"
else

### HTML FORM

touch /var/tmp/iptfilter.tmp;
touch /var/tmp/iptnat.tmp;
touch /var/tmp/iptmangle.tmp;
touch /var/tmp/iptraw.tmp;
touch /var/tmp/ip6tfilter.tmp;
touch /var/tmp/ip6tmangle.tmp;
touch /var/tmp/ip6traw.tmp;

if [ -n "$(iptables -S -t filter | grep -e '^Table does not exist')" ]; then touch /var/tmp/iptfilter.tmp; else iptables -t filter -S > /var/tmp/iptfilter.tmp; fi
if [ -n "$(iptables -S -t nat    | grep -e '^Table does not exist')" ]; then touch /var/tmp/iptnat.tmp; else iptables -t nat -S > /var/tmp/iptnat.tmp; fi
if [ -n "$(iptables -S -t mangle | grep -e '^Table does not exist')" ]; then touch /var/tmp/iptmangle.tmp; else iptables -t mangle -S > /var/tmp/iptmangle.tmp; fi
if [ -n "$(iptables -S -t raw 	 | grep -e '^Table does not exist')" ]; then touch /var/tmp/iptraw.tmp; else iptables -t raw -S > /var/tmp/iptraw.tmp; fi

if [ -n "$(ip6tables -S -t filter | grep -e '^-sh: ip6tables: not found')" ]; then
	touch /var/tmp/ip6tfilter.tmp;
	touch /var/tmp/ip6tmangle.tmp;
	touch /var/tmp/ip6traw.tmp;
else
	if [ -n "$(ip6tables -S -t filter | grep -e '^Table does not exist')" ]; then touch /var/tmp/ip6tfilter.tmp; else ip6tables -t filter -S > /var/tmp/ip6tfilter.tmp; fi
	if [ -n "$(ip6tables -S -t mangle | grep -e '^Table does not exist')" ]; then touch /var/tmp/ip6tmangle.tmp; else ip6tables -t mangle -S > /var/tmp/ip6tmangle.tmp; fi
	if [ -n "$(ip6tables -S -t raw 	  | grep -e '^Table does not exist')" ]; then touch /var/tmp/ip6traw.tmp; else ip6tables -t raw -S > /var/tmp/ip6traw.tmp; fi
fi

  echo "$(awk -v IFCS="$x" -v PSTR="$post_string" -v QSTR="$QUERY_STRING" -v CSRF_TOKEN="$_CGI_CSRF_TOKEN" 'BEGIN {
	print "Content-type: text/html"
	print ""
	print "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\"  \"http://www.w3.org/TR/html4/strict.dtd\">";
	print "<html xmlns=\"http://www.w3.org/1999/xhtml\" >";
	print "<head>";
	print "<title>NHIPT - IPTABLES FIREWALL ADMIN INTERFACE FOR FRITZ!BOX</title>";
	print "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />";
	print "<meta http-equiv=\"pragma\" content=\"no-cache\">";
	print "<meta http-equiv=\"expires\" content=\"-1\">";
	print "<meta name=\"expires\" content=\"0\">";
	print "<meta name=\"csrf-token\" content=\"" CSRF_TOKEN "\">";
	while ((getline csrfLine < "/usr/lib/mod/cgi/csrf.js") > 0) { print csrfLine; }
	close("/usr/lib/mod/cgi/csrf.js");
	print "<STYLE>";
	print "TR			{background-color:#FFFFFF;}";
	print "TR:hover		{background-color:#CCCCCC;}";
	print "TR.solid		{background-color:#FFFFFF;}";
	print "H1			{FONT-FAMILY: Arial, Verdana, sans-serif; color:#FF0000; text-align:center; border:10px solid red; padding:10px 10px 10px 10px; margin: 10px 10px 10px 10px; vertical-align:middle;}";
	print "TD			{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;}";
	print "TD.ACCEPT	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;background-color:#CCFFCC;}";
	print "TD.DROP		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;background-color:#FFCCCC;}";
	print "TD.error		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;background-color:#FF8080;}";
	print "TD.ok		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;background-color:#80FF80;}";
	print "TD.noborder	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:left;   border:1px solid white;  padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; vertical-align:top;}";
	print "TD.log		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:left;   border:1px solid white; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; background-color:#EEEEEE;}";
	print "TH			{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; font-weight:bold;background-color:#EEEEEE;}";
	print "TH.left		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; font-weight:bold;background-color:#EEEEEE;}";
	print "TH.right		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:right; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; font-weight:bold;background-color:#EEEEEE; vertical-align:top;}";
	print "TD.left		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px;}";
	print "TABLE		{padding:0;}";
	print "INPUT[type=text]{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "INPUT[type=submit]{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "INPUT.expert	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; background-color:#FFCCCC; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:99%;}";
	print "INPUT.admin	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; background-color:#FFFFFF; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "INPUT.adminr	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; background-color:#FFCCCC; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "INPUT.adming	{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; background-color:#CCFFCC; text-align:left; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "SELECT		{FONT-SIZE:11px; FONT-FAMILY: Arial, Verdana, sans-serif; color:#000000; text-align:center; border:1px solid silver; padding:1px 1px 1px 1px; margin: 0px 0px 0px 0px; width:95%;}";
	print "</STYLE>";
	print "</head>";
	print "<body>";
	exitSwitch=0;

    BoxType = substr(ENVIRON["CONFIG_PRODUKT"],index(ENVIRON["CONFIG_PRODUKT"],"Box_") + 4, 2);

	system("lsmod \| grep \"^ip_\\\|^ipt_\\\|^iptable\\\|^x_\\\|^xt_\" \| awk \47{print $1}\47 \| sort > /var/tmp/nhipt.yyy");
	ip6enabled = system("lsmod | grep -e \47^ipv6\47 1> /dev/null");
	while((stat = getline test < "/var/tmp/nhipt.yyy") > 0) { myModules[test] = 1;} if (stat==0) { close("/var/tmp/nhipt.yyy"); system("rm /var/tmp/nhipt.yyy");}
	while ((stat = getline test < "/var/tmp/nhipt.par") > 0) { split(test,par,"=");myConf[par[1]] = par[2]; }
	RCOD=myConf["ADMINIP"];
	if (stat==-1) {system("cat " BootTarget "nhipt.par > /var/tmp/nhipt.par"); while ((stat = getline test < "/var/tmp/nhipt.par") > 0) { split(test,par,"=");myConf[par[1]] = par[2]; }}
	if (stat==0) { close("/var/tmp/nhipt.par");}
	if (myConf["PORT"] > "") { myPort = myConf["PORT"]} else {myPort = substr(ENVIRON["HTTP_REFERER"],index(ENVIRON["HTTP_REFERER"],".")); myPort = substr(myPort, index(myPort,":")+1); myPort = substr(myPort,1,index(myPort,"/")-1); myConf["PORT"] = myPort;}
	if (myConf["ROOT"] > "") { myRoot = myConf["ROOT"]} else {myRoot = substr(ENVIRON["SCRIPT_FILENAME"],1,index(ENVIRON["SCRIPT_FILENAME"],"cgi-bin")-2); myConf["ROOT"] = myRoot;}
#	if (myConf["BACK"] == "") { myConf["BACK"] = myRoot;}
	if (myConf["LOGD"] == "") { myConf["LOGD"] = myRoot;}
	myConf["MYIP"] = myIP = ENVIRON["REMOTE_ADDR"];
	#CHECK LOGIN CREDENTIALS
	gsub(/ /,"",RCOD);
	if (RCOD > ""){ i = split(RCOD,ipadr,"/"); if (i > 1) {ip = ipadr[1]; mask=ipadr[2];} else {ip = ipadr[1]; mask="255.255.255.255";} if (index(mask,".") == 0) { sm = "";	ma[8]=255; ma[7]=127; ma[6]=63; ma[5]=31; ma[4]=15; ma[3]=7; ma[2]=3; ma[1]=1; ma[0]=0; for (i=1;i<=4;i++){if (mask >=8) {sm = sm "255.";mask=mask-8;} else {sm = sm ma[mask] ".";mask=0;}} mask=sm; } split(myIP,mpar,".");	split(ip,ipar,"."); split(mask,maskar,"."); if ((and(mpar[1],maskar[1]) == and(ipar[1],maskar[1])) && (and(mpar[2],maskar[2]) == and(ipar[2],maskar[2])) && (and(mpar[3],maskar[3]) == and(ipar[3],maskar[3])) && (and(mpar[4],maskar[4]) == and(ipar[4],maskar[4]))) { login=1} else {login=0} } else { login = 1;}
	#END CHECK
	if(login != 1){print "<BR><BR><BR><H1>ACCESS DENIED FROM IP : " myIP "</H1>\n</BODY>\n</HTML>"; exitSwitch=1; exit 0;};
	myURL = ENVIRON["SCRIPT_NAME"];
	csrfInput = "<INPUT TYPE=HIDDEN NAME=csrf_token VALUE=\"" CSRF_TOKEN "\">";
	admIP = RCOD;
	settingsPrinted = 0;
	myIP  = ENVIRON["REMOTE_ADDR"];
	n = split(QSTR, PA, "&"); for (i=1;i<=n;i++) {split(PA[i], PM, "=");Param[PM[1]] = PM[2]}
	CurrentJumpMark = Param["J"];
	if (CurrentJumpMark !~ /^[0-9]+$/) CurrentJumpMark = 0;
	if (Param["MODE"]=="EDT"){ editRule=1; } else {editRule = 0}
	JumpMark = (CurrentJumpMark + 1) % 9;
	if (admIP == "") { ifcIP = myIP; ipStr = "SET ";} else { ifcIP = admIP;  ipStr = "CHANGE ";}
	check["log_deamon"] = system("ps | grep -v grep | grep iptlogger 1> /dev/null");
	check["changed"] = myConf["CHANGED"];
	check["AIRBAG"] = myConf["AIRBAG"];
	if (myConf["LOGTARGET"] == "syslog") { nolog=1; } else { nolog=0; }
	print "<TABLE cellspacing=\"0\">";
	i = 0;
	formPrinted = 0;
	inSubTable = 0;
	nTables = 0;
	nCChains = 0;
	delete Chains;
	delete CChains;
	myFile = "ipt.tmp"

	# INERFACES DROP-DOWN
	n = split(IFCS, Params,"+");
	ifSel = ""; selected = " selected";
	for (j=1;j<=n;j++){ if (index(Params[j],":") == 0 ){ifSel = ifSel "<OPTION VALUE=\"" Params[j] "\"" selected ">" Params[j] "</OPTION>";	selected = "" }}

	# PROTOCOLS DROP-DOWN
	myProt = "<OPTION VALUE=\"\"></OPTION><OPTION VALUE=tcp>tcp</OPTION><OPTION VALUE=udp>udp</OPTION><OPTION VALUE=icmp>icmp</OPTION><OPTION VALUE=ah>ah</OPTION><OPTION VALUE=esp>esp</OPTION><OPTION VALUE=gre>gre</OPTION><OPTION VALUE=sctp>sctp</OPTION>\
<OPTION VALUE=ipv6>ipv6</OPTION><OPTION VALUE=ipv6-route>ipv6-route</OPTION><OPTION VALUE=ipv6-frag>ipv6-frag</OPTION><OPTION VALUE=ipv6-icmp>ipv6-icmp</OPTION><OPTION VALUE=ipv6-nonxt>ipv6-nonxt</OPTION><OPTION VALUE=ipv6-opts>ipv6-opts</OPTION>\
<OPTION VALUE=vrrp>vrrp</OPTION><OPTION VALUE=pgm>pgm</OPTION><OPTION VALUE=igmp>igmp</OPTION><OPTION VALUE=l2tp>l2tp</OPTION><OPTION VALUE=sctp>sctp</OPTION><OPTION VALUE=!tcp>!tcp</OPTION><OPTION VALUE=!udp>!udp</OPTION><OPTION VALUE=!icmp>!icmp</OPTION><OPTION VALUE=!ah>!ah</OPTION><OPTION VALUE=!esp>!esp</OPTION><OPTION VALUE=!gre>!gre</OPTION><OPTION VALUE=!sctp>!sctp</OPTION></SELECT>";

	# PRESET FORM ROW STRING LEFT AND RIGHT - ACTION DROP DOWN WILL BE CREATED AND INSERTED DURING RUN TIME
	myFL = "<TD><INPUT TYPE=TEXT NAME=S SIZE=18 MAXLENGTH=32></TD><TD><INPUT TYPE=TEXT NAME=D SIZE=18 MAXLENGTH=32></TD><TD><SELECT NAME=I>" ifSel "</SELECT></TD><TD><SELECT NAME=O>" ifSel "</SELECT></TD><TD><SELECT NAME=P>" myProt "</TD><TD><SELECT NAME=MODULE><OPTION VALUE=\"\">auto</OPTION><OPTION VALUE=state>state</OPTION><OPTION VALUE=ah>ah</OPTION><OPTION VALUE=esp>esp</OPTION><OPTION VALUE=comment>comment</OPTION></SELECT></TD><TD><INPUT TYPE=TEXT NAME=SPORT SIZE=3></TD><TD><INPUT TYPE=TEXT NAME=DPORT></TD><TD><SELECT NAME=ACTION>";
	myFR = "</SELECT></TD><TD><INPUT TYPE=TEXT NAME=EXTRA></TD><TD><INPUT TYPE=SUBMIT NAME=DOIT VALUE=Insert></TD></TR></FORM>";

}


function myTT (CChains,nCChains, chn) {
	mySel = "<OPTION VALUE=ACCEPT>ACCEPT</OPTION><OPTION VALUE=DROP>DROP</OPTION><OPTION VALUE=LOG>LOG</OPTION><OPTION VALUE=REJECT>REJECT</OPTION><OPTION VALUE=RETURN>RETURN</OPTION><OPTION VALUE=CONNMARK>CONNMARK</OPTION>";
	if (table == "nat" && (chn == "PREROUTING" || chn == "OUTPUT")){mySel = mySel "<OPTION VALUE=DNAT>DNAT</OPTION><OPTION VALUE=REDIRECT>REDIRECT</OPTION>";}
	if (table == "nat" && chn == "POSTROUTING"){mySel = mySel "<OPTION VALUE=SNAT>SNAT</OPTION><OPTION VALUE=MASQUERADE>MASQUERADE</OPTION>";}
	if (table == "mangle"){mySel = mySel "<OPTION VALUE=MARK>MARK</OPTION>";}
	if (table == "raw"){mySel = mySel "<OPTION VALUE=NOTRACK>NOTRACK</OPTION>";}
	for (z = 1; z<=nCChains; z++) {	if (CChains[z] != chn) { mySel = mySel "<OPTION VALUE=" CChains[z] ">" CChains[z] "</OPTION>";}	}
	return mySel;
}
function myDD (lines) {
	mySel = "<TR><TD><SELECT NAME=ROW>";
	for (z = 1; z<=lines-1; z++) {
		mySel = mySel "<OPTION VALUE=" z ">" z "</OPTION>";
	}
	mySel = mySel "<OPTION VALUE=A SELECTED>" lines "</OPTION>";
	myStr = mySel "</SELECT></TD>";
	return mySel;
}

function AdminIFC () {
	usb=""; flash=""; admsafe=""; admunsafe=""; logsyslog=""; loginternal="";
	if (myConf["BOOT"] =="usb") {usb=" checked";} else if (myConf["BOOT"] =="flash") {flash=" checked";}
	if (check["AIRBAG"] == "1") {admsafe=" checked";} else {admunsafe=" checked";}
	if (myConf["LOGTARGET"] == "syslog") {logsyslog=" checked";} else {loginternal=" checked";}
	if (myConf["DSLDOFF"] == "1") {dsldoff=" checked";}
	if (myConf["ADMINIP"] > "") {adminr="adming";} else {adminr="adminr";}
	myStr = "<TABLE cellspacing=\"0\" WIDTH=100%><TR><TH COLSPAN=3>INTERFACE SETTINGS </TH></TR>";
	myStr = myStr "<FORM METHOD=POST ACTION=" myURL ">" csrfInput "<TR><TH class=right>" ipStr "ADMIN IP : </TH><TD COLSPAN=2><INPUT CLASS=" adminr " TYPE=TEXT NAME=ADMIP VALUE=\"" ifcIP "\"></TD><TD><INPUT TYPE=SUBMIT NAME=SETIP VALUE=set></TD></TR></FORM>";
	myStr = myStr "<FORM METHOD=POST ACTION=" myURL ">" csrfInput;
	myStr = myStr "<TR><TH class=right>SET BACKUP DIRECTORY : </TH><TD COLSPAN=2><INPUT CLASS=admin TYPE=TEXT NAME=BACDIR VALUE=\"" myConf["BACK"] "\"></TD></TR>";
if (nolog == 0) {
	myStr = myStr "<TR><TH class=right>SET LOG DIRECTORY : </TH><TD COLSPAN=2><INPUT CLASS=admin TYPE=TEXT NAME=LOGDIR VALUE=\"" myConf["LOGD"] "\"></TD></TR>";
} else {
	myStr = myStr "<INPUT TYPE=HIDDEN NAME=LOGDIR VALUE=\"" myConf["LOGD"] "\">";
}
if (myConf["BOOT"]=="usb") {
	myStr = myStr "<TR><TH class=right>SET BOOT DIRECTORY : </TH><TD COLSPAN=2><INPUT CLASS=admin TYPE=TEXT NAME=BOOTDIR VALUE=\"" myConf["BOOTDIR"] "\"></TD></TR>";
} else {
	myStr = myStr "<INPUT TYPE=HIDDEN NAME=BOOTDIR VALUE=\"" myConf["BOOTDIR"] "\">";
}
	if (ip6enabled == 1){ myRowspan = 7;} else { myRowspan = 8;}
	myStr = myStr "<TR><TH class=right>BOOT FROM : </TH><TD class=left><INPUT TYPE=RADIO NAME=BOOT VALUE=flash" flash ">Fritz flash</TD><TD class=left><INPUT TYPE=RADIO NAME=BOOT VALUE=usb" usb ">USB stick</TD></TR>";
	if (BoxType == 72) {
		myStr = myStr "<TR><TH class=right>LOG TO : </TH><TD class=left><INPUT TYPE=RADIO NAME=LOGTO VALUE=internal " loginternal "> nhipt-deamon</TD><TD class=left><INPUT TYPE=RADIO NAME=LOGTO VALUE=syslog " logsyslog "> syslog-deamon </TD></TR>";
	} else {
		myStr = myStr "<INPUT TYPE=HIDDEN NAME=LOGTO VALUE=syslog>"
	}
	if (BoxType == 73) {
		myModules["ip_conntrack"] = 1;
		myModules["ip_nat"] = 1;
		myModules["iptable_mangle"] = 1;
	}
	myStr = myStr "<TR><TH class=right>ADMIN LEVEL : </TH><TD class=left><INPUT TYPE=RADIO NAME=AIRBAG VALUE=0 " admunsafe "> advanced</TD><TD class=left><INPUT TYPE=RADIO NAME=AIRBAG VALUE=1 " admsafe "> safe</TD></TR>";
	myStr = myStr "<TR><TH class=right>BOOT DELAY : </TH><TD class=left><SELECT NAME=DELAY>" cbOption(myConf["DELAY"],0,"OFF") cbOption(myConf["DELAY"],30,"30 sec") cbOption(myConf["DELAY"],60,"1 min") cbOption(myConf["DELAY"],180,"3 min") cbOption(myConf["DELAY"],300,"5 min") cbOption(myConf["DELAY"],600,"10 min")"</TD><TD class=left><INPUT TYPE=CHECKBOX NAME=DSLDOFF VALUE=1 " dsldoff "> stop dsld on delay</TD></TR>";
	myStr = myStr "<TR><TH class=right ROWSPAN=" myRowspan ">EXTRAS : </TH><TH class=left>" cbModule("ip_conntrack", "CONNTRACK") "</TH><TH class=left>" cbModule("ip_nat", "NAT") "</TH></TR>";
	if (BoxType != 73) {
		myStr = myStr "<TR><TD class=left>" cbModule("ip_conntrack_ftp", "ftp")   "</TD><TD class=left>" cbModule("ip_nat_ftp","ftp") "</TD></TR>";
	}
	myStr = myStr "<TR><TD class=left>" cbModule("ip_conntrack_h323", "h323") "</TD><TD class=left>" cbModule("ip_nat_h323","h323") "</TD></TR>";
	myStr = myStr "<TR><TD class=left>" cbModule("ip_conntrack_irc", "irc")   "</TD><TD class=left>" cbModule("ip_nat_irc", "irc") "</TD></TR>";
	myStr = myStr "<TR><TD class=left>" cbModule("ip_conntrack_pptp", "pptp") "</TD><TD class=left>" cbModule("ip_nat_pptp", "pptp") "</TD></TR>";
	myStr = myStr "<TR><TD class=left>" cbModule("ip_conntrack_tftp", "tftp") "</TD><TD class=left>" cbModule("ip_nat_tftp", "tftp") "</TD></TR>";
	if (ip6enabled == 0){
		myStr = myStr "<TR><TH class=left>" cbModule("iptable_mangle", "mangle")  "</TH><TH class=left>" cbModule("iptable_raw", "raw")  "</TH></TR>";
		myStr = myStr "<TR><TH class=left>" cbModule("ip6table_mangle", "mangle [ipv6]")  "</TH><TH class=left>" cbModule("ip6table_raw", "raw [ipv6]")  "</TH><TD><INPUT TYPE=SUBMIT NAME=SESAV VALUE=set></TD></TR>";}
	else {
		myStr = myStr "<TR><TH class=left>" cbModule("iptable_mangle", "mangle")  "</TH><TH class=left>" cbModule("iptable_raw", "raw")  "</TH><TD><INPUT TYPE=SUBMIT NAME=SESAV VALUE=set></TD></TR>";}
	myStr = myStr "</FORM></TABLE>";
	return myStr;
}
function html(value) {
	gsub(/&/, "\\&amp;", value);
	gsub(/</, "\\&lt;", value);
	gsub(/>/, "\\&gt;", value);
	gsub(/\42/, "\\&quot;", value);
	gsub(/\47/, "\\&#39;", value);
	return value;
}
function cbOption(comp, value, caption){if (comp==value){checked=" SELECTED";} else {checked="";} return "<OPTION VALUE=\"" value "\" " checked ">" caption "</OPTION>";}
function cbModule(name,caption){ return ("<INPUT TYPE=CHECKBOX NAME=\"" name "\"  VALUE=\"" name "\"  " checkModule(name)  "> " caption);}
function checkModule (name){	if (myModules[name] == 1) {return " checked";} else {return "";}}

function AdminButtons(){
	if (check["changed"] == 0)   {prStyle = "ok";} else {prStyle = "error";}
	if (check["log_deamon"] == 0){lgStyle = "ok"; lgAction="<INPUT TYPE=SUBMIT NAME=STOPLOG VALUE=\"stop logging\">"; } else {lgStyle = "error"; lgAction="<INPUT TYPE=SUBMIT NAME=STRTLOG VALUE=\"start logging\">";}
	myStr = "<TABLE cellspacing=\"0\" WIDTH=100%><TR><TH COLSPAN=3>ACTIONS</TH></TR>";
	myStr = myStr "<FORM METHOD=POST ACTION=" myURL "?J=" JumpMark "#END" JumpMark">" csrfInput "<TR><TD COLSPAN=3 CLASS=" prStyle "><INPUT TYPE=SUBMIT NAME=PERSIST VALUE=\"persist rules\"></TD></TR>";
	if (nolog == 0){
		myStr = myStr "<TR CLASS=solid><TD COLSPAN=3 CLASS=" lgStyle ">" lgAction "</TD></TR>\
		<TR CLASS=solid><TD COLSPAN=3><INPUT TYPE=SUBMIT NAME=GETSTAT VALUE=\"check status\"></TD></TR>\
		<TR CLASS=solid></TR>\
		<TR CLASS=solid></TR>\
		<TR CLASS=solid><TD><INPUT TYPE=SUBMIT NAME=GETFWLOG VALUE=\"list fw log\"></TD><TD><INPUT TYPE=SUBMIT NAME=SAVFWLOG VALUE=\"arch fw log\"></TD><TD><INPUT TYPE=SUBMIT NAME=CUTFWLOG VALUE=\"trunc fw log\"></TD></TR>\
		<TR CLASS=solid><TD><INPUT TYPE=SUBMIT NAME=GETSYSLOG VALUE=\"list syslog\"></TD><TD><INPUT TYPE=SUBMIT NAME=SAVSYSLOG VALUE=\"arch syslog\"></TD><TD><INPUT TYPE=SUBMIT NAME=CUTSYSLOG VALUE=\"trunc syslog\"></TD></TR>\
		</FORM>";
	} else {
		myStr = myStr "<TR CLASS=solid><TD COLSPAN=3><INPUT TYPE=SUBMIT NAME=GETSTAT VALUE=\"check status\"></TD></TR>\
		<TR CLASS=solid><TD><INPUT TYPE=SUBMIT NAME=GETFWLOG VALUE=\"list fw log\"></TD></TR>\
		<TR CLASS=solid><TD><INPUT TYPE=SUBMIT NAME=GETSYSLOG VALUE=\"list syslog\"></TD></TR>\
		</FORM>";
	}
	myStr = myStr "</TABLE>";
	return myStr;
}
function myTBHL (chain) {
	formPrinted = 1;
	print "<FORM METHOD=POST ACTION=" myURL "?J=" JumpMark "#" table ipv6 chain JumpMark ">" csrfInput
	print "<TR class=solid><TD COLSPAN=\"11\" class=noborder><A NAME=" table ipv6 chain CurrentJumpMark "><INPUT TYPE=HIDDEN NAME=CHAIN VALUE=" chain "><INPUT TYPE=HIDDEN NAME=TABLE VALUE=" table "><INPUT TYPE=HIDDEN NAME=IPV6 VALUE=" ipv6 ">&nbsp;</TD></TR><TR><TH COLSPAN=\"11\">RULES FOR CHAIN " chain " [ " table " ] [ " ipv6txt " ]</TH></TR>";
	print "<TR><TH>ID</TH><TH>Source IP</TH><TH>Dest IP</TH><TH>In IFC</TH><TH>Out IFC</TH><TH>Prot</TH><TH>Module</TH><TH>S-Port</TH><TH>D-Port</TH><TH>Action</TH><TH>Param</TH><TH>Edit</TH></TR>";
}

{
	if (FILENAME != myFile){
		if (formPrinted == 1){
			CurrentChain = myArray["Chain"];
			for (y=1;y<=nTables;y++) { if (Chains[y,1]==CurrentChain) {Chains[y,2] = 1;}}
			if (inSubTable ==1) {inSubTable=0; print "</TABLE><P></TD><TD></TD></TR>"}
			print myDD(i) myFL myTT(CChains,nCChains,CurrentChain) myFR;
		}
		if (inSubTable ==1) {
			if (MySection == "-P") {
				print "<TR><TD COLSPAN=4 class=noborder>&nbsp;</TD></TR><TR><TH COLSPAN=4>CUSTOM CHAINS</TH></TR>";
				inSubTable=1;
				print "<FORM METHOD=POST ACTION=" myURL "?J=" JumpMark "#P" table ipv6 JumpMark ">" csrfInput "<TR><TD COLSPAN=2><INPUT TYPE=HIDDEN NAME=TABLE VALUE=" table "><INPUT TYPE=HIDDEN NAME=IPV6 VALUE=" ipv6 "><INPUT TYPE=TEXT NAME=CHAIN></TD><TD COLSPAN=2><INPUT TYPE=SUBMIT NAME=MODE VALUE=New></TD></TR></FORM>";
			}
			inSubTable=0; print "</TABLE><P></TD><TD CLASS=noborder COLSPAN=9></TD></TR>"
		}
		for (y=1;y<=nTables;y++) { if (Chains[y,2]==0) { myTBHL(Chains[y,1]); print myDD(1) myFL myTT(CChains,nCChains,Chains[y,1]) myFR;}}

		if (index(FILENAME,"ip6") > 0){ipv6 = 1; ipv6txt = "IPv6"; table = FILENAME; gsub(/\/var\/tmp\/ip6t/,"",table); gsub(/.tmp/,"",table);} else { ipv6 = 0;  ipv6txt = "IPv4"; table = FILENAME; gsub(/\/var\/tmp\/ipt/,"",table); gsub(/.tmp/,"",table);}
		i = 0;
		formPrinted = 0;
		nTables = 0;
		nCChains = 0;
		delete Chains;
		delete CChains;
		myFile = FILENAME;
		MySection = ""

		if (inSubTable ==1) {inSubTable=0;
				print "</TABLE><P></TD><TD CLASS=noborder COLSPAN=9></TD></TR>"
			}
		print "<TR class=solid><TD COLSPAN=\"3\" class=noborder><TABLE cellspacing=0>";
		print "<TR><TD COLSPAN=12 CLASS=noborder></TD><TR><TH COLSPAN=4>RULES FOR TABLE [ " table " ] [ " ipv6txt " ]</TD></TR>";
	}
	InIF=0;
	OutIF=0;
	SourceIP=0;
	DestIP=0;
	Mode=0;
	SourcePort=0;
	DestPort=0;
	delete myArray;
	myArray["Extra"]=" ";
	myArray["Action"]=$1;
	myArray["Chain"]=$2;
	if (myArray["Action"] == "-P") {
		myArray["Target"]=$3;
		if (MySection != $1)
			{ inSubTable=1; print "<TR><TH COLSPAN=4><A NAME=P" table ipv6 CurrentJumpMark ">DEFAULT POLICIES</TH></TR><TR><TH>CHAIN</TH><TH>POLICY</TH><TH COLSPAN=2>EDIT</TH></TR>"; }
		nTables++;
		Chains[nTables,1] = $2;
		Chains[nTables,2] = 0;
		if (myArray["Target"] == "ACCEPT") {NewPol = "DROP";} else {NewPol = "ACCEPT";}
		print "<TR><TD>" myArray["Chain"] "</TD><TD class=" myArray["Target"] ">" myArray["Target"] "</TD><TD><A HREF=" myURL "?MODE=POL&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&POL=" NewPol "&J=" JumpMark "#P" table ipv6 JumpMark " onclick=\"return csrfPost(this.href)\">[change]</A></TD><TD><A HREF=" myURL "?MODE=POL&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&POL=PURGE&J=" JumpMark "#P" table ipv6 JumpMark " onclick=\"return csrfPost(this.href)\">[purge]</A></TD></TR>";
	} else if (myArray["Action"] == "-N") {
		if (MySection != $1) {inSubTable=1; print "<TR><TD COLSPAN=4 class=noborder>&nbsp;</TD></TR><TR><TH COLSPAN=4>CUSTOM CHAINS</TH></TR>"; }
		nTables++;  Chains[nTables,1] = $2; Chains[nTables,2] = 0;
		nCChains++; CChains[nCChains] = $2;
		inSubTable=1;
		print "<TR><TD COLSPAN=\"2\">" myArray["Chain"] "</TD><TD><A HREF=" myURL "?MODE=POL&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&POL=DEL&J=" JumpMark "#P" table ipv6 JumpMark " onclick=\"return csrfPost(this.href)\">[Del]</A></TD><TD><A HREF=" myURL "?MODE=POL&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&POL=PURGE&J=" JumpMark "#P" table ipv6 JumpMark " onclick=\"return csrfPost(this.href)\">[purge]</A></TD></TR>";
	} else {
		if (MySection != $1){
			if (MySection != "-N") { print "<TR><TD COLSPAN=4 class=noborder>&nbsp;</TD></TR><TR><TH COLSPAN=4>CUSTOM CHAINS</TH></TR>"; }
			inSubTable=1;
			print "<FORM METHOD=POST ACTION=" myURL "?J=" JumpMark "#P" table ipv6 JumpMark ">" csrfInput "<TR><TD COLSPAN=2><INPUT TYPE=HIDDEN NAME=TABLE VALUE=" table "><INPUT TYPE=HIDDEN NAME=IPV6 VALUE=" ipv6 "><INPUT TYPE=TEXT NAME=CHAIN></TD><TD COLSPAN=2><INPUT TYPE=SUBMIT NAME=MODE VALUE=New></TD></TR></FORM>";
			if (settingsPrinted == 0) {settingsPrinted=1;
				print "</TABLE><P></TD><TD COLSPAN=6 class=noborder>" AdminIFC() "</TD><TD class=noborder></TD><TD COLSPAN=2 class=noborder>" AdminButtons() "</TD></TR>";
				inSubTable=0;
				print "<FORM METHOD=POST ACTION=" myURL ">" csrfInput;
			print "<TR><TH COLSPAN=\"2\">Experts only: iptables / ip6tables </TH><TD COLSPAN=\"9\"><INPUT TYPE=TEXT NAME=EXPERT class=expert></TD><TD><INPUT TYPE=SUBMIT NAME=EXEC VALUE=execute></TD></TR></FORM>";
				} else {inSubTable=0; print "</TABLE><P></TD><TD CLASS=noborder COLSPAN=9></TD></TR>"}
			}
		if (CurrentChain != myArray["Chain"]) {
			if (i > 0){
				print myDD(i) myFL myTT(CChains,nCChains,CurrentChain) myFR;
				for (y=1;y<=nTables;y++) { if (Chains[y,1]==CurrentChain) {Chains[y,2] = 1;}}
			}
			myTBHL(myArray["Chain"]);
			i = 1;
			CurrentChain = myArray["Chain"];
		}
		x="";
		for ( j = 3; j <= NF; j++ ) {
			if ($j == "-s")					{j++; if ($j == "!") {j++; myArray["SourceIP"] = "!" $j;} else {myArray["SourceIP"] = $j;}}
			else if ($j == "-d")			{j++; if ($j == "!") {j++; myArray["DestIP"]   = "!" $j;} else {myArray["DestIP"]   = $j;}}
			else if ($j == "-i")			{j++; if ($j == "!") {j++; myArray["InIF"]     = "!" $j;} else {myArray["InIF"]     = $j;}}
			else if ($j == "-o")			{j++; if ($j == "!") {j++; myArray["OutIF"]    = "!" $j;} else {myArray["OutIF"]    = $j;}}
			else if ($j == "-p")			{j++; if ($j == "!") {j++; myArray["Prot"]     = "!" $j;} else {myArray["Prot"]     = $j;}}
			else if ($j == "-m")			{j++; myArray["Module"] = myArray["Module"] $j " ";}
			else if ($j == "!")             {x="!";}
			else if ($j == "--src-range")	{j++; myArray["SourceIP"] = x $j; x="";}
			else if ($j == "--dst-range")	{j++; myArray["DestIP"] = x $j;   x="";}
			else if ($j == "--sport")		{j++; if ($j == "!") {j++; myArray["Sport"]     = "!" $j;} else {myArray["Sport"]    = $j;}}
			else if ($j == "--dport")		{j++; if ($j == "!") {j++; myArray["Dport"]     = "!" $j;} else {myArray["Dport"]    = $j;}}
			else if ($j == "--sports")		{j++; if ($j == "!") {j++; myArray["Sport"]     = "!" $j;} else {myArray["Sport"]    = $j;}}
			else if ($j == "--dports")		{j++; if ($j == "!") {j++; myArray["Dport"]     = "!" $j;} else {myArray["Dport"]    = $j;}}
			else if ($j == "--ports")		{j++; if ($j == "!") {j++; myArray["Dport"]     = "!" $j;} else {myArray["Dport"]    = $j;} myArray["Sport"] = myArray["Dport"]}
			else if ($j == "--state")		{j++; myArray["State"] = $j " ";}
			else if ($j == "-j")			{j++; myArray["Target"] = $j;}
			else if ($j == "--log-prefix")	{j++; myArray["Log"] = $j;     ixx = length($j); if (index($j, "\"") > 0 && substr($j,ixx,1) != "\"") {do {j++; myArray["Log"] = myArray["Log"] " " $j " "; if (index($j, "\"") > 0) break;} while (j <= NF)}}
			else if ($j == "--comment")		{j++; myArray["Comment"] = $j; ixx = length($j); if (index($j, "\"") > 0 && substr($j,ixx,1) != "\"") {do {j++; myArray["Comment"] = myArray["Comment"] " " $j " "; if (index($j, "\"") > 0) break;} while (j <= NF)}}
			else if ($j == "--reject-with")	{j++; myArray["Rej"] = $j " ";}
			else					  		{myArray["Extra"] = myArray["Extra"] $j " "; j++; myArray["Extra"] = myArray["Extra"] $j " ";}
		}
		if (editRule==1 && Param["TABLE"] == table && Param["CHAIN"] == myArray["Chain"] && Param["IDX"] == i && Param["IPV6"] == ipv6){
			myRule=$0; gsub(/\"/,"\47", myRule); gsub("-A " myArray["Chain"],"-t " table " -R " myArray["Chain"] " " i " ", myRule);
			if (ipv6 == 1) {myCmd = "ip6tables ";} else {myCmd = "iptables ";}
			print "<TR><TD>" i "</TD><TD><B>iptables / ip6tables</B></TD><TD COLSPAN=9><INPUT TYPE=TEXT NAME=EXPERT class=expert VALUE=\"" html(myCmd myRule) "\"></TD><TD><INPUT TYPE=SUBMIT NAME=EXEC VALUE=execute></TD></TR></FORM>";
		} else {
			print "<TR><TD>&nbsp;" i "</TD><TD>&nbsp;" \
			myArray["SourceIP"] "</TD><TD>&nbsp;" myArray["DestIP"] "</TD><TD>&nbsp;" myArray["InIF"] "</TD><TD>&nbsp;" \
			myArray["OutIF"] "</TD><TD>&nbsp;" myArray["Prot"] "</TD><TD>&nbsp;" myArray["Module"] "</TD><TD>&nbsp;" \
			myArray["Sport"] "</TD><TD>&nbsp;" myArray["Dport"] "</TD><TD>&nbsp;" myArray["Target"] "</TD><TD>&nbsp;" \
			html(myArray["Rej"] myArray["Log"] myArray["State"] myArray["Extra"] myArray["Comment"]) "</TD><TD nowrap><A HREF=" myURL "?MODE=UP&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&IDX=" i "&J=" JumpMark "#" table ipv6 myArray["Chain"] JumpMark " onclick=\"return csrfPost(this.href)\">[UP]</A> <A HREF=" myURL "?MODE=DN&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&IDX=" i "&J=" JumpMark "#" table ipv6 myArray["Chain"] JumpMark " onclick=\"return csrfPost(this.href)\">[DN]</A> <A HREF=" myURL "?MODE=DEL&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&IDX=" i "&J=" JumpMark "#" table ipv6 myArray["Chain"] JumpMark " onclick=\"return csrfPost(this.href)\">[Del]</A> <A HREF=" myURL "?MODE=EDT&IPV6=" ipv6 "&TABLE=" table "&CHAIN=" myArray["Chain"] "&IDX=" i "&J=" JumpMark "#" table ipv6 myArray["Chain"] JumpMark ">[Edit]</A></TD></TR>"
		}
		i++;
	}
	MySection = $1;
    }

     END {
	if(exitSwitch==1){exit 0;}
	if (MySection == "-P") {
		print "<TR><TD COLSPAN=4 class=noborder>&nbsp;</TD></TR><TR><TH COLSPAN=4>CUSTOM CHAINS</TH></TR>";
		inSubTable=1;
		print "<FORM METHOD=POST ACTION=" myURL "?J=" JumpMark "#P" table ipv6 JumpMark ">" csrfInput "<TR><TD COLSPAN=2><INPUT TYPE=HIDDEN NAME=TABLE VALUE=" table "><INPUT TYPE=HIDDEN NAME=IPV6 VALUE=" ipv6 "><INPUT TYPE=TEXT NAME=CHAIN></TD><TD COLSPAN=2><INPUT TYPE=SUBMIT NAME=MODE VALUE=New></TD></TR></FORM>";
		}
	if (inSubTable ==1) {
		 inSubTable=0;
			if (settingsPrinted == 0) {settingsPrinted=1;
				print "</TABLE><P></TD><TD COLSPAN=6 class=noborder>" AdminIFC() "</TD><TD class=noborder></TD><TD COLSPAN=2 class=noborder>" AdminButtons() "</TD></TR>";
				inSubTable=0;
				print "<FORM METHOD=POST ACTION=" myURL ">" csrfInput;
			print "<TR><TH COLSPAN=\"2\">Experts only: iptables / ip6tables </TH><TD COLSPAN=\"9\"><INPUT TYPE=TEXT NAME=EXPERT class=expert></TD><TD><INPUT TYPE=SUBMIT NAME=EXEC VALUE=execute></TD></TR></FORM>";
				} else {inSubTable=0; print "</TABLE><P></TD><TD CLASS=noborder COLSPAN=9></TD></TR>"}
		 }
	if (formPrinted == 1){
		CurrentChain = myArray["Chain"];
		for (y=1;y<=nTables;y++) { if (Chains[y,1]==CurrentChain) {Chains[y,2] = 1;}}
		print myDD(i) myFL myTT(CChains,nCChains,CurrentChain) myFR;
	}
	for (y=1;y<=nTables;y++) { if (Chains[y,2]==0) { myTBHL(Chains[y,1]); print myDD(1) myFL myTT(CChains,nCChains,Chains[y,1]) myFR;}}
	print "<TR class=solid><TD COLSPAN=\"12\" class=noborder><A NAME=END" CurrentJumpMark ">&nbsp;</TD></TR>";
	while ((ret = getline test < "/var/tmp/nhipt.log") > 0) {
		print "<TR><TD COLSPAN=\"12\" class=log>" html(test) "</TD></TR>";
	}
	if (ret==0){close("/var/tmp/nhipt.log"); system("rm /var/tmp/nhipt.log");}
	print "</TABLE>";
	print "</BODY>";
	print "</HTML>";
	}' /var/tmp/iptfilter.tmp /var/tmp/iptnat.tmp /var/tmp/iptmangle.tmp /var/tmp/iptraw.tmp /var/tmp/ip6tfilter.tmp /var/tmp/ip6tmangle.tmp /var/tmp/ip6traw.tmp)"
rm /var/tmp/ip*.tmp
myfile=$(echo "$PWD" | sed s/cgi-bin/index.html/)
if [ ! -r $myfile ]
then
cat << EOF > $myfile
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
   "http://www.w3.org/TR/html4/frameset.dtd">
<html>
<head>
<title>NHIPT-IPTABLES FIREWALL ADMIN</title>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
</head>
<frameset rows="*">
<frame src="/cgi-bin/nhipt.cgi" name="topframe" scrolling="auto" frameborder="0">
<noframes>
<body>
<p>Der Browser unterst&uuml;tzt keine Frames!
<a href="/cgi-bin/nhipt.cgi">Klick mich</a></p>
</body>
</noframes>
</frameset>
</html>

EOF

fi
fi
###########
### EOF ###
###########
