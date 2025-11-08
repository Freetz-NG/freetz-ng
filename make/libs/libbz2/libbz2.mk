$(call PKG_INIT_LIB, 1.0.8)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=bzip2-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
$(PKG)_SITE:=https://sourceware.org/pub/bzip2
### WEBSITE:=https://sourceware.org/bzip2/
### MANPAGE:=https://sourceware.org/bzip2/docs.html
### CHANGES:=https://sourceware.org/bzip2/CHANGES
### CVSREPO:=https://sourceware.org/git/bzip2.git

$(PKG)_BINARY:=$($(PKG)_DIR)/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libbz2.so.$($(PKG)_LIB_VERSION)

$(PKG)_MAKE_VARS += CC="$(TARGET_CC)"
$(PKG)_MAKE_VARS += AR="$(TARGET_AR)"
$(PKG)_MAKE_VARS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_VARS += CFLAGS="$(TARGET_CFLAGS) -fPIC -D_FILE_OFFSET_BITS=64"
$(PKG)_MAKE_VARS += LDFLAGS="$(TARGET_LDFLAGS)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBBZ2_DIR) \
		$(LIBBZ2_MAKE_VARS) \
		libbz2.a
	$(SUBMAKE) -C $(LIBBZ2_DIR) \
		$(LIBBZ2_MAKE_VARS) \
		-f Makefile-libbz2_so

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	@mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/{lib,include}
	cp -a $(LIBBZ2_DIR)/libbz2.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp -a $(LIBBZ2_DIR)/libbz2.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp -a $(LIBBZ2_DIR)/bzlib.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBBZ2_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/bzlib.h

$(pkg)-uninstall:
	$(RM) $(LIBBZ2_TARGET_DIR)/libbz2.so*

$(PKG_FINISH)
