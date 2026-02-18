$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=64312f9ac569ddcadb615593cd002c94b76e93a0d4625d3ce1abb49e08e2c2da
$(PKG)_SITE:=https://github.com/opsengine/cpulimit/archive/refs/tags
### WEBSITE:=https://github.com/opsengine/cpulimit
### MANPAGE:=https://github.com/opsengine/cpulimit#cpulimit
### CHANGES:=https://github.com/opsengine/cpulimit/commits/master
### CVSREPO:=https://github.com/opsengine/cpulimit
### SUPPORT:=freetz-ng

$(PKG)_BINARY:=$($(PKG)_DIR)/src/cpulimit
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/cpulimit

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CPULIMIT_STATIC

$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/src

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CPULIMIT_BUILD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CPULIMIT_BUILD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CPULIMIT_TARGET_BINARY)

$(PKG_FINISH)
