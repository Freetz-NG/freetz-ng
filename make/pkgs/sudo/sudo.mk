$(call PKG_INIT_BIN, 1.9.17p1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ff607ea717072197738a78f778692cd6df9a7e3e404565f51de063ca27455d32
$(PKG)_SITE:=https://www.sudo.ws/dist
### WEBSITE:=https://www.sudo.ws/
### MANPAGE:=https://www.sudo.ws/docs/man/sudoers.man/
### CHANGES:=https://www.sudo.ws/releases/stable/
### CVSREPO:=https://github.com/sudo-project/sudo

$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_DIR)/src/.libs/$(pkg)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_LIBS:=lib$(pkg)_util.so
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/lib/util/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-log-server
$(PKG)_CONFIGURE_OPTIONS += --disable-log-client
$(PKG)_CONFIGURE_OPTIONS += --without-bsm-audit
$(PKG)_CONFIGURE_OPTIONS += --without-linux-audit 
$(PKG)_CONFIGURE_OPTIONS += --without-solaris-audit
$(PKG)_CONFIGURE_OPTIONS += --without-sssd
$(PKG)_CONFIGURE_OPTIONS += --without-SecurID
$(PKG)_CONFIGURE_OPTIONS += --without-fwtk
$(PKG)_CONFIGURE_OPTIONS += --without-kerb5
$(PKG)_CONFIGURE_OPTIONS += --without-AFS
$(PKG)_CONFIGURE_OPTIONS += --without-DCE
$(PKG)_CONFIGURE_OPTIONS += --without-sendmail
$(PKG)_CONFIGURE_OPTIONS += --without-nsswitch
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-apparmor
$(PKG)_CONFIGURE_OPTIONS += --without-pam-login
$(PKG)_CONFIGURE_OPTIONS += --without-lecture
$(PKG)_CONFIGURE_OPTIONS += --without-pam
$(PKG)_CONFIGURE_OPTIONS += --without-sendmail
$(PKG)_CONFIGURE_OPTIONS += --disable-pam-session
$(PKG)_CONFIGURE_OPTIONS += --disable-root-mailer
$(PKG)_CONFIGURE_OPTIONS += --disable-root-sudo
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --disable-zlib
$(PKG)_CONFIGURE_OPTIONS += --enable-static-sudoers

$(PKG)_CONFIGURE_ENV += sudo_cv_uid_t_len=10


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SUDO_DIR)

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)
	chmod +s $(SUDO_BINARY_TARGET_DIR)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/lib/util/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(SUDO_DIR) clean
	$(RM) $(SUDO_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SUDO_BINARY_TARGET_DIR) $(SUDO_LIBS_TARGET_DIR)

$(PKG_FINISH)
