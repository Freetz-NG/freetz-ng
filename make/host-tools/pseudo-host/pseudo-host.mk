$(call TOOLS_INIT, 414ce2da8e0ad1f3ba5d841f4db094987f33eafd)
$(PKG)_SOURCE:=pseudo-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2e2196002ba14cc8a8fc73c8de7af7881ea25bcb74227af78dcc39265fe6d1e0
$(PKG)_SITE:=https://git.yoctoproject.org/pseudo/snapshot,https://downloads.yoctoproject.org/releases/pseudo
#$(PKG)_SITE:=git@https://git.yoctoproject.org/git/pseudo
### VERSION:=1.9.3 master 414ce2d
### WEBSITE:=https://www.yoctoproject.org/software-item/pseudo/
### MANPAGE:=https://manpages.debian.org/testing/pseudo/pseudo.1.en.html
### CHANGES:=https://git.yoctoproject.org/pseudo/log/?h=master
### CVSREPO:=https://git.yoctoproject.org/pseudo/
### STEWARD:=fda77

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build

$(PKG)_MAINARCH_NAME:=arch
$(PKG)_BIARCH_NAME:=biarch

$(PKG)_MAINARCH_DIR:=$($(PKG)_DIR)/$($(PKG)_MAINARCH_NAME)
$(PKG)_BIARCH_DIR:=$($(PKG)_DIR)/$($(PKG)_BIARCH_NAME)

$(PKG)_MAINARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib
$(PKG)_BIARCH_LD_PRELOAD_PATH:=$($(PKG)_DESTDIR)/lib64
$(PKG)_TARGET_MAINARCH_LIB:=$($(PKG)_MAINARCH_LD_PRELOAD_PATH)/libpseudo.so
$(PKG)_TARGET_BIARCH_LIB:=$($(PKG)_BIARCH_LD_PRELOAD_PATH)/libpseudo.so

$(PKG)_TARBALL_STRIP_COMPONENTS:=0
$(PKG)_PATCH_POST_CMDS := mv $(pkg_short)-* $($(PKG)_MAINARCH_NAME);
$(PKG)_PATCH_POST_CMDS += cp -a $($(PKG)_MAINARCH_NAME) $($(PKG)_BIARCH_NAME);

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit pseudo support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
#BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))
# replaced by HOST_BIARCH


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_MAINARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	(cd $(PSEUDO_HOST_MAINARCH_DIR); $(RM) config.cache Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		CXXFLAGS="$(TOOLS_CXXFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		$(if $(HOST_BIARCH),--bits=32) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon $(if $(HOST_BIARCH),$(HOST_CFLAGS_FORCE_32BIT_CODE))" \
		--libdir=$(PSEUDO_HOST_MAINARCH_LD_PRELOAD_PATH) \
		$(DISABLE_NLS) \
		$(QUIET) \
		$(SILENT) \
	);
	touch $@
$($(PKG)_TARGET_MAINARCH_LIB): $($(PKG)_MAINARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) install-lib $(if $(HOST_BIARCH),,install-bin)
	touch $@

$($(PKG)_BIARCH_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@$(call _ECHO,configuring)
	(cd $(PSEUDO_HOST_BIARCH_DIR); $(RM) config.cache Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		CXXFLAGS="$(TOOLS_CXXFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		--bits=$(HOST_BITNESS) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon" \
		--libdir=$(PSEUDO_HOST_BIARCH_LD_PRELOAD_PATH) \
		$(DISABLE_NLS) \
		$(QUIET) \
		$(SILENT) \
	);
	touch $@
$($(PKG)_TARGET_BIARCH_LIB): $($(PKG)_BIARCH_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PSEUDO_HOST_BIARCH_DIR) install-lib install-bin
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_MAINARCH_LIB) $(if $(HOST_BIARCH),$($(PKG)_TARGET_BIARCH_LIB))


$(pkg)-clean:
	-$(MAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(PSEUDO_HOST_BIARCH_DIR) clean
	-$(RM) $(PSEUDO_HOST_DIR)/.{compiled}
	-$(RM) $(PSEUDO_HOST_MAINARCH_DIR)/.{configured,compiled}
	-$(RM) $(PSEUDO_HOST_BIARCH_DIR)/.{configured,compiled}

$(pkg)-dirclean:
	$(RM) -r $(PSEUDO_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PSEUDO_HOST_DESTDIR)/bin/pseudo* $(PSEUDO_HOST_TARGET_MAINARCH_LIB) $(PSEUDO_HOST_TARGET_BIARCH_LIB)

$(TOOLS_FINISH)
