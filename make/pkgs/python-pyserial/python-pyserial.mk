# -----------------------
# Python pySerial Module
# -----------------------
$(call PKG_INIT_BIN,2.6)
$(PKG)_SOURCE:=pyserial-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=049dbcda0cd475d3be903e721d60889ee2cc4ec3b62892a81ecef144196413ed
$(PKG)_SITE:=https://pypi.python.org/packages/source/p/pyserial
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/serial/__init__.py
$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Installing Python module: pySerial ==="
	@echo "Source: $(PYTHON_PYSERIAL_DIR)"
	@echo "Dest: $(PYTHON_PYSERIAL_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYSERIAL_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(HOST_PYTHON_BIN) ./setup.py build \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYSERIAL_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	touch -c $@

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_PYSERIAL_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYSERIAL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/serial \
		$(PYTHON_PYSERIAL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyserial-*.egg-info

$(PKG_FINISH)
