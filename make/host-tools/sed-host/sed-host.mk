$(call TOOLS_INIT, 4.9)
$(PKG)_SOURCE:=sed-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=6e226b732e1cd739464ad6862bd1a1aba42d7982922da7a53519631d24975181
$(PKG)_SITE:=@GNU/sed

$(PKG)_BINARY:=$($(PKG)_DIR)/sed/sed
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/sed

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-acl


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
