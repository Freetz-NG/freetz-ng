$(call PKG_INIT_LIB, 2.8.15)
$(PKG)_LIB_VERSION:=10.3.3
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1cfa7d6ef19b8d98808b1f4bce225454781299f885815c22ab59d85585f54ee3
$(PKG)_SITE:=https://github.com/cminyard/$(pkg)/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://github.com/cminyard/gensio
### CHANGES:=https://github.com/cminyard/gensio/releases
### CVSREPO:=https://github.com/cminyard/gensio

$(PKG)_LIBRARIES_SHORT   := gensio gensioosh gensiomdns
$(PKG)_LIBRARIES_FILES   := $($(PKG)_LIBRARIES_SHORT:%=lib%.so.$($(PKG)_LIB_VERSION))
$(PKG)_BUILD_BINARIES    := $($(PKG)_LIBRARIES_FILES:%=$($(PKG)_DIR)/lib/.libs/%)
$(PKG)_STAGING_BINARIES  := $($(PKG)_LIBRARIES_FILES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_TARGET_BINARIES   := $($(PKG)_LIBRARIES_FILES:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --with-glib=no
$(PKG)_CONFIGURE_OPTIONS += --with-tcl=no
$(PKG)_CONFIGURE_OPTIONS += --with-swig=no
$(PKG)_CONFIGURE_OPTIONS += --with-cplusplus=no
$(PKG)_CONFIGURE_OPTIONS += --with-sctp=no
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=no
$(PKG)_CONFIGURE_OPTIONS += --with-certauth=no
$(PKG)_CONFIGURE_OPTIONS += --with-tcp-wrappers=no
$(PKG)_CONFIGURE_OPTIONS += --with-all-gensios=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BUILD_BINARIES): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GENSIO_DIR)/lib

$($(PKG)_STAGING_BINARIES): $($(PKG)_BUILD_BINARIES)
	$(SUBMAKE) -C $(GENSIO_DIR)/lib \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SUBMAKE) -C $(GENSIO_DIR)/include \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libgensio*.pc

$($(PKG)_TARGET_BINARIES): $($(PKG)_TARGET_DIR)/lib%.so.$($(PKG)_LIB_VERSION): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%.so.$($(PKG)_LIB_VERSION)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARIES)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARIES)


$(pkg)-clean:
	-$(SUBMAKE) -C $(GENSIO_DIR)/lib clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgensio*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libgensio*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gensio

$(pkg)-uninstall:
	$(RM) $(GENSIO_TARGET_DIR)/libgensio*.so* \
		$(GENSIO_TARGET_DIR)/libgensioosh*.so* \
		$(GENSIO_TARGET_DIR)/libgensiomdns*.so*

$(PKG_FINISH)
