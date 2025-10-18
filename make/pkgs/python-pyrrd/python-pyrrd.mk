# -----------------------
# Python PyRRD Module
# -----------------------
$(call PKG_INIT_BIN,0.1.0)
$(PKG)_SOURCE:=PyRRD-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=103b3a6f855e38946e0fc100a54ec46be69c37cc349ceb95decad35424f629a9
$(PKG)_SITE:=https://pyrrd.googlecode.com/files
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd/__init__.py
$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Installing Python module: PyRRD ==="
	@echo "Source: $(PYTHON_PYRRD_DIR)"
	@echo "Dest: $(PYTHON_PYRRD_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYRRD_DIR) && \
		$(HOST_PYTHON_BIN) ./setup.py build --force --verbose && \
		$(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYRRD_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	# Cleanup test directories safely
	@if [ -d "$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd" ]; then \
		$(RM) -rf $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd/backend/tests \
		       $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd/testing \
		       $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd/tests; \
	elif [ -d "$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD" ]; then \
		$(RM) -rf $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD/backend/tests \
		       $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD/testing \
		       $(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD/tests; \
	fi
	touch -c $@

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_PYRRD_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd \
		$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD-*.egg-info

$(PKG_FINISH)
