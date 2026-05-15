$(call TOOLS_INIT, 26.1.1)
#
$(PKG)_SOURCE_DOWNLOAD_NAME:=pip-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d36762751d156a4ee895de8af39aa0abeeeb577f93a2eca6ab62467bbf0f8a78
$(PKG)_SITE:=http://download.openpkg.org/components/cache/python-setup,https://distfiles.macports.org/py-pip,https://files.pythonhosted.org/packages/b6/48/cb9b7a682f6fe01a4221e1728941dd4ac3cd9090a17db3779d6ff490b602
### WEBSITE:=https://pypi.org/project/pip/
### MANPAGE:=https://pip.pypa.io/
### CHANGES:=https://pypi.org/project/pip/#history
### CVSREPO:=https://github.com/pypa/pip
### STEWARD:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/src/pip


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_PIP_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_PIP_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/pip/

$(TOOLS_FINISH)
