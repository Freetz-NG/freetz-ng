$(call PKG_INIT_LIB, $(if $(FREETZ_MBEDTLS_VERSION_207),2.7.19,$(if $(FREETZ_MBEDTLS_VERSION_228),2.28.10,3.6.4)))
$(PKG)_SOURCE_2.7  :=mbedtls-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_2.28 :=mbedtls-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_3.6  :=mbedtls-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE:=$($(PKG)_SOURCE_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)))
$(PKG)_HASH_2.7  :=3da12b1cebe1a25da8365d5349f67db514aefcaa75e26082d7cb2fa3ce9608aa
$(PKG)_HASH_2.28 :=c785ddf2ad66976ab429c36dffd4a021491e40f04fe493cfc39d6ed9153bc246
$(PKG)_HASH_3.6  :=ed0d2b8c01ae5c02d95322acf2e4bda65c859c0d28e866862bc30aa0bdba3dc9
$(PKG)_HASH:=$($(PKG)_HASH_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)))
$(PKG)_SITE:=https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-$($(PKG)_VERSION),https://github.com/ARMmbed/mbedtls/archive,https://tls.mbed.org/download
### VERSION:=2.7.19/2.28.10/3.6.4
### WEBSITE:=https://www.trustedfirmware.org/projects/mbed-tls/
### MANPAGE:=https://mbed-tls.readthedocs.io/en/latest/
### CHANGES:=https://github.com/Mbed-TLS/mbedtls/releases
### CVSREPO:=https://github.com/Mbed-TLS/mbedtls
### SUPPORT:=fda77

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_LIBNAMES_SHORT      := crypto tls x509

$(PKG)_LIBNAMES_SO         := $($(PKG)_LIBNAMES_SHORT:%=libmbed%.so.$($(PKG)_VERSION))
$(PKG)_LIBS_SO_BUILD_DIR   := $($(PKG)_LIBNAMES_SO:%=$($(PKG)_DIR)/library/%)
$(PKG)_LIBS_SO_STAGING_DIR := $($(PKG)_LIBNAMES_SO:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_SO_TARGET_DIR  := $($(PKG)_LIBNAMES_SO:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_LIBNAMES_A          := $($(PKG)_LIBNAMES_SHORT:%=libmbed%.a)
$(PKG)_LIBS_A_BUILD_DIR    := $($(PKG)_LIBNAMES_A:%=$($(PKG)_DIR)/library/%)
$(PKG)_LIBS_A_STAGING_DIR  := $($(PKG)_LIBNAMES_A:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libmbedcrypto_WITH_GENRSA

# disable some features to reduce library size
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_SELF_TEST
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_CAMELLIA_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_CERTS_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_DEBUG_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_PADLOCK_C
$(PKG)_FEATURES_TO_DISABLE += MBEDTLS_XTEA_C
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libmbedcrypto_WITH_BLOWFISH),,MBEDTLS_BLOWFISH_C)
$(PKG)_FEATURES_TO_DISABLE += $(if $(FREETZ_LIB_libmbedcrypto_WITH_GENRSA),,MBEDTLS_GENPRIME)

$(PKG)_CONFIGH_2.7  :=config.h
$(PKG)_CONFIGH_2.28 :=config.h
$(PKG)_CONFIGH_3.6  :=mbedtls_config.h
$(PKG)_CONFIGH:=include/mbedtls/$($(PKG)_CONFIGH_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)))

# Don't use -D/-U to define/undefine required symbols, patch config.h instead. The installed headers must contain properly defined symbols.
$(PKG)_PATCH_POST_CMDS += $(SED) -ri $(foreach f,$(MBEDTLS_FEATURES_TO_DISABLE),-e 's|^([ \t]*$(_hash)define[ \t]+$(f)[ \t]*)$$$$|/* \1 */|') $($(PKG)_CONFIGH)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_LIBS_SO_BUILD_DIR) $($(PKG)_LIBS_A_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MBEDTLS_DIR)/library \
		VERSION="$(MBEDTLS_VERSION)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -ffunction-sections -fdata-sections" \
		AR="$(TARGET_AR)" \
		SHARED=1 \
		shared static

$($(PKG)_LIBS_SO_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/library/%
	$(INSTALL_LIBRARY)

$($(PKG)_LIBS_A_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/library/%
	$(INSTALL_FILE)

$($(PKG)_DIR)/.headers: $($(PKG)_DIR)/.configured
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/
	cp -a $(MBEDTLS_DIR)/include/mbedtls/* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/
	@touch $@

$($(PKG)_LIBS_SO_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_SO_STAGING_DIR) $($(PKG)_LIBS_A_STAGING_DIR) $($(PKG)_DIR)/.headers

$(pkg)-precompiled: $($(PKG)_LIBS_SO_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MBEDTLS_DIR)/library clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmbed* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/mbedtls/

$(pkg)-uninstall:
	$(RM) $(MBEDTLS_TARGET_DIR)/libmbed*.so*

$(PKG_FINISH)
