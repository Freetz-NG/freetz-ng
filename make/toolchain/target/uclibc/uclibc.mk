UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc$(if $(FREETZ_TARGET_UCLIBC_1),-ng)-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(MAKE_DIR)/toolchain/target/uclibc
UCLIBC_SOURCE:=uClibc$(if $(FREETZ_TARGET_UCLIBC_1),-ng)-$(UCLIBC_VERSION).tar.$(if $(FREETZ_TARGET_UCLIBC_1),xz,bz2)
UCLIBC_HASH_0.9.28   = c8bc5383eafaa299e9874ae50acc6549f8b54bc29ed64a9a3387b3e4cd7f4bcb
UCLIBC_HASH_0.9.29   = ca70501ae859cd86b387bb196908838275b4b06e6f4d692f9aa51b8a633334a7
UCLIBC_HASH_0.9.32.1 = b41c91dcc043919a3c19bd73a524adfd375d6d8792ad7be3631f90ecad8465e9
UCLIBC_HASH_0.9.33.2 = 988d2c777e0605fe253d12157f71ec68f25d1bb8428725d2b7460bf9977e1662
UCLIBC_HASH_1.0.14   = 3c63d9f8c8b98b65fa5c4040d1c8ab1b36e99a16e1093810cedad51ac15c9a9e
UCLIBC_HASH_1.0.56   = 23c9cab54c113e020fb20b9dc06be4a49560df791b78fcbc2ca899a6e8f213dd
UCLIBC_HASH=$(UCLIBC_HASH_$(UCLIBC_VERSION))
UCLIBC_SITE_0:=http://www.uclibc.org/downloads$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),/old-releases)
UCLIBC_SITE_1:=https://downloads.uclibc-ng.org/releases/$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_SITE  :=$(UCLIBC_SITE_$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION))
### WEBSITE:=https://www.uclibc-ng.org/
### MANPAGE:=https://uclibc-ng.org/docs/
### CHANGES:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/log/
### CVSREPO:=https://cgit.uclibc-ng.org/cgi/cgit/uclibc-ng.git/

UCLIBC_ECHO_TYPE:=TTC
UCLIBC_ECHO_MAKE:=uclibc

UCLIBC_KERNEL_HEADERS_DIR:=$(KERNEL_HEADERS_DEVEL_DIR)

UCLIBC_DEVEL_SUBDIR:=uClibc_dev

UCLIBC_CONFIG_FILE:=$(UCLIBC_MAKE_DIR)/configs/freetz/config-$(FREETZ_TARGET_ARCH_ENDIANNESS_DEPENDENT)-$(if $(FREETZ_SEPARATE_AVM_UCLIBC),separate,$(UCLIBC_VERSION))

UCLIBC_PATCHES_DIR:=$(UCLIBC_MAKE_DIR)/patches/$(if $(FREETZ_SEPARATE_AVM_UCLIBC),separate,$(UCLIBC_VERSION))

UCLIBC_TARGET_SUBDIR:=$(if $(FREETZ_SEPARATE_AVM_UCLIBC),$(FREETZ_RPATH),/lib)

# uClibc >= 0.9.31 supports parallel building
#  TODO    1.0.14: reenable parallel building
UCLIBC_MAKE:=$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29),$(FREETZ_TARGET_UCLIBC_1_0_14)),$(MAKE1),$(MAKE))

UCLIBC_COMMON_BUILD_FLAGS:=

# uClibc pregenerated locale data
UCLIBC_LOCALE_DATA_SITE:=http://www.uclibc.org/downloads
# TODO: FREETZ_TARGET_UCLIBC_REDUCED_LOCALE_SET is a REBUILD_SUBOPT
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_REDUCED_LOCALE_SET)),y)
UCLIBC_LOCALE_DATA_FILENAME:=uClibc-locale-$(if $(FREETZ_TARGET_ARCH_BE),be,le)-32-de_DE-en_US.tar.gz
UCLIBC_LOCALE_DATA_HASH:=$(if $(FREETZ_TARGET_ARCH_BE),670cfa9c600de4d652ebf7eda7aee88e3dc62d2bdd9298f7c69ed951da277723,353c93317ce09e4c9ed7188a316c6dca764fda97dad3bd145719893dd6f0f88b)
else
UCLIBC_LOCALE_DATA_FILENAME:=uClibc-locale-030818.tgz
UCLIBC_LOCALE_DATA_HASH:=c4362be318a38f18d98dccf462d22d95bab92f05548bb93f65298fe9afaebd57
endif
UCLIBC_COMMON_BUILD_FLAGS += LOCALE_DATA_FILENAME=$(UCLIBC_LOCALE_DATA_FILENAME)

