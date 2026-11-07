$(call PKG_INIT_BIN, 0.9.36)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8f6048bfc77dfe8d1032aec2e708fddfa36d225c25d14b474f70ba7d6eefabc1
$(PKG)_SITE:=@SF/haserl
### WEBSITE:=http://haserl.sourceforge.net/
### MANPAGE:=http://haserl.sourceforge.net/manpage.html
### CHANGES:=https://sourceforge.net/p/haserl/mailman/haserl-users/
### CVSREPO:=https://sourceforge.net/projects/haserl/files/
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/haserl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/haserl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HASERL_WITH_LUA
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_liblua_WITH_VERSION_ABANDON

ifeq ($(strip $(FREETZ_PACKAGE_HASERL_WITH_LUA)),y)
$(PKG)_DEPENDS_ON += lua
$(PKG)_CONFIGURE_OPTIONS += --enable-luashell
$(PKG)_CONFIGURE_OPTIONS += --enable-luacshell
$(PKG)_CONFIGURE_OPTIONS += --with-lua
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HASERL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(HASERL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HASERL_TARGET_BINARY)

$(PKG_FINISH)
