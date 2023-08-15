$(call PKG_INIT_BIN,0.5.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ea9ef59002b86519a43fca320982ae971e2df54cdc54cdb35562c751704278d9
$(PKG)_SITE:=http://www.hsc.fr/ressources/outils/dns2tcp/download
$(PKG)_BINARY:=$($(PKG)_DIR)/server/dns2tcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dns2tcpd

$(PKG)_CONFIGURE_OPTIONS += --without-client

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -fcommon

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DNS2TCP_DIR) \
		CFLAGS="$(DNS2TCP_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNS2TCP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNS2TCP_TARGET_BINARY)

$(PKG_FINISH)
