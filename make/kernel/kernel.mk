KERNEL_MAKE_DIR:=$(MAKE_DIR)/kernel
KERNEL_PATCHES_DIR:=$(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)$(SYSTEM_TYPE_CORE_SUFFIX)

KERNEL_DEPENDS_ON += lzma1-host
KERNEL_DEPENDS_ON += lzma2eva-host

ifeq ($(strip $(FREETZ_KERNEL_VERSION_2)),y)
KERNEL_MAKE_TARGET:=vmlinux.eva_pad
KERNEL_IMAGE_FILE:=vmlinux.eva_pad
else
ifeq ($(strip $(FREETZ_KERNEL_VERSION_3)),y)
KERNEL_MAKE_TARGET:=vmlinux.eva_pad
KERNEL_IMAGE_FILE:=arch/$(KERNEL_ARCH)/boot/vmlinux.eva_pad
else
ifeq ($(strip $(FREETZ_KERNEL_VERSION_4)),y)
#TODO!
KERNEL_MAKE_TARGET:=vmlinux.eva_pad
KERNEL_IMAGE_FILE:=arch/$(KERNEL_ARCH)/boot/vmlinux.eva_pad
else
KERNEL_MAKE_TARGET:=vmlinux.lzma
KERNEL_IMAGE_FILE:=vmlinux.lzma
endif
endif
endif
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_ID).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/configs/freetz/config-$(KERNEL_ID)

KERNEL_COMMON_MAKE_OPTIONS := -C $(KERNEL_SOURCE_DIR)
KERNEL_COMMON_MAKE_OPTIONS += CROSS_COMPILE="$(KERNEL_CROSS)"
ifeq ($(strip $(FREETZ_TOOLCHAIN_CCACHE)),y)
KERNEL_COMMON_MAKE_OPTIONS += KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(KERNEL_CCACHE_PATH):$(PATH)"
else
KERNEL_COMMON_MAKE_OPTIONS += KERNEL_MAKE_PATH="$(KERNEL_CCACHE_PATH):$(KERNEL_MAKE_PATH):$(PATH)"
endif
KERNEL_COMMON_MAKE_OPTIONS += ARCH="$(KERNEL_ARCH)"
KERNEL_COMMON_MAKE_OPTIONS += INSTALL_HDR_PATH=$(KERNEL_HEADERS_DEVEL_DIR)
KERNEL_COMMON_MAKE_OPTIONS += INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_DIR)"
ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
KERNEL_COMMON_MAKE_OPTIONS += V=1
endif

KERNEL_VANILLA_SOURCE:=$(call qstrip,$(FREETZ_DL_KERNEL_VANILLA_SOURCE))
KERNEL_VANILLA_HASH:=$(call qstrip,$(FREETZ_DL_KERNEL_VANILLA_HASH))
KERNEL_VANILLA_SITE:=@KERNEL/linux/kernel/v$(call qstrip,$(FREETZ_KERNEL_VANILLA_DLDIR))

KERNEL_AVMDIFF_SOURCE:=$(call qstrip,$(FREETZ_DL_KERNEL_AVMDIFF_SOURCE))
KERNEL_AVMDIFF_HASH:=$(call qstrip,$(FREETZ_DL_KERNEL_AVMDIFF_HASH))
KERNEL_AVMDIFF_SITE:=@MIRROR/

KERNEL_ECHO_TYPE:=KRN


$(DL_DIR)/$(KERNEL_VANILLA_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(KERNEL_ECHO_TYPE))
	$(DL_TOOL) $(DL_DIR) $(KERNEL_VANILLA_SOURCE) $(KERNEL_VANILLA_SITE) $(KERNEL_VANILLA_HASH) $(SILENT)

$(DL_DIR)/$(KERNEL_AVMDIFF_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(KERNEL_ECHO_TYPE))
	$(DL_TOOL) $(DL_DIR) $(KERNEL_AVMDIFF_SOURCE) $(KERNEL_AVMDIFF_SITE) $(KERNEL_AVMDIFF_HASH) $(SILENT)

