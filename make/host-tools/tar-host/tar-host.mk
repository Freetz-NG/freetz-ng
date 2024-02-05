$(call TOOLS_INIT, 1.35)
$(PKG)_SOURCE:=tar-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=4d62ff37342ec7aed748535323930c7cf94acf71c3591882b26a7ea50f3edc16
$(PKG)_SITE:=@GNU/tar

$(PKG)_DEPENDS_ON:=kconfig-host

$(PKG)_BINARY:=$($(PKG)_DIR)/src/tar
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/tar-gnu

$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-acl


define $(PKG)_CUSTOM_UNPACK
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(TAR_HOST_DIR) all
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(TAR_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(TAR_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TAR_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
