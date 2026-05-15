$(call TOOLS_INIT, 26.2)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=24d24b249ba8fb0213ac046d8e2c1cecf6b1013311a5febfb87a02093ef2c991
$(PKG)_SITE:=https://github.com/pypa/packaging/archive/refs/tags
### WEBSITE:=https://pypi.org/project/packaging/
### MANPAGE:=https://packaging.pypa.io/
### CHANGES:=https://github.com/pypa/packaging/releases
### CVSREPO:=https://github.com/pypa/packaging
### STEWARD:=fda77

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
