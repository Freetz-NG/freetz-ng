$(call PKG_INIT_LIB, 1.0.18)
$(PKG)_LIB_VERSION:=0.4.0
$(PKG)_SOURCE:=fribidi-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1de5e8073d035388b71d0b2d452b1da1f8caeea8a7702997b401fe1b6250727f
$(PKG)_SITE:=https://github.com/fribidi/fribidi/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://github.com/fribidi/fribidi
### MANPAGE:=https://github.com/fribidi/fribidi/wiki
### CHANGES:=https://github.com/fribidi/fribidi/releases
### CVSREPO:=https://github.com/fribidi/fribidi

$(PKG)_CATEGORY_LIBS:=Charsets & Internationalization

$(PKG)_LIBNAME_SHORT:=$(pkg)
$(PKG)_LIBNAME_LONG:=$($(PKG)_LIBNAME_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/$($(PKG)_LIBNAME_LONG)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME_LONG)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME_LONG)

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-deprecated


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FRIBIDI_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(FRIBIDI_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fribidi.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfribidi.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(FRIBIDI_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfribidi.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fribidi/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fribidi.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man3/fribidi*.3 \

$(pkg)-uninstall:
	$(RM) $(FRIBIDI_TARGET_DIR)/libfribidi.so*

$(PKG_FINISH)
