$(call PKG_INIT_BIN, 4.4.1)
$(PKG)_SOURCE:=make-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3
$(PKG)_SITE:=@GNU/make

$(PKG)_BINARY:=$($(PKG)_DIR)/make
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/make

$(PKG)_CONFIGURE_ENV += ac_cv_lib_elf_elf_begin=no

$(PKG)_CONFIGURE_ENV += make_cv_sys_gnu_glob=no
$(PKG)_CONFIGURE_ENV += GLOBINC='-Iglob/'
$(PKG)_CONFIGURE_ENV += GLOBLIB=glob/libglob.a

# Only define download rules if make-host is not being built
ifndef MAKE_HOST_VERSION
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNU_MAKE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GNU_MAKE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GNU_MAKE_TARGET_BINARY)

$(PKG_FINISH)
