$(call TOOLS_INIT, 1.37.1.1)
$(PKG)_SOURCE:=fakeroot_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_HASH:=86b0b75bf319ca42e525c098675b6ed10a06b76e69ec9ccf20ef5e03883b3a14
$(PKG)_SITE:=https://ftp.debian.org/debian/pool/main/f/fakeroot
### WEBSITE:=https://wiki.debian.org/FakeRoot
### MANPAGE:=https://man.archlinux.org/man/fakeroot.1.en
### TRACKER:=https://bugs.debian.org/cgi-bin/pkgreport.cgi?pkg=fakeroot;dist=unstable
### CHANGES:=https://launchpad.net/debian/+source/fakeroot/+changelog
### CVSREPO:=https://github.com/openwrt/openwrt/tree/master/tools/fakeroot/patches
### SUPPORT:=fda77

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_MAINARCH_DIR:=$($(PKG)_DIR)/build/arch
$(PKG)_BIARCH_DIR:=$($(PKG)_DIR)/build/biarch

$(PKG)_MAINARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib
$(PKG)_BIARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib32
$(PKG)_TARGET_SCRIPT:=$($(PKG)_DESTDIR)/bin/fakeroot
$(PKG)_TARGET_BIARCH_LIB:=$($(PKG)_BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
#BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))
# replaced by HOST_BIARCH


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_MAINARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	(mkdir -p $(FAKEROOT_HOST_MAINARCH_DIR); cd $(FAKEROOT_HOST_MAINARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		CXXFLAGS="$(TOOLS_CXXFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(DISABLE_NLS) \
		$(QUIET) \
		$(SILENT) \
	);
	touch $@
$($(PKG)_TARGET_SCRIPT): $($(PKG)_MAINARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) install
	$(SED) -i 's,^FAKEROOT_PREFIX=.*,FAKEROOT_PREFIX="$$(readlink -f $$0 | sed "s!/bin/fakeroot\\$$!!")",'  $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^FAKEROOT_BINDIR=.*,FAKEROOT_BINDIR=$${FAKEROOT_PREFIX}/bin,'                              $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^PATHS=.*,PATHS=$${FAKEROOT_PREFIX}/lib:$${FAKEROOT_PREFIX}/lib32,'                        $(FAKEROOT_HOST_TARGET_SCRIPT)

$($(PKG)_BIARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	(mkdir -p $(FAKEROOT_HOST_BIARCH_DIR); cd $(FAKEROOT_HOST_BIARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		CXXFLAGS="$(TOOLS_CXXFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(if $(findstring Microsoft,$(shell uname -r)),--host=$(shell uname -m),) \
		$(DISABLE_NLS) \
		$(QUIET) \
		$(SILENT) \
	);
	touch $@
$($(PKG)_TARGET_BIARCH_LIB): $($(PKG)_BIARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) libdir="$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES
	touch $@

$(pkg)-fixhardcoded:
	-@$(SED) -i "s!$(TOOLS_HARDCODED_DIR)!$(FAKEROOT_HOST_DESTDIR)!g" \
		$(FAKEROOT_HOST_MAINARCH_LD_PRELOAD_PATH)/libfakeroot.la \
		$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)/libfakeroot.la

$(pkg)-precompiled: $($(PKG)_TARGET_SCRIPT) $(if $(HOST_BIARCH),$($(PKG)_TARGET_BIARCH_LIB))


$(pkg)-clean:
	-$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) clean
	-$(RM) $(FAKEROOT_HOST_DIR)/.{compiled,fixhardcoded}
	-$(RM) $(FAKEROOT_HOST_MAINARCH_DIR)/.{configured,compiled}
	-$(RM) $(FAKEROOT_HOST_BIARCH_DIR)/.{configured,compiled}

$(pkg)-dirclean:
	$(RM) -r $(FAKEROOT_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(FAKEROOT_HOST_TARGET_SCRIPT) \
		$(FAKEROOT_HOST_DESTDIR)/bin/faked \
		$(FAKEROOT_HOST_DESTDIR)/lib*/libfakeroot*

$(TOOLS_FINISH)
