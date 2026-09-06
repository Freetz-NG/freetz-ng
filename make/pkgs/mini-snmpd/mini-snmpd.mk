$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON),1.7,2.1))
$(PKG)_SOURCE:=mini-snmpd-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=bf119818276cd63e37d29d4c5e88f8cdf2975113bc9a2a39ee2b3a91f66de20a
$(PKG)_HASH_CURRENT:=2f9936e4c62d1469a13e43611001b6ac36901ddb9809e3c7cb2297830615a6a1
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/troglobit/mini-snmpd/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://troglobit.com/projects/mini-snmpd/
### MANPAGE:=https://ftp.troglobit.com/mini-snmpd/mini-snmpd.html
### CHANGES:=https://github.com/troglobit/mini-snmpd/releases
### CVSREPO:=https://github.com/troglobit/mini-snmpd
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/$(if $(FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON),,src/)mini-snmpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mini-snmpd

ifneq ($(strip $(FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON)),y)
$(PKG)_DEPENDS_ON += libconfuse
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINI_SNMPD_VERSION_ABANDON

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-demo
$(PKG)_CONFIGURE_OPTIONS += --disable-test
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINI_SNMPD_DIR) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_STRIP)" \
		OFLAGS="$(TARGET_CFLAGS) $(MINI_SNMPD_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MINI_SNMPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINI_SNMPD_TARGET_BINARY)

$(PKG_FINISH)
