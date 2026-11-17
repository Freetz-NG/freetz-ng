$(call PKG_INIT_BIN, 1.0.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3bb0ed89f8b3fcf47a08784b323189baf740e27021edb9da854c70afbb49d8f6
$(PKG)_SITE:=https://github.com/libpcpnatpmp/libpcpnatpmp/archive/refs/tags/
### MANPAGE:=https://github.com/libpcpnatpmp/libpcpnatpmp/tree/master/pcp_app#readme
### CHANGES:=https://github.com/libpcpnatpmp/libpcpnatpmp/commits/master/
### CVSREPO:=https://github.com/libpcpnatpmp/libpcpnatpmp/
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/cli-client/pcpnatpmpc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/pcpnatpmpc

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-prof
$(PKG)_CONFIGURE_OPTIONS += --disable-gcov
$(PKG)_CONFIGURE_OPTIONS += --enable-enable-cli-client
$(PKG)_CONFIGURE_OPTIONS += --disable-server
$(PKG)_CONFIGURE_OPTIONS += --enable-natpmp
#$(PKG)_CONFIGURE_OPTIONS += --enable-flow-priority
#$(PKG)_CONFIGURE_OPTIONS += --enable-learn-dscp
#$(PKG)_CONFIGURE_OPTIONS += --enable-experimental
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCPNATPMP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PCPNATPMP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PCPNATPMP_DEST_DIR)/usr/bin/pcpnatpmpc

$(PKG_FINISH)
