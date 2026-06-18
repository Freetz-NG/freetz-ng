$(call PKG_INIT_LIB, 1.7.15)
$(PKG)_LIB_VERSION:=1.7.15
$(PKG)_SOURCE:=cJSON-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=5308fd4bd90cef7aa060558514de6a1a4a0819974a26e6ed13973c5f624c24b2
$(PKG)_SITE:=https://github.com/DaveGamble/cJSON/archive/refs/tags/v$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/libcjson.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcjson.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libcjson.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) -fPIC -Wno-error"
$(PKG)_CONFIGURE_ENV += LDFLAGS="$(TARGET_LDFLAGS) -lm"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -j1 -C $(LIBCJSON_DIR) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS) -fPIC -Wno-error" shared

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBCJSON_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		PREFIX="/usr" \
		INCLUDE_PATH="include/cjson" \
		LIBRARY_PATH="lib" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCJSON_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcjson.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cjson/cJSON.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libcjson.pc

$(pkg)-uninstall:
	$(RM) $(LIBCJSON_TARGET_DIR)/libcjson.so*

$(PKG_FINISH)
