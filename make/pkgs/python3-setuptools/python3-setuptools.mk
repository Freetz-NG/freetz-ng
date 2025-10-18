$(call PKG_INIT_BIN, 75.6.0)
$(PKG)_SOURCE:=setuptools-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=setuptools-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/s/setuptools
$(PKG)_HASH:=8199222558df7c86216af4f84c30e9b34a61d8ba19366cc914424cdbd28252f6
### WEBSITE:=https://setuptools.pypa.io/
### MANPAGE:=https://setuptools.pypa.io/en/latest/
### CHANGES:=https://setuptools.pypa.io/en/latest/history.html
### CVSREPO:=https://github.com/pypa/setuptools

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(call Build/Py3Mod/PKG, PYTHON3_SETUPTOOLS, , )
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DIR)/.compiled


$(pkg)-clean:
	$(RM) $(PYTHON3_SETUPTOOLS_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON3_SETUPTOOLS_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_SETUPTOOLS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/setuptools \
		$(PYTHON3_SETUPTOOLS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/setuptools-*.dist-info \
		$(PYTHON3_SETUPTOOLS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pkg_resources \
		$(PYTHON3_SETUPTOOLS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/_distutils_hack

$(PKG_FINISH)
