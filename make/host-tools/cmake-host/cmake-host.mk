$(call TOOLS_INIT, 4.1.3)
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=765879a53d178bf1e1509768de4c9a672dabaa20047a9f3809571558e783be88
$(PKG)_SITE:=https://github.com/Kitware/CMake/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://cmake.org/
### MANPAGE:=https://cmake.org/cmake/help/latest/
### CHANGES:=https://github.com/Kitware/CMake/releases
### CVSREPO:=https://gitlab.kitware.com/cmake/cmake
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=patchelf-host
$(PKG)_DEPENDS_ON+=openssl-host
$(PKG)_DEPENDS_ON+=ca-bundle-host

$(PKG)_DESTDIR             := $(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_BINARIES            := ccmake cmake cpack ctest
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)
$(PKG)_DOC_TARGET_DIR      := $($(PKG)_DESTDIR)/doc/$(pkg_short)-$($(PKG)_MAJOR_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(CMAKE_HOST_DESTDIR)
$(PKG)_CONFIGURE_OPTIONS += --generator='Unix Makefiles'
$(PKG)_CONFIGURE_OPTIONS += --enable-ccache
$(PKG)_CONFIGURE_OPTIONS += --no-qt-gui
$(PKG)_CONFIGURE_OPTIONS += --no-debugger
$(PKG)_CONFIGURE_OPTIONS += --no-system-libs
$(PKG)_CONFIGURE_OPTIONS += --
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_USE_OPENSSL=ON
$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_ROOT_DIR="$(OPENSSL_HOST_INSTALLDIR)"
$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_INCLUDE_DIR="$(OPENSSL_HOST_INSTALLDIR)/include"
$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_CRYPTO_LIBRARY="$(OPENSSL_HOST_INSTALLDIR)/lib/libcrypto.so.$(OPENSSL_HOST_LIB_VERSION)"
$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_SSL_LIBRARY="$(OPENSSL_HOST_INSTALLDIR)/lib/libssl.so.$(OPENSSL_HOST_LIB_VERSION)"


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(CMAKE_HOST_DIR) all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(CMAKE_HOST_DIR) install
	@$(RM) -r "$(CMAKE_HOST_DOC_TARGET_DIR)"
	-@rmdir "$(dir $(CMAKE_HOST_DOC_TARGET_DIR))"
	$(call CMAKE_HOST_FIXHARDCODED)
	@touch $@

define $(PKG)_FIXHARDCODED
	@for binfile in $(CMAKE_HOST_BINARIES); do \
	for libfile in libcrypto libssl; do \
	$(PATCHELF_HOST) --replace-needed $(1)$${libfile}.so.$(OPENSSL_HOST_LIB_VERSION) $(OPENSSL_HOST_DESTDIR)/$${libfile}.so.$(OPENSSL_HOST_LIB_VERSION) $(CMAKE_HOST_DESTDIR)/bin/$${binfile} ;\
	done ;\
	done ;
endef

$(pkg)-fixhardcoded:
	$(call CMAKE_HOST_FIXHARDCODED,$(TOOLS_HARDCODED_DIR)/freetz/)

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(CMAKE_HOST_DIR) clean
	$(RM) $(CMAKE_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(CMAKE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(CMAKE_HOST_BINARIES_TARGET_DIR) \
		$($(PKG)_DESTDIR)/share/aclocal/cmake.m4 \
		$($(PKG)_DESTDIR)/share/$(pkg_short)-$($(PKG)_MAJOR_VERSION)/ \
		$(CMAKE_HOST_DOC_TARGET_DIR)/

$(TOOLS_FINISH)
