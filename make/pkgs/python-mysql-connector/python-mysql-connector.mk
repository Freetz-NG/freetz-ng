# -----------------------
# Python MySQL Connector Module
# -----------------------
$(call PKG_INIT_BIN,8.0.21)
$(PKG)_SOURCE:=mysql-connector-python-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0eecec5ab1a4ba03741bee5ec3cb02a8647470ba4a5c50a14c49425db2ec3590
$(PKG)_SITE:=https://pypi.python.org/packages/source/m/mysql-connector-python
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql/__init__.py
$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Installing Python module: MySQL Connector ==="
	@echo "Source: $(PYTHON_MYSQL_CONNECTOR_DIR)"
	@echo "Dest: $(PYTHON_MYSQL_CONNECTOR_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_MYSQL_CONNECTOR_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(HOST_PYTHON_BIN) ./setup.py build \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_MYSQL_CONNECTOR_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	touch -c $@

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_MYSQL_CONNECTOR_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_MYSQL_CONNECTOR_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql \
		$(PYTHON_MYSQL_CONNECTOR_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysqlx \
		$(PYTHON_MYSQL_CONNECTOR_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mysql_connector_python-*.egg-info

$(PKG_FINISH)
