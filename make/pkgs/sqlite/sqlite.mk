$(call PKG_INIT_BIN, $(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),3400100,3500400))
$(PKG)_LIB_VERSION:=3.50.4
$(PKG)_SOURCE:=$(pkg)-autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=2c5dea207fa508d765af1ef620b637dcb06572afa6f01f0815bd5bbf864b33d9
$(PKG)_HASH_CURRENT:=a3db587a1b92ee5ddac2f66b3edb41b26f9c867275782d46c3a088977d6a5b18
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=https://www.sqlite.org/2022
$(PKG)_SITE_CURRENT:=https://www.sqlite.org/2025
$(PKG)_SITE:=$($(PKG)_SITE_$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),ABANDON,CURRENT))
### VERSION:=3.40.1/3.50.4
### WEBSITE:=https://www.sqlite.org
### MANPAGE:=https://www.sqlite.org/docs.html
### CHANGES:=https://www.sqlite.org/changes.html
### CVSREPO:=https://www.sqlite.org/src/timeline

ifeq ($(strip $(FREETZ_PACKAGE_SQLITE_WITH_READLINE)),y)
$(PKG)_DEPENDS_ON += readline
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/sqlite3
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sqlite3

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/.libs/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libsqlite3.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libsqlite3_WITH_VERSION_ABANDON


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

# SQLite uses a non-standard configure script (jimtcl-based)
# It doesn't support standard autoconf options like --target, --cache-file etc
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	( cd $(SQLITE_DIR); \
		$(TARGET_CONFIGURE_ENV) \
		ac_cv_header_zlib_h=no \
		./configure \
		--prefix=/usr \
		--enable-shared \
		--enable-static \
		--disable-editline \
		--disable-static-shell \
		$(if $(FREETZ_PACKAGE_SQLITE_WITH_READLINE),--enable-readline,--disable-readline) \
	)
	touch $@

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQLITE_DIR)

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	@touch -c $@

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(SQLITE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sqlite3.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SQLITE_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sqlite3.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sqlite3ext.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/sqlite3*

$(pkg)-uninstall:
	$(RM) $(SQLITE_TARGET_BINARY) $(SQLITE_TARGET_LIBDIR)/libsqlite3*.so*

$(call PKG_ADD_LIB,libsqlite3)
$(PKG_FINISH)
