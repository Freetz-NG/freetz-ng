$(call PKG_INIT_BIN, 3.100)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_HASH:=ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e
$(PKG)_SITE:=@DEBIAN/lame
$(PKG)_SOURCE:=lame_$($(PKG)_VERSION).orig.tar.gz
### WEBSITE:=https://lame.sourceforge.io/

$(PKG)_CATEGORY_LIBS:=Multimedia##Audio
$(PKG)_BINARY:=$($(PKG)_DIR)/frontend/$(if $(FREETZ_PACKAGE_LAME_STATIC),,.libs/)lame
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lame
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libmp3lame/.libs/libmp3lame.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libmp3lame.so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_PACKAGE_LAME)),)
$(PKG)_EXCLUDED += /usr/bin/lame
endif
ifeq ($(strip $(FREETZ_LIB_libmp3lame)),)
$(PKG)_EXCLUDED += $(addprefix $($(PKG)_TARGET_LIBDIR)/,libmp3lame.so libmp3lame.so.0 libmp3lame.so.$($(PKG)_LIB_VERSION))
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LAME FREETZ_PACKAGE_LAME_STATIC FREETZ_LIB_libmp3lame
$(PKG)_CONFIGURE_OPTIONS += --enable-shared --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
# LAME's frontend defaults to linking libmp3lame statically when this option is omitted.
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LAME_STATIC),,--enable-dynamic-frontends)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LAME_DIR)/mpglib
	$(SUBMAKE) -C $(LAME_DIR)/libmp3lame

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(LAME_DIR)/frontend

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(LAME_DIR)/libmp3lame DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(SUBMAKE) -C $(LAME_DIR)/include DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $(if $(FREETZ_PACKAGE_LAME),$($(PKG)_TARGET_BINARY)) \
	$(if $(FREETZ_LIB_libmp3lame),$($(PKG)_LIB_TARGET_BINARY))

$(pkg)-clean:
	-$(SUBMAKE) -C $(LAME_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmp3lame.*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lame

$(pkg)-uninstall:
	$(RM) $(LAME_TARGET_BINARY) $(LAME_TARGET_LIBDIR)/libmp3lame.so*

$(call PKG_ADD_LIB,libmp3lame)
$(PKG_FINISH)
