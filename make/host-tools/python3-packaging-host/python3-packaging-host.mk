$(call TOOLS_INIT, 25.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=15b6ba95eb12d8f99dcf215ea37cbea16812ef28358e8ef3d9344acb827acac1
$(PKG)_SITE:=https://github.com/pypa/packaging/archive/refs/tags
### WEBSITE:=https://pypi.org/project/packaging/
### MANPAGE:=https://packaging.pypa.io/
### CHANGES:=https://github.com/pypa/packaging/releases
### CVSREPO:=https://github.com/pypa/packaging
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/src/packaging


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_PACKAGING_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_PACKAGING_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/packaging/

$(TOOLS_FINISH)
