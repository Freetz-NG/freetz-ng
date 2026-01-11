$(call PKG_INIT_BIN, 0.21.5)
$(PKG)_SHLIB_VERSION:=5.3.5
$(PKG)_SOURCE:=libpsl-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1dcc9ceae8b128f3c0b3f654decd0e1e891afc6ff81098f227ef260449dae208
$(PKG)_SITE:=https://github.com/rockdaboot/libpsl/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://rockdaboot.github.io/libpsl/
### MANPAGE:=https://rockdaboot.github.io/libpsl/libpsl-Public-Suffix-List-functions.html
### CHANGES:=https://github.com/rockdaboot/libpsl/releases
### CVSREPO:=https://github.com/rockdaboot/libpsl

$(PKG)_LIST_BUILD       := $($(PKG)_DIR)/list/public_suffix_list.dat
$(PKG)_LIST_TARGET      := $($(PKG)_DEST_DIR)/usr/share/psl/public_suffix_list.dat

$(PKG)_BINARY_BUILD     := $($(PKG)_DIR)/tools/.libs/$(pkg)
$(PKG)_BINARY_TARGET    := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_LIBNAME          := libpsl.so.$($(PKG)_SHLIB_VERSION)
$(PKG)_LIBRARY_BUILD    := $($(PKG)_DIR)/src/.libs/$($(PKG)_LIBNAME)
$(PKG)_LIBRARY_STAGING  := $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_LIBRARY_TARGET   := $($(PKG)_TARGET_LIBDIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON += python3-host

$(PKG)_CONFIGURE_ENV += PYTHON=$(HOST_TOOLS_DIR)/usr/bin/python3

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-man
$(PKG)_CONFIGURE_OPTIONS += --disable-cfi
$(PKG)_CONFIGURE_OPTIONS += --disable-ubsan
$(PKG)_CONFIGURE_OPTIONS += --disable-asan
$(PKG)_CONFIGURE_OPTIONS += --disable-runtime
$(PKG)_CONFIGURE_OPTIONS += --disable-valgrind-tests
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PSL_DIR)
	@touch $@

$($(PKG)_LIST_BUILD) $($(PKG)_BINARY_BUILD) $($(PKG)_LIBRARY_BUILD): $($(PKG)_DIR)/.compiled

$($(PKG)_LIBRARY_STAGING): $($(PKG)_LIBRARY_BUILD)
	$(SUBMAKE) -C $(PSL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpsl.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libpsl.pc

$($(PKG)_LIBRARY_TARGET): $($(PKG)_LIBRARY_STAGING)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_BUILD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIST_TARGET): $($(PKG)_LIST_BUILD)
	$(INSTALL_FILE)

$(pkg): $($(PKG)_LIBRARY_STAGING)

$(pkg)-precompiled: $($(PKG)_LIST_TARGET) $($(PKG)_BINARY_TARGET) $($(PKG)_LIBRARY_TARGET)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PSL_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libpsl.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpsl.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libpsl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/psl

$(pkg)-uninstall:
	$(RM) -r $(PSL_DEST_DIR)/usr/share/psl/ $(PSL_BINARY_TARGET) $(PSL_TARGET_DIR)/libpsl.so*

$(call PKG_ADD_LIB,libpsl)
$(PKG_FINISH)
