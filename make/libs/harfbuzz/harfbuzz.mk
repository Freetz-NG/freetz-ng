$(call PKG_INIT_LIB, 11.3.2)
$(PKG)_LIB_VERSION:=0.61132.0
$(PKG)_SOURCE:=harfbuzz-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=d58ada9b2d28821245e8bdb8b94a4e2dad01a08c50d57feb027b32e84c9abfb1
$(PKG)_SITE:=https://github.com/harfbuzz/harfbuzz/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://harfbuzz.github.io/
### MANPAGE:=https://github.com/harfbuzz/harfbuzz/wiki
### CHANGES:=https://github.com/harfbuzz/harfbuzz/releases
### CVSREPO:=https://github.com/harfbuzz/harfbuzz
### SUPPORT:=fda77

$(PKG)_LIBNAME_SHORT:=$(pkg)
$(PKG)_LIBNAME_LONG:=$($(PKG)_LIBNAME_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_BINARY:=$($(PKG)_DIR)/builddir/src/$($(PKG)_LIBNAME_LONG)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME_LONG)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME_LONG)

$(PKG)_DEPENDS_ON += meson-host
$(PKG)_DEPENDS_ON += freetype

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_OPTIONS += -D buildtype=release
$(PKG)_CONFIGURE_OPTIONS += -D tests=disabled
$(PKG)_CONFIGURE_OPTIONS += -D benchmark=disabled
$(PKG)_CONFIGURE_OPTIONS += -D docs=disabled
$(PKG)_CONFIGURE_OPTIONS += -D doc_tests=false
$(PKG)_CONFIGURE_OPTIONS += -D freetype=enabled
$(PKG)_CONFIGURE_OPTIONS += -D cairo=disabled
$(PKG)_CONFIGURE_OPTIONS += -D chafa=disabled
$(PKG)_CONFIGURE_OPTIONS += -D coretext=disabled
$(PKG)_CONFIGURE_OPTIONS += -D directwrite=disabled
$(PKG)_CONFIGURE_OPTIONS += -D gdi=disabled
$(PKG)_CONFIGURE_OPTIONS += -D glib=disabled
$(PKG)_CONFIGURE_OPTIONS += -D gobject=disabled
$(PKG)_CONFIGURE_OPTIONS += -D graphite=disabled
$(PKG)_CONFIGURE_OPTIONS += -D graphite2=disabled
$(PKG)_CONFIGURE_OPTIONS += -D icu=disabled
$(PKG)_CONFIGURE_OPTIONS += -D introspection=disabled


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_MESON)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMESON) compile \
		-C $(HARFBUZZ_DIR)/builddir/
#meson	$(MESON) configure $(HARFBUZZ_DIR)/builddir/

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMESON) install \
		--destdir "$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(HARFBUZZ_DIR)/builddir/
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/harfbuzz*.pc
#meson		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libharfbuzz*.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBNINJA) -C $(HARFBUZZ_DIR)/builddir/ clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libharfbuzz* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/harfbuzz/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/harfbuzz*.pc

$(pkg)-uninstall:
	$(RM) $(HARFBUZZ_TARGET_DIR)/libharfbuzz.so*

$(PKG_FINISH)
