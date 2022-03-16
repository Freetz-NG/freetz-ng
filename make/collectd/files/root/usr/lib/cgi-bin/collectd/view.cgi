#!/bin/sh
# cgi for viewing the collectd graphs
# Copyright 2010,  2011 Brian Jensen (Jensen.J.Brian@googlemail.com)


. /usr/lib/libmodcgi.sh

#load the configuration
. /mod/etc/conf/collectd.cfg
. /usr/share/collectd/generate_graphs

[ -n "$COLLECTD_GRAPH_SCRIPT" ] && . $COLLECTD_GRAPH_SCRIPT

HOSTS_DIR=$(cat /tmp/flash/collectd/collectd.conf | sed -e 's/^[ \t]*//' -n -e 's/^DataDir *\"\(.*\)\"/\1/p')
RRDTOOL=$(which rrdtool)

#Error message will be printed later
if [ -d "$HOSTS_DIR" -a -n "$RRDTOOL" ]; then
	HOSTS=$(ls $HOSTS_DIR | grep -v graph)
	CGI_HOST=$(cgi_param host)
	CGI_PLUGIN=$(cgi_param plugin)
	CGI_REFRESH=$(cgi_param refresh)
	SHOW_INTERFACE_ERRORS=$(cgi_param iferrors)

	if [ -n "$CGI_PLUGIN" -a ! "$CGI_PLUGIN" == "All" ]; then
		PERIOD=$COLLECTD_PERIODSSUB
	else
		PERIOD=$COLLECTD_PERIODMAIN
		GRAPH_MAINPAGE="yes"
	fi

	#navigation form
	echo "<form name=\"nav\" type=\"GET\"><center>"
	echo "Host: <select name=\"host\" onChange=\"selectedHostChanged(document.forms.nav.plugin.value);\"></select>"
	echo "&nbsp; Plugin: <select name=\"plugin\"></select>"
	echo "&nbsp; <input type=\"submit\" value=\"Go\">"
	echo "</center></form>"

	#script for filling out the combobox options
	echo "<script type=\"text/javascript\">"
	echo "var Hosts = [];"
	echo "var Plugins  = [];"

	#always have to refresh the available plugins on a per host basis
	echo "function selectedHostChanged(defaultPlugin) {"
	echo "var newIndex = document.nav.host.selectedIndex;"

	#index zero is the special All option
	echo "if(newIndex == 0) {"
	echo "document.forms.nav.plugin.options.length = 1;"
	echo "document.forms.nav.plugin.options[0] = new Option('All');"
	echo "return;"
	echo "}"

	echo "document.forms.nav.plugin.options.length = Plugins[newIndex].length;"
	echo "for ( var i = 0; i < Plugins[newIndex].length; i++) {"
	echo "document.forms.nav.plugin.options[i] = new Option(Plugins[newIndex][i]);"
	echo "if(defaultPlugin == Plugins[newIndex][i]) document.forms.nav.plugin.selectedIndex = i;"
	echo "}"
	echo "}"

	echo "Hosts[0]='All';"
	i=1

	#fill out the available host and plugin arrays
	for HOST in $HOSTS; do
		echo "Hosts[$i]='$HOST';"
		PLUGINS=$(ls $HOSTS_DIR/$HOST/)

		echo "Plugins[$i] = [];"
		echo "Plugins[$i][0] = 'All';"
		j=1
		for PLUGIN in $PLUGINS; do
			echo "Plugins[$i][$j] = '$PLUGIN';"
			j=$(( $j + 1 ))
		done
		i=$(( $i + 1 ))
	done

	mkdir -p "$COLLECTD_GRAPHDIR"

	#set the initial values
	echo "document.forms.nav.host.options  = [];"
	echo "for(var i = 0; i < Hosts.length; i++) {"
	echo "document.forms.nav.host.options[i] = new Option(Hosts[i]);"
	if [ -n "$CGI_HOST" ]; then
		echo "if(Hosts[i] == '$CGI_HOST') document.forms.nav.host.selectedIndex = i;"
	fi
	echo "}"
	echo "selectedHostChanged('$CGI_PLUGIN');"
	echo "</script>"
fi

display_begin()
{
	sec_begin "$1"
}

display_graph()
{
	echo "<center>"
	[ -n "$GRAPH_MAINPAGE" ] && echo "<a href=\"$SCRIPT_NAME?host=$HOST&plugin=$PLUGIN\" class=\"image\">"
	echo "<img src=\"/graph/$HOST/$PLUGIN/$1\" alt=\"$PLUGIN stats for last $PERIOD\" border=\"0\" />"
	[ -n "$GRAPH_MAINPAGE" ] && echo "</a>"
	echo "</center>"
}

display_end()
{
	sec_end
}

process_plugin()
{
	PLUGIN_TITLE=""
	PLUGINDIR=$HOSTS_DIR/$HOST/$PLUGIN
	PLUGIN_GRAPHDIR=$COLLECTD_GRAPHDIR/$HOST/$PLUGIN
	mkdir -p "$PLUGIN_GRAPHDIR"
	graph_plugin

}

process_host()
{
	mkdir -p "$COLLECTD_GRAPHDIR/$HOST"
	PLUGINS=$(ls $HOSTS_DIR/$HOST/)

	echo "<center><h1>$HOST</h1></center>"

	if [ -n "$CGI_PLUGIN" -a "y" == $(echo $PLUGINS | sed  "s/.*$CGI_PLUGIN.*/y/") ]; then
		PLUGIN="$CGI_PLUGIN"
		process_plugin
	else
		for PLUGIN in $PLUGINS; do
			if [ -n "$GRAPH_MAINPAGE" -a -n "$COLLECTD_MAINPAGE_PLUGINS" ]; then
				[ "y" == $(echo "$COLLECTD_MAINPAGE_PLUGINS" | sed  "s/.*$PLUGIN.*/y/") ] && \
					process_plugin
			else
				process_plugin
			fi
		done
	fi
}

if [ -n "$CGI_HOST" -a "y" == $(echo $HOSTS | sed  "s/.*$CGI_HOST.*/y/") ]; then
	HOST=$CGI_HOST
	process_host
elif [ -n "$HOSTS" ]; then
	for HOST in $HOSTS; do
		if [ -n "$COLLECTD_MAINPAGE_HOSTS" ]; then
			[ "y" == $(echo "$COLLECTD_MAINPAGE_HOSTS" | sed  "s/.*$HOST.*/y/") ] && \
				process_host
		else
			process_host
		fi
	done
else
	print_error "RRD Data directory is not valid or rrdtool was not found"
fi
