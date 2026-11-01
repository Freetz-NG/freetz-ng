$(call PKG_INIT_BIN, 4.0.7)
$(PKG)_LIB_VERSION:=5.2.5
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9f43a2cfb9589e5cecaa66e16bf87f814c945f22df7ba600d63aac4632c4f019
$(PKG)_SITE:=http://download.osgeo.org/libtiff

$(PKG)_CATEGORY_LIBS:=Graphics & fonts

$(PKG)_BINARIES_ALL := fax2ps fax2tiff ppm2tiff raw2tiff tiff2bw tiff2pdf tiff2ps tiffinfo tiffsplit
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/tools/.libs/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_LIBNAMES_SHORT := libtiff libtiffxx
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=%.so.$($(PKG)_LIB_VERSION))

$(PKG)_LIBS_BUILD_DIR :=$($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/libtiff/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON += config-host
$(PKG)_DEPENDS_ON += $(STDCXXLIB) zlib jpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_UPDATE_CONFIGS,./config/)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-cxx=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-ccitt
$(PKG)_CONFIGURE_OPTIONS += --enable-packbits
$(PKG)_CONFIGURE_OPTIONS += --enable-lzw
$(PKG)_CONFIGURE_OPTIONS += --enable-thunder
$(PKG)_CONFIGURE_OPTIONS += --enable-next
$(PKG)_CONFIGURE_OPTIONS += --enable-logluv
$(PKG)_CONFIGURE_OPTIONS += --enable-mdi
$(PKG)_CONFIGURE_OPTIONS += --enable-zlib
$(PKG)_CONFIGURE_OPTIONS += --enable-jpeg
$(PKG)_CONFIGURE_OPTIONS += --disable-old-jpeg
$(PKG)_CONFIGURE_OPTIONS += --disable-jbig
$(PKG)_CONFIGURE_OPTIONS += --disable-lzma
$(PKG)_CONFIGURE_OPTIONS += --without-apple-opengl-framework

$(PKG)_CONFIGURE_OPTIONS += --with-jpeg-include-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg-lib-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TIFF_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/tools/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(TIFF_DIR)/libtiff \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SUBMAKE) -C $(TIFF_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgconfigDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtiff*.pc \
		$(TIFF_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TIFF_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtiff* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtiff*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tiff*

$(pkg)-uninstall:
	$(RM) \
		$(TIFF_BINARIES_ALL:%=$(TIFF_DEST_DIR)/usr/bin/%) \
		$(TIFF_TARGET_DIR)/libtiff*.so*

$(call PKG_ADD_LIB,libtiff)
$(PKG_FINISH)
