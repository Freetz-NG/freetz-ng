$(call TOOLS_INIT, 5.4.2)
$(PKG)_SOURCE:=gawk-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b95e4909533b5f988c6b5e5539b3b3ddf76e7d7df02ca2e5b5b7d6f62db78e6a
$(PKG)_SITE:=@GNU/gawk
### WEBSITE:=https://www.gnu.org/software/gawk/
### MANPAGE:=https://www.gnu.org/software/gawk/manual/
### CHANGES:=https://ftp.gnu.org/gnu/gawk/
### CVSREPO:=https://git.savannah.gnu.org/cgit/gawk.git
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/gawk
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/gawk

$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-mpfr
$(PKG)_CONFIGURE_OPTIONS += --disable-pma
$(PKG)_CONFIGURE_OPTIONS += --disable-extensions
$(PKG)_CONFIGURE_OPTIONS += --without-readline


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(GAWK_HOST_DIR) \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(GAWK_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(GAWK_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(GAWK_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
