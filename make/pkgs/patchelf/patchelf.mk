$(call PKG_INIT_BIN, 0.19.2)
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=d4ad9a4e5c689e09119ce2f30a94b0e8b4f98c78590123ea21665e34c6928801
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://github.com/NixOS/patchelf
### MANPAGE:=https://github.com/NixOS/patchelf/blob/master/README.md
### CHANGES:=https://github.com/NixOS/patchelf/releases
### CVSREPO:=https://github.com/NixOS/patchelf
### STEWARD:=fda77

$(PKG)_CATEGORY_PKGS:=Debug helpers

$(PKG)_DEPENDS_ON += $(STDCXXLIB)

$(PKG)_BINARY_BUILD := $($(PKG)_DIR)/src/patchelf
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/patchelf

$(PKG)_CONFIGURE_ENV += CXXFLAGS="$(TARGET_CFLAGS) -fPIC"


ifneq ($($(PKG)_SOURCE),$(PATCHELF_HOST_SOURCE))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PATCHELF_DIR)

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_BUILD)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PATCHELF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PATCHELF_BINARY_TARGET)

$(PKG_FINISH)
