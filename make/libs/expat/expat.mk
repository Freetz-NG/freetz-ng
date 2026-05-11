$(call PKG_INIT_LIB, $(if $(FREETZ_LIB_libexpat_WITH_VERSION_ABANDON),2.7.5,2.8.1))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_LIB_libexpat_WITH_VERSION_ABANDON),1.11.3,1.12.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=1032dfef4ff17f70464827daa28369b20f6584d108bc36f17ab1676e1edd2f91
$(PKG)_HASH_CURRENT:=10b195ee78160a908388180a8fe3603d4e9a12f4755fbf5f3816b23a9d750da0
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libexpat_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@SF/expat,https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$($(PKG)_VERSION))
### VERSION:=2.7.5/2.8.1
### WEBSITE:=https://libexpat.github.io/
### MANPAGE:=https://libexpat.github.io/doc/
### CHANGES:=https://github.com/libexpat/libexpat/blob/master/expat/Changes
### CVSREPO:=https://github.com/libexpat/libexpat

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libexpat.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libexpat_WITH_VERSION_ABANDON),abandon,current)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-xmlwf
$(PKG)_CONFIGURE_OPTIONS += --without-examples
$(PKG)_CONFIGURE_OPTIONS += --without-tests
$(PKG)_CONFIGURE_OPTIONS += --without-docbook
#$(PKG)_CONFIGURE_OPTIONS += --without-arc4random
#$(PKG)_CONFIGURE_OPTIONS += --without-arc4random-buf
#$(PKG)_CONFIGURE_OPTIONS += --without-getentropy
#$(PKG)_CONFIGURE_OPTIONS += --without-getrandom
#$(PKG)_CONFIGURE_OPTIONS += --without-sys-getrandom

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -DXML_POOR_ENTROPY


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(EXPAT_DIR) \
		CFLAGS="$(EXPAT_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(EXPAT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/expat.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(EXPAT_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/expat.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/expat*.h

$(pkg)-uninstall:
	$(RM) $(EXPAT_TARGET_DIR)/libexpat*.so*

$(PKG_FINISH)
