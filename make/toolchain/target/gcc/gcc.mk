GCC_VERSION:=$(TARGET_TOOLCHAIN_GCC_VERSION)
GCC_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$(call qstrip,$(FREETZ_TARGET_GCC_VERSION)),2)
GCC_SOURCE:=gcc-$(GCC_VERSION).tar.$(if $(or $(FREETZ_TARGET_GCC_4_6),$(FREETZ_TARGET_GCC_4_7),$(FREETZ_TARGET_GCC_4_8),$(FREETZ_TARGET_GCC_4_9)),bz2,xz)
GCC_SITE:=@GNU/gcc/gcc-$(GCC_VERSION)
GCC_HASH_4.6.4  := 35af16afa0b67af9b8eb15cafb76d2bc5f568540552522f5dc2c88dd45d977e8
GCC_HASH_4.7.4  := 92e61c6dc3a0a449e62d72a38185fda550168a86702dea07125ebd3ec3996282
GCC_HASH_4.8.5  := 22fb1e7e0f68a63cee631d85b20461d1ea6bda162f03096350e38c8d427ecf23
GCC_HASH_4.9.4  := 6c11d292cd01b294f9f84c9a59c230d80e9e4a47e5c6355f046bb36d4f358092
GCC_HASH_5.5.0  := 530cea139d82fe542b358961130c69cfde8b3d14556370b65823d2f91f0ced87
GCC_HASH_8.3.0  := 64baadfe6cc0f4947a84cb12d7f0dfaf45bb58b7e92461639596c21e02d97d2c
GCC_HASH_8.4.0  := e30a6e52d10e1f27ed55104ad233c30bd1e99cfb5ff98ab022dc941edd1b2dd4
GCC_HASH_9.3.0  := 71e197867611f6054aa1119b13a0c0abac12834765fe2d81f35ac57f84f742d1
GCC_HASH_9.4.0  := c95da32f440378d7751dd95533186f7fc05ceb4fb65eb5b85234e6299eb9838e
GCC_HASH_13.4.0 := 9c4ce6dbb040568fdc545588ac03c5cbc95a8dbf0c7aa490170843afb59ca8f5
GCC_HASH_14.3.0 := e0dc77297625631ac8e50fa92fffefe899a4eb702592da5c32ef04e2293aca3a
GCC_HASH_15.2.0 := 438fd996826b0c82485a29da03a72d71d6e3541a83ec702df4271f6fe025d24e
GCC_HASH:=$(GCC_HASH_$(GCC_VERSION))

GCC_DIR:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)
GCC_MAKE_DIR:=$(MAKE_DIR)/toolchain/target/gcc

GCC_ECHO_TYPE:=TTC
GCC_ECHO_MAKE:=gcc


# g++ -v --help 2>/dev/null | grep ' -std='
GCC_CFLAGS:=$(TOOLCHAIN_HOST_CFLAGS)
GCC_CXXFLAGS:=$(TOOLCHAIN_HOST_CFLAGS)
# gcc 4+5 does not like be compiled by gcc11/C++17
ifeq ($(strip $(FREETZ_TARGET_GCC_5_MAX)),y)
GCC_CFLAGS+=--std=gnu11
GCC_CXXFLAGS+=--std=gnu++11
endif


GCC_INITIAL_PREREQ=
GCC_STAGING_PREREQ=
GCC_TARGET_PREREQ=

GCC_BUILD_TARGET_LIBGCC:=y

GCC_STAGING_PREREQ+=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a

