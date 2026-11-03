$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON),1.18,2.14))
$(PKG)_SOURCE:=vnstat-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=d7193592b9e7445fa5cbe8af7d3b39982f165ee8fc58041ff41f509b37c687d5
$(PKG)_HASH_CURRENT:=8ba2119b3c6f780775135f9c9fa7236867da67e2f93649f1313319b9cf48f87c
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://humdi.net/vnstat
### WEBSITE:=https://humdi.net/vnstat/
### MANPAGE:=https://humdi.net/vnstat/man/
### CHANGES:=https://humdi.net/vnstat/CHANGES
### CVSREPO:=https://github.com/vergoh/vnstat
### STEWARD:=fda77

$(PKG)_BINARIES_ALL := vnstat vnstatd vnstati
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_VNSTAT_CLI),,vnstat) $(if $(FREETZ_PACKAGE_VNSTAT_DAEMON),,vnstatd) $(if $(FREETZ_PACKAGE_VNSTAT_IMAGE),,vnstati),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON += libgd
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON),,sqlite)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON),abandon,current)

ifneq ($(strip $(FREETZ_PACKAGE_VNSTAT_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_ENV += ac_cv_have_decl_gdImageStringFT=no

$(PKG)_CONFIGURE_OPTIONS += --disable-extra-paths
endif


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
