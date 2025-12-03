$(call TOOLS_INIT, 2025-12-02)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=f1407d974c5ed87d544bd931a278232e13925177e239fca370619aba63c757b4
$(PKG)_SITE:=https://curl.se/ca,https://www.curl.se/ca,https://curl.haxx.se/ca
### WEBSITE:=https://www.curl.se/ca
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/cacert.pem
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/cacert.pem

#


define $(PKG)_CUSTOM_UNPACK
	cp -fa $(DL_DIR)/$(CA_BUNDLE_HOST_SOURCE) $(CA_BUNDLE_HOST_BINARY)
endef

#
$(TOOLS_SOURCE_DOWNLOAD)
#
$(TOOLS_UNPACKED)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

#

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(CA_BUNDLE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(CA_BUNDLE_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
