$(call TOOLS_INIT, 34.3)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=985554de49c21a58abd68c6cda2251384e1e5bb08b3b14c7f02b51f4c90c2958
$(PKG)_SITE:=@KERNEL/linux/utils/kernel/kmod
### WEBSITE:=https://github.com/kmod-project/kmod
### MANPAGE:=https://kmod-project.github.io/kmod/man/depmod.8.html
### CHANGES:=https://github.com/kmod-project/kmod/blob/master/NEWS
### CVSREPO:=https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/tools/kmod
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/depmod

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_OPTIONS += --disable-maintainer-mode
$(PKG)_CONFIGURE_OPTIONS += --disable-manpages
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --with-module-directory=/lib/modules
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --without-xz
$(PKG)_CONFIGURE_OPTIONS += --without-zstd
$(PKG)_CONFIGURE_OPTIONS += --without-openssl


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(KMOD_HOST_DIR) tools/kmod

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(KMOD_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(KMOD_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(KMOD_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