ifeq ($(strip $(FREETZ_TARGET_ARCH_MIPS)),y)
UCLIBC_COMMON_BUILD_FLAGS += MIPS_CUSTOM_ARCH_CPU_CFLAGS="$(strip $(filter -march=% -mcpu=% -mtune=%,$(TARGET_CFLAGS_HW_CAPABILITIES)))"
endif
UCLIBC_COMMON_BUILD_FLAGS += $(if $(FREETZ_TARGET_UCLIBC_DODEBUG),$(if $(FREETZ_TARGET_UCLIBC_DODEBUG_MAXIMUM),DEBUG_LEVEL=3))

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
ifeq ($(or $(FREETZ_TARGET_UCLIBC_0_9_32),$(FREETZ_TARGET_UCLIBC_0_9_33)),y)
# Changed with uClibc-0.9.32-rc3: "V=1 is quiet plus defines. V=2 are verbatim commands."
# For more details see <http://lists.uclibc.org/pipermail/uclibc/2011-March/045005.html>
UCLIBC_COMMON_BUILD_FLAGS += V=2
# Changed once again in uClibc-ng
# See https://github.com/wbx-github/uclibc-ng/commit/98d8242d872774356d8efb93857036f3a26578d7
else
UCLIBC_COMMON_BUILD_FLAGS += V=1
endif
endif

UCLIBC_HOST_CFLAGS:=$(TOOLCHAIN_HOST_CFLAGS)
# g++ -v --help 2>/dev/null | grep ' -std='
#ifeq ($(strip $(FREETZ_TARGET_GCC_5_MAX)),y)
#UCLIBC_HOST_CFLAGS+=--std=gnu11
#endif
UCLIBC_HOST_CFLAGS+=-U_GNU_SOURCE -fno-strict-aliasing


$(DL_DIR)/$(UCLIBC_LOCALE_DATA_FILENAME): | $(DL_DIR)
	@$(call _ECHO,downloading,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(UCLIBC_LOCALE_DATA_FILENAME) $(UCLIBC_LOCALE_DATA_SITE) $(UCLIBC_LOCALE_DATA_HASH) $(SILENT)

uclibc-source: $(DL_DIR)/$(UCLIBC_SOURCE)
ifneq ($(LDD_SOURCE),$(UCLIBC_SOURCE))
$(DL_DIR)/$(UCLIBC_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(UCLIBC_SOURCE) $(UCLIBC_SITE) $(UCLIBC_HASH) $(SILENT)
endif

uclibc-unpacked: $(UCLIBC_DIR)/.unpacked
$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE) $(DL_DIR)/$(UCLIBC_LOCALE_DATA_FILENAME) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(RM) -r $(UCLIBC_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(UCLIBC_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(UCLIBC_PATCHES_DIR)/avm $(UCLIBC_PATCHES_DIR),$(UCLIBC_DIR))
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0)),y)
	@echo "#fixing ncurses detection bug" $(SILENT); \
	$(SED) 's/main() {}/int &/' -i "$(UCLIBC_DIR)/extra/config/Makefile" "$(UCLIBC_DIR)/extra/config/lxdialog/check-lxdialog.sh" 2>/dev/null || true
endif
ifeq ($(FREETZ_TARGET_UCLIBC_0_9_33),y)
# "remove"-part of 980-nptl_remove_duplicate_vfork_in_libpthread
# instead of removing files using patch, we remove them using rm
# see http://lists.uclibc.org/pipermail/uclibc/2014-September/048597.html for details
	find $(UCLIBC_DIR)/libpthread/nptl -name "*pt-vfork*" -exec $(RM) {} \+
endif
	cp -dpf $(DL_DIR)/$(UCLIBC_LOCALE_DATA_FILENAME) $(UCLIBC_DIR)/extra/locale/
	touch $@

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
UCLIBC_PREREQ_GCC_INITIAL=$(GCC_BUILD_DIR1)/.installed
else
UCLIBC_PREREQ_GCC_INITIAL=$(TARGET_CROSS_COMPILER)
endif

