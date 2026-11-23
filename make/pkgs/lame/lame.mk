$(call PKG_INIT_BIN, 4.0)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=lame-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3df5124d5ad3a98312ffd7ba6a9b36230e4f8a3e66d3ce0f425e336c32d216eb
$(PKG)_SITE:=@SF/lame
### WEBSITE:=https://lame.sourceforge.io/
### MANPAGE:=https://lame.sourceforge.io/using.php
### CHANGES:=https://svn.code.sf.net/p/lame/svn/trunk/lame/doc/html/history.html
### CVSREPO:=https://sourceforge.net/p/lame/svn/HEAD/tree/

$(PKG)_CATEGORY_LIBS:=Multimedia##Audio

$(PKG)_BINARY:=$($(PKG)_DIR)/frontend/$(if $(FREETZ_PACKAGE_LAME_STATIC),,.libs/)lame
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lame

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libmp3lame/.libs/libmp3lame.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libmp3lame.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LAME_STATIC

$(PKG)_CONFIGURE_ENV += GTK_CONFIG=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_termcap_initscr=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_curses_initscr=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_ncurses_initscr=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_ffm_cos=no
$(PKG)_CONFIGURE_ENV += $(if $(FREETZ_TARGET_UCLIBC_0_9_28),am_cv_func_iconv=no)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
$(PKG)_CONFIGURE_OPTIONS += --disable-cpml
$(PKG)_CONFIGURE_OPTIONS += --disable-efence
$(PKG)_CONFIGURE_OPTIONS += --without-dot
$(PKG)_CONFIGURE_OPTIONS += --with-fileio=lame

# needs libmpg123 >= 1.26.0
$(PKG)_CONFIGURE_OPTIONS += --disable-decoder
# LAME's frontend defaults to linking libmp3lame statically when this option is omitted.
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LAME_STATIC),,--enable-dynamic-frontends)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LAME_DIR)/libmp3lame

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(LAME_DIR)/frontend

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(LAME_DIR)/libmp3lame DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(SUBMAKE) -C $(LAME_DIR)/include DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lame.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LAME_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lame.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lame/

$(pkg)-uninstall:
	$(RM) $(LAME_TARGET_BINARY) $(LAME_TARGET_LIBDIR)/libmp3lame.so*

$(call PKG_ADD_LIB,libmp3lame)
$(PKG_FINISH)
