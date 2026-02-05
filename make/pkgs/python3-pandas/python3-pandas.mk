$(call PKG_INIT_BIN, 2.2.3)
$(PKG)_SOURCE:=pandas-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=pandas-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pandas
$(PKG)_HASH:=4f18ba62b61d7e192368b84517265a99b4d7ee8912f8708660fb4a366cc82667
### WEBSITE:=https://pandas.pydata.org/
### MANPAGE:=https://pandas.pydata.org/docs/
### CHANGES:=https://pandas.pydata.org/docs/whatsnew/
### CVSREPO:=https://github.com/pandas-dev/pandas

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host
$(PKG)_DEPENDS_ON += python3-numpy

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pandas/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/PKG, PYTHON3_PANDAS, , )

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYTHON3_PANDAS_DIR)/.configured
	$(RM) -r $(PYTHON3_PANDAS_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_PANDAS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pandas \
		$(PYTHON3_PANDAS_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/pandas-*.dist-info

$(PKG_FINISH)