GCC_HOST_COMMON_CONFIGURE_ENV := PATH=$(TARGET_PATH)
GCC_HOST_COMMON_CONFIGURE_ENV += CC="$(strip $(TOOLCHAIN_HOSTCC))"
GCC_HOST_COMMON_CONFIGURE_ENV += CFLAGS="$(strip $(GCC_CFLAGS))"
GCC_HOST_COMMON_CONFIGURE_ENV += CXXFLAGS="$(strip $(GCC_CXXFLAGS))"
GCC_HOST_COMMON_CONFIGURE_ENV += CFLAGS_FOR_TARGET="$(strip $(TARGET_CFLAGS))"
GCC_HOST_COMMON_CONFIGURE_ENV += CXXFLAGS_FOR_TARGET="$(strip $(TARGET_CFLAGS))"

GCC_COMMON_CONFIGURE_OPTIONS := --enable-option-checking
GCC_COMMON_CONFIGURE_OPTIONS += --with-gnu-as
GCC_COMMON_CONFIGURE_OPTIONS += --with-gnu-ld
GCC_COMMON_CONFIGURE_OPTIONS += --disable-__cxa_atexit
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libgomp
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libmudflap
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libsanitizer
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libssp
GCC_COMMON_CONFIGURE_OPTIONS += --disable-multilib
GCC_COMMON_CONFIGURE_OPTIONS += $(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),--enable-tls,--disable-tls)
GCC_COMMON_CONFIGURE_OPTIONS += --disable-fixed-point
GCC_COMMON_CONFIGURE_OPTIONS += $(strip $(GCC_COMMON_CONFIGURE_OPTIONS_HW_CAPABILITIES))
GCC_COMMON_CONFIGURE_OPTIONS += --disable-nls
GCC_COMMON_CONFIGURE_OPTIONS += $(QUIET)

ifneq ($(strip $(FREETZ_TARGET_TOOLCHAIN_AVM_COMPATIBLE)),y)
ifeq ($(strip $(FREETZ_TARGET_ARCH_MIPS)),y)
# enable non-PIC for mips* targets
GCC_COMMON_CONFIGURE_OPTIONS += --with-mips-plt
endif
endif

ifndef TARGET_TOOLCHAIN_NO_MPFR
GCC_COMMON_CONFIGURE_OPTIONS += --disable-decimal-float

GCC_INITIAL_PREREQ += $(GMP_HOST_BINARY)   $(MPFR_HOST_BINARY)   $(MPC_HOST_BINARY)
GCC_TARGET_PREREQ  += $(GMP_TARGET_BINARY) $(MPFR_TARGET_BINARY) $(MPC_TARGET_BINARY)
GCC_WITH_HOST_GMP   = --with-gmp=$(HOST_TOOLS_DIR)
GCC_WITH_HOST_MPFR  = --with-mpfr=$(HOST_TOOLS_DIR)
GCC_WITH_HOST_MPC   = --with-mpc=$(HOST_TOOLS_DIR)
endif

# --with-isl is available since gcc-4.8.x, exclude all versions before
ifneq ($(or $(FREETZ_TARGET_GCC_4_6),$(FREETZ_TARGET_GCC_4_7)),y)
GCC_WITH_HOST_ISL   = --with-isl=no
endif

GCC_EXTRA_MAKE_OPTIONS := MAKEINFO=true

#
# s. https://git.buildroot.net/buildroot/commit/package/gcc/gcc.mk?id=a7463a6c8195314c870c3667a3971448e7fa4d39 for more details
#
GCC_HOST_COMMON_CONFIGURE_ENV += gcc_cv_libc_provides_ssp=$(if $(FREETZ_TARGET_UCLIBC_PROVIDES_SSP),yes,no)
GCC_EXTRA_MAKE_OPTIONS        += gcc_cv_libc_provides_ssp=$(if $(FREETZ_TARGET_UCLIBC_PROVIDES_SSP),yes,no)

