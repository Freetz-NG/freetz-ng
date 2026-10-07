$(call PKG_INIT_BIN, 0.6.23d)
$(PKG)_SOURCE:=empty-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=9ad495d52b942e3fd858643536d8d12e282568214300954d4518d8c22b893585
$(PKG)_SITE:=@SF/empty
$(PKG)_BINARY:=$($(PKG)_DIR)/empty
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/empty

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(EMPTY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(EMPTY_DIR) clean
	$(RM) $(EMPTY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(EMPTY_TARGET_BINARY)

$(PKG_FINISH)
