$(call PKG_INIT_BIN, 5.75)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0c1ef0ed85240974dccb94fe74fb92d6383474c7c0d10e8796d1f781a3ba5683
$(PKG)_SITE:=https://www.stunnel.org/downloads/archive/5.x
### WEBSITE:=https://www.stunnel.org/
### MANPAGE:=https://www.stunnel.org/static/stunnel.html
### CHANGES:=https://www.stunnel.org/NEWS.html
### CVSREPO:=https://github.com/mtrojnar/stunnel
### SUPPORT:=fda77

$(PKG)_STARTLEVEL=81

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_DEPENDS_ON += openssl

ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_BOXCERT)),y)
$(PKG)_CONDITIONAL_PATCHES+=boxcert
$(PKG)_DEPENDS_ON += privatekeypassword
$(PKG)_EXTRA_LDFLAGS += -lprivatekeypassword
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_BOXCERT
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS|LIBS)

# reduce binary size by setting appropriate CFLAGS/LDFLAGS
$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -all-static
$(PKG)_STATIC_LIBS += $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
endif

$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptmx=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_ptc=no
$(PKG)_CONFIGURE_ENV += ac_cv_file__dev_urandom=yes

$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --disable-systemd
$(PKG)_CONFIGURE_OPTIONS += --with-threads=pthread
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STUNNEL_DIR) \
		EXTRA_CFLAGS="$(STUNNEL_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(STUNNEL_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(STUNNEL_STATIC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(STUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STUNNEL_TARGET_BINARY)

$(PKG_FINISH)