GCC_LIB_SUBDIR=lib/gcc/$(REAL_GNU_TARGET_NAME)/$$(cat $(abspath $(GCC_DIR))/gcc/BASE-VER)
# This macro exists for the following reason:
#   uClibc depends on some gcc internal headers located under $(GCC_LIB_SUBDIR).
#   uClibc is compiled using gcc-initial, after that gcc-final (which depends on uClibc)
#   is compiled and installed into the same location as gcc-initial. The causes the headers
#   under $(GCC_LIB_SUBDIR) to be installed again, i.e. overwritten. The files are absolutely
#   identical they however get new timestamp, which causes uClibc to be recompiled, which
#   in turn causes gcc-final to be recompiled.
#   We workaround the problem by explicitly setting the timestamp of the headers to some fixed value.
# $1 - base dir (most of time $(TARGET_TOOLCHAIN_STAGING_DIR))
# $2 (optional) - timestamp to be used
define GCC_SET_HEADERS_TIMESTAMP
$(if $(strip $(1)),\
	if [ -d "$(strip $(1))/$(GCC_LIB_SUBDIR)" ] ; then \
		find $(strip $(1))/$(GCC_LIB_SUBDIR) -name "*.h" -type f -exec touch -t $(if $(strip $(2)),$(strip $(2)),200001010000.00) \{\} \+; \
	fi; \
)
endef

GCC_PATCHES_ROOT_DIR := $(GCC_MAKE_DIR)/patches/$(GCC_MAJOR_VERSION)
GCC_CONDITIONAL_PATCHES += $(if $(FREETZ_TARGET_GCC_DEFAULT_AS_NEEDED),default-as-needed)


gcc-source: $(DL_DIR)/$(GCC_SOURCE)
ifneq ($(strip $(DL_DIR)/$(GCC_SOURCE)), $(strip $(DL_DIR)/$(GCC_KERNEL_SOURCE)))
$(DL_DIR)/$(GCC_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(GCC_SOURCE) $(GCC_SITE) $(GCC_HASH) $(SILENT)
endif

gcc-unpacked: $(GCC_DIR)/.unpacked
$(GCC_DIR)/.unpacked: $(DL_DIR)/$(GCC_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE))
	$(RM) -r $(GCC_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GCC_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(GCC_PATCHES_ROOT_DIR) $(addprefix $(GCC_PATCHES_ROOT_DIR)/,$(strip $(GCC_CONDITIONAL_PATCHES))),$(GCC_DIR))
	for f in $$(find $(GCC_DIR) \( -name "configure" -o -name "config.rpath" \)); do $(call PKG_PREVENT_RPATH_HARDCODING1,$$f) done
	touch $@

gcc-autofix: gcc-dirclean
	$(MAKE) AUTO_FIX_PATCHES=y gcc-unpacked

##############################################################################
#
#   build the first pass gcc compiler
#
##############################################################################
GCC_BUILD_DIR1:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-initial

$(GCC_BUILD_DIR1)/.configured: $(GCC_DIR)/.unpacked $(GCC_INITIAL_PREREQ) | binutils target-toolchain-kernel-headers
	@$(call _ECHO,configuring,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage1)
	mkdir -p $(GCC_BUILD_DIR1)
	(cd $(GCC_BUILD_DIR1); $(RM) config.cache; \
		$(GCC_HOST_COMMON_CONFIGURE_ENV) \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_DEVEL_SYSROOT) \
		--with-newlib=yes \
		--with-headers=no \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c \
		--disable-shared \
		--disable-threads \
		$(GCC_WITH_HOST_GMP) \
		$(GCC_WITH_HOST_MPFR) \
		$(GCC_WITH_HOST_MPC) \
		$(GCC_WITH_HOST_ISL) \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
		$(SILENT) \
	);
	touch $@

$(GCC_BUILD_DIR1)/.compiled: $(GCC_BUILD_DIR1)/.configured
	@$(call _ECHO,building,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage1)
	PATH=$(TARGET_PATH) \
		$(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR1) all-gcc $(SILENT) \
		$(if $(GCC_BUILD_TARGET_LIBGCC),all-target-libgcc)
	touch $@

