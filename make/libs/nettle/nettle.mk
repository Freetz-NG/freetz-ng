$(call PKG_INIT_LIB, 3.10.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=fe9ff51cb1f2abb5e65a6b8c10a92da0ab5ab6eaf26e7fc2b675c45f1fb519b5
$(PKG)_SITE:=@GNU/nettle,https://www.lysator.liu.se/~nisse/archive
### WEBSITE:=https://www.lysator.liu.se/~nisse/nettle/
### MANPAGE:=https://www.lysator.liu.se/~nisse/nettle/nettle.html
### CHANGES:=https://git.lysator.liu.se/nettle/nettle/blob/master/ChangeLog
### CVSREPO:=https://git.lysator.liu.se/nettle/nettle

$(PKG)_LIBNAMES         := nettle hogweed
$(PKG)_LIBVERSIONS      := 8.11   6.11
$(PKG)_LIBNAMES_LONG    := $(join $($(PKG)_LIBNAMES:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES:%=$($(PKG)_DIR)/lib%.so)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_DEPENDS_ON += gmp

$(PKG)_CONFIGURE_OPTIONS += --disable-assembler
$(PKG)_CONFIGURE_OPTIONS += --disable-documentation
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl
$(PKG)_CONFIGURE_OPTIONS += --disable-mini-gmp
$(PKG)_CONFIGURE_OPTIONS += --enable-public-key


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NETTLE_DIR) \
		EXTRA_CFLAGS="-ffunction-sections -fdata-sections"

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(NETTLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-here
	$(PKG_FIX_LIBTOOL_LA) \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(NETTLE_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/nettle \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*) \
		$(NETTLE_LIBNAMES:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)

$(pkg)-uninstall:
	$(RM) $(NETTLE_LIBNAMES:%=$(NETTLE_TARGET_DIR)/lib%*.so*)

$(PKG_FINISH)