# Make sure that a perfectly clean build is performed whenever Freetz package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
kernel-unpacked: $(KERNEL_DIR)/.unpacked
$(KERNEL_DIR)/.unpacked: $(DL_DIR)/$(KERNEL_VANILLA_SOURCE) $(if $(FREETZ_KERNEL_AVMDIFF_AVAILABLE),$(DL_DIR)/$(KERNEL_AVMDIFF_SOURCE)) | $(UNPACK_TARBALL_PREREQUISITES) gcc-kernel
	@echo "Using kernel version: $(call qstrip,$(FREETZ_KERNEL_VERSION))" $(SILENT)
	$(RM) -r $(KERNEL_DIR)
	mkdir -p $(KERNEL_SOURCE_DIR)
	@$(call _ECHO,preparing,$(KERNEL_ECHO_TYPE))
	@$(call UNPACK_TARBALL,$(DL_DIR)/$(KERNEL_VANILLA_SOURCE),$(KERNEL_SOURCE_DIR),1)
	@$(call _ECHO,patching,$(KERNEL_ECHO_TYPE))
	@echo "" $(SILENT)
ifeq ($(strip $(FREETZ_KERNEL_AVMDIFF_AVAILABLE)),y)
	@echo "#vanilla to avm patch: $(DL_DIR)/$(KERNEL_AVMDIFF_SOURCE)" $(SILENT)
	@$(call APPLY_PATCHES,$(DL_DIR),$(KERNEL_SOURCE_DIR),$(KERNEL_AVMDIFF_SOURCE),/dev/null)
	@echo "#vanilla to avm fixes" $(SILENT)
	@find $(KERNEL_SOURCE_DIR) -type l -exec rm -f {} ';'
	@$(TOOLS_DIR)/unxz $(DL_DIR)/$(KERNEL_AVMDIFF_SOURCE) -c | grep -E '^    #FREETZ# (mkdir|chmod|slink|touch) .*' | while read x a b c; do \
	  [ "$$a" != "mkdir" ] && [ "$$b" != "$${b%/*}" ] && mkdir -p    "$(KERNEL_SOURCE_DIR)/$${b%/*}"; \
	  [ "$$a" == "mkdir" ] && mkdir -p    "$(KERNEL_SOURCE_DIR)/$${b}"; \
	  [ "$$a" == "chmod" ] && touch       "$(KERNEL_SOURCE_DIR)/$${b}"; \
	  [ "$$a" == "chmod" ] && chmod +x    "$(KERNEL_SOURCE_DIR)/$${b}"; \
	  [ "$$a" == "slink" ] && ln -s "$$c" "$(KERNEL_SOURCE_DIR)/$${b}"; \
	  [ "$$a" == "touch" ] && touch       "$(KERNEL_SOURCE_DIR)/$${b}"; \
	done $(SILENT) || true
