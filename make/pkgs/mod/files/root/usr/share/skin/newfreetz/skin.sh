skin_head() {
	local title=$1 id=$2
	local hname="$(hostname -s|html)"
	[ "$hname" != "fritz" ] && hname="&#64;${hname}&nbsp;" || hname=""
	cat << EOF
<title>Freetz-NG&nbsp;${hname}&ndash; $title</title>
<link rel="stylesheet" type="text/css" href="/style/newfreetz/base.css">
<link rel="stylesheet" type="text/css" href="/style/newfreetz/colorscheme.css">
EOF
	_cgi_print_extra_styles

	# If there is no menu, we make the space available to the content.
	[ -z "$id" ] && let _cgi_width+=180

	# The width of the whole cgi: There are 20px border, 20 px space
	# and 180px for the menu area.
	let _cgi_content_width=_cgi_width+30
	let _cgi_border_width=_cgi_content_width-20
	let _cgi_total_width=_cgi_content_width+20
	[ -z "$id" ] || let _cgi_total_width+=180
	let _cgi_title_box_width=_cgi_total_width+11
	let _cgi_title_box_mid_width=_cgi_total_width-49
	let _cgi_title_box_version_width=_cgi_total_width-255

	# If there is no menu, we can use the space between menu and content.
	[ -z "$id" ] && let _cgi_content_width+=20 && let _cgi_border_width+=20

	export _cgi_content_width
}

skin_body_begin() {
	local title=$1 id=$2
	local help=""
	if [ -n "$_CGI_HELP" ]; then
		help="&nbsp;<span class='help'>(<a href='$(html "$_CGI_HELP")' target='_blank'>$(lang de:"Hilfe" en:"Help")</a>)</span>"
	fi
	cat << EOF
	<div id="wrapper" style="width:${_cgi_total_width}px">
	<div id="title-box" style="width:${_cgi_title_box_width}px">
		<div id="title-box-left"></div>
		<div id="title-box-mid" style="width:${_cgi_title_box_mid_width}px"></div>
		<div id="title-box-right"></div>
		<div id="title-box-logo"><a href="https://freetz-ng.github.io" target="_blank" class="logo"><img src="/images/newfreetz/freetz_logo.gif"></a></div>
		<div id="title-box-fun">the fun has just begun ...</div>
		<div id="title-box-version" style="width:${_cgi_title_box_version_width}px">$(html < /etc/.freetz-version)</div>
	</div>
	<div id="contentwrapper" style="width:${_cgi_total_width}px">
EOF

    if [ -n "$id" ]; then
	cat << EOF
<div id="menu">
	<div style>
		<div id="menu-top-left"></div>
		<div id="menu-top"></div>
		<div id="menu-top-right"></div>
	</div>
	<div id="menu-back">
		<div id="menucontainer">
EOF

 _cgi_print_menu "$id"

cat << EOF
		</div>
	</div>
	<div style>
		<div id="edge-bot-left"></div>
		<div id="menu-bot"></div>
		<div id="edge-bot-right"></div>
	</div>
</div>
EOF
fi
cat << EOF
<div id="edge" style="width:${_cgi_content_width}px">
	<div id="top">
		<div id="edge-top-left"></div>
		<div id="edge-top" style="width:${_cgi_border_width}px"></div>
		<div id="edge-top-right"></div>
		<div id="titlebar"><span class="title">$title</span>$help</div>
	</div>

	<div id="container">
EOF
}

skin_body_end() {
	cat << EOF
	</div>

	<div style>
		<div id="edge-bot-left"></div>
		<div id="edge-bot" style="width:${_cgi_border_width}px"></div>
		<div id="edge-bot-right"></div>
	</div>

	<div id="footer">
		<span class="datetime" title="$(lang de:"Systemzeit des Routers" en:"Router's system time")">$(date +"$(lang de:"%d.%m.%Y" en:"%m/%d/%Y") %H:%M")</span>&nbsp;&ndash;
		<span class="uptime" title="Uptime">$(uptime | sed -r 's/.*(up.*), *load.*/\1/')</span>&nbsp;&ndash;
		<span class="opt">$(lang de:"optimiert f&uuml;r" en:"optimized for") Mozilla Firefox</span>
	</div>
</div>
</div>
</div>
EOF
}

skin_sec_begin() {
echo "<h1>$1</h1>"
}

skin_sec_end() {
let _cgi_breakline_width=_cgi_content_width-2
echo "<div id='breakline' style='width:${_cgi_breakline_width}px'></div>"
}
