$(call TOOLS_INIT, 4.10)
$(PKG)_SOURCE:=sed-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b8e72182b2ec96a3574e2998c47b7aaa64cc20ce000d8e9ac313cc07cecf28c7
$(PKG)_SITE:=@GNU/sed
### WEBSITE:=https://www.gnu.org/software/sed/
### MANPAGE:=https://sed.sourceforge.io/#docs
### CHANGES:=https://git.savannah.gnu.org/cgit/sed.git/refs/tags
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=sed.git
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/sed/sed
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/sed

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-acl
$(PKG)_CONFIGURE_OPTIONS += --disable-xattr


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(SED_HOST_DIR) all
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(SED_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SED_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(SED_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