endif
	@if [ -e "$(KERNEL_SOURCE_DIR)/scripts/kconfig/lxdialog/check-lxdialog.sh" ]; then \
		echo "#fixing ncurses detection bug" $(SILENT); \
		$(SED) 's/^main()/int &/' -i $(KERNEL_SOURCE_DIR)/scripts/kconfig/lxdialog/check-lxdialog.sh; \
	fi;
	@echo "#fixing hardcoded depmod path" $(SILENT); \
	find $(KERNEL_SOURCE_DIR)/ -name Makefile | while read -r file; do \
		grep -q '/sbin/depmod' "$${file}" || continue; \
		echo "# - $${file}" $(SILENT); \
		$(SED) 's,/sbin/depmod,depmod,g' -i "$${file}"; \
	done;
	@echo "#applying patches" $(SILENT)
	@echo "##kernel version specific patches dir: $(KERNEL_PATCHES_DIR)" $(SILENT)
	@echo "##firmware version specific patches dir: $(KERNEL_PATCHES_DIR)/$(AVM_SOURCE_ID)" $(SILENT)
	@$(call APPLY_PATCHES,$(KERNEL_PATCHES_DIR) $(KERNEL_PATCHES_DIR)/$(AVM_SOURCE_ID),$(KERNEL_DIR))
	@echo "#additional generic fixes" $(SILENT)
	@for i in $(KERNEL_LINKING_FILES); do \
		f="$${i%%,*}"; symlink_location="$${i##*,}"; \
		if [ -e "$(KERNEL_SOURCE_DIR)/$${f}" ] && [ -d "$(KERNEL_SOURCE_DIR)/$$(dirname $${symlink_location})" ]; then \
			 symlink_target="$$(dirname $${symlink_location} | sed -r -e 's,([^/]+),..,g')/$$f"; \
			if [ -h "$(KERNEL_SOURCE_DIR)/$${symlink_location}" ]; then \
				if \
					[ "$$(readlink "$(KERNEL_SOURCE_DIR)/$${symlink_location}")" != "$${symlink_target}" ] \
					&& \
					[ "$$(readlink -f "$(KERNEL_SOURCE_DIR)/$${symlink_location}")" != "$(abspath $(KERNEL_SOURCE_DIR))/$${f}" ] \
				; then \
					$(call MESSAGE, Warning: Symlink \"$(KERNEL_SOURCE_DIR)/$${symlink_location}\" doesn't point to expected \"$${symlink_target}\"); \
					if [ "$$(readlink "$(KERNEL_SOURCE_DIR)/$${symlink_location}" | sed 's/^\/.*/X/')" == "X" ]; then \
						$(call MESSAGE, Deleting \"$(KERNEL_SOURCE_DIR)/$${symlink_location}\" --> $$(readlink "$(KERNEL_SOURCE_DIR)/$${symlink_location}")); \
						$(RM) "$(KERNEL_SOURCE_DIR)/$${symlink_location}"; \
					else \
						continue; \
					fi; \
				else \
					continue; \
				fi; \
			fi; \
			\
			if [ -e "$(KERNEL_SOURCE_DIR)/$${symlink_location}" ]; then \
				$(call MESSAGE, Warning: \"$(KERNEL_SOURCE_DIR)/$${symlink_location}\" is expected to be a symlink to \"$${symlink_target}\"); \
				continue; \
			fi; \
			\
			$(call MESSAGE, Linking  \"$(KERNEL_SOURCE_DIR)/$${symlink_location}\" to \"$${symlink_target}\"); \
			ln -sf "$${symlink_target}" "$(KERNEL_SOURCE_DIR)/$${symlink_location}"; \
		fi; \
	done;
	@for i in $$(find $(KERNEL_SOURCE_DIR) -name Makefile.26 -printf '%h\n'); do \
		if [ ! -e $$i/Makefile ]; then \
			$(call MESSAGE, Linking  \"$$i/Makefile\" to \"Makefile.26\"); \
			ln -sf Makefile.26 $$i/Makefile; \
		fi; \
	done;
	@for i in $$( \
		find $(KERNEL_SOURCE_DIR) -name Makefile -xtype f -exec \
		awk '/^[ \t]*(obj|subdir)-.*=/ && !/(obj|subdir)-ccflags.*=/ { \
			while (match ($$0,/\\/)) {sub(/\\/," "); getline l;$$0=$$0""l} \
			sub(/\r/,""); \
			gsub(/(#.*|.*=)/,""); \
			if (! match ($$0,/,/)) { \
				dirname=substr(FILENAME,1,length(FILENAME)-8); \
				for (i=1;i<=NF;i++) { \
					if (match ($$i,/\.(o|lds)[)]?$$|\$$/)) { \
						$$i=""; \
					} else if (substr($$i,length($$i))!="/") { \
						$$i=$$i"/"; \
					} \
					if ($$i!="") { \
						if (system("test -e "dirname""$$i"Makefile")) { \
							print dirname""$$i"Makefile"; \
						} \
					} \
				} \
			} \
		}' {} '+' \
		| sort -u \
	); do \
		$(call MESSAGE, Creating \"$$i\"); \
		mkdir -p $$(dirname "$$i"); \
		[ -h $$i ] && $(RM) $$i; \
		touch $$i; \
	done;
	@for i in $$( \
		find $(KERNEL_SOURCE_DIR) -name Kconfig -exec grep -hs "source.*Kconfig" {} '+' \
		| sed -e 's/\(.*\)#.*/\1/g;s/.*source //g;s/"//g' \
		| sort -u \
	); do \
		if [ ! -e $(KERNEL_SOURCE_DIR)/$$i ]; then \
			$(call MESSAGE, Creating \"$(KERNEL_SOURCE_DIR)/$$i\"); \
			mkdir -p $(KERNEL_SOURCE_DIR)/$${i%\/*}; \
			[ -h $(KERNEL_SOURCE_DIR)/$$i ] && $(RM) $(KERNEL_SOURCE_DIR)/$$i; \
			touch $(KERNEL_SOURCE_DIR)/$$i; \
		fi; \
	done; \
	ln -s linux-$(KERNEL_VERSION_MAJOR) $(KERNEL_DIR)/linux
	touch $@

kernel-configured-gen: $(KERNEL_DIR)/.configured
kernel-configured-del:
	-rm -f $(KERNEL_DIR)/.configured
kernel-configured-rebuild: kernel-configured-del kernel-configured-gen
.PHONY: kernel-configured-gen kernel-configured-del kernel-configured-rebuild

ifeq ($(strip $(FREETZ_MODULES_KOON)),y)
# Force kernel rebuild if the user changed the selected modules in freetz-config and they should be automatically be enable in kernel-config.
$(shell grep '^FREETZ_MODULE_' $(TOPDIR)/.config | diff -du --label "old" --label "new" "$(KERNEL_DIR)/.configured" - >/dev/null 2>&1 || $(RM) "$(KERNEL_DIR)/.configured" >/dev/null 2>&1)
endif

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	$(call _ECHO,configuring,$(KERNEL_ECHO_TYPE))
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_SOURCE_DIR)/.config
	[ "$(FREETZ_MODULES_KOON)" != "y" -o "${AUTO_FIX_PATCHES}" == "y" ] || $(TOOLS_DIR)/kernel_modules_koon "$(KERNEL_SOURCE_DIR)" $(SILENT)
ifeq ($(strip $(FREETZ_KERNEL_VERSION_2_MAX)),y)
	yes '' | make $(KERNEL_COMMON_MAKE_OPTIONS) oldconfig >/dev/null $(SILENT)
else
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) olddefconfig $(SILENT)
endif
	@cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE) && grep '^FREETZ_MODULE_' $(TOPDIR)/.config > $@ || true

$(KERNEL_DIR)/.prepared: $(KERNEL_DIR)/.configured
	@$(call _ECHO,preparing,$(KERNEL_ECHO_TYPE))
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) prepare
	touch $@

