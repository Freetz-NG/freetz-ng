$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_IMAGEMAGICK_VERSION_ABANDON),7.1.0-62,7.1.1-47))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_VERSION_ABANDON),10.0.0,10.0.2)
$(PKG)_ABI_SUFFIX:=Q16
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1)
$(PKG)_SOURCE:=ImageMagick-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=8b89c1a023d4b03cca3e63a0f3cb944427d46d1363a20440282d9f6e0e343518
$(PKG)_HASH_CURRENT:=2396cd3c4237cfbc09a89d31d1cee157ee11fbc8ec1e540530e10175cb707160
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_IMAGEMAGICK_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://download.imagemagick.org/archive,https://download.imagemagick.org/archive/releases,https://imagemagick.org/archive,https://imagemagick.org/archive/releases,@SF/$(pkg)
### WEBSITE:=https://www.imagemagick.org/
### MANPAGE:=https://www.imagemagick.org/Usage/
### CHANGES:=https://github.com/ImageMagick/ImageMagick/releases
### CVSREPO:=https://github.com/ImageMagick/ImageMagick
### SUPPORT:=fda77

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY := magick
$(PKG)_BINARY_BUILD_DIR := $($(PKG)_BINARY:%=$($(PKG)_DIR)/utilities/$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,.libs/)%)
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_BINARY:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_SYMLINKS := animate compare composite conjure convert display identify import magick-script mogrify montage stream
$(PKG)_SYMLINKS_TARGET_DIR := $($(PKG)_SYMLINKS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIB_CORE := libMagickCore-$($(PKG)_MAJOR_VERSION)-$($(PKG)_ABI_SUFFIX).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_CORE_BUILD_DIR := $($(PKG)_LIB_CORE:%=$($(PKG)_DIR)/MagickCore/.libs/%)
$(PKG)_LIB_CORE_TARGET_DIR := $($(PKG)_LIB_CORE:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_LIB_WAND := libMagickWand-$($(PKG)_MAJOR_VERSION)-$($(PKG)_ABI_SUFFIX).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_WAND_BUILD_DIR := $($(PKG)_LIB_WAND:%=$($(PKG)_DIR)/MagickWand/.libs/%)
$(PKG)_LIB_WAND_TARGET_DIR := $($(PKG)_LIB_WAND:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_XML_CONFIGS := \
	coder.xml colors.xml delegates.xml english.xml locale.xml log.xml magic.xml mime.xml policy.xml quantization-table.xml \
	thresholds.xml type.xml type-apple.xml type-dejavu.xml type-ghostscript.xml type-urw-base35.xml type-windows.xml

$(PKG)_XML_CONFIGS_BUILD_DIR := $($(PKG)_XML_CONFIGS:%=$($(PKG)_DIR)/config/%)
$(PKG)_XML_CONFIGS_TARGET_DIR := $($(PKG)_XML_CONFIGS:%=$($(PKG)_DEST_DIR)/etc/ImageMagick-$($(PKG)_MAJOR_VERSION)/%)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),,$($(PKG)_XML_CONFIGS_TARGET_DIR))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_freetype
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_jpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_libz
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_png
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_xml
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_STATIC

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_freetype),freetype)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts),ghostscript-fonts)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg),jpeg)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_libz),zlib)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_png),libpng)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),libxml2)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_PRE_CMDS += \
	find $(abspath $($(PKG)_DIR)) -name "*.in" -type f -exec \
	$(SED) -i -r -e 's,($($(PKG)_MAJOR_VERSION)|@MAGICK_MAJOR_VERSION@)[.]($($(PKG)_ABI_SUFFIX)|@MAGICK_ABI_SUFFIX@),\1-\2,g' \{\} \+;

$(PKG)_CONFIGURE_ENV += ac_cv_func_newlocale=no