$(GCC_BUILD_DIR1)/.installed: $(GCC_BUILD_DIR1)/.compiled
	@$(call _ECHO,installing,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage1)
	PATH=$(TARGET_PATH) \
		$(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR1) install-gcc $(SILENT) \
		$(if $(GCC_BUILD_TARGET_LIBGCC),install-target-libgcc)
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	touch $@

gcc_initial-configured: $(GCC_BUILD_DIR1)/.configured

gcc_initial: binutils $(GCC_BUILD_DIR1)/.installed


gcc_initial-uninstall: gcc-uninstall

gcc_initial-clean: gcc_initial-uninstall
	$(RM) -r $(GCC_BUILD_DIR1)

gcc_initial-dirclean: gcc_initial-clean gcc-dirclean

gcc_initial-distclean: gcc_initial-dirclean


##############################################################################
#
# second pass compiler build. Build the compiler targeting
# the newly built shared uClibc library.
#
##############################################################################
GCC_BUILD_DIR2:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-final

$(GCC_BUILD_DIR2)/.configured: $(GCC_DIR)/.unpacked $(GCC_STAGING_PREREQ) | binutils
	@$(call _ECHO,configuring,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage2)
	mkdir -p $(GCC_BUILD_DIR2)
	# Important! Required for limits.h to be fixed.
	ln -sf ../include $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/sys-include
	(cd $(GCC_BUILD_DIR2); $(RM) config.cache; \
		$(GCC_HOST_COMMON_CONFIGURE_ENV) \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX-gcc-final-phase) \
		--with-sysroot=$(TARGET_TOOLCHAIN_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c,c++ \
		--enable-shared \
		--enable-threads \
		$(GCC_WITH_HOST_GMP) \
		$(GCC_WITH_HOST_MPFR) \
		$(GCC_WITH_HOST_MPC) \
		$(GCC_WITH_HOST_ISL) \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
		$(SILENT) \
	);
	touch $@

$(GCC_BUILD_DIR2)/.compiled: $(GCC_BUILD_DIR2)/.configured
	@$(call _ECHO,building,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage2)
	PATH=$(TARGET_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR2) all $(SILENT)
	touch $@

$(GCC_BUILD_DIR2)/.installed: $(GCC_BUILD_DIR2)/.compiled
	@$(call _ECHO,installing,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),stage2)
	PATH=$(TARGET_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR2) install $(SILENT)
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	# Link some files to make mklibs happy
	for i in libgcc_pic.a libgcc.map; do \
		ln -sf ../usr/$(GCC_LIB_SUBDIR)/$$i $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/; \
	done
	# strip libraries
	-(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* libgcc_s.so.1 libatomic.so.*.*.* >/dev/null 2>&1)
	# remove broken *.la* files (invalid checkout directory with dl-toolchains)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/*.la*
	# Remove libiberty.a which may be in wrong format (host instead of target) for old GCC versions
	# This prevents libtool relink errors in packages like binutils-tools with armeb gcc-4.7.4
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib{,64}/libiberty*
	# set up the symlinks to enable lying about target name
	ln -snf $(REAL_GNU_TARGET_NAME) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))
	touch $@

gcc-configured: $(GCC_BUILD_DIR2)/.configured

gcc: uclibc-configured binutils gcc_initial uclibc $(GCC_BUILD_DIR2)/.installed


gcc-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/{lib,libexec}/gcc

gcc-clean: gcc-uninstall
	$(RM) -r $(GCC_BUILD_DIR2)

gcc-dirclean: gcc-clean
	$(RM) -r $(GCC_DIR)

gcc-distclean: gcc-dirclean


#############################################################
#
# Next build target gcc compiler
#
#############################################################
GCC_BUILD_DIR3:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-target