$(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h: $(KERNEL_DIR)/.prepared
	$(call _ECHO,headers,$(KERNEL_ECHO_TYPE))
ifeq ($(strip $(FREETZ_KERNEL_VERSION_2_6_13)),y)
	$(call COPY_KERNEL_HEADERS,$(KERNEL_SOURCE_DIR),$(KERNEL_HEADERS_DEVEL_DIR),{asm$(_comma)asm-generic$(_comma)linux$(_comma)mtd$(_comma)scsi$(_comma)video})
else
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) headers_install
	find "$(KERNEL_HEADERS_DEVEL_DIR)" \( -name "..install.cmd" -o -name ".install" \) -exec rm -f \{\} \+
endif
	touch $@

target-toolchain-kernel-headers: $(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER)
$(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER): $(TOPDIR)/.config $(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h | $(if $(FREETZ_BUILD_TOOLCHAIN),$(TARGET_TOOLCHAIN_STAGING_DIR),$(TARGET_CROSS_COMPILER))
	@$(call COPY_KERNEL_HEADERS,$(KERNEL_HEADERS_DEVEL_DIR),$(TARGET_TOOLCHAIN_STAGING_DIR)/usr)
	@touch $@


ifeq ($(strip $(FREETZ_AVM_KERNEL_CONFIG_AREA_KNOWN)),y)
KERNEL_BUILD_DEPENDENCIES += $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S

DL_SOURCE_ID=$(shell echo $(DL_SOURCE_LOCAL) | md5sum | sed 's/ .*//')

$(AVM_KERNEL_CONFIG_DIR): | $(KERNEL_DIR)/.unpacked
	@mkdir -p $@

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).bin: $(DL_FW_DIR)/$(DL_SOURCE_LOCAL) | $(KERNEL_DIR)/.unpacked $(AVM_KERNEL_CONFIG_DIR) tools
	@$(TOOLS_DIR)/avm_kernel_config.extract.sh -s $(FREETZ_AVM_KERNEL_CONFIG_AREA_SIZE) "$<" > "$@" || { $(RM) "$@"; exit 1; }

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).bin | $(KERNEL_DIR)/.unpacked $(AVM_KERNEL_CONFIG_DIR) tools
	@$(TOOLS_DIR)/avm_kernel_config.bin2asm "$<" >"$@" || { $(RM) "$@"; exit 1; }

