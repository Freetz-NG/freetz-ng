$(call PKG_INIT_BIN,$(if $(FREETZ_BUSYBOX__VERSION_V127),1.27.2,$(if $(FREETZ_BUSYBOX__VERSION_V134),1.34.1,1.35.0)))
#$(call PKG_INIT_BIN,$(if $(FREETZ_BUSYBOX__VERSION_V127),1.27.2,1.34.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256_1.27.2:=9d4be516b61e6480f156b11eb42577a13529f75d3383850bb75c50c285de63df
$(PKG)_SOURCE_SHA256_1.34.1:=415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549
$(PKG)_SOURCE_SHA256_1.35.0:=faeeb244c35a348a334f4a59e44626ee870fb07b6884d68c10ae8bc19f83a694
$(PKG)_SOURCE_SHA256:=$($(PKG)_SOURCE_SHA256_$($(PKG)_VERSION))
$(PKG)_SITE:=https://www.busybox.net/downloads

$(PKG)_REBUILD_SUBOPTS += FREETZ_BUSYBOX__VERSION_STRING
$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION_MAJOR
$(PKG)_CONDITIONAL_PATCHES += $(call GET_MAJOR_VERSION,$($(PKG)_VERSION))/$(KERNEL_VERSION_MAJOR)

$(PKG)_REBUILD_SUBOPTS += FREETZ_BUSYBOX__BUILD_TIMESTAMP
ifneq ($(strip $(FREETZ_BUSYBOX__BUILD_TIMESTAMP)),y)
$(PKG)_CONDITIONAL_PATCHES += $(call GET_MAJOR_VERSION,$($(PKG)_VERSION))/no_build_timestamp
endif

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)

$(PKG)_TARGET_DIR:=$(subst -$($(PKG)_VERSION),,$($(PKG)_TARGET_DIR))
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg)

$(PKG)_MAKE_FLAGS += CC="$(TARGET_CC)"
$(PKG)_MAKE_FLAGS += CROSS_COMPILE="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)"
$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_FLAGS += ARCH="$(TARGET_ARCH)"

include $(MAKE_DIR)/busybox/busybox.rebuild-subopts.mk.in

ifneq ($(strip $(DL_DIR)/$(BUSYBOX_SOURCE)), $(strip $(DL_DIR)/$(BUSYBOX_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	@cat $(TOPDIR)/.config \
		| sed -nr 's!^(# )*(FREETZ_BUSYBOX___V[0-9]{3}_)([^_].*)!\1CONFIG_\3!p' \
		> $(BUSYBOX_DIR)/.config ;\
	for bbsym in $$(sed -rn 's/^depends_on ([^ ]+) .*/\1/p' "$(BUSYBOX_MAKE_DIR)/generate.sh"); do \
		if ! grep -qE "(# )?CONFIG_$$bbsym[= ]" "$(BUSYBOX_DIR)/.config"; then \
			echo "# CONFIG_$$bbsym is not set" >> $(BUSYBOX_DIR)/.config ;\
		fi ;\
	done ;\
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BUSYBOX_DIR) \
		$(BUSYBOX_MAKE_FLAGS)

$($(PKG)_BINARY).links: $($(PKG)_BINARY)
	$(SUBMAKE) -C $(BUSYBOX_DIR) \
		$(BUSYBOX_MAKE_FLAGS) \
		busybox.links
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY).links: $($(PKG)_BINARY).links
	cat $(BUSYBOX_BINARY).links | sed -r -e 's,/($(if $(FREETZ_PACKAGE_BASH),bash|)$(if $(FREETZ_AVM_HAS_REBOOT_SCRIPT),reboot|)$(if $(FREETZ_AVM_HAS_IP_BINARY),ip|)blkid|wget)$$,/\1-busybox,g' > $(BUSYBOX_TARGET_BINARY).links

$(pkg)-precompiled: uclibc $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_BINARY).links

$(pkg)-clean: $(pkg)-uninstall
	-$(SUBMAKE) -C $(BUSYBOX_DIR) $(BUSYBOX_MAKE_FLAGS) clean

$(pkg)-uninstall:
	$(RM) $(BUSYBOX_TARGET_BINARY) $(BUSYBOX_TARGET_BINARY).links

$(PKG_FINISH)
