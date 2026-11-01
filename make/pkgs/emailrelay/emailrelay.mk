$(call PKG_INIT_BIN, 1.9)
$(PKG)_SOURCE:=emailrelay-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_HASH:=869a3e2d053237d7f63784acc25e748af2dbf2d9b9c5c48e4a5269d4e4b5bda0
$(PKG)_SITE:=@SF/emailrelay
$(PKG)_BINARY:=$($(PKG)_DIR)/src/main/emailrelay
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/emailrelay
### WEBSITE:=https://emailrelay.sourceforge.net/
### MANPAGE:=https://emailrelay.sourceforge.net/index.html#userguide_md_User_Guide
### CHANGES:=https://emailrelay.sourceforge.net/Change_Log.html
### CVSREPO:=https://sourceforge.net/p/emailrelay/git/ci/master/tree/

# uClibc causes stalling while pop3 access
$(PKG)_DEPENDS_ON += libstdcxx openssl zlib

$(PKG)_CONFIGURE_ENV += CXX="$(TARGET_CXX_GNU)"

#daemon does not start if ipv6 enabled but unused (no valid dns configuration)
#$(PKG)_REBUILD_SUBOPTS := FREETZ_TARGET_IPV6_SUPPORT
#$(PKG)_CONFIGURE_OPTIONS := $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --disable-admin
$(PKG)_CONFIGURE_OPTIONS += --disable-gui


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(EMAILRELAY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(EMAILRELAY_DIR) clean
	$(RM) $(EMAILRELAY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(EMAILRELAY_TARGET_BINARY)

$(PKG_FINISH)
