$(call PKG_INIT_BIN, 0.1)
$(PKG)_CATEGORY:=Disk Tools
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4669b0014a9b29a7e63d80141c2d85fe44b8d6f6fbc1d77feb557888c33c281c
$(PKG)_SITE:=http://mkp.net/code/fstyp

$(PKG)_BINARY:=$($(PKG)_DIR)/src/fstyp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fstyp

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FSTYP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FSTYP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(FSTYP_TARGET_BINARY)

$(PKG_FINISH)
