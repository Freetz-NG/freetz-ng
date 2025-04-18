$(call PKG_INIT_LIB, 1.3.10)
$(PKG)_LIB_VERSION:=1.3.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=be81ef08baa2516ecda76a77adf7def7bc3227eeb578b9a33b45f7b41dc064e6
$(PKG)_SITE:=@APACHE/serf
### WEBSITE:=https://serf.apache.org/
### MANPAGE:=https://serf.apache.org/abi/timeline/serf/index.html
### CHANGES:=https://svn.apache.org/viewvc/serf/trunk/CHANGES?view=markup
### CVSREPO:=https://svn.apache.org/viewvc/serf/

$(PKG)_BINARY:=$($(PKG)_DIR)/libserf-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libserf-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libserf-1.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += apr apr-util openssl zlib
$(PKG)_DEPENDS_ON += scons-host

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION

$(PKG)_SCONS_OPTIONS += CC="PATH=$(TARGET_PATH) $(FREETZ_LD_RUN_PATH) $(TARGET_CC)"
$(PKG)_SCONS_OPTIONS += CFLAGS="$(TARGET_CFLAGS) -fPIC"
$(PKG)_SCONS_OPTIONS += AR="$(TARGET_AR)"
$(PKG)_SCONS_OPTIONS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_SCONS_OPTIONS += PREFIX="/usr"
$(PKG)_SCONS_OPTIONS += APR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_SCONS_OPTIONS += APU="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_SCONS_OPTIONS += OPENSSL="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_SCONS_OPTIONS += ZLIB="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_SCONS_OPTIONS += $(SILENT)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SCONS_HOST_TARGET_BINARY) -C $(SERF_DIR) $(SERF_SCONS_OPTIONS)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) serf-clean-staging
	$(SCONS_HOST_TARGET_BINARY) -C $(SERF_DIR) \
		--install-sandbox="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install $(SILENT)
	$(call PKG_FIX_LIBTOOL_LA,prefix libdir) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/serf-1.pc
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean: $(pkg)-clean-staging
	-$(SCONS_HOST_TARGET_BINARY) -C $(SERF_DIR) -c

$(pkg)-clean-staging:
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libserf-1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/serf-1.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{serf.h,serf_*.h}

$(pkg)-uninstall:
	$(RM) $(SERF_TARGET_DIR)/libserf-1.so*

$(PKG_FINISH)
