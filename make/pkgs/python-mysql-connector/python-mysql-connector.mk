$(call PKG_INIT_BIN, 8.0.21)
$(PKG)_SOURCE:=mysql-connector-python-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0eecec5ab1a4ba03741bee5ec3cb02a8647470ba4a5c50a14c49425db2ec3590
$(PKG)_SITE:=https://pypi.python.org/packages/source/m/mysql-connector-python

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql/__init__.py

$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_MYSQL_CONNECTOR, , PYTHONHOME=$(HOST_TOOLS_DIR)/usr)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $($(PKG)_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql \
		$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysqlx \
		$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql_connector_python-*.egg-info

$(PKG_FINISH)
