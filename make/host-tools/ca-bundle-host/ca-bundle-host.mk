$(call TOOLS_INIT, 2025-07-15)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=7430e90ee0cdca2d0f02b1ece46fbf255d5d0408111f009638e3b892d6ca089c
$(PKG)_SITE:=https://www.curl.se/ca,https://curl.haxx.se/ca
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
