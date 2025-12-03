$(call PKG_INIT_BIN, 2025-12-02)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=f1407d974c5ed87d544bd931a278232e13925177e239fca370619aba63c757b4
$(PKG)_SITE:=https://curl.se/ca,https://www.curl.se/ca,https://curl.haxx.se/ca
### WEBSITE:=https://www.curl.se/ca
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/cacert.pem
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/ssl/certs/ca-bundle.crt

$(PKG)_STARTLEVEL=30


define $(PKG)_CUSTOM_UNPACK
	cp -fa $(DL_DIR)/$(CA_BUNDLE_SOURCE) $(CA_BUNDLE_BINARY)
endef

ifneq ($(strip $(DL_DIR)/$(CA_BUNDLE_SOURCE)), $(strip $(DL_DIR)/$(CA_BUNDLE_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(CA_BUNDLE_TARGET_BINARY)

$(PKG_FINISH)
