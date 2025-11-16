$(call PKG_INIT_BIN, $(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),3400100,3470100))
$(PKG)_LIB_VERSION:=0.8.6
$(PKG)_SOURCE:=$(pkg)-autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=2c5dea207fa508d765af1ef620b637dcb06572afa6f01f0815bd5bbf864b33d9
$(PKG)_HASH_CURRENT:=416a6f45bf2cacd494b208fdee1beda509abda951d5f47bc4f2792126f01b452
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=https://www.sqlite.org/2022
$(PKG)_SITE_CURRENT:=https://www.sqlite.org/2024
$(PKG)_SITE:=$($(PKG)_SITE_$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),ABANDON,CURRENT))
### VERSION:=3.40.1/3.47.1
### WEBSITE:=https://www.sqlite.org
### MANPAGE:=https://www.sqlite.org/docs.html
### CHANGES:=https://www.sqlite.org/changes.html
### CVSREPO:=https://www.sqlite.org/src/timeline

ifeq ($(strip $(FREETZ_PACKAGE_SQLITE_WITH_READLINE)),y)
$(PKG)_DEPENDS_ON += readline
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/sqlite3
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sqlite3

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/.libs/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libsqlite3.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-editline
$(PKG)_CONFIGURE_OPTIONS += --disable-static-shell
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SQLITE_WITH_READLINE),--enable-readline,--disable-readline)

$(PKG)_CONFIGURE_ENV += ac_cv_header_zlib_h=no
# Disable math functions for uClibc 0.9.28/29 (missing trunc() and other C99 math functions)
ifeq ($(strip $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) -USQLITE_ENABLE_MATH_FUNCTIONS"
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQLITE_DIR)

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	@touch -c $@

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(SQLITE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SQLITE_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sqlite \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/sqlite3*

$(pkg)-uninstall:
	$(RM) $(SQLITE_TARGET_BINARY) $(SQLITE_TARGET_LIBDIR)/libsqlite3*.so*

$(call PKG_ADD_LIB,libsqlite3)
$(PKG_FINISH)
