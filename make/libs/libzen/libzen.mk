$(call PKG_INIT_LIB, 0.4.41)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=ZenLib-v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=45d5173fa0278f5264daa6836ae297aa303984482227d00b35c4f03929494c8f
$(PKG)_SITE:=https://github.com/MediaArea/ZenLib/archive/refs/tags
### WEBSITE:=https://mediaarea.net/en/ZenLib
### CHANGES:=https://github.com/MediaArea/ZenLib/releases
### CVSREPO:=https://github.com/MediaArea/ZenLib

$(PKG)_BINARY:=$($(PKG)_DIR)/Project/GNU/Library/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	(cd $(LIBZEN_DIR)/Project/GNU/Library && \
		./autogen.sh && \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/usr \
			$(LIBZEN_CONFIGURE_OPTIONS) && \
		$(SUBMAKE) \
	) $(SILENT)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBZEN_DIR)/Project/GNU/Library \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libzen.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBZEN_DIR)/Project/GNU/Library clean $(SILENT)
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libzen* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ZenLib \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libzen.pc

$(pkg)-uninstall:
	$(RM) $(LIBZEN_TARGET_DIR)/libzen*.so*

$(PKG_FINISH)
