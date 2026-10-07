$(call PKG_INIT_BIN, 1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=786cea9e2c8e0a37d3d4ecd984ca4a0ae0b2d6e2b8da37e3cdbb9d49ccdecbf0
$(PKG)_SITE:=https://github.com/skeeto/$(pkg)/archive/refs/tags
### WEBSITE:=https://github.com/skeeto/endlessh
### MANPAGE:=https://github.com/skeeto/endlessh?tab=readme-ov-file
### CHANGES:=https://github.com/skeeto/endlessh/releases
### CVSREPO:=https://github.com/skeeto/endlessh.git
### STEWARD:=pfichtner

$(PKG)_BINARY:=$($(PKG)_DIR)/endlessh
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/endlessh


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	$(SUBMAKE) -C $(ENDLESSH_DIR) \
		 CC=$(TARGET_CC) \
		 CFLAGS="$(TARGET_CFLAGS)" \
		 LDFLAGS="$(TARGET_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(ENDLESSH_DIR)$($(PKG)_BINARY)

$(pkg)-uninstall:
	$(RM) $(ENDLESSH_TARGET_BINARY)

$(PKG_FINISH)
