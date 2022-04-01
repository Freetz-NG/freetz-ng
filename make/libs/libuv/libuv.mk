$(call PKG_INIT_LIB, 1.30.1)
$(PKG)_SHLIB_VERSION:=1.0.0
$(PKG)_SOURCE:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=aefd1b237821bec8bb964d7ba85661fca35b6a97
$(PKG)_SITE:=https://github.com/libuv/libuv/archive/refs/tags/
$(PKG)_LIBNAME=$(pkg).so.$($(PKG)_SHLIB_VERSION)

#$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
#$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)/$(pkg).so.1.0.0
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.1.0.0
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.1.0.0

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG)_CONFIGURE_PRE_CMDS += sh ./autogen.sh;
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBUV_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUV_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuv.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBUV_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuv.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uv.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uv

$(pkg)-uninstall:
	$(RM) $(LIBEV_TARGET_DIR)/libuv.*.so*

$(PKG_FINISH)
