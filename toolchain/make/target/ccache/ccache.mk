CCACHE_VERSION:=4.6
CCACHE_SOURCE:=ccache-$(CCACHE_VERSION).tar.xz
CCACHE_SHA256:=3d2bb860f4359169e640f60cf7cc11da5fab5fb9aed55230d78141e49c3945e9
CCACHE_SITE:=https://github.com/ccache/ccache/releases/download/v$(CCACHE_VERSION)

CCACHE_DIR:=$(TARGET_TOOLCHAIN_DIR)/ccache-$(CCACHE_VERSION)
CCACHE_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/ccache
CCACHE_BINARY:=ccache
CCACHE_TARGET_BINARY:=usr/bin/ccache

CCACHE_BIN_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache


ccache-source: $(DL_DIR)/$(CCACHE_SOURCE)
ifneq ($(strip $(DL_DIR)/$(CCACHE_SOURCE)), $(strip $(DL_DIR)/$(CCACHE_KERNEL_SOURCE)))
$(DL_DIR)/$(CCACHE_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(CCACHE_SOURCE) $(CCACHE_SITE) $(CCACHE_SHA256)
endif

ccache-unpacked: $(CCACHE_DIR)/.unpacked
$(CCACHE_DIR)/.unpacked: $(DL_DIR)/$(CCACHE_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(CCACHE_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(CCACHE_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	#$(call APPLY_PATCHES,$(CCACHE_MAKE_DIR)/patches,$(CCACHE_DIR))
	# WARNING - this will break if the toolchain is moved.
	# Should probably patch things to use a relative path.
	$(SED) -i 's,ctx.config.path(),"$(CCACHE_BIN_DIR)",' $(CCACHE_DIR)/src/execute.cpp
	touch $@

$(CCACHE_DIR)/.configured: $(CCACHE_DIR)/.unpacked
	(cd $(CCACHE_DIR); $(RM) CMakeCache.txt; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CXX="$(TOOLCHAIN_HOSTCXX)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		CXXFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		cmake . \
		-DCMAKE_C_COMPILER_TARGET=$(GNU_HOST_NAME) \
		-DCMAKE_CXX_COMPILER_TARGET=$(GNU_HOST_NAME) \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DENABLE_DOCUMENTATION=OFF \
		-DENABLE_TESTING=OFF \
		-DREDIS_STORAGE_BACKEND=OFF \
		$(QUIETCMAKE) \
	);
	touch $@

$(CCACHE_DIR)/$(CCACHE_BINARY): $(CCACHE_DIR)/.configured
	$(MAKE) -C $(CCACHE_DIR)

$(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY): $(CCACHE_DIR)/$(CCACHE_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin
	cp $(CCACHE_DIR)/$(CCACHE_BINARY) $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
	# Keep the actual toolchain binaries in a directory at the same level.
	# Otherwise, relative paths for include dirs break.
	mkdir -p $(CCACHE_BIN_DIR)
	for i in gcc g++; do \
		[ -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i -a \
			! -h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i ] && \
			mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i $(CCACHE_BIN_DIR)/ || true; \
	done
	( cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; \
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-gcc; \
		ln -fs ccache $(REAL_GNU_TARGET_NAME)-g++; \
	)
	( cd $(CCACHE_BIN_DIR); \
		ln -fs $(REAL_GNU_TARGET_NAME)-gcc $(REAL_GNU_TARGET_NAME)-cc; \
		ln -fs $(REAL_GNU_TARGET_NAME)-g++ $(REAL_GNU_TARGET_NAME)-c++; \
		for i in gcc g++ cc c++; do \
			ln -fs $(REAL_GNU_TARGET_NAME)-$$i $(GNU_TARGET_NAME)-$$i; \
		done; \
	)

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
ccache: gcc $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
else
ccache: $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
endif


ccache-clean:
	for i in gcc g++; do \
		if [ -f $(CCACHE_BIN_DIR)/$(REAL_GNU_TARGET_NAME)-$$i ] ; then \
			$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-$$i; \
			mv $(CCACHE_BIN_DIR)/$(REAL_GNU_TARGET_NAME)-$$i $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/; \
		fi; \
	done
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin-ccache
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/$(CCACHE_TARGET_BINARY)
	-$(MAKE) -C $(CCACHE_DIR) clean

ccache-dirclean: ccache-clean
	$(RM) -r $(CCACHE_DIR)

.PHONY: ccache ccache-source ccache-unpacked ccache-clean ccache-dirclean

