$(call PKG_INIT_BIN, 5.3.0)
$(PKG)_SOURCE:=lxml-py3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_DOWNLOAD_NAME:=lxml-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/l/lxml
$(PKG)_HASH:=4e109ca30d1edec1ac60cdbe341905dc3b8f55b16855e03a54aaf59e51ec8c6f
### WEBSITE:=https://lxml.de/
### MANPAGE:=https://lxml.de/tutorial.html
### CHANGES:=https://lxml.de/changes-5.3.0.html
### CVSREPO:=https://github.com/lxml/lxml

$(PKG)_DEPENDS_ON += python3
$(PKG)_DEPENDS_ON += python3-setuptools-host
$(PKG)_DEPENDS_ON += libxml2
$(PKG)_DEPENDS_ON += xsltproc

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/lxml/__init__.py

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod3/PKG, PYTHON3_LXML, \
		, \
		XSLT_CONFIG=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xslt-config \
		XML2_CONFIG=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/xml2-config \
	)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYTHON3_LXML_DIR)/.configured
	$(RM) -r $(PYTHON3_LXML_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON3_LXML_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/lxml \
		$(PYTHON3_LXML_DEST_DIR)$(PYTHON3_SITE_PKG_DIR)/lxml-*.dist-info

$(PKG_FINISH)
