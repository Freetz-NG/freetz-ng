$(call PKG_INIT_BIN, 4.99.7)
$(PKG)_SOURCE:=lsof-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4a10391aab0b8ce1f539e82a1966693b2a6cf225972a6504ebb7ec4fa71675de
$(PKG)_SITE:=https://github.com/lsof-org/lsof/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://people.freebsd.org/~abe/
### MANPAGE:=https://lsof.readthedocs.io/
### CHANGES:=https://github.com/lsof-org/lsof/releases
### CVSREPO:=https://github.com/lsof-org/lsof

$(PKG)_BINARY:=$($(PKG)_DIR)/lsof
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lsof
$(PKG)_CATEGORY_PKGS:=Debug helpers

$(PKG)_DEPENDS_ON += wget-host

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_HASIPV6 := Y
endif

$(PKG)_PATCH_PRE_CMDS += chmod -R u+w .;
$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_OPTIONS += --host=$(REAL_GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-liblsof --without-libtirpc


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LSOF_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LSOF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LSOF_TARGET_BINARY)

$(PKG_FINISH)
