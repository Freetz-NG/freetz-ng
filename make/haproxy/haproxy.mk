$(call PKG_INIT_BIN, 2.5.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=d6fa3c66f707ff93b5bd27ce69e70a8964d7b7078548b51868d47d7df3943fe4
$(PKG)_SITE:=https://www.haproxy.org/download/2.5/src
### WEBSITE:=https://www.haproxy.org/
### MANPAGE:=https://linux.die.net/man/1/haproxy
### CHANGES:=https://www.haproxy.org/download/2.5/src/CHANGELOG
### CVSREPO:=https://git.haproxy.org/

$(PKG)_BINARY:=$($(PKG)_DIR)/haproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/haproxy

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION_2_6_28_MIN
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HAPROXY_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HAPROXY_WITH_PCRE

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_HAPROXY_WITH_OPENSSL),openssl)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_HAPROXY_WITH_PCRE),pcre)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HAPROXY_DIR) \
		TARGET=custom \
		USE_EPOLL=$(if $(FREETZ_KERNEL_VERSION_2_6_28_MIN),1) \
		USE_OPENSSL=$(if $(FREETZ_PACKAGE_HAPROXY_WITH_OPENSSL),1) \
		USE_PCRE=$(if $(FREETZ_PACKAGE_HAPROXY_WITH_PCRE),1) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections -fwrapv" \
		LDFLAGS="-Wl,--gc-sections"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HAPROXY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HAPROXY_TARGET_BINARY)

$(PKG_FINISH)
