$(call PKG_INIT_BIN, 0.17)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d032547c708307159ff5fd0df23ebd3cfa7799c31536fa0aea1820318a8e0eac
$(PKG)_SITE:=http://www.ex-parrot.com/pdw/$(pkg)/download
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON += ncurses libpcap
$(PKG)_LIBS := -lpcap -lm  -lncurses -lpthread

$(PKG)_CONFIGURE_OPTIONS += --with-libpcap="$(TARGET_TOOLCHAIN_STAGING_DIR)/include/pcap"
#$(PKG)_CONFIGURE_OPTIONS += --with-resolver=none

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE1) -C $(IFTOP_DIR) \
		LIBS="$(IFTOP_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IFTOP_DIR) clean
	$(RM) $(IFTOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IFTOP_TARGET_BINARY)

$(PKG_FINISH)
