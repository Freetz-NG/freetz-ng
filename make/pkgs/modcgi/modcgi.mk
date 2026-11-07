$(call PKG_INIT_BIN, 0.3)
$(PKG)_SOURCE:=modcgi-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=7ec1c1cb3ec1c8519844ae5b9692d0d1fa4f64171c0302f0d62a612ef22113dd
$(PKG)_SITE:=@MIRROR
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/modcgi
### STEWARD:=X


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MODCGI_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MODCGI_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MODCGI_TARGET_BINARY)

$(PKG_FINISH)
