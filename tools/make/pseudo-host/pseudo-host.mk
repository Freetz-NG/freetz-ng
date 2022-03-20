PSEUDO_HOST_VERSION:=0cda3ba5f94aed8d50652a99ee9c502975aa2926
# Newer versions build with Ubuntu 14 and 18 cause problems on other systems with tar-host: https://github.com/Freetz-NG/freetz-ng/issues/468
PSEUDO_HOST_SOURCE:=pseudo-$(PSEUDO_HOST_VERSION).tar.xz
PSEUDO_HOST_SOURCE_SHA256:=405652c57ed80f9230c7be213350c0bf51aeb8a4d629778b338160dd25cbf642
PSEUDO_HOST_SITE:=git@https://git.yoctoproject.org/git/pseudo
#PSEUDO_HOST_SITE:=http://downloads.yoctoproject.org/releases/pseudo/
### WEBSITE:=https://www.yoctoproject.org/software-item/pseudo/
### MANPAGE:=https://manpages.debian.org/testing/pseudo/pseudo.1.en.html
### CHANGES:=http://git.yoctoproject.org/cgit.cgi/pseudo/log/?h=oe-core
### CVSREPO:=http://git.yoctoproject.org/cgit.cgi/pseudo/

PSEUDO_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/pseudo-host
PSEUDO_HOST_DIR:=$(TOOLS_SOURCE_DIR)/pseudo-$(PSEUDO_HOST_VERSION)
PSEUDO_HOST_MAINARCH_DIR:=$(PSEUDO_HOST_DIR)/arch
PSEUDO_HOST_BIARCH_DIR:=$(PSEUDO_HOST_DIR)/biarch

PSEUDO_HOST_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
PSEUDO_HOST_MAINARCH_LD_PRELOAD_PATH:=$(PSEUDO_HOST_DESTDIR)/lib
PSEUDO_HOST_BIARCH_LD_PRELOAD_PATH:=$(PSEUDO_HOST_DESTDIR)/lib64
PSEUDO_HOST_TARGET_MAINARCH_LIB:=$(PSEUDO_HOST_MAINARCH_LD_PRELOAD_PATH)/libpseudo.so
PSEUDO_HOST_TARGET_BIARCH_LIB:=$(PSEUDO_HOST_BIARCH_LD_PRELOAD_PATH)/libpseudo.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit pseudo support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))


pseudo-host-source: $(DL_DIR)/$(PSEUDO_HOST_SOURCE)
$(DL_DIR)/$(PSEUDO_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PSEUDO_HOST_SOURCE) $(PSEUDO_HOST_SITE) $(PSEUDO_HOST_SOURCE_SHA256)

pseudo-host-unpacked: $(PSEUDO_HOST_DIR)/.unpacked
$(PSEUDO_HOST_DIR)/.unpacked: $(DL_DIR)/$(PSEUDO_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(PSEUDO_HOST_MAINARCH_DIR) $(PSEUDO_HOST_BIARCH_DIR)
	mkdir -p $(PSEUDO_HOST_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(PSEUDO_HOST_SOURCE),$(PSEUDO_HOST_DIR))
	mv $(PSEUDO_HOST_DIR)/pseudo-* $(PSEUDO_HOST_MAINARCH_DIR)
	$(call APPLY_PATCHES,$(PSEUDO_HOST_MAKE_DIR)/patches,$(PSEUDO_HOST_MAINARCH_DIR))
	cp -a $(PSEUDO_HOST_MAINARCH_DIR) $(PSEUDO_HOST_BIARCH_DIR)
	touch $@

$(PSEUDO_HOST_MAINARCH_DIR)/.configured: $(PSEUDO_HOST_DIR)/.unpacked
	(cd $(PSEUDO_HOST_MAINARCH_DIR); $(RM) Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		$(if $(BIARCH_BUILD_SYSTEM),--bits=32) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon $(if $(BIARCH_BUILD_SYSTEM),$(HOST_CFLAGS_FORCE_32BIT_CODE))" \
		--libdir=$(PSEUDO_HOST_MAINARCH_LD_PRELOAD_PATH) \
	);
	touch $@
$(PSEUDO_HOST_TARGET_MAINARCH_LIB): $(PSEUDO_HOST_MAINARCH_DIR)/.configured
	$(MAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) install-lib $(if $(BIARCH_BUILD_SYSTEM),,install-bin)
	touch $@

$(PSEUDO_HOST_BIARCH_DIR)/.configured: $(PSEUDO_HOST_DIR)/.unpacked
	(cd $(PSEUDO_HOST_BIARCH_DIR); $(RM) Makefile; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		./configure \
		--prefix=$(PSEUDO_HOST_DESTDIR) \
		--enable-xattr=no \
		--bits=$(HOST_BITNESS) \
		--cflags="-Wno-cast-function-type -Wno-nonnull-compare -fcommon" \
		--libdir=$(PSEUDO_HOST_BIARCH_LD_PRELOAD_PATH) \
	);
	touch $@
$(PSEUDO_HOST_TARGET_BIARCH_LIB): $(PSEUDO_HOST_BIARCH_DIR)/.configured
	$(MAKE) -C $(PSEUDO_HOST_BIARCH_DIR) install-lib install-bin
	touch $@

pseudo-host-precompiled: $(PSEUDO_HOST_TARGET_MAINARCH_LIB) $(if $(BIARCH_BUILD_SYSTEM),$(PSEUDO_HOST_TARGET_BIARCH_LIB))


pseudo-host-clean:
	-$(MAKE) -C $(PSEUDO_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(PSEUDO_HOST_BIARCH_DIR) clean

pseudo-host-dirclean:
	$(RM) -r $(PSEUDO_HOST_DIR)

pseudo-host-distclean: pseudo-host-dirclean
	$(RM) -r $(PSEUDO_HOST_DESTDIR)/bin/pseudo* $(PSEUDO_HOST_TARGET_MAINARCH_LIB) $(PSEUDO_HOST_TARGET_BIARCH_LIB)

