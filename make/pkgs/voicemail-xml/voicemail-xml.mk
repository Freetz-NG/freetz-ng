$(call PKG_INIT_BIN, 1.0)
### STEWARD:=Dag0d

$(PKG)_DEPENDS_ON += expat

$(PKG)_BINARY:=$($(PKG)_DIR)/voicemail-xml
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/callmonitor/bin/voicemail-xml


$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VOICEMAIL_XML_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(VOICEMAIL_XML_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VOICEMAIL_XML_TARGET_BINARY)

$(PKG_FINISH)
