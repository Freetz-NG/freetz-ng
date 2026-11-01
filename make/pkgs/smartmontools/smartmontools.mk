$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_SMARTMONTOOLS_VERSION_ABANDON),7.2,7.5))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=5cd98a27e6393168bc6aaea070d9e1cd551b0f898c52f66b2ff2e5d274118cd6
$(PKG)_HASH_CURRENT:=690b83ca331378da9ea0d9d61008c4b22dde391387b9bbad7f29387f2595f76e
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_SMARTMONTOOLS_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@SF/smartmontools
### WEBSITE:=https://www.smartmontools.org/
### MANPAGE:=https://www.smartmontools.org/wiki/TocDoc
### CHANGES:=https://github.com/smartmontools/smartmontools/releases
### CVSREPO:=https://www.smartmontools.org/timeline
### STEWARD:=fda77

$(PKG)_BINARIES := smartctl
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_BINARIES))

$(PKG)_DEPENDS_ON += libstdcxx
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SMARTMONTOOLS_VERSION_ABANDON),abandon,current)
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SMARTMONTOOLS_VERSION_ABANDON),abandon,current)/$(if $(FREETZ_SYSTEM_TYPE_PUMA6),puma,mips)

$(PKG)_CONFIGURE_ENV += CXX="$(TARGET_CXX_GNU)"

$(PKG)_CONFIGURE_OPTIONS += --without-gnupg
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-libcap-ng
$(PKG)_CONFIGURE_OPTIONS += --without-libsystemd
$(PKG)_CONFIGURE_OPTIONS += --without-nvme-devicescan
ifeq ($(strip $(FREETZ_PACKAGE_SMARTMONTOOLS_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += --without-cxx11-option
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SMARTMONTOOLS_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SMARTMONTOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SMARTMONTOOLS_BINARIES_TARGET_DIR)

$(PKG_FINISH)

