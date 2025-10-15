$(call PKG_INIT_BIN, 1.1.43)
$(PKG)_SOURCE:=libxslt-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=5a3d6b383ca5afc235b171118e90f5ff6aa27e9fea3303065231a6d403f0183a
$(PKG)_SITE:=https://download.gnome.org/sources/libxslt/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)),ftp://xmlsoft.org/libxslt
### WEBSITE:=http://www.xmlsoft.org/libxslt/index.html
### MANPAGE:=https://gitlab.gnome.org/GNOME/libxslt/wikis/home
### CHANGES:=https://gitlab.gnome.org/GNOME/libxslt/blob/master/NEWS
### CVSREPO:=https://gitlab.gnome.org/GNOME/libxslt

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/$(pkg)$(if $(FREETZ_PACKAGE_XSLTPROC_STATIC),,/.libs)/$(pkg)
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_LIBNAMES_SHORT := libxslt libexslt
$(PKG)_LIBVERSIONS := 1.1.43 0.8.24
$(PKG)_LIBNAMES_LONG :=  $(join $($(PKG)_LIBNAMES_SHORT:%=%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_DEPENDS_ON += wget-host
$(PKG)_DEPENDS_ON += libxml2

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XSLTPROC_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-plugins=no
$(PKG)_CONFIGURE_OPTIONS += --with-python=no
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=no
$(PKG)_CONFIGURE_OPTIONS += --with-debugger=no
$(PKG)_CONFIGURE_OPTIONS += --with-debug=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(XSLTPROC_DIR) \
		$(if $(FREETZ_PACKAGE_XSLTPROC_STATIC),xsltproc_LDFLAGS="-all-static") \
		all

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(XSLTPROC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.la) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xslt-config

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(XSLTPROC_DIR) clean
	$(RM) -r \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%.*) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%-plugins) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc) \
		$(XSLTPROC_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/%) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xslt*

$(pkg)-uninstall:
	$(RM) $(XSLTPROC_BINARY_TARGET_DIR) $(XSLTPROC_LIBNAMES_SHORT:%=$(XSLTPROC_TARGET_LIBDIR)/%.so*)

$(call PKG_ADD_LIB,libxslt)
$(PKG_FINISH)
