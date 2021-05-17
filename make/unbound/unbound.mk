$(call PKG_INIT_BIN, 1.13.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=0cd660a40d733acc6e7cce43731cac62
$(PKG)_SITE:=http://www.$(pkg).net/downloads

$(PKG)_BINARIES:=$(pkg) $(pkg)-control $(pkg)-checkconf
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBS:=lib$(pkg).so.8.1.12
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$(pkg)-host
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)-host

$(PKG)_FILES:=root.hints
$(PKG)_FILES_BUILD_DIR:=$($(PKG)_FILES:%=$($(PKG)_DIR)/%)
$(PKG)_FILES_TARGET_DIR:=$($(PKG)_FILES:%=$($(PKG)_DEST_DIR)/etc/$(pkg)/%)

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
ifeq ($(strip $(FREETZ_LIB_libcrypto_WITH_EC)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-ecdsa
else
$(PKG)_CONFIGURE_OPTIONS += --disable-ecdsa
endif
ifeq ($(strip $(FREETZ_OPENSSL_VERSION_2)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-gost
else
$(PKG)_CONFIGURE_OPTIONS += --enable-gost
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		wget -N -q -c https://www.internic.net/domain/named.cache -O $(UNBOUND_DIR)/root.hints
		$(SUBMAKE) -C $(UNBOUND_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_FILES_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/$(pkg)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_TARGET_BINARY) \
$($(PKG)_FILES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNBOUND_DIR) clean
	$(RM) $(UNBOUND_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UNBOUND_BINARIES_TARGET_DIR) $(UNBOUND_LIBS_TARGET_DIR) $(UNBOUND_FILES_TARGET_DIR)

$(PKG_FINISH)
