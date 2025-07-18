$(call PKG_INIT_BIN, 1.23.1)
$(PKG)_LIB_VERSION:=8.1.32
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=6a6b117c799d8de3868643397e0fd71591f6d42f4473f598bdb22609ff362590
$(PKG)_SITE:=https://www.unbound.net/downloads
### WEBSITE:=https://www.unbound.net
### MANPAGE:=https://www.unbound.net/documentation/unbound.html
### CHANGES:=https://www.nlnetlabs.nl/projects/unbound/download/
### CVSREPO:=https://github.com/NLnetLabs/unbound
### SUPPORT:=fda77

$(PKG)_STARTLEVEL=40 # multid-wrapper may start it earlier!

$(PKG)_BINARIES:=$(pkg) $(pkg)-control $(pkg)-checkconf
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_WRAPPED:=$(pkg)-anchor $(pkg)-host
$(PKG)_WRAPPED_BUILD_DIR:=$($(PKG)_WRAPPED:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_WRAPPED_TARGET_DIR:=$($(PKG)_WRAPPED:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_SCRIPTS:=$(pkg)-control-setup
$(PKG)_SCRIPTS_BUILD_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DIR)/%)
$(PKG)_SCRIPTS_TARGET_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBRARIES_SHORT:=lib$(pkg)
$(PKG)_LIBRARIES:=$($(PKG)_LIBRARIES_SHORT:%=%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBRARIES_BUILD_DIR:=$($(PKG)_LIBRARIES:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_LIBRARIES_TARGET_DIR:=$($(PKG)_LIBRARIES:%=$($(PKG)_TARGET_LIBDIR)/%)
$(PKG)_LIBRARIES_STAGING_DIR:=$($(PKG)_LIBRARIES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libcrypto_WITH_EC
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_VERSION_10_MAX

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON += openssl expat
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
$(PKG)_CONFIGURE_OPTIONS += --with-libexpat=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
$(PKG)_CONFIGURE_OPTIONS += --with-pidfile=/var/run/unbound.pid
$(PKG)_CONFIGURE_OPTIONS += --with-conf-file=/tmp/flash/unbound/unbound.conf
$(PKG)_CONFIGURE_OPTIONS += --without-pyunbound
$(PKG)_CONFIGURE_OPTIONS += --without-pythonmodule
$(PKG)_CONFIGURE_OPTIONS += --without-libevent
$(PKG)_CONFIGURE_OPTIONS += --with-pthreads
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libcrypto_WITH_EC),--enable-ecdsa,--disable-ecdsa)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_OPENSSL_VERSION_10_MAX),--enable-gost,--disable-gost)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_DAEMON)        ,,usr/bin/unbound)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_ANCHOR)        ,,usr/bin/unbound-anchor)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CHECKCONF)     ,,usr/bin/unbound-checkconf)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CONTROL)       ,,usr/bin/unbound-control)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_CONTROL_SETUP) ,,usr/bin/unbound-control-setup)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_HOST)          ,,usr/bin/unbound-host)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_UNBOUND_WEBIF)         ,,etc/default.unbound/ etc/init.d/rc.unbound usr/lib/cgi-bin/unbound.cgi)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_WRAPPED_BUILD_DIR) $($(PKG)_SCRIPTS_BUILD_DIR) $($(PKG)_LIBRARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNBOUND_DIR)

$($(PKG)_LIBRARIES_STAGING_DIR): $($(PKG)_LIBRARIES_BUILD_DIR)
	$(SUBMAKE) -C $(UNBOUND_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_WRAPPED_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SCRIPTS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$($(PKG)_LIBRARIES_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBRARIES_STAGING_DIR)
$($(PKG)_LIBRARIES_SHORT): $(pkg)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_WRAPPED_TARGET_DIR) $($(PKG)_SCRIPTS_TARGET_DIR) $($(PKG)_LIBRARIES_TARGET_DIR)
$(patsubst %,%-precompiled,$($(PKG)_LIBRARIES_SHORT)): $(pkg)-precompiled


$(pkg)-clean:
	-$(SUBMAKE) -C $(UNBOUND_DIR) clean
	$(RM) $(UNBOUND_DIR)/.configured

$(pkg)-clean-staging:
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/sbin/unbound* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libunbound.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libunbound.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/unbound.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man?/*unbound*

$(pkg)-uninstall:
	$(RM) $(UNBOUND_BINARIES_TARGET_DIR) $(UNBOUND_WRAPPED_TARGET_DIR) $(UNBOUND_SCRIPTS_TARGET_DIR) $(UNBOUND_TARGET_LIBDIR)/libunbound*.so*

$(call PKG_ADD_LIB,libunbound)
$(PKG_FINISH)

