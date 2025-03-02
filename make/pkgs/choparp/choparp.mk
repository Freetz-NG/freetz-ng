$(call PKG_INIT_BIN, 20150613)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=141cad384dc42f094d0c9a1fd49440adc1bf7f19c1cce122091374d8ca261f19
$(PKG)_SITE:=https://github.com/quinot/choparp/archive/refs/tags/release
### WEBSITE:=https://github.com/quinot/choparp

$(PKG)_BINARY:=$($(PKG)_DIR)/choparp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/choparp

$(PKG)_DEPENDS_ON += libpcap

$(PKG)_EXTRA_CFLAGS := -I.
$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/glib-2.0
$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/glib-2.0/include


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CHOPARP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(CHOPARP_EXTRA_CFLAGS) -Wall" \
		choparp

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(CHOPARP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CHOPARP_TARGET_BINARY)

$(PKG_FINISH)
