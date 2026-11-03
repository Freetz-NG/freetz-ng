$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_RSYNC_VERSION_ABANDON),3.4.1,3.5.2))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52
$(PKG)_HASH_CURRENT:=a10d591825251e070f74c98df3daad195def4ed81b4a2de16169026aea33f6c8
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_RSYNC_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@SAMBA/rsync/src
### WEBSITE:=https://rsync.samba.org/
### MANPAGE:=https://rsync.samba.org/documentation.html
### CHANGES:=https://download.samba.org/pub/rsync/NEWS
### CVSREPO:=https://git.samba.org/?p=rsync.git
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/rsync
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rsync

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_RSYNC_REMOVE_WEBIF),usr/lib/cgi-bin/rsync.cgi etc/default.rsync etc/init.d/rc.rsync)

$(PKG)_DEPENDS_ON += popt zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_RSYNC_VERSION_ABANDON),abandon,current)

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-md2man
$(PKG)_CONFIGURE_OPTIONS += --disable-locale
$(PKG)_CONFIGURE_OPTIONS += --disable-openssl
$(PKG)_CONFIGURE_OPTIONS += --disable-xxhash
$(PKG)_CONFIGURE_OPTIONS += --disable-zstd
$(PKG)_CONFIGURE_OPTIONS += --disable-lz4
$(PKG)_CONFIGURE_OPTIONS += --disable-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-acl-support
$(PKG)_CONFIGURE_OPTIONS += --without-included-popt
$(PKG)_CONFIGURE_OPTIONS += --without-included-zlib
$(PKG)_CONFIGURE_OPTIONS += --with-nobody-group=nobody
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)

ifeq ($(strip $(FREETZ_PACKAGE_RSYNC_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-simd
$(PKG)_CONFIGURE_OPTIONS += --disable-asm
else
$(PKG)_CONFIGURE_OPTIONS += --disable-idn
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RSYNC_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(RSYNC_DIR) clean
	$(RM) $(RSYNC_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RSYNC_TARGET_BINARY)

$(PKG_FINISH)
