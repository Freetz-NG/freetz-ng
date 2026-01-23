$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_TCPDUMP_VERSION_ABANDON),4.1.1,4.99.6))
$(PKG)_SOURCE:=tcpdump-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=e6cd4bbd61ec7adbb61ba8352c4b4734f67b8caaa845d88cb826bc0b9f1e7f0a
$(PKG)_HASH_CURRENT:=5839921a0f67d7d8fa3dacd9cd41e44c89ccb867e8a6db216d62628c7fd14b09
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_TCPDUMP_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://www.tcpdump.org/release
### WEBSITE:=https://www.tcpdump.org
### MANPAGE:=https://www.tcpdump.org/manpages/tcpdump.1.html
### CHANGES:=https://github.com/the-tcpdump-group/tcpdump/blob/master/CHANGES
### CVSREPO:=https://github.com/the-tcpdump-group/tcpdump
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/tcpdump
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpdump

$(PKG)_DEPENDS_ON += libpcap

ifeq ($(strip $(FREETZ_PACKAGE_TCPDUMP_MINI)),y)
$(PKG)_CFLAGS := -DTCPDUMP_MINI
$(PKG)_CONFIGURE_OPTIONS += --disable-smb
endif

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_TCPDUMP_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TCPDUMP_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TCPDUMP_VERSION_CURRENT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TCPDUMP_MINI
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_ENV += ac_cv_path_PCAP_CONFIG=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcap-config
ifeq ($(strip $(FREETZ_PACKAGE_TCPDUMP_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_ENV += td_cv_buggygetaddrinfo="no"
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
else
$(PKG)_CONFIGURE_OPTIONS += --disable-local-libpcap
$(PKG)_CONFIGURE_OPTIONS += --without-smi
$(PKG)_CONFIGURE_OPTIONS += --without-sandbox-capsicum
$(PKG)_CONFIGURE_OPTIONS += --without-cap-ng
endif
$(PKG)_CONFIGURE_OPTIONS += --without-crypto


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TCPDUMP_DIR) all \
		CCOPT="$(TARGET_CFLAGS) $(TCPDUMP_CFLAGS)" \
		INCLS="-I." \
		$(if $(FREETZ_PACKAGE_TCPDUMP_MINI),TCPDUMP_MINI=1,)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(TCPDUMP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TCPDUMP_TARGET_BINARY)

$(PKG_FINISH)
