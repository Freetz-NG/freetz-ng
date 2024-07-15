$(call PKG_INIT_BIN,1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b3e03d7342f2b8f33644f66388f484cdfead45cabed7a9a93f8be50f8bc91a42
$(PKG)_SITE:=https://github.com/skeeto/$(pkg)/releases/download/$($(PKG)_VERSION)
### CHANGES:=https://github.com/skeeto/endlessh/releases
### CVSREPO:=https://github.com/skeeto/endlessh.git

$(PKG)_BINARY:=$($(PKG)_DIR)/endlessh
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/endlessh

$(PKG)_CFLAGS := $(TARGET_CFLAGS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

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
