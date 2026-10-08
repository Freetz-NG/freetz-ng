$(call PKG_INIT_BIN,1.5)
$(PKG)_SOURCE:=bridge-utils-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=42f9e5fb8f6c52e63a98a43b81bd281c227c529f194913e1c51ec48a393b6688
$(PKG)_SITE:=@SF/bridge
$(PKG)_BINARY:=$($(PKG)_DIR)/brctl/brctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/brctl

$(PKG)_CONFIGURE_PRE_CMDS += ln -sf configure.in configure.ac;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf > /dev/null 2>&1;

# TODO: check if this package really requires internal kernel headers
#       I doubt this is the case as the following path is relative,
#       i.e. doesn't really point to the kernel headers dir while
#       package is being built
#$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION
$(PKG)_CONFIGURE_OPTIONS += --with-linux-headers=$(KERNEL_SOURCE_DIR)/include

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BRIDGE_UTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BRIDGE_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BRIDGE_UTILS_TARGET_BINARY)

$(PKG_FINISH)
