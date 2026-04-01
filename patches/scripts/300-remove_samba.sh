
# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)

# AVM scripts should not kill Freetz Samba
if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" -a "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" ]; then
	echo1 "prevent stopping smbd"
	sed -i -e "/killall smbd*$/d" -e "s/pidof smbd/pidof/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
fi

# remove AVM's specific samba files
if [ "$FREETZ_REMOVE_SAMBA" == "y" -o "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" ]; then
	echo1 "remove AVM samba/nqcs config"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/bin/samba_config_gen" \
	  "${FILESYSTEM_MOD_DIR}/sbin/samba_config_gen"

	if [ "$FREETZ_AVM_HAS_SAMBA_SMBD" == "y" ]; then
		echo1 "remove AVM smbd config"
		rm_files \
		  "${FILESYSTEM_MOD_DIR}/bin/inetdsamba" \
		  "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar" \
		  "${FILESYSTEM_MOD_DIR}/lib/libsamba.so"
	fi

	if [ -n "$SYSTEMD_CORE_MOD_DIR" ]; then
		echo1 "remove AVM systemd files"
		rm_files \
		  "${FILESYSTEM_MOD_DIR}/etc/onlinechanged/start_smbd" \
		  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.smb2"
		supervisor_delete_service "smb2"
	fi

	echo1 "patching rc.net: renaming sambastart()"
	modsed 's/^\(sambastart *()\)/\1{ return; }\n_\1/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"

	# patcht Heimnetz > Speicher (NAS)
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e "$sedfile" ]; then
		mod_del_area \
		  '<div id="uiViewHomeSharing">' \
		  0 \
		  'write_html_msg(g_val, "uiViewWorkgroup")' \
		  2 \
		  "$sedfile"
		# disable value checking
		modsed '/uiViewShareName/d;/uiViewWorkgroup/d' $sedfile
		# disable value saving
		modsed '/ctlusb.settings.fritznas_share.*/d;/ctlusb.settings.samba-workgroup/d' $sedfile
	fi

	echo1 "patching rc.conf"
	modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi

# no need for AVM's or Freetz's nmbd
if [ "$FREETZ_REMOVE_SAMBA" == "y" ] || \
  [ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -a "$FREETZ_PACKAGE_SAMBA_NMBD" != "y" ]; then
	if [ "$FREETZ_AVM_HAS_SAMBA_SMBD" == "y" ]; then
		echo1 "remove AVM's nmbd"
		rm_files "${FILESYSTEM_MOD_DIR}/sbin/nmbd"
	fi
fi

# no need for AVM's or Freetz's smbd/nqcs
if [ "$FREETZ_REMOVE_SAMBA" == "y" ]; then
	echo1 "remove AVM samba/nqcs files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/etc/samba_control"
	if [ "$FREETZ_AVM_HAS_SAMBA_SMBD" == "y" ]; then
		echo1 "remove AVM smbd files"
		rm_files \
		  "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
		  "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"
	fi
	if [ "$FREETZ_AVM_HAS_SAMBA_NQCS" == "y" ]; then
		echo1 "remove AVM nqcs files"
		rm_files \
		  "${FILESYSTEM_MOD_DIR}/sbin/nqcs" \
		  "${FILESYSTEM_MOD_DIR}/lib/apparmor.d/sbin.nqcs.bin"
	fi
fi