uclibc-config: $(UCLIBC_DIR)/.config
$(UCLIBC_DIR)/.config: $(UCLIBC_DIR)/.unpacked | $(UCLIBC_PREREQ_GCC_INITIAL)
	@$(call _ECHO,configuring,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	cp $(UCLIBC_CONFIG_FILE) $(UCLIBC_DIR)/.config
	$(call PKG_EDIT_CONFIG,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS)) $(UCLIBC_DIR)/Rules.mak
	$(call PKG_EDIT_CONFIG, \
		$(if $(FREETZ_TARGET_UCLIBC_0_9_28), \
			KERNEL_SOURCE=\"$(UCLIBC_KERNEL_HEADERS_DIR)\" \
		, \
			KERNEL_HEADERS=\"$(UCLIBC_KERNEL_HEADERS_DIR)/include\" \
			ARCH_WANTS_LITTLE_ENDIAN=$(if $(FREETZ_TARGET_ARCH_BE),n,y) \
			ARCH_WANTS_BIG_ENDIAN=$(if $(FREETZ_TARGET_ARCH_BE),y,n) \
		) \
		CONFIG_MIPS_ISA_MIPS32=$(if $(FREETZ_TARGET_ARCH_LE),y,n) \
		CONFIG_MIPS_ISA_MIPS32R2=$(if $(FREETZ_TARGET_ARCH_BE),y,n) \
		UCLIBC_HAS_IPV6=$(FREETZ_TARGET_IPV6_SUPPORT) \
		UCLIBC_HAS_FOPEN_LARGEFILE_MODE=n \
		UCLIBC_HAS_WCHAR=y \
		UCLIBC_HAS_XLOCALE=$(if $(FREETZ_AVM_UCLIBC_XLOCALE_ENABLED),y,n) \
		\
		$(if $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),, \
			LINUXTHREADS_OLD=$(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),n,y) \
			UCLIBC_HAS_THREADS_NATIVE=$(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),y,n) \
			UCLIBC_HAS_BACKTRACE=$(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_libubacktrace),y,n) \
		) \
		\
		DODEBUG=$(if $(FREETZ_TARGET_UCLIBC_DODEBUG),y,n) \
		$(if $(FREETZ_SYSTEM_TYPE_BCM63138), \
			UCLIBC_HAS_FPU=n \
			UCLIBC_HAS_SOFT_FLOAT=y \
		) \
	) $(UCLIBC_DIR)/.config

	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/include
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/lib
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
		oldconfig < /dev/null $(SILENT)
	touch $@

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.config | $(UCLIBC_KERNEL_HEADERS_DIR)/include/linux/version.h $(UCLIBC_PREREQ_GCC_INITIAL)
	@$(call _ECHO,headers,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS)" headers \
		$(if $(FREETZ_TARGET_UCLIBC_0_9_28),install_dev,install_headers) \
		$(SILENT)
	touch $@

uclibc-menuconfig: $(UCLIBC_DIR)/.config
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
		menuconfig && \
	cp -f $^ $(UCLIBC_CONFIG_FILE) && \
	touch $^

uclibc-oldconfig uclibc-olddefconfig: $(UCLIBC_DIR)/.config
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
		$(if $(FREETZ_TARGET_UCLIBC_0),oldconfig,olddefconfig)
	cp -f $^ $(UCLIBC_CONFIG_FILE) && \
	touch $^

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured | $(UCLIBC_PREREQ_GCC_INITIAL)
	@$(call _ECHO,building,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS)" \
		all $(SILENT)
ifneq ($(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29)),y)
	# At this point uClibc is compiled and there is no reason for us to recompile it.
	# Remove some FORCE rule dependencies causing parts of uClibc to be recompiled (without a need)
	# over and over again each time make is invoked within uClibc dir (the actual target doesn't matter).
	# This is a bit dirty workaround we actually should get rid of as soon as we find a better solution.
	for i in $(UCLIBC_DIR)/Makerules $(UCLIBC_DIR)/extra/locale/Makefile.in; do \
		cp -a "$$i" "$$i-with-FORCE"; \
		sed -i -r -e '/.*%[.]o[sS]:.*FORCE.*/s, FORCE , ,g' $$i; \
	done;
endif
	touch -c $@

define STRIP_UCLIBC
	[ "$(FREETZ_STRIP_UCLIBC)" != "y" ] || \
	for i in $(UCLIBC_FILES); do \
		[ ! -L "$(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i" ] || continue; \
		[ -f "$(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i" ] || continue; \
		file $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i | grep -q ':.* not stripped' || continue; \
		echo "stripping $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i" $(SILENT); \
		$(TARGET_STRIP) $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i; \
	done
endef

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	@$(call _ECHO,installing,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=/ \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/ \
		install_runtime install_dev $(SILENT)
	# Copy some files to make mklibs happy
	# Note: uclibc 1.0.18+ has a single libc and does not build libpthread etc. anymore
	# Ref.: https://github.com/wbx-github/uclibc-ng/commit/29ff9055c80efe77a7130767a9fcb3ab8c67e8ce
ifeq ($(strip $(UCLIBC_VERSION)),$(filter $(strip $(UCLIBC_VERSION)),0.9.29 0.9.32 0.9.33 1.0.14))
	for f in libc_pic.a libdl_pic.a libpthread_pic.a; do \
		$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$f; \
	done; \
	cp $(UCLIBC_DIR)/libc/libc_so.a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc_pic.a; \
	cp $(UCLIBC_DIR)/libpthread/*/libpthread_so.a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpthread_pic.a ; \
	cp $(UCLIBC_DIR)/ldso/libdl/libdl_so.a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libdl_pic.a
endif
	# Build the host utils.
	# Note: in order the host utils to work the __ELF_NATIVE_CLASS (= __WORDSIZE) of the target
	# must be known. That's the reason we provide -DARCH_NATIVE_BIT=32 here.
	# uClibc-0.9.28: no fix required
	# uClibc-0.9.29/uClibc-0.9.32: 990-ldd_fix_host_ldd...patch requires ARCH_NATIVE_BIT to be provided externally
	# uClibc-0.9.33: 990-ldd_fix_host_ldd...patch(es) contain all required changes
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR)/utils \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(TOOLCHAIN_HOSTCC) $(UCLIBC_HOST_CFLAGS) $(if $(or $(FREETZ_TARGET_UCLIBC_0_9_29),$(FREETZ_TARGET_UCLIBC_0_9_32)),-DARCH_NATIVE_BIT=32)" \
		BUILD_LDFLAGS="" \
		hostutils $(SILENT)
	for i in ldd ldconfig; do \
		install -c $(UCLIBC_DIR)/utils/$$i.host $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/$$i; \
		$(HOST_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/$$i; \
		ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/$$i $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i; \
		ln -sf $(REAL_GNU_TARGET_NAME)-$$i $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(GNU_TARGET_NAME)-$$i; \
	done
	touch -c $@

$(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/libc.so.$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	@$(call _ECHO,runtime,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE))
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX="$(FREETZ_BASE_DIR)/$(TARGET_SPECIFIC_ROOT_DIR)" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime $(SILENT)
	$(call STRIP_UCLIBC)
	touch -c $@
else
$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a: $(TARGET_CROSS_COMPILER)
	touch -c $@

$(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/libc.so.$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	@$(RM) -r $(TARGET_SPECIFIC_ROOT_DIR)/lib $(TARGET_SPECIFIC_ROOT_DIR)/usr
	@mkdir -p $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)
	for i in $(UCLIBC_FILES); do \
		[ "$$i" == "libc.so.0" ] && [ ! -e $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$i ] && [ ! -L $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$i ] && continue; \
		cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$i $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/$$i; \
	done
	$(call STRIP_UCLIBC)
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/libc.so
	touch -c $@
endif

uclibc-autofix: uclibc-dirclean
	$(MAKE) AUTO_FIX_PATCHES=y uclibc-unpacked

uclibc-configured: kernel-configured $(UCLIBC_DIR)/.configured

uclibc: $(UCLIBC_PREREQ_GCC_INITIAL) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a $(TARGET_SPECIFIC_ROOT_DIR)$(UCLIBC_TARGET_SUBDIR)/libc.so.$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION)


uclibc-clean:
	-$(MAKE1) -C $(UCLIBC_DIR) clean
	$(RM) $(UCLIBC_DIR)/.config

uclibc-dirclean:
	$(RM) -r $(UCLIBC_DIR)

uclibc-distclean: uclibc-dirclean


#############################################################
#
# uClibc for the target
#
#############################################################

$(TARGET_UTILS_DIR)/usr/lib/libc.a: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	@$(call _ECHO,headers,$(UCLIBC_ECHO_TYPE),$(UCLIBC_ECHO_MAKE),target)
	$(UCLIBC_MAKE) -C $(UCLIBC_DIR) \
		$(UCLIBC_COMMON_BUILD_FLAGS) \
		PREFIX=$(TARGET_UTILS_DIR) \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		RUNTIME_PREFIX_LIB_FROM_DEVEL_PREFIX_LIB=/lib/ \
		install_dev $(SILENT)
	# create two additional symlinks, required because libc.so is not really
	# a shared lib, but a GNU ld script referencing the libs below
	for f in libc.so.$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION) $(sort ld-uClibc.so.0 ld-uClibc.so.$(TARGET_TOOLCHAIN_UCLIBC_MAJOR_VERSION)); do \
		ln -fs /lib/$$f $(TARGET_UTILS_DIR)/usr/lib/; \
	done
	$(call COPY_KERNEL_HEADERS,$(UCLIBC_KERNEL_HEADERS_DIR),$(TARGET_UTILS_DIR)/usr)
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))
	touch -c $@

uclibc_target: gcc uclibc $(TARGET_UTILS_DIR)/usr/lib/libc.a


uclibc_target-clean: uclibc_target-dirclean
	$(RM) $(TARGET_UTILS_DIR)/lib/libc.a

uclibc_target-dirclean:
	$(RM) -r $(TARGET_UTILS_DIR)/usr/include

uclibc_target-distclean: uclibc_target-dirclean


.PHONY: uclibc-source uclibc-unpacked uclibc-autofix uclibc-menuconfig uclibc-oldconfig uclibc-olddefconfig uclibc-configured
.PHONY: uclibc        uclibc-clean        uclibc-dirclean        uclibc-distclean
.PHONY: uclibc_target uclibc_target-clean uclibc_target-dirclean uclibc_target-distclean

