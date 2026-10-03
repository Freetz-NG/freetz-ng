$(call PKG_INIT_BIN, 4.6.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e651adcc4cc0d0ceaa36e5997dab9ea7f8aea732b4c87ba6018d2dcc88fbe8e3
$(PKG)_SITE:=@SF/ser2net
### WEBSITE:=https://ser2net.sourceforge.net/
### MANPAGE:=https://linux.die.net/man/8/ser2net
### CHANGES:=https://sourceforge.net/p/ser2net/news/
### CVSREPO:=https://sourceforge.net/projects/ser2net/

$(PKG)_BINARY:=$($(PKG)_DIR)/ser2net
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ser2net

$(PKG)_DEPENDS_ON += gensio
$(PKG)_DEPENDS_ON += yaml

$(PKG)_CONFIGURE_OPTIONS += --with-pam=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SER2NET_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SER2NET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SER2NET_TARGET_BINARY)

$(PKG_FINISH)
