LIBTOOL_STAGING_VERSION:=1.5.26
LIBTOOL_STAGING_SOURCE:=libtool-$(LIBTOOL_STAGING_VERSION).tar.gz
LIBTOOL_STAGING_HASH:=1c35ae34fe85aa167bd7ab4bc9f477fe019138e1af62678d952fc43c0b7e2f09
LIBTOOL_STAGING_SITE:=@GNU/libtool

LIBTOOL_STAGING_DIR:=$(TARGET_TOOLCHAIN_DIR)/libtool-$(LIBTOOL_STAGING_VERSION)
LIBTOOL_STAGING_MAKE_DIR:=$(MAKE_DIR)/toolchain/target/libtool-staging
LIBTOOL_STAGING_SCRIPT:=$(LIBTOOL_STAGING_DIR)/libtool
LIBTOOL_STAGING_TARGET_SCRIPT:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtool

GLOBAL_LIBDIR=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib

LIBTOOL_STAGING_ECHO_TYPE:=TTC
LIBTOOL_STAGING_ECHO_MAKE:=libtool


libtool-staging-source: $(DL_DIR)/$(LIBTOOL_STAGING_SOURCE)
ifneq ($(strip $(DL_DIR)/$(LIBTOOL_STAGING_SOURCE)), $(strip $(DL_DIR)/$(LIBTOOL_SOURCE)))
$(DL_DIR)/$(LIBTOOL_STAGING_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(LIBTOOL_STAGING_ECHO_TYPE),$(LIBTOOL_STAGING_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(LIBTOOL_STAGING_SOURCE) $(LIBTOOL_STAGING_SITE) $(LIBTOOL_STAGING_HASH) $(SILENT)
endif

libtool-staging-unpacked: $(LIBTOOL_STAGING_DIR)/.unpacked
$(LIBTOOL_STAGING_DIR)/.unpacked: $(DL_DIR)/$(LIBTOOL_STAGING_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(LIBTOOL_STAGING_ECHO_TYPE),$(LIBTOOL_STAGING_ECHO_MAKE))
	$(RM) -r $(LIBTOOL_STAGING_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(LIBTOOL_STAGING_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(LIBTOOL_STAGING_MAKE_DIR)/patches,$(LIBTOOL_STAGING_DIR))
# touch some patched files to ensure no file except for ltmain.sh gets regenerated
	for i in $$(find $(LIBTOOL_STAGING_DIR) -type f \( \( -name "*.m4" -o -name "*.am" \) -a ! -name "aclocal.m4" \)); do \
		touch -t 200001010000.00 $$i; \
	done; \
	touch $@

libtool-staging-configured: $(LIBTOOL_STAGING_DIR)/.configured
$(LIBTOOL_STAGING_DIR)/.configured: $(LIBTOOL_STAGING_DIR)/.unpacked | $(TARGET_CXX_CROSS_COMPILER_SYMLINK_TIMESTAMP)
	@$(call _ECHO,configuring,$(LIBTOOL_STAGING_ECHO_TYPE),$(LIBTOOL_STAGING_ECHO_MAKE))
	(cd $(LIBTOOL_STAGING_DIR); $(RM) config.cache; \
		CC=$(TARGET_CC) \
		CXX=$(TARGET_CXX) \
		CFLAGS="$(TARGET_CFLAGS)" \
		PATH=$(TARGET_PATH) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--prefix=/usr \
		--disable-ltdl-install \
		--enable-shared \
		--enable-static \
		--disable-nls \
		$(SILENT) \
	);
	touch $@

$(LIBTOOL_STAGING_SCRIPT): $(LIBTOOL_STAGING_DIR)/.configured
	@$(call _ECHO,building,$(LIBTOOL_STAGING_ECHO_TYPE),$(LIBTOOL_STAGING_ECHO_MAKE))
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBTOOL_STAGING_DIR) \
		GLOBAL_LIBDIR=$(GLOBAL_LIBDIR) \
		all $(SILENT)
	touch -c $@

$(LIBTOOL_STAGING_TARGET_SCRIPT): $(LIBTOOL_STAGING_SCRIPT)
	@$(call _ECHO,installing,$(LIBTOOL_STAGING_ECHO_TYPE),$(LIBTOOL_STAGING_ECHO_MAKE))
	$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		MAKEINFO=true \
		-C $(LIBTOOL_STAGING_DIR) \
		install $(SILENT)
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))

libtool-staging: $(LIBTOOL_STAGING_TARGET_SCRIPT) | $(STDCXXLIB)


libtool-staging-clean:
	-$(MAKE) -C $(LIBTOOL_STAGING_DIR) clean

libtool-staging-dirclean:
	$(RM) -r \
		$(LIBTOOL_STAGING_DIR) \
		$(LIBTOOL_STAGING_TARGET_SCRIPT) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libtoolize \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/libtool.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/ltdl.m4 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/libtool/

libtool-staging-distclean: libtool-staging-dirclean


.PHONY: libtool-staging libtool-staging-source libtool-staging-unpacked
.PHONY: libtool-staging-clean libtool-staging-dirclean libtool-staging-distclean

