$(call PKG_INIT_LIB, 2.13.2)
$(PKG)_LIB_VERSION:=6.20.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d
$(PKG)_SITE:=@SF/freetype
### WEBSITE:=https://freetype.org
### MANPAGE:=https://freetype.org/freetype2/docs/documentation.html
### CHANGES:=https://freetype.org/index.html#news
### CVSREPO:=https://gitlab.freedesktop.org/freetype

$(PKG)_BINARY:=$($(PKG)_DIR)/objs/.libs/libfreetype.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libfreetype.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_OPTIONS += --with-bzip2=no
$(PKG)_CONFIGURE_OPTIONS += --with-harfbuzz=no
$(PKG)_CONFIGURE_OPTIONS += --with-png=no
$(PKG)_CONFIGURE_OPTIONS += --with-zlib=yes


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FREETYPE_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(FREETYPE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/freetype2.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(FREETYPE_DIR) distclean
	$(RM) $(FREETYPE_DIR)/.configured
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/freetype2 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/freetype2.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/freetype2.m4

$(pkg)-uninstall:
	$(RM) $(FREETYPE_TARGET_DIR)/libfreetype*.so*

$(PKG_FINISH)
