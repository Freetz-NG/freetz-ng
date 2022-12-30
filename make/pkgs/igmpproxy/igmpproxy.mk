$(call PKG_INIT_BIN, 0.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=afa4b75a823b82f71ce99f33eae4e8136b906ae8a5ede5caaad93bac38cdae24
$(PKG)_SITE:=https://github.com/pali/igmpproxy/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://github.com/pali/igmpproxy
### CHANGES:=https://github.com/pali/igmpproxy/releases
### CVSREPO:=https://github.com/pali/igmpproxy/commits/master

$(PKG)_BINARY:=$($(PKG)_DIR)/src/igmpproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/igmpproxy


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IGMPPROXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(IGMPPROXY_DIR) clean
	$(RM) $(IGMPPROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IGMPPROXY_TARGET_BINARY)

$(PKG_FINISH)
