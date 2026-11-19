$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON),2.17.1,2.18.4))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON),1.16.1,1.16.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=9f5cae93f4fffc1fbc05ae99cdfc708cd60dfd6612ffc0512827025c026fa541
$(PKG)_HASH_CURRENT:=95013637eff5f81d4871dd16cd098c273264c16d0f9f0b27cc43b81b2794bee3
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/$(pkg)/$($(PKG)_VERSION)
### WEBSITE:=https://www.freedesktop.org/wiki/Software/fontconfig/
### CHANGES:=https://gitlab.freedesktop.org/fontconfig/fontconfig/tags
### CVSREPO:=https://gitlab.freedesktop.org/fontconfig/fontconfig
### STEWARD:=fda77

$(PKG)_CATEGORY_LIBS:=Graphics & fonts

$(PKG)_BINARIES:=fonts.conf
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/etc/fonts/%)

$(PKG)_LIBRARIES_SHORT:=lib$(pkg)
$(PKG)_LIBRARIES:=$($(PKG)_LIBRARIES_SHORT:%=%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBRARIES_BUILD_DIR:=$($(PKG)_LIBRARIES:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIBRARIES_STAGING_DIR:=$($(PKG)_LIBRARIES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBRARIES_TARGET_DIR:=$($(PKG)_LIBRARIES:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON += gperf-host freetype libxml2 zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON),abandon,current)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += LIBXML2_CFLAGS=-I"$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"

ifneq ($(strip $(FREETZ_PACKAGE_FONTCONFIG_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += ac_cv_va_copy=.C99
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-docbook
$(PKG)_CONFIGURE_OPTIONS += --disable-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-cache-build
$(PKG)_CONFIGURE_OPTIONS += --enable-libxml2
$(PKG)_CONFIGURE_OPTIONS += --without-expat
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBRARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FONTCONFIG_DIR) \
		all

$($(PKG)_LIBRARIES_STAGING_DIR): $($(PKG)_LIBRARIES_BUILD_DIR)
	$(SUBMAKE) -C $(FONTCONFIG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfontconfig.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fontconfig.pc

$($(PKG)_LIBRARIES_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/etc/fonts/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg): $($(PKG)_LIBRARIES_STAGING_DIR)
$($(PKG)_LIBRARIES_SHORT): $(pkg)

##tiny /etc/fonts/fonts.conf from files/root dir:
#$(pkg)-precompiled:                              $($(PKG)_LIBRARIES_TARGET_DIR)
##huge generated /etc/fonts/fonts.conf from src:
$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBRARIES_TARGET_DIR)
$(patsubst %,%-precompiled,$($(PKG)_LIBRARIES_SHORT)): $(pkg)-precompiled


$(pkg)-clean:
	-$(SUBMAKE) -C $(FONTCONFIG_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/fontconfig/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfontconfig.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/fontconfig.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/fonts/fonts.conf* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/etc/fonts/conf.d/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/fontconfig/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/xml/fontconfig/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/gettext/its/fontconfig.*

$(pkg)-uninstall:
	$(RM) $(FONTCONFIG_BINARIES_TARGET_DIR) $(FONTCONFIG_TARGET_LIBDIR)/libfontconfig.so*

$(call PKG_ADD_LIB,libfontconfig)
$(PKG_FINISH)
