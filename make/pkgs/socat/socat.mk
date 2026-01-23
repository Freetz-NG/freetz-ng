$(call PKG_INIT_BIN, 1.8.1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=91f222ee65559036600c2505b999acebed48b899f0e2e53ae1c9c31d6986b6a4
$(PKG)_SITE:=http://www.dest-unreach.org/socat/download
### WEBSITE:=http://www.dest-unreach.org/socat/
### MANPAGE:=http://www.dest-unreach.org/socat/doc/socat.html
### CHANGES:=https://repo.or.cz/socat.git/blob_plain/refs/heads/master:/CHANGES
### CVSREPO:=https://repo.or.cz/socat.git
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/socat
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/socat

$(PKG)_DEPENDS_ON += openssl

$(PKG)_CONFIGURE_ENV += ac_cv_func_SSLv2_client_method=no ac_cv_lib_crypt_SSLv2_client_method=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_SSLv2_server_method=no ac_cv_lib_crypt_SSLv2_server_method=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_SSLv3_client_method=no ac_cv_lib_crypt_SSLv3_client_method=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_SSLv3_server_method=no ac_cv_lib_crypt_SSLv3_server_method=no

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SOCAT_WITHTERMIOS),--enable-termios,--disable-termios)
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-ssl
$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --disable-readline
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_SEPARATE_AVM_UCLIBC),,--disable-vsock)

$(PKG)_CONFIGURE_OPTIONS += sc_cv_sys_crdly_shift=9
$(PKG)_CONFIGURE_OPTIONS += sc_cv_sys_tabdly_shift=11
$(PKG)_CONFIGURE_OPTIONS += sc_cv_sys_csize_shift=4
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_ARCH_X86),sc_cv_termios_ispeed=no)

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SOCAT_WITHTERMIOS

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SOCAT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SOCAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SOCAT_TARGET_BINARY)

$(PKG_FINISH)