# Force kernel rebuild if avm_kernel_config_area.S differs from avm_kernel_config_area.$(DL_SOURCE_ID).S
# To reduce maintenance effort we often use the same opensrc package for different boxes.
# avm_kernel_config_area is however box/firmware-release specific, i.e. the kernel must be rebuilt
# if BOX_ID changes even though the opensrc package might still be the same.
$(shell diff -q "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S" "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S" >/dev/null 2>&1 || $(RM) "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S" >/dev/null 2>&1)

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S
	@cat "$<" >"$@"

.PHONY: avm_kernel_config
avm_kernel_config: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S
endif


kernel-autofix: kernel-dirclean
	$(MAKE) AUTO_FIX_PATCHES=y $(KERNEL_DIR)/.configured
kernel-recompile: kernel-distclean kernel-precompiled
.PHONY: kernel-autofix kernel-recompile

$(KERNEL_SOURCE_DIR)/$(KERNEL_IMAGE_FILE): $(KERNEL_DIR)/.prepared $(KERNEL_BUILD_DEPENDENCIES) | $(KERNEL_DEPENDS_ON)
	$(call _ECHO,image,$(KERNEL_ECHO_TYPE))
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) $(KERNEL_MAKE_TARGET)
	touch -c $@

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_SOURCE_DIR)/$(KERNEL_IMAGE_FILE) | $(KERNEL_TARGET_DIR)
	cp $(KERNEL_SOURCE_DIR)/$(KERNEL_IMAGE_FILE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp $(KERNEL_SOURCE_DIR)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_ID).map
	touch -c $@

$(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX): $(KERNEL_SOURCE_DIR)/$(KERNEL_IMAGE_FILE)
	@$(call _ECHO,modules,$(KERNEL_ECHO_TYPE))
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) modules
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX): $(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX)
	$(RM) -r $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	$(call COPY_USING_TAR,$(KERNEL_DIR)/lib/modules/$(call qstrip,$(FREETZ_KERNEL_VERSION_MODULES_SUBDIR))/kernel,$(KERNEL_MODULES_DIR))
	touch $@

kernel-precompiled: clear-echo-temporary $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX)
	@$(call _ECHO_DONE)

kernel-configured: $(KERNEL_DIR)/.prepared

kernel-modules: $(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX)

kernel-help: $(KERNEL_DIR)/.unpacked
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) help

kernel-menuconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) menuconfig
	-cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $<

kernel-xconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) xconfig
	-cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $<

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $<

kernel-olddefconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $<

kernel-source: $(KERNEL_DIR)/.unpacked


kernel-clean:
	-$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) clean

kernel-mrproper:
	-cp -f $(KERNEL_SOURCE_DIR)/.config $(KERNEL_CONFIG_FILE)
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) mrproper
	-cp -f $(KERNEL_CONFIG_FILE) $(KERNEL_SOURCE_DIR)/.config
ifeq ($(strip $(FREETZ_KERNEL_VERSION_2_MAX)),y)
	-$(SUBMAKE) kernel-oldconfig
else
	-$(SUBMAKE) kernel-olddefconfig
endif

kernel-dirclean:
	$(RM) -r $(KERNEL_DIR)
	$(RM) -r $(KERNEL_HEADERS_DEVEL_DIR) $(addprefix $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/,$(KERNEL_HEADERS_SUBDIRS))
	$(RM) $(KERNEL_TARGET_DIR)/System-$(KERNEL_ID).map
	$(RM) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	$(RM) -r $(KERNEL_TARGET_DIR)/modules-$(KERNEL_ID)

kernel-distclean: kernel-dirclean


.PHONY: kernel-unpacked kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig kernel-olddefconfig target-toolchain-kernel-headers

