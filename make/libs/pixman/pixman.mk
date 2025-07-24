$(call PKG_INIT_LIB, 0.46.4)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=pixman-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d09c44ebc3bd5bee7021c79f922fe8fb2fb57f7320f55e97ff9914d2346a591c
$(PKG)_SITE:=https://www.cairographics.org/releases/
### WEBSITE:=http://www.pixman.org/
### CHANGES:=https://www.cairographics.org/releases/
### CVSREPO:=https://cgit.freedesktop.org/pixman/

$(PKG)_LIBNAME_SHORT:=$(pkg)
$(PKG)_LIBNAME_LONG:=$($(PKG)_LIBNAME_SHORT:%=lib%-1.so.$($(PKG)_LIB_VERSION))
$(PKG)_BINARY:=$($(PKG)_DIR)/builddir/pixman/$($(PKG)_LIBNAME_LONG)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME_LONG)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME_LONG)

$(PKG)_DEPENDS_ON += meson-host

ifeq ($(strip $(FREETZ_LIB_libpng16)),y)
$(PKG)_DEPENDS_ON += libpng
$(PKG)_CONFIGURE_OPTIONS += -D libpng=enabled
else
$(PKG)_CONFIGURE_OPTIONS += -D libpng=disabled
endif

$(PKG)_CONFIGURE_OPTIONS += -D gnu-inline-asm=disabled
$(PKG)_CONFIGURE_OPTIONS += -D tls=disabled
$(PKG)_CONFIGURE_OPTIONS += -D loongson-mmi=disabled
$(PKG)_CONFIGURE_OPTIONS += -D vmx=disabled
$(PKG)_CONFIGURE_OPTIONS += -D demos=disabled
$(PKG)_CONFIGURE_OPTIONS += -D gtk=disabled
$(PKG)_CONFIGURE_OPTIONS += -D tests=disabled
$(PKG)_CONFIGURE_OPTIONS += -D openmp=disabled
$(PKG)_CONFIGURE_OPTIONS += -D gnuplot=false
$(PKG)_CONFIGURE_OPTIONS += -D timers=false
$(PKG)_CONFIGURE_OPTIONS += -D mmx=disabled
$(PKG)_CONFIGURE_OPTIONS += -D sse2=disabled
$(PKG)_CONFIGURE_OPTIONS += -D ssse3=disabled
$(PKG)_CONFIGURE_OPTIONS += -D mips-dspr2=disabled
$(PKG)_CONFIGURE_OPTIONS += -D arm-simd=disabled
$(PKG)_CONFIGURE_OPTIONS += -D neon=disabled
$(PKG)_CONFIGURE_OPTIONS += -D a64-neon=disabled


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_MESON)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMESON) compile \
		-C $(PIXMAN_DIR)/builddir/
#meson	$(MESON) configure $(PIXMAN_DIR)/builddir/

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMESON) install \
		--destdir "$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(PIXMAN_DIR)/builddir/
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pixman-1.pc
#meson		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpixman-1.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBNINJA) -C $(PIXMAN_DIR)/builddir/ clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpixman-1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pixman-1/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pixman-1.pc

$(pkg)-uninstall:
	$(RM) $(PIXMAN_TARGET_DIR)/libpixman-1.so*

$(PKG_FINISH)
