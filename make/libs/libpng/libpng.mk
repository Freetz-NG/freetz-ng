$(call PKG_INIT_LIB, 1.6.47)
$(PKG)_LIB_VERSION:=16.47.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b213cb381fbb1175327bd708a77aab708a05adde7b471bc267bd15ac99893631
$(PKG)_SITE:=@SF/libpng
### WEBSITE:=http://www.libpng.org/pub/png/libpng.html
### CHANGES:=https://libpng.sourceforge.io/index.html
### CVSREPO:=https://github.com/glennrp/libpng

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpng16.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng16.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpng16.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIGURE_ENV += gl_cv_func_malloc_0_nonnull=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_strtod=yes

$(PKG)_CONFIGURE_ENV += ac_cv_func_pow=no   # semantic pow is in libc
$(PKG)_CONFIGURE_ENV += ac_cv_lib_m_pow=yes # semantic pow is in libm

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBPNG_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBPNG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng16.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpng16.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng16-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBPNG_DIR) clean
	$(RM) -r  \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpng*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng*-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/png*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpng16 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man3/libpng*.3 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man5/png.5

$(pkg)-uninstall:
	$(RM) $(LIBPNG_TARGET_DIR)/libpng*.so*

$(PKG_FINISH)
