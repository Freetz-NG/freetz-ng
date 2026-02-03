BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.$(if $(filter $(BINUTILS_VERSION),2.18 2.22 2.23.2 2.24 2.25.1 2.26.1),bz2,xz)
BINUTILS_SITE:=@GNU/binutils
BINUTILS_HASH_2.18   := X
BINUTILS_HASH_2.22   := 6c7af8ed1c8cf9b4b9d6e6fe09a3e1d3d479fe63984ba8b9b26bf356b6313ca9
BINUTILS_HASH_2.23.2 := fe914e56fed7a9ec2eb45274b1f2e14b0d8b4f41906a5194eac6883cfe5c1097
BINUTILS_HASH_2.24   := e5e8c5be9664e7f7f96e0d09919110ab5ad597794f5b1809871177a0f0f14137
BINUTILS_HASH_2.25.1 := b5b14added7d78a8d1ca70b5cb75fef57ce2197264f4f5835326b0df22ac9f22
BINUTILS_HASH_2.26.1 := 39c346c87aa4fb14b2f786560aec1d29411b6ec34dce3fe7309fe3dd56949fd8
BINUTILS_HASH_2.31.1 := 5d20086ecf5752cc7d9134246e9588fa201740d540f7eb84d795b1f7a93bca86
BINUTILS_HASH_2.36.1 := e81d9edf373f193af428a0f256674aea62a9d74dfe93f65192d4eae030b0f3b0
BINUTILS_HASH_2.42   := X
BINUTILS_HASH_2.43.1 := 13f74202a3c4c51118b797a39ea4200d3f6cfbe224da6d1d95bb938480132dfd
BINUTILS_HASH_2.45.1 := 5fe101e6fe9d18fdec95962d81ed670fdee5f37e3f48f0bef87bddf862513aa5
BINUTILS_HASH:=$(BINUTILS_HASH_$(BINUTILS_VERSION))

BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(MAKE_DIR)/toolchain/target/binutils
BINUTILS_DIR1:=$(BINUTILS_DIR)-build

BINUTILS_CFLAGS := $(TOOLCHAIN_HOST_CFLAGS)
#
#
#
ifeq ($(if $(filter $(BINUTILS_VERSION),2.18 2.22 2.23.2 2.24 2.25.1 2.26.1 2.31.1 2.36.1 2.42 2.43.1),y),y)
BINUTILS_CFLAGS += --std=gnu11
endif

BINUTILS_EXTRA_MAKE_OPTIONS := MAKEINFO=true

BINUTILS_ECHO_TYPE:=TTC
BINUTILS_ECHO_MAKE:=binutils


binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE)
ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)))
ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_TOOLS_SOURCE)))
$(DL_DIR)/$(BINUTILS_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(BINUTILS_SOURCE) $(BINUTILS_SITE) $(BINUTILS_HASH) $(SILENT)
endif
endif

binutils-unpacked: $(BINUTILS_DIR)/.unpacked
$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE))
	$(RM) -r $(BINUTILS_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(BINUTILS_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(BINUTILS_MAKE_DIR)/patches/$(call GET_MAJOR_VERSION,$(BINUTILS_VERSION)),$(BINUTILS_DIR))
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$(find $(BINUTILS_DIR) -name "configure" -type f)
	touch $@


$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.unpacked
	@$(call _ECHO,configuring,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE))
	mkdir -p $(BINUTILS_DIR1)
	(cd $(BINUTILS_DIR1); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(BINUTILS_CFLAGS)" \
		$(BINUTILS_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--disable-libssp \
		$(DISABLE_NLS) \
		--disable-werror \
		$(SILENT) \
	);
	touch $@

$(BINUTILS_DIR1)/.compiled: $(BINUTILS_DIR1)/.configured
	@$(call _ECHO,building,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE))
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) configure-host $(SILENT)
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) all $(SILENT)
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/.compiled
	@$(call _ECHO,installing,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE))
	$(MAKE1) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) install $(SILENT)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld.bfd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))

binutils: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld


binutils-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib{,64}/{libiberty*,ldscripts}

binutils-clean: binutils-uninstall
	$(RM) -r $(BINUTILS_DIR1)

binutils-dirclean: binutils-clean binutils_target-dirclean
	$(RM) -r $(BINUTILS_DIR)

binutils-distclean: binutils-dirclean


#############################################################
#
# build binutils for use on the target system
#
#############################################################
BINUTILS_DIR2:=$(BINUTILS_DIR)-target
$(BINUTILS_DIR2)/.configured: $(BINUTILS_DIR)/.unpacked
	@$(call _ECHO,configuring,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE),target)
	mkdir -p $(BINUTILS_DIR2)
	(cd $(BINUTILS_DIR2); $(RM) config.cache; \
		CFLAGS_FOR_BUILD="-O2 $(BINUTILS_CFLAGS)" \
		$(TARGET_CONFIGURE_ENV) \
		CONFIG_SITE=$(TARGET_SITE) \
		$(BINUTILS_DIR)/configure \
		--prefix=/usr \
		--with-sysroot=/ \
		--exec-prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--without-zlib \
		--disable-gprofng \
		$(DISABLE_NLS) \
		--disable-werror \
		$(SILENT) \
	)
	touch $@

$(BINUTILS_DIR2)/.compiled: $(BINUTILS_DIR2)/.configured
	@$(call _ECHO,building,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE),target)
	$(MAKE_ENV) $(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR2) all $(SILENT)
	touch $@

$(TARGET_UTILS_DIR)/usr/bin/ld: $(BINUTILS_DIR2)/.compiled
	@$(call _ECHO,installing,$(BINUTILS_ECHO_TYPE),$(BINUTILS_ECHO_MAKE),target)
	$(MAKE_ENV) $(MAKE1) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR2) \
		tooldir=/usr \
		build_tooldir=/usr \
		DESTDIR=$(TARGET_UTILS_DIR) install $(SILENT)
	$(RM) $(TARGET_UTILS_DIR)/usr/bin/ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))

binutils_target: $(TARGET_UTILS_DIR)/usr/bin/ld


binutils_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))

binutils_target-clean: binutils_target-uninstall
	$(RM) -r $(BINUTILS_DIR2)

binutils_target-dirclean: binutils_target-clean

binutils_target-distclean: binutils_target-dirclean


.PHONY: binutils-source binutils-unpacked 
.PHONY: binutils        binutils-uninstall        binutils-clean        binutils-dirclean        binutils-distclean
.PHONY: binutils_target binutils_target-uninstall binutils_target-clean binutils_target-dirclean binutils_target-distclean

