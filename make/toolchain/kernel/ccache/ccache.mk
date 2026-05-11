CCACHE_KERNEL_VERSION:=4.13.6
CCACHE_KERNEL_SOURCE:=ccache-$(CCACHE_KERNEL_VERSION).tar.xz
CCACHE_KERNEL_HASH:=a7de667ca08cf67c3c8af9f213f6aa701a1188a2b3163fb74483858ce5e79fbb
CCACHE_KERNEL_SITE:=https://github.com/ccache/ccache/releases/download/v$(CCACHE_KERNEL_VERSION)
### WEBSITE:=https://ccache.dev/
### MANPAGE:=https://ccache.dev/documentation.html
### CHANGES:=https://ccache.dev/releasenotes.html
### CVSREPO:=https://github.com/ccache/ccache

CCACHE_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/ccache-$(CCACHE_KERNEL_VERSION)
CCACHE_KERNEL_MAKE_DIR:=$(MAKE_DIR)/toolchain/kernel/ccache
CCACHE_KERNEL_BINARY:=ccache
CCACHE_KERNEL_TARGET_BINARY:=bin/ccache

CCACHE_KERNEL_BIN_DIR:=$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache

CCACHE_KERNEL_ECHO_TYPE:=KTC
CCACHE_KERNEL_ECHO_MAKE:=ccache


ccache-kernel-source: $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)
#
$(DL_DIR)/$(CCACHE_KERNEL_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(CCACHE_KERNEL_ECHO_TYPE),$(CCACHE_KERNEL_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(CCACHE_KERNEL_SOURCE) $(CCACHE_KERNEL_SITE) $(CCACHE_KERNEL_HASH) $(SILENT)
#

ccache-kernel-unpacked: $(CCACHE_KERNEL_DIR)/.unpacked
$(CCACHE_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_KERNEL_SOURCE) | $(KERNEL_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(CCACHE_KERNEL_ECHO_TYPE),$(CCACHE_KERNEL_ECHO_MAKE))
	$(RM) -r $(CCACHE_KERNEL_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(CCACHE_KERNEL_SOURCE),$(KERNEL_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(CCACHE_KERNEL_MAKE_DIR)/patches,$(CCACHE_KERNEL_DIR))
	touch $@

$(CCACHE_KERNEL_DIR)/.configured: $(CCACHE_KERNEL_DIR)/.unpacked
	@$(call _ECHO,configuring,$(CCACHE_KERNEL_ECHO_TYPE),$(CCACHE_KERNEL_ECHO_MAKE))
	(cd $(CCACHE_KERNEL_DIR); $(RM) CMakeCache.txt; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CXX="$(TOOLCHAIN_HOSTCXX)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		CXXFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(CMAKE) . \
		-DCMAKE_C_COMPILER_TARGET=$(GNU_HOST_NAME) \
		-DCMAKE_CXX_COMPILER_TARGET=$(GNU_HOST_NAME) \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DENABLE_DOCUMENTATION=OFF \
		-DENABLE_TESTING=OFF \
		-DREDIS_STORAGE_BACKEND=OFF \
		-DDEPS=DOWNLOAD \
		-Wno-dev \
		$(QUIETCMAKE) \
		$(SILENT) \
	);
	touch $@

$(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY): $(CCACHE_KERNEL_DIR)/.configured
	@$(call _ECHO,building,$(CCACHE_KERNEL_ECHO_TYPE),$(CCACHE_KERNEL_ECHO_MAKE))
	$(MAKE) -C $(CCACHE_KERNEL_DIR) $(SILENT)

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY): $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY)
	@$(call _ECHO,installing,$(CCACHE_KERNEL_ECHO_TYPE),$(CCACHE_KERNEL_ECHO_MAKE))
	mkdir -p $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin
	cp $(CCACHE_KERNEL_DIR)/$(CCACHE_KERNEL_BINARY) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(CCACHE_KERNEL_BIN_DIR)
	for i in gcc    ; do \
		[ -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$i -a \
			! -h $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$i ] && \
			mv $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$i $(CCACHE_KERNEL_BIN_DIR)/ || true; \
	done
	( cd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin; \
		ln -fs ccache $(REAL_GNU_KERNEL_NAME)-gcc; \
		                                           \
	)
	( cd $(CCACHE_KERNEL_BIN_DIR); \
		ln -fs $(REAL_GNU_KERNEL_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc; \
		                                                               \
		for i in gcc           ; do \
			ln -fs $(REAL_GNU_KERNEL_NAME)-$$i $(GNU_TARGET_NAME)-$$i; \
		done; \
	)

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache-kernel: gcc-kernel $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
else
#ccache-kernel: $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
ccache-kernel: $(KERNEL_CROSS_COMPILER)
endif


ccache-kernel-clean:
	for i in gcc    ; do \
		if [ -f $(CCACHE_KERNEL_BIN_DIR)/$(REAL_GNU_KERNEL_NAME)-$$i ] ; then \
			$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$i; \
			mv $(CCACHE_KERNEL_BIN_DIR)/$(REAL_GNU_KERNEL_NAME)-$$i $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/; \
		fi; \
	done
	$(RM) -r $(CCACHE_KERNEL_BIN_DIR)
	$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(CCACHE_KERNEL_TARGET_BINARY)
	-[ -d "$(CCACHE_KERNEL_DIR)" ] && $(MAKE) -C $(CCACHE_KERNEL_DIR) clean $(QUIET)

ccache-kernel-dirclean: ccache-kernel-clean
	$(RM) -r $(CCACHE_KERNEL_DIR)

ccache-kernel-distclean: ccache-kernel-dirclean


.PHONY: ccache-kernel ccache-kernel-source ccache-kernel-unpacked ccache-kernel-clean ccache-kernel-dirclean ccache-kernel-distclean

