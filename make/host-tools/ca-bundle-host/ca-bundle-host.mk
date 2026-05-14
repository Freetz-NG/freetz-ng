$(call TOOLS_INIT, 2026-05-14)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=86a1f3366afac7c6f8ae9f3c779ac221129328c43f0ab2b8817eb2f362a5025c
$(PKG)_SITE:=https://curl.se/ca,https://www.curl.se/ca,https://curl.haxx.se/ca
### WEBSITE:=https://www.curl.se/ca
### STEWARD:=fda77

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
