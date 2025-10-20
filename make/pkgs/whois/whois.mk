$(call PKG_INIT_BIN, 5.6.5)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3ec4168da3ff61e5e426964428202bc0573ad6ecc1f3baf6f43daea6c748aa7d
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/w/whois
### WEBSITE:=https://www.linux.it/~md/software/
### MANPAGE:=https://manpages.debian.org/whois/whois.1.en.html
### CHANGES:=https://github.com/rfc1036/whois/tags
### CVSREPO:=https://github.com/rfc1036/whois
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/whois
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/whois

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_WHOIS_WHIS_LIBIDN),libidn)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WHOIS_WHIS_LIBIDN

ifeq ($(strip $(FREETZ_PACKAGE_WHOIS_WHIS_LIBIDN)),y)
$(PKG)_ADDITIONAL_VARS += WITH_LIBIDN=y
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WHOIS_DIR) all \
		$(WHOIS_ADDITIONAL_VARS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDCFLAGS="$(TARGET_LDFLAGS)" \
		PERL="$(PERL)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(WHOIS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WHOIS_TARGET_BINARY)

$(PKG_FINISH)
