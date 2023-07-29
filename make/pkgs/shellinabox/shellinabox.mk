$(call PKG_INIT_BIN, 4f0ecc31ac6f985e0dd3f5a52cbfc0e9251f6361)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@https://github.com/shellinabox/shellinabox.git
### WEBSITE:=https://code.google.com/archive/p/shellinabox/
### CHANGES:=https://github.com/shellinabox/shellinabox/releases
### CVSREPO:=https://github.com/shellinabox/shellinabox

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

# prevent zlib support for from being (accidentally) compiled/linked in
$(PKG)_CONFIGURE_ENV += ac_cv_header_zlib_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_z_deflate=no

# disable features not available on non-freetz'ed boxes
ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_NONFREETZ)),y)
$(PKG)_CONFIGURE_ENV += ac_cv_header_libutil_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_utmp_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_utmpx_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_login_tty=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_util_login_tty=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_openpty=no
endif

$(PKG)_CONFIGURE_PRE_CMDS += chmod +x compile config.guess config.sub configure depcomp install-sh missing;
$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# touch configure.ac to prevent aclocal.m4 & configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac ./Makefile.am;

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_BOXCERT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_NONFREETZ
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SHELLINABOX_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_EXTRA_LIBS += $(if $(FREETZ_PACKAGE_SHELLINABOX_STATIC),$(OPENSSL_LIBCRYPTO_EXTRA_LIBS))
$(PKG)_CONFIGURE_OPTIONS += --enable-ssl
# will not work with SSL disabled, I suspect a bug in source??
$(PKG)_CONFIGURE_OPTIONS += --disable-runtime-loading
else
$(PKG)_CONFIGURE_OPTIONS += --disable-ssl
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-pam

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TARGET_IPV6_SUPPORT),ipv6)
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SHELLINABOX_STATIC),static)

ifeq ($(strip $(FREETZ_PACKAGE_SHELLINABOX_BOXCERT)),y)
$(PKG)_CONDITIONAL_PATCHES += boxcert
$(PKG)_DEPENDS_ON          += privatekeypassword
$(PKG)_EXTRA_LIBS          += -lprivatekeypassword
endif

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections
$(PKG)_EXTRA_LIBS    += -ldl -lm

$(PKG)_CONFIGURE_ENV += LIBS="$(SHELLINABOX_EXTRA_LIBS)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SHELLINABOX_DIR) \
		EXTRA_CFLAGS="$(SHELLINABOX_EXTRA_CFLAGS)" \
		shellinaboxd_EXTRA_LDFLAGS="$(SHELLINABOX_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SHELLINABOX_DIR) clean
	$(RM) $(SHELLINABOX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SHELLINABOX_TARGET_BINARY)

$(PKG_FINISH)
