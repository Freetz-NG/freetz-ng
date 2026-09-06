$(call TOOLS_INIT, 2026-09-06)
$(PKG)_SOURCE:=tools-$($(PKG)_VERSION).tar.lzma
$(PKG)_HASH:=bee3de36704f6acc29a4f5efa0f9c951b83fa93dadb1089ec5f7e44c4ce6bb8e
$(PKG)_SITE:=@DLTOKEN/https://api.github.com/repos/Freetz-NG/internal/releases/tags/host-tools
### STEWARD:=fda77

$(PKG)_BUILD_PREREQ += $(if $(filter x86_64,$(HOST_ARCH)),,x86_64-system)
$(PKG)_BUILD_PREREQ_HINT := You have to use a x86_64 system to compile this

$(PKG)_DEPENDS_ON:=kconfig-host

$(PKG)_TARBALL_STRIP_COMPONENTS:=0


define $(PKG)_CUSTOM_UNPACK
	tar -C $($(PKG)_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

#$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
#$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
#	$(info ERROR: File '$(DL_DIR)/$(TOOLS_HOST_SOURCE)' not found.)
#	$(info There is and will no download source be available.)
#	$(info Either disable 'FREETZ_HOSTTOOLS_DOWNLOAD' in menuconfig or)
#	$(info create the file by yourself with 'tools/dl-hosttools own'.)
#	$(error )
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(TOOLS_HOST_DIR)/tools $(FREETZ_BASE_DIR)/
	touch $@

$($(PKG)_DIR)/.fixhardcoded: $($(PKG)_DIR)/.installed | $(patsubst %,%-fixhardcoded,$(TOOLS))
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.fixhardcoded


$(pkg)-clean:
	-$(RM) $(TOOLS_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(TOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean $(patsubst %,%-distclean,$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)))

$(TOOLS_FINISH)
