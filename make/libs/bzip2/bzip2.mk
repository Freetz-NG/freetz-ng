$(call PKG_INIT_LIB, 1.0.8)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
$(PKG)_SITE:=https://sourceware.org/pub/bzip2
### WEBSITE:=https://sourceware.org/bzip2/
### MANPAGE:=https://sourceware.org/bzip2/docs.html
### CHANGES:=https://sourceware.org/bzip2/CHANGES
### CVSREPO:=https://sourceware.org/git/bzip2.git

$(PKG)_BINARY:=$($(PKG)_DIR)/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libbz2.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BZIP2_DIR) \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		CFLAGS="$(TARGET_CFLAGS) -fPIC -D_FILE_OFFSET_BITS=64" \
		LDFLAGS="" \
		PREFIX=/usr \
		-f Makefile-libbz2_so \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(BZIP2_DIR)/libbz2.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp $(BZIP2_DIR)/bzlib.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	ln -sf libbz2.so.$(BZIP2_LIB_VERSION) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so.1.0
	ln -sf libbz2.so.$(BZIP2_LIB_VERSION) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BZIP2_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/bzlib.h

$(pkg)-uninstall:
	$(RM) $(BZIP2_TARGET_DIR)/libbz2.so*

$(PKG_FINISH)