$(GCC_BUILD_DIR3)/.configured: $(GCC_BUILD_DIR2)/.installed $(GCC_TARGET_PREREQ) | binutils_target
	@$(call _ECHO,configuring,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),target)
	mkdir -p $(GCC_BUILD_DIR3)
	(cd $(GCC_BUILD_DIR3); $(RM) config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		CONFIG_SITE=$(TARGET_SITE) \
		\
		CXX="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)g++" \
		\
		CFLAGS="" \
		CXXFLAGS="" \
		CC_FOR_BUILD="gcc" \
		CXX_FOR_BUILD="g++" \
		CFLAGS_FOR_BUILD="$(GCC_CFLAGS) -O2 -I$(HOST_TOOLS_DIR)/include" \
		CXXFLAGS_FOR_BUILD="$(GCC_CXXFLAGS) -O2 -I$(HOST_TOOLS_DIR)/include" \
		LDFLAGS_FOR_BUILD="-L$(HOST_TOOLS_DIR)/lib" \
		\
		$(GCC_DIR)/configure \
		--prefix=/usr \
		--with-gxx-include-dir=/usr/include/c++ \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c,c++ \
		--enable-shared \
		--enable-threads \
		--disable-libstdcxx-pch \
		--disable-libcc1 \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
		$(SILENT) \
	);
	touch $@

$(GCC_BUILD_DIR3)/.compiled: $(GCC_BUILD_DIR3)/.configured
	@$(call _ECHO,building,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),target)
	# Force serial build (-j1) to avoid race conditions in toolchain dependencies
	# uClibc header generation requires cross-compiler to be fully built first
	$(MAKE_ENV) CFLAGS= CXXFLAGS= $(MAKE) -j1 $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR3) all $(SILENT)
	touch $@

GCC_INCLUDE_DIR:=include-fixed

$(TARGET_UTILS_DIR)/usr/bin/gcc: $(GCC_BUILD_DIR3)/.compiled
	@$(call _ECHO,installing,$(GCC_ECHO_TYPE),$(GCC_ECHO_MAKE),target)
	$(MAKE_ENV) $(MAKE1) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR3) DESTDIR=$(TARGET_UTILS_DIR) install
	$(call GCC_INSTALL_COMMON,$(TARGET_UTILS_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))
	# strip libraries
	-(cd $(TARGET_UTILS_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* libgcc_s.so.1 libatomic.so.*.*.* >/dev/null 2>&1)
	# remove broken specs file (cross compile flag is set) and *.la* files
	$(RM) $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/specs $(TARGET_UTILS_DIR)/usr/lib/*.la*
	# work around problem of missing syslimits.h
	if [ ! -f $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/$(GCC_INCLUDE_DIR)/syslimits.h ]; then \
		echo "warning: working around missing syslimits.h"; \
		cp -f $(TARGET_TOOLCHAIN_STAGING_DIR)/$(GCC_LIB_SUBDIR)/include/syslimits.h \
			$(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/$(GCC_INCLUDE_DIR)/; \
	fi
	touch -c $@

gcc_target-configured: $(GCC_BUILD_DIR3)/.configured

gcc_target: uclibc_target binutils_target $(TARGET_UTILS_DIR)/usr/bin/gcc


gcc_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) -r $(TARGET_UTILS_DIR)/usr/{lib,libexec}/gcc

gcc_target-clean: gcc_target-uninstall
	$(RM) -r $(GCC_BUILD_DIR3)

gcc_target-dirclean: gcc_target-clean gcc-dirclean

gcc_target-distclean: gcc_target-dirclean


.PHONY: gcc-source gcc-unpacked gcc-autofix
.PHONY: gcc_initial gcc_initial-configured gcc_initial-uninstall gcc_initial-clean gcc_initial-dirclean gcc_initial-distclean
.PHONY: gcc         gcc-configured         gcc-uninstall         gcc-clean         gcc-dirclean         gcc-distclean
.PHONY: gcc_target  gcc_target-configured  gcc_target-uninstall  gcc_target-clean  gcc_target-dirclean  gcc_target-distclean

