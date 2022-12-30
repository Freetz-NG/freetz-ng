$(call TOOLS_INIT, 5.2.10)
$(PKG)_SOURCE:=xz-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=d615974a17299eaa1bf3d0f3b7afa172624755c8885111b17659051869d6f072
$(PKG)_SITE:=https://tukaani.org/xz
### WEBSITE:=https://tukaani.org/xz/
### CHANGES:=https://git.tukaani.org/?p=xz.git;a=blob_plain;f=NEWS;hb=HEAD
### CVSREPO:=https://git.tukaani.org/?p=xz.git

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/xz-$($(PKG)_VERSION)

$(PKG)_ALONE_DIR:=$($(PKG)_DIR)/src/xz
$(PKG)_LIB_DIR:=$($(PKG)_DIR)/src/liblzma/.libs

$(PKG)_CONFIGURE_OPTIONS += --enable-encoders=lzma1,lzma2,delta
$(PKG)_CONFIGURE_OPTIONS += --enable-decoders=lzma1,lzma2,delta
$(PKG)_CONFIGURE_OPTIONS += --disable-lzmadec
$(PKG)_CONFIGURE_OPTIONS += --disable-lzmainfo
$(PKG)_CONFIGURE_OPTIONS += --disable-lzma-links
$(PKG)_CONFIGURE_OPTIONS += --disable-scripts
$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=no
$(PKG)_CONFIGURE_OPTIONS += --enable-static=yes
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_DIR)/liblzma.a $($(PKG)_ALONE_DIR)/xz: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(LZMA2_HOST_DIR)

$($(PKG)_DIR)/liblzma.a: $($(PKG)_LIB_DIR)/liblzma.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/xz: $($(PKG)_ALONE_DIR)/xz
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_DIR)/liblzma.a $(TOOLS_DIR)/xz


$(pkg)-clean:
	-$(MAKE) -C $(LZMA2_HOST_DIR) clean
	$(RM) $(LZMA2_HOST_DIR)/liblzma.a

$(pkg)-dirclean:
	$(RM) -r $(LZMA2_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/xz

$(TOOLS_FINISH)
