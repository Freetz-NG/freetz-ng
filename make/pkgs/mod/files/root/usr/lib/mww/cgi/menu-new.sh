_cgi_mark_active() {
	local sub=$1 id=$2
	sed -r "
		s# id=(['\"])($id)\1# class='active'&#
		s#(<li)([^>]*>.* id=(['\"])($sub)\3)#\1 class='open'\2#
		s# id=\"[^\"]*\"##
		s# id='[^']*'##
		s# class='([^']*)' class='([^']*)'# class='\1 \2'#g
	"
}
_cgi_submenu() {
	local id=$1
	case $id in
		status*|daemons) sub=status ;;
		system|avmwif_*|rudi_*|firmware_*|backup_*|uimods|support_*|freetz) sub=system ;;
		*:*) sub=${id#*:}; sub="pkg:${sub%%:*}" ;;
	esac
	echo "$sub"
}

_cgi_print_menu() {
	local id=$1
	local sub=$(_cgi_submenu "$id")
	new_menu | _cgi_mark_active "$sub" "$id"
}
_cgi_print_submenu() {
	local id=$1
	local sub=$(_cgi_submenu "$id")
	new_submenu "$sub" | _cgi_mark_active "" "$id"
}

MENU_CACHE=/mod/var/cache/menu

# Beware: This function will change the working directory
new_menu_init() {
	if ! [ -e "$MENU_CACHE.stale" ] && cd "$MENU_CACHE"; then
		return
	fi 2> /dev/null
	rm -f "$MENU_CACHE.stale"

	# prepare new menu in a private place
	local base=${MENU_CACHE##*/}
	local dir=${MENU_CACHE%/*}
	local tmp="$MENU_CACHE.$$"
	new_menu_prepare "$tmp/$base"

	# set working directory to new menu to allow delivery
	cd "$tmp/$base"

	{ {
		# replace main copy (perhaps multiple tries needed);
		# last writer wins; this can be done asynchronously
		local n=0
		while ! mv "$tmp/$base" "$dir"; do
			# remove old copy
			mv "$MENU_CACHE" "$tmp/old.$n"
			let n++
		done 2>/dev/null

		# give readers of old menu a chance
		sleep 1

		# clean up
		rm -rf "$tmp"
	} & } & # double fork to prevent zombies
}

new_menu() {
	local sub=$1
	(
		new_menu_init
		new_menu_deliver "$sub"
	)
}

# display only the current submenu
new_submenu() {
	local sub=$1 dir=$MENU_CACHE
	[ -z "$sub" ] && return
	(
		new_menu_init
		echo "<ul class='menu new sub'>"
		case $sub in
			pkg:*) cat "./pkg/${sub#pkg:}.sub" ;;
			*) cat "./$sub.sub" ;;
		esac
		echo "</ul>"
	)
}

# deliver menu from the current working directory
new_menu_deliver() {
	local sub=$1 dir=.
	local p="$dir/pkg"

	# assemble new menu

	echo "<ul class='menu new'>"

	new_menu_tree "$dir/status"
	new_menu_tree "$dir/system"
	new_menu_package_tree "mod"
	ls /usr/lib/cgi-bin/conf.avm/* &>/dev/null && new_menu_package_tree "avm"
	echo "<li><a id='logout' onclick='return confirm(\"Logout?\")' href='/cgi-bin/logout.cgi'>Logout</a></li>"
	echo "<hr>"

	while read -r pkg; do
		# ignore "internal" mod and avm packages
		[ "$pkg" = mod -o "$pkg" = avm ] && continue
		new_menu_package_tree "$pkg"
	done < "$dir/packages"

	echo "</ul>"
}

new_menu_tree() {
	local path=$1
	local base=${path##*/}
	echo -n "<li>"
	cat "$path"
	if [ \( "$base" = "$sub" -o -z "$sub" \) -a -s "$path.sub" ]; then
		echo "<ul>"
		cat "$path.sub"
		echo "</ul>"
	fi
	echo "</li>"
}

new_menu_package_tree() {
	local pkg=$1 sub
	if [ "$sub" = "pkg:$pkg" ]; then
		sub=$pkg
	else
		sub=
	fi
	new_menu_tree "$p/$pkg"
}

new_menu_add_pkg_item() {
	local type=$1 pkg=$2 id=$3 title=$4
	local a_id=$(_cgi_id "$type:$pkg${id:+/$id}") a_class=$type
	local a_href=$(href "$type" "$pkg" "$id")
	echo "<li><a id='$a_id' class='$a_class' href='$a_href'>$(html "$title")</a></li>" >> "$p/$pkg.sub"
	if [ ! -e "$p/$pkg.index" ]; then
		echo "$a_href" > "$p/$pkg.index"
	fi
}

new_menu_prepare() {
	local dir=$1
	local p="$dir/pkg"
	rm -rf "$dir"
	mkdir -p "$p"

	# collect data for packages
	if [ -r /mod/etc/reg/pkg.reg ]; then
		local pkg title escaped="'\''"
		while IFS='|' read -r pkg title; do
			echo "title='${title//\'/$escaped}'" >> "$p/$pkg.meta"
		done < /mod/etc/reg/pkg.reg
	fi

	if [ -r /mod/etc/reg/conf.reg ]; then
		local pkg id title
		while IFS='|' read -r pkg id title; do
			new_menu_add_pkg_item conf "$pkg" "$id" "$title"
		done < /mod/etc/reg/conf.reg
	fi

	if [ -r /mod/etc/reg/file.reg ]; then
		local pkg id title sec def _
		# sort by title
		while IFS='|' read -r pkg id _; do
			echo "$_|$pkg|$id"
		done  < /mod/etc/reg/file.reg | sort |
		while IFS='|' read -r title sec def pkg id; do
			new_menu_add_pkg_item file "$pkg" "$id" "$title"
		done
	fi

	if [ -r /mod/etc/reg/extra.reg ]; then
		while IFS='|' read -r pkg title sec cgi; do
			[ -z "$title" ] && continue
			new_menu_add_pkg_item extra "$pkg" "$cgi" "$title"
		done < /mod/etc/reg/extra.reg
	fi

	# system menu
	{
		cat << EOF
<li><a id="backup_restore" href="/cgi-bin/backup/index.cgi">$(lang de:"Sichern &amp; Wiederherstellen" en:"Backup &amp; restore")</a></li>
EOF
		[ -d /usr/mww/cgi-bin/update ] && cat << EOF
<li><a id="firmware_update" href="$(href mod update)">$(lang de:"Firmware-Update" en:"Firmware update")</a></li>
EOF
		[ -x /usr/mww/cgi-bin/uimods.cgi ] && cat << EOF
<li><a id="uimods" href="/cgi-bin/uimods.cgi">$(lang de:"FOS UI-Module" en:"FOS UI-Modules")</a></li>
EOF
		cat << EOF
<li><a id="support_file" href="/cgi-bin/support/index.cgi">$(lang de:"Supportdatei erstellen" en:"Create support file")</a></li>
<li><a id="rudi_shell" href="/cgi-bin/shell/index.cgi" target="_blank">$(lang de:"Rudi-Shell" en:"Rudi shell")</a></li>
<li><a id="avmwif_link" href="/cgi-bin/avm" target="_blank">$(lang de:"AVM-Webinterface" en:"AVM web interface")</a></li>
<li><a id="freetz" href="/cgi-bin/freetz.cgi">$(lang de:"&Uuml;ber" en:"About") Freetz-NG</a></li>
EOF
	} > "$dir/system.sub"

	{
		if [ -r /mod/etc/reg/status.reg ]; then
			local pkg title cgi
			echo "<li><a id='daemons' href='$(href mod daemons)'>$(lang de:"Dienste" en:"Services")</a></li>"
			while IFS='|' read -r pkg title cgi; do
				echo "<li><a id='$(_cgi_id "status:$pkg/$cgi")' href='$(href status "$pkg" "$cgi")'>$(html "$title")</a></li>"
			done < /mod/etc/reg/status.reg
		fi
	} > "$dir/status.sub"

	# put mod and avm package in front
	echo "mod" > "$dir/packages"
	echo "avm" >> "$dir/packages"
	for i in "$p"/*.sub; do
		pkg=${i##*/}; pkg=${pkg%.sub}
		[ "$pkg" = mod -o "$pkg" = avm ] && continue
		title=$pkg
		if [ -r "$p/$pkg.meta" ]; then
			source "$p/$pkg.meta"
		fi
		echo "$title|$pkg"
	done | tr '[:upper:]' '[:lower:]' | sort |
		cut -d"|" -f2 >> "$dir/packages"

	echo "<a id='status' href='$(href mod status)'>Status</a>" > "$dir/status"
	echo "<a id='system' href='$(href mod system)'>System</a>" > "$dir/system"

	while read -r pkg; do
		new_menu_prepare_package "$pkg" > "$p/$pkg"
	done < "$dir/packages"

	rm -f "$p"/*.meta "$p"/*.index
}

new_menu_prepare_package() {
	local pkg=$1
	title=$pkg
	[ -r "$p/$pkg.meta" ] && source "$p/$pkg.meta"
	echo -n "<a id='$(_cgi_id "pkg:$pkg")' class='package' href='$(cat "$p/$pkg.index")'>$(html "$title")</a>"
}

