$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_WGET_VERSION_ABANDON),1.21.2,1.25.0))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.lz
$(PKG)_HASH_ABANDON:=1727a330a86acacb3e57615ce268f5f29978bf7adec4abe6a30d370207bc91b3
$(PKG)_HASH_CURRENT:=19225cc756b0a088fc81148dc6a40a0c8f329af7fd8483f1c7b2fe50f4e08a1f
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_WGET_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/wget/
### MANPAGE:=https://www.gnu.org/software/wget/manual/
### CHANGES:=https://git.savannah.gnu.org/cgit/wget.git/tree/NEWS
### CVSREPO:=https://git.savannah.gnu.org/cgit/wget.git/
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget-gnu

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_WGET_VERSION_ABANDON),abandon,current)

# Rename base64_encode/decode to avoid name clash with the same named functions from GnuTLS
$(PKG)_PATCH_POST_CMDS += find $(abspath $($(PKG)_DIR)) \( -name *.h -o -name *.c \) -type f \
	-exec $(SED) -i -r -e 's,(base64_(en|de)code),wget_\1,g' \{\} \+;

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS|LIBS)

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_CFLAGS  += $(if $(FREETZ_PACKAGE_WGET_CA_BUNDLE),-DWGET_DEFAULT_CA_BUNDLE='\"/etc/ssl/certs/ca-bundle.crt\"')
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_TARGET_ARCH_ARM)),y)
ifeq ($(strip $(FREETZ_TARGET_ARCH_BE)),y)
$(PKG)_CONFIGURE_ENV += gl_cv_header_working_byteswap_h=yes
endif
endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)

ifeq ($(strip $(FREETZ_PACKAGE_WGET_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
$(PKG)_CONFIGURE_OPTIONS += --with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libgnutls-prefix
ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_STATIC_LIBS := $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
endif
endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_GNUTLS)),y)
$(PKG)_DEPENDS_ON += gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-libgnutls-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libssl-prefix
ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_STATIC_LIBS := -ltasn1 -lz -lhogweed -lnettle -lgmp
endif
endif

endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-iri
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libpsl
$(PKG)_CONFIGURE_OPTIONS += --without-libuuid
$(PKG)_CONFIGURE_OPTIONS += --without-zlib # is only required for compressing warc files
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_WGET_WITH_SSL),,--without-ssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_BUSYBOX_WGET
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_CA_BUNDLE
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_GNUTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WGET_DIR) \
		EXTRA_CFLAGS="$(WGET_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(WGET_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(WGET_STATIC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_DEST_DIR)/usr/bin/wget-gnu

$(PKG_FINISH)
