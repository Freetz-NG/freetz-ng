# -----------------------
# Python pyOpenSSL Module
# -----------------------
$(call PKG_INIT_BIN,0.13.1)
$(PKG)_SOURCE:=pyOpenSSL-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ba06ec710414f6dfe5566ec24c81882547c3e6fc48458d64315b73a0d5142fdb
$(PKG)_SITE:=https://pypi.python.org/packages/source/p/pyOpenSSL
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/OpenSSL/SSL.so
$(PKG)_DEPENDS_ON += python openssl
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += $(OPENSSL_REBUILD_SUBOPTS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: pyOpenSSL ==="
	@echo "Source: $(PYTHON_PYOPENSSL_DIR)"
	@echo "Dest: $(PYTHON_PYOPENSSL_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYOPENSSL_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYOPENSSL_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_PYOPENSSL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/OpenSSL/SSL.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_PYOPENSSL_DIR)/build
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYOPENSSL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/OpenSSL \
		$(PYTHON_PYOPENSSL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyOpenSSL-*.egg-info

$(PKG_FINISH)
