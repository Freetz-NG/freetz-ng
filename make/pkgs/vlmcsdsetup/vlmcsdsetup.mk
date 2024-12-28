$(call PKG_INIT_BIN, 0.0.1)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=c8443079b7ecbcd36629213f3d49d8b24269fbaeb895639d058e07a44594232a
$(PKG)_SITE:=https://github.com/manfred-mueller/vlmcsdsetup/archive/refs/tags/
$(PKG)_BINARY:=$($(PKG)_DIR)/vlmcsdsetup
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/vlmcsdsetup

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VLMCSDSETUP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VLMCSDSETUP_DIR) clean
	$(RM) $(VLMCSDSETUP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(VLMCSDSETUP_TARGET_BINARY)

$(PKG_FINISH)
