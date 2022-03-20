$(call PKG_INIT_BIN,1.0)

$(PKG_UNPACKED)

$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_cuma),,usr/share/*/cuma)
$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_legacy),,usr/share/*/legacy)
$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_newfreetz),,usr/share/*/newfreetz)
$(PKG)_EXCLUDED += $(if $(FREETZ_SKIN_phoenix),,usr/share/*/phoenix)
$(PKG)_EXCLUDED += $(if $(FREETZ_STYLE_COLORED),usr/share/style/colorscheme-grey.css,usr/share/style/colorscheme-colored.css)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOD_SWAPOPTIONS),,etc/init.d/rc.swap usr/mww/cgi-bin/exec.d/create-swap.sh usr/lib/cgi-bin/mod/conf/20-swap.sh)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOD_ETCSERVICES),,etc/services)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOD_ETCNETCONFIG),,etc/netconfig)

$(PKG)_EXCLUDED += $(if $(FREETZ_AVM_HAS_UDEV),etc/device.table,etc/udev)
$(PKG)_EXCLUDED += $(if $(FREETZ_CUSTOM_UDEV_RULES),,etc/default.mod/udev_*.def etc/udev/rules.d/??-custom.rules)
$(PKG)_EXCLUDED += $(if $(FREETZ_PATCH_FREETZMOUNT),,usr/lib/libmodmount.sh usr/lib/cgi-bin/mod/conf/30-mount.sh)
$(PKG)_EXCLUDED += $(if $(FREETZ_PATCH_UDEVMOUNT),,usr/lib/libmodudevm.sh usr/lib/cgi-bin/mod/conf/30-udevm.sh)

$(PKG)_EXCLUDED += $(if $(FREETZ_TYPE_EXTENDER) ,usr/bin/wrapper/dsld   etc/init.d/rc.dsld)
$(PKG)_EXCLUDED += $(if $(FREETZ_TYPE_EXTENDER) ,usr/bin/wrapper/multid etc/init.d/rc.multid)
$(PKG)_EXCLUDED += $(if $(FREETZ_TYPE_EXTENDER),,usr/bin/wrapper/rextd  etc/init.d/rc.rextd)

$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_FTPD)),etc/init.d/rc.ftpd)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(FREETZ_AVM_HAS_USB_HOST)),$(FREETZ_REMOVE_SAMBA),$(FREETZ_PACKAGE_SAMBA_SMBD),$(FREETZ_AVM_HAS_SAMBA_NQCS)),etc/init.d/rc.smbd)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_DSLD),usr/bin/wrapper/dsld etc/init.d/rc.dsld)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_WEBSRV),,etc/init.d/rc.websrv usr/bin/websrv usr/lib/cgi-bin/conf.avm/20-websrv.sh)
$(PKG)_EXCLUDED += $(if $(FREETZ_BUSYBOX_TELNETD),,etc/init.d/rc.telnetd usr/lib/cgi-bin/conf.avm/10-telnetd.sh)
$(PKG)_EXCLUDED += $(if $(or $(call not-y,$(EXTERNAL_ENABLED)),$(EXTERNAL_DOWNLOADER)),usr/lib/cgi-bin/mod/conf/40-external.sh etc/init.d/rc.external etc/external.pkg)
$(PKG)_EXCLUDED += $(if $(or $(FREETZ_AVM_HAS_FWLAYOUT_5),$(FREETZ_AVM_HAS_FWLAYOUT_6)),usr/mww/cgi-bin/update/)

$(PKG)_EXCLUDED += $(if $(FREETZ_BUSYBOX_FEATURE_WTMP),,usr/lib/cgi-bin/mod/conf/60-utmp_wtmp.sh)
$(PKG)_EXCLUDED += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,usr/lib/cgi-bin/mod/conf/90-ipv6.sh)

$(PKG)_EXCLUDED += $(if $(FREETZ_STRIP_SCRIPTS),usr/share/abo??.txt)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_BOX_INFO),usr/lib/cgi-bin/mod/box_info.cgi)
$(PKG)_EXCLUDED += $(if $(FREETZ_REMOVE_FREETZ_INFO),usr/lib/cgi-bin/mod/do_download_config.cgi usr/lib/cgi-bin/mod/info.cgi)
$(PKG)_EXCLUDED += $(if $(FREETZ_ADD_JUIS_CHECK),,usr/mww/cgi-bin/system_juis.cgi usr/mww/cgi-bin/exec.d/juis_check.sh usr/bin/juis)
$(PKG)_EXCLUDED += $(if $(and $(FREETZ_AVM_HAS_SEPARATE_FILESYSTEM_IMAGE),$(call not-y,$(FREETZ_AVM_HAS_FWLAYOUT_6))),,usr/mww/cgi-bin/system_lfs.cgi usr/mww/cgi-bin/exec.d/linux_fs_start.sh)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:

$(PKG_FINISH)