$(PKG)_CONFIGURE_OPTIONS += --with-modules=no
$(PKG)_CONFIGURE_OPTIONS += --enable-hdri=no
$(PKG)_CONFIGURE_OPTIONS += --with-bzlib=no
$(PKG)_CONFIGURE_OPTIONS += --with-autotrace=no
$(PKG)_CONFIGURE_OPTIONS += --with-djvu=no
$(PKG)_CONFIGURE_OPTIONS += --with-dps=no
$(PKG)_CONFIGURE_OPTIONS += --with-fftw=no
$(PKG)_CONFIGURE_OPTIONS += --with-fpx=no
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no
$(PKG)_CONFIGURE_OPTIONS += --with-gs-font-dir=$(GHOSTSCRIPT_FONTS_RUNTIME_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-gvc=no
$(PKG)_CONFIGURE_OPTIONS += --with-jbig=no
$(PKG)_CONFIGURE_OPTIONS += --with-jp2=no
$(PKG)_CONFIGURE_OPTIONS += --with-lcms=no
$(PKG)_CONFIGURE_OPTIONS += --with-lcms2=no
$(PKG)_CONFIGURE_OPTIONS += --with-lqr=no
$(PKG)_CONFIGURE_OPTIONS += --with-ltdl=no
$(PKG)_CONFIGURE_OPTIONS += --with-lzma=no
$(PKG)_CONFIGURE_OPTIONS += --with-magick-plus-plus=no
$(PKG)_CONFIGURE_OPTIONS += --with-openexr=no
$(PKG)_CONFIGURE_OPTIONS += --with-perl=no
$(PKG)_CONFIGURE_OPTIONS += --with-pango=no
$(PKG)_CONFIGURE_OPTIONS += --with-rsvg=no
$(PKG)_CONFIGURE_OPTIONS += --with-tiff=no
$(PKG)_CONFIGURE_OPTIONS += --with-webp=no
$(PKG)_CONFIGURE_OPTIONS += --with-wmf=no
$(PKG)_CONFIGURE_OPTIONS += --with-x=no

$(PKG)_CONFIGURE_OPTIONS += --enable-static=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),no,yes)

$(PKG)_CONFIGURE_OPTIONS += --with-zlib=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_libz),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-png=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_png),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-xml=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-freetype=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_freetype),yes,no)

ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC)),y)
$(PKG)_EXTRA_CFLAGS  := -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS := -Wl,--gc-sections -all-static
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,$($(PKG)_LIB_CORE_BUILD_DIR) $($(PKG)_LIB_WAND_BUILD_DIR)): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IMAGEMAGICK_DIR) \
		EXTRA_CFLAGS="$(IMAGEMAGICK_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(IMAGEMAGICK_EXTRA_LDFLAGS)" \
		V=1

$($(PKG)_XML_CONFIGS_BUILD_DIR): $($(PKG)_DIR)/config/%: $($(PKG)_DIR)/.configured
	@touch $@

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_LIB_CORE_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/MagickCore/.libs/%
	$(INSTALL_LIBRARY_STRIP)
$($(PKG)_LIB_WAND_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/MagickWand/.libs/%
	$(INSTALL_LIBRARY_STRIP)
$($(PKG)_XML_CONFIGS_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/ImageMagick-$($(PKG)_MAJOR_VERSION)/%: $($(PKG)_DIR)/config/%
	$(INSTALL_FILE)

$($(PKG)_SYMLINKS_TARGET_DIR): $($(PKG)_BINARY_TARGET_DIR)
	ln -sf $(notdir $<) $@

$(pkg):

$(pkg)-precompiled: \
	$($(PKG)_BINARY_TARGET_DIR) \
	$($(PKG)_SYMLINKS_TARGET_DIR) \
	$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,$($(PKG)_LIB_CORE_TARGET_DIR) $($(PKG)_LIB_WAND_TARGET_DIR)) \
	$(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),$($(PKG)_XML_CONFIGS_TARGET_DIR))


$(pkg)-clean:
	-$(SUBMAKE) -C $(IMAGEMAGICK_DIR) clean
	$(RM) $(IMAGEMAGICK_DIR)/.configured

$(pkg)-uninstall:
	$(RM) \
		$(IMAGEMAGICK_BINARY_TARGET_DIR) \
		$(IMAGEMAGICK_SYMLINKS_ALL:%=$(IMAGEMAGICK_DEST_DIR)/usr/bin/%) \
		$(IMAGEMAGICK_LIB_CORE_TARGET_DIR) \
		$(IMAGEMAGICK_LIB_WAND_TARGET_DIR) \
		$(IMAGEMAGICK_XML_CONFIGS_TARGET_DIR)

$(PKG_FINISH)
