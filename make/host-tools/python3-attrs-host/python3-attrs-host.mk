$(call TOOLS_INIT, 26.1.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ea97d5c2b587bd038d7f4a32483b1a08c7a04770b1391180117530541918b18b
$(PKG)_SITE:=https://github.com/python-attrs/attrs/archive/refs/tags
### WEBSITE:=https://pypi.org/project/attrs/
### MANPAGE:=https://www.attrs.org/
### CHANGES:=https://github.com/python-attrs/attrs/releases
### CVSREPO:=https://github.com/python-attrs/attrs
### STEWARD:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/src/*


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_ATTRS_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_ATTRS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/attr/ $(PYTHON3_HOST_SITE_PACKAGES)/attrs/

$(TOOLS_FINISH)
