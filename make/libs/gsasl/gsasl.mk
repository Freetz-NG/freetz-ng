$(call PKG_INIT_LIB, 1.10.0)
$(PKG)_LIB_VERSION:=7.10.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=ec3def1bdc4a0b6284f0d1e2901495218c87587e
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_LIBNAME_SHORT := lib$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/src/.libs/$($(PKG)_LIBNAME_SHORT).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$($(PKG)_LIBNAME_SHORT).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/$($(PKG)_LIBNAME_SHORT).so.$($(PKG)_LIB_VERSION)



$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GSASL_DIR) all
	file $(GSASL_BINARY)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GSASL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(GSASL_LIBNAME_SHORT).la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GSASL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(GSASL_LIBNAME_SHORT).so

$(pkg)-uninstall:
	$(RM) $(GSASL_DEST_LIB)/$(GSASL_LIBNAME_SHORT).so

$(PKG_FINISH)

