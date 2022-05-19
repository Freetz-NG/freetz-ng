YF_BOOTMANAGER_REPOSITORY:=https://github.com/PeterPawn/YourFritz.git
$(call TOOL_INIT, $(shell git ls-remote --tags $(YF_BOOTMANAGER_REPOSITORY) freetz-ng-version | sed -n -e "s|^\([0-9a-f]*\).*|\1|p"))
# Versions after this commit have no vanilla GPL3 - but it's not a problem to use the unchanged(!) version in an own image.
$(TOOL)_SITE:=git_sparse@https://github.com/PeterPawn/YourFritz.git,bootmanager
$(TOOL)_SOURCE:=yf-bootmanager-$($(TOOL)_VERSION).tar.xz


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	mkdir -p $(TOOLS_DIR)/yf/
	$(call COPY_USING_TAR,$(YF_BOOTMANAGER_HOST_DIR)/,$(TOOLS_DIR)/yf/,bootmanager/)
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(YF_BOOTMANAGER_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/yf/bootmanager/

$(TOOLS_FINISH)
