$(call PKG_INIT_BIN, 014)
$(PKG)_SOURCE:=repeater$($(PKG)_VERSION).zip
$(PKG)_SITE:=https://web.archive.org/web/20151001044013/http://koti.mbnet.fi/jtko/uvncrepeater
$(PKG)_DIR=$(SOURCE_DIR)/Ver014
$(PKG)_BINARY:=$($(PKG)_DIR)/repeater
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/uvncrepeater
$(PKG)_HASH:=f22f2c5a283c7ff636a649b4b2e0de7409537eaa

### WEBSITE:=https://uvnc.com/products/ultravnc-repeater.html
### MANPAGE:=https://uvnc.com/docs/ultravnc-repeater.html
### SUPPORT:=manfred-mueller

$(PKG)_BINARY:=$($(PKG)_DIR)/repeater
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/uvncrepeater

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UVNCREPEATER_DIR) \
                CC="$(TARGET_CC)" \
                CFLAGS="$(TARGET_CFLAGS)"


$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(UVNCREPEATER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(UVNCREPEATER_TARGET_BINARY)

$(PKG_FINISH)
