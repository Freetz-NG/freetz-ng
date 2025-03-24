$(call PKG_INIT_BIN, 0.4.8.15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=5d5d99e21992c4c71af1afcef16c70f4c5e7ee021633ac138b2a2761be75064b
$(PKG)_SITE:=https://www.torproject.org/dist
### WEBSITE:=https://www.torproject.org/download/tor/
### MANPAGE:=https://trac.torproject.org/projects/tor/wiki/
### CHANGES:=https://gitlab.torproject.org/tpo/core/tor/tags
### CVSREPO:=https://gitweb.torproject.org/tor.git/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/app/tor
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tor

$(PKG)_ALL_GEOIPDB := geoip geoip6
$(PKG)_TARGET_GEOIP := $(addprefix $($(PKG)_DEST_DIR)/usr/share/tor/,$($(PKG)_ALL_GEOIPDB))

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_TOR_GEOIP_V4),,$(if $(FREETZ_PACKAGE_TOR_GEOIP_V6),/usr/share/tor/geoip))
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_TOR_GEOIP_V6),,$(if $(FREETZ_PACKAGE_TOR_GEOIP_V4),/usr/share/tor/geoip6))
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_TOR_GEOIP_V4),,$(if $(FREETZ_PACKAGE_TOR_GEOIP_V6),,/usr/share/))

$(PKG)_DEPENDS_ON += libevent openssl zlib

$(PKG)_CONFIGURE_ENV += tor_cv_malloc_zero_works=no
$(PKG)_CONFIGURE_ENV += tor_cv_null_is_zero=yes
$(PKG)_CONFIGURE_ENV += tor_cv_sign_extend=yes
$(PKG)_CONFIGURE_ENV += tor_cv_size_t_signed=no
$(PKG)_CONFIGURE_ENV += tor_cv_time_t_signed=yes
$(PKG)_CONFIGURE_ENV += tor_cv_twos_complement=yes
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fasynchronous_unwind_tables=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fstack_protector_all=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__Wstack_protector=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags___param_ssp_buffer_size_1=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fPIE=no
$(PKG)_CONFIGURE_ENV += tor_cv_ldflags__pie=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_cap_cap_init=no

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --disable-asciidoc
$(PKG)_CONFIGURE_OPTIONS += --disable-manpage
$(PKG)_CONFIGURE_OPTIONS += --disable-html-manual
$(PKG)_CONFIGURE_OPTIONS += --disable-tool-name-check
$(PKG)_CONFIGURE_OPTIONS += --disable-unittests
$(PKG)_CONFIGURE_OPTIONS += --with-openssl-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-libevent-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-zlib-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --disable-nss
$(PKG)_CONFIGURE_OPTIONS += --disable-seccomp
$(PKG)_CONFIGURE_OPTIONS += --disable-systemd
$(PKG)_CONFIGURE_OPTIONS += --disable-lzma
$(PKG)_CONFIGURE_OPTIONS += --disable-zstd
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_TOR_RELAY),,--disable-module-relay)

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TOR_STATIC

# touch some patched files to prevent auto*-tools from being executed
$(PKG)_PATCH_POST_CMDS += touch -t 200001010000.00 ./configure.ac;

# add EXTRA_(C|LD)FLAGS
$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections -DDISABLE_ENGINES
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_TOR_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TOR_DIR) \
		EXTRA_CFLAGS="$(TOR_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(TOR_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_GEOIP): $($(PKG)_DEST_DIR)/usr/share/tor/%: $($(PKG)_DIR)/src/config/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_GEOIP)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TOR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TOR_TARGET_BINARY)
	$(RM) $(TOR_TARGET_GEOIP)

$(PKG_FINISH)
