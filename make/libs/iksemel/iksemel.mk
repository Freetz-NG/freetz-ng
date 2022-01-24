$(call PKG_INIT_BIN, 3.1.1)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=v1.4.2.tar.gz
$(PKG)_SOURCE_MD5:=04353ca58a5cc745fd1d4fc255a73f8d
$(PKG)_SITE:=https://github.com/timothytylee/iksemel-1.4/archive/refs/tags/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += openssl

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --disable-python

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IKSEMEL_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(IKSEMEL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiksemel.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/iksemel.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IKSEMEL_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libiksemel.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/iksemel.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/iksemel.h

$(pkg)-uninstall:
	$(RM) $(IKSEMEL_TARGET_DIR)/libiksemel.so*

$(PKG_FINISH)
