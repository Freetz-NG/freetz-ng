FAKEROOT_HOST_VERSION:=1.28
FAKEROOT_HOST_SOURCE:=fakeroot_$(FAKEROOT_HOST_VERSION).orig.tar.gz
FAKEROOT_HOST_SOURCE_SHA256:=56d405e36ff685f83879be08fdd654255ab9aa38632b4605a98e896ad63990c2
FAKEROOT_HOST_SITE:=https://ftp.debian.org/debian/pool/main/f/fakeroot
### WEBSITE:=https://wiki.debian.org/FakeRoot
### MANPAGE:=https://man.archlinux.org/man/fakeroot.1.en
### TRACKER:=https://bugs.debian.org/cgi-bin/pkgreport.cgi?pkg=fakeroot;dist=unstable
### CHANGES:=https://launchpad.net/debian/+source/fakeroot/+changelog
### CVSREPO:=https://github.com/openwrt/openwrt/tree/master/tools/fakeroot/patches

FAKEROOT_HOST_MAKE_DIR:=$(TOOLS_DIR)/make/fakeroot-host
FAKEROOT_HOST_DIR:=$(TOOLS_SOURCE_DIR)/fakeroot-$(FAKEROOT_HOST_VERSION)
FAKEROOT_HOST_MAINARCH_DIR:=$(FAKEROOT_HOST_DIR)/build/arch
FAKEROOT_HOST_BIARCH_DIR:=$(FAKEROOT_HOST_DIR)/build/biarch

FAKEROOT_HOST_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build
FAKEROOT_HOST_MAINARCH_LD_PRELOAD_PATH:=$(FAKEROOT_HOST_DESTDIR)/lib
FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH:=$(FAKEROOT_HOST_DESTDIR)/lib32
FAKEROOT_HOST_TARGET_SCRIPT:=$(FAKEROOT_HOST_DESTDIR)/bin/fakeroot
FAKEROOT_HOST_TARGET_BIARCH_LIB:=$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)/libfakeroot-0.so

# BIARCH means 32-bit libraries on 64-bit hosts
# We need 32-bit fakeroot support if we use the 32-bit mips*-linux-strip during fwmod on a 64-bit host
# The correct condition here would be:
# (using 32-bit [tools/toolchains] [own/dl]) AND (any of the STRIP-options is selected) AND (host is 64-bit)
BIARCH_BUILD_SYSTEM:=$(filter-out 32,$(HOST_BITNESS))


fakeroot-host-source: $(DL_DIR)/$(FAKEROOT_HOST_SOURCE)
$(DL_DIR)/$(FAKEROOT_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(FAKEROOT_HOST_SOURCE) $(FAKEROOT_HOST_SITE) $(FAKEROOT_HOST_SOURCE_SHA256)

fakeroot-host-unpacked: $(FAKEROOT_HOST_DIR)/.unpacked
$(FAKEROOT_HOST_DIR)/.unpacked: $(DL_DIR)/$(FAKEROOT_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(FAKEROOT_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(FAKEROOT_HOST_MAKE_DIR)/patches,$(FAKEROOT_HOST_DIR))
	touch $@

$(FAKEROOT_HOST_MAINARCH_DIR)/.configured: $(FAKEROOT_HOST_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_MAINARCH_DIR); cd $(FAKEROOT_HOST_MAINARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(DISABLE_NLS) \
	);
	touch $@
$(FAKEROOT_HOST_TARGET_SCRIPT): $(FAKEROOT_HOST_MAINARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) install
	$(SED) -i 's,^FAKEROOT_PREFIX=.*,FAKEROOT_PREFIX="$$(readlink -f $$0 | sed "s!/bin/fakeroot\\$$!!")",'  $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^FAKEROOT_BINDIR=.*,FAKEROOT_BINDIR=$${FAKEROOT_PREFIX}/bin,'                              $(FAKEROOT_HOST_TARGET_SCRIPT)
	$(SED) -i 's,^PATHS=.*,PATHS=$${FAKEROOT_PREFIX}/lib:$${FAKEROOT_PREFIX}/lib32,'                        $(FAKEROOT_HOST_TARGET_SCRIPT)

$(FAKEROOT_HOST_BIARCH_DIR)/.configured: $(FAKEROOT_HOST_DIR)/.unpacked
	(mkdir -p $(FAKEROOT_HOST_BIARCH_DIR); cd $(FAKEROOT_HOST_BIARCH_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS) $(HOST_CFLAGS_FORCE_32BIT_CODE)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		../../configure \
		--prefix=$(FAKEROOT_HOST_DESTDIR) \
		--enable-shared \
		$(if $(findstring Microsoft,$(shell uname -r)),--with-ipc=tcp,--with-ipc=sysv) \
		$(if $(findstring Microsoft,$(shell uname -r)),--host=$(shell uname -m),) \
		$(DISABLE_NLS) \
		$(QUIET) \
	);
	touch $@
$(FAKEROOT_HOST_TARGET_BIARCH_LIB): $(FAKEROOT_HOST_BIARCH_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) libdir="$(FAKEROOT_HOST_BIARCH_LD_PRELOAD_PATH)" install-libLTLIBRARIES
	touch $@

fakeroot-host-precompiled: $(FAKEROOT_HOST_TARGET_SCRIPT) $(if $(BIARCH_BUILD_SYSTEM),$(FAKEROOT_HOST_TARGET_BIARCH_LIB))


fakeroot-host-clean:
	-$(MAKE) -C $(FAKEROOT_HOST_MAINARCH_DIR) clean
	-$(MAKE) -C $(FAKEROOT_HOST_BIARCH_DIR) clean

fakeroot-host-dirclean:
	$(RM) -r $(FAKEROOT_HOST_DIR)

fakeroot-host-distclean: fakeroot-host-dirclean
	$(RM) -r $(FAKEROOT_HOST_TARGET_SCRIPT) $(FAKEROOT_HOST_DESTDIR)/bin/faked $(FAKEROOT_HOST_DESTDIR)/lib*/libfakeroot*

