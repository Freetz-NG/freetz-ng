$(call PKG_INIT_BIN, 1.18)
$(PKG)_SOURCE:=vnstat-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d7193592b9e7445fa5cbe8af7d3b39982f165ee8fc58041ff41f509b37c687d5
$(PKG)_SITE:=http://humdi.net/vnstat

$(PKG)_BINARIES_ALL := vnstat vnstatd vnstati
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_VNSTAT_DAEMON),,vnstatd) $(if $(FREETZ_PACKAGE_VNSTAT_IMAGE),,vnstati),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON += libgd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VNSTAT_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VNSTAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VNSTAT_BINARIES_ALL:%=$(VNSTAT_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
