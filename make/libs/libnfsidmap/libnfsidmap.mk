$(call PKG_INIT_LIB, 0.27)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=27cfb22f1ee85e51b863b71858a97da0
$(PKG)_SITE:=https://fedorapeople.org/~steved/libnfsidmap/$($(PKG)_VERSION)
$(PKG)_SHLIB_VERSION:=1.0.0

$(PKG)_LIBNAME := $(pkg).so
$(PKG)_BINARY := $($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY := $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY := $($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

LIBNFSIDMAP_PLUGIN_ADDON_DIR := $(ADDON_DIR)/$(pkg)-plugin/root$(FREETZ_LIBRARY_DIR)/$(pkg)
LIBNFSIDMAP_PLUGIN_PKG := $(ADDON_DIR)/$(pkg)-plugin.pkg

$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --with-pluginpath=$(FREETZ_LIBRARY_DIR)/$(pkg)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBNFSIDMAP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBNFSIDMAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-strip

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)
	echo libnfsidmap-plugin > $(LIBNFSIDMAP_PLUGIN_PKG); \
	mkdir -p $(LIBNFSIDMAP_PLUGIN_ADDON_DIR)
	cp -a $(dir $<)libnfsidmap/*.so  $(LIBNFSIDMAP_PLUGIN_ADDON_DIR)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBNFSIDMAP_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libnfsidmap* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libnfsidmap.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/nfsidmap.h \
		$(ADDON_DIR)/$(pkg)*

$(pkg)-uninstall:
	$(RM) -r $(LIB_TARGET_DIR)/libnfsidmap*

$(PKG_FINISH)
