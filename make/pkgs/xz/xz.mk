$(call PKG_INIT_BIN, 5.2.10)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=d615974a17299eaa1bf3d0f3b7afa172624755c8885111b17659051869d6f072
$(PKG)_SITE:=https://tukaani.org/xz
### WEBSITE:=https://tukaani.org/xz/
### CHANGES:=https://git.tukaani.org/?p=xz.git;a=blob_plain;f=NEWS;hb=HEAD
### CVSREPO:=https://git.tukaani.org/?p=xz.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/xz/.libs/xz
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/xz

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/liblzma/.libs/liblzma.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/liblzma.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-static=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-encoders=lzma1,lzma2,delta
$(PKG)_CONFIGURE_OPTIONS += --enable-decoders=lzma1,lzma2,delta
$(PKG)_CONFIGURE_OPTIONS += --disable-assembler
$(PKG)_CONFIGURE_OPTIONS += --disable-xzdec
$(PKG)_CONFIGURE_OPTIONS += --disable-lzmadec
$(PKG)_CONFIGURE_OPTIONS += --disable-lzmainfo
$(PKG)_CONFIGURE_OPTIONS += --disable-lzma-links
$(PKG)_CONFIGURE_OPTIONS += --disable-scripts
$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix


ifneq ($(strip $(DL_DIR)/$(XZ_SOURCE)), $(strip $(DL_DIR)/$(LZMA2_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(XZ_DIR) EXTRA_CFLAGS="-ffunction-sections -fdata-sections"

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	@touch -c $@

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(XZ_DIR)/src/liblzma     DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install-libLTLIBRARIES install-pkgconfigDATA
	$(SUBMAKE) -C $(XZ_DIR)/src/liblzma/api DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install-nobase_includeHEADERS
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/liblzma.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(XZ_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/liblzma.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lzma.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lzma \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xz

$(pkg)-uninstall:
	$(RM) $(XZ_TARGET_BINARY) $(XZ_TARGET_LIBDIR)/liblzma*.so*

$(call PKG_ADD_LIB,liblzma)
$(PKG_FINISH)
