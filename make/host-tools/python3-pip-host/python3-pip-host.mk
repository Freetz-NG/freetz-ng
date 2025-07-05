$(call TOOLS_INIT, 25.1.1)
#
$(PKG)_SOURCE_DOWNLOAD_NAME:=pip-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3de45d411d308d5054c2168185d8da7f9a2cd753dbac8acbfa88a8909ecd9077
$(PKG)_SITE:=https://distfiles.macports.org/py-pip,https://files.pythonhosted.org/packages/59/de/241caa0ca606f2ec5fe0c1f4261b0465df78d786a38da693864a116c37f4
### WEBSITE:=https://pypi.org/project/pip/
### MANPAGE:=https://pip.pypa.io/
### CHANGES:=https://pypi.org/project/pip/#history
### CVSREPO:=https://github.com/pypa/pip
### SUPPORT:=fda77

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
