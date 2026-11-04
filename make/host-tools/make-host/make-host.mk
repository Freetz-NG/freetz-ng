$(call TOOLS_INIT, 4.4.1)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/make/
### MANPAGE:=https://www.gnu.org/software/make/manual/
### CHANGES:=https://ftp.gnu.org/gnu/make/
### CVSREPO:=https://git.savannah.gnu.org/cgit/make.git
### STEWARD:=fda77

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build

$(PKG)_BINARY_NAME    := make
$(PKG)_BINARY_SOURCE  := $($(PKG)_DIR)/$($(PKG)_BINARY_NAME)
$(PKG)_BINARY_TARGET  := $($(PKG)_DESTDIR)/bin/$($(PKG)_BINARY_NAME)

$(PKG)_INCLUDE_NAME   := gnumake.h
$(PKG)_INCLUDE_SOURCE := $($(PKG)_DIR)/src/$($(PKG)_INCLUDE_NAME)
$(PKG)_INCLUDE_TARGET := $($(PKG)_DESTDIR)/include/$($(PKG)_INCLUDE_NAME)

$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-guile
$(PKG)_CONFIGURE_OPTIONS += --without-dmalloc


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_SOURCE) $($(PKG)_INCLUDE_SOURCE): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(MAKE_HOST_DIR) all
	@touch -c $@

$($(PKG)_INCLUDE_TARGET): $($(PKG)_INCLUDE_SOURCE)
	$(INSTALL_FILE)

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_SOURCE)
	$(RM) $(MAKE_HOST_BINARY_TARGET)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET) $($(PKG)_INCLUDE_TARGET)


$(pkg)-clean:
	-$(MAKE) -C $(MAKE_HOST_DIR) clean
	-$(RM) $(MAKE_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(MAKE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(MAKE_HOST_BINARY_TARGET) \
		$(MAKE_HOST_INCLUDE_TARGET)

$(TOOLS_FINISH)
