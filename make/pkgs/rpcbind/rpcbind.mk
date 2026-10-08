$(call PKG_INIT_BIN,1.3.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=8e551b445f5172f8ef218845af342fb2a2d741b57ce8c777c781a01ea92f92a5
$(PKG)_SITE:=@SF/rpcbind
### WEBSITE:=https://sourceforge.net/projects/rpcbind/
### MANPAGE:=https://linux.die.net/man/8/rpcbind
### CHANGES:=http://git.linux-nfs.org/?p=steved/rpcbind.git;a=shortlog;h=refs/heads/master
### CVSREPO:=http://git.linux-nfs.org/?p=steved/rpcbind.git
### STEWARD:=fda77

$(PKG)_BINARY_USRSBIN:=rpcbind
$(PKG)_BINARY_BIN:=rpcinfo
$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_BINARY_USRSBIN:%=$($(PKG)_DIR)/%) $($(PKG)_BINARY_BIN:%=$($(PKG)_DIR)/%)
$(PKG)_BINARY_TARGET_DIR_USRSBIN:=$($(PKG)_BINARY_USRSBIN:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
$(PKG)_BINARY_TARGET_DIR_BIN:=$($(PKG)_BINARY_BIN:%=$($(PKG)_DEST_DIR)/bin/%)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_RPCBIND_RPCINFO),,/bin/rpcinfo)

$(PKG)_DEPENDS_ON += tcp_wrappers
$(PKG)_DEPENDS_ON += libtirpc

$(PKG)_CONFIGURE_OPTIONS += --enable-rmtcalls
$(PKG)_CONFIGURE_OPTIONS += --enable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --enable-warmstarts
$(PKG)_CONFIGURE_OPTIONS += --without-systemdsystemunitdir
$(PKG)_CONFIGURE_OPTIONS += --with-rpcuser=nobody

$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RPCBIND_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(RPCBIND_CFLAGS)"

$($(PKG)_BINARY_TARGET_DIR_USRSBIN): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_BINARY_TARGET_DIR_BIN): $($(PKG)_DEST_DIR)/bin/%: $($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR_USRSBIN) $($(PKG)_BINARY_TARGET_DIR_BIN)


$(pkg)-clean:
	-$(SUBMAKE) -C $(RPCBIND_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RPCBIND_BINARY_TARGET_DIR_USRSBIN) $(RPCBIND_BINARY_TARGET_DIR_BIN)

$(PKG_FINISH)
