$(call PKG_INIT_BIN, svn1113)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f73b801d56ec7f5e06a306bfb0a6e22b531617ca
$(PKG)_SITE:=https://github.com/Wind4/vlmcsd/archive/refs/tags/
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/vlmcsd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/vlmcsd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VLMCSD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VLMCSD_DIR) clean
	$(RM) $(VLMCSD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(VLMCSD_TARGET_BINARY)

$(PKG_FINISH)
