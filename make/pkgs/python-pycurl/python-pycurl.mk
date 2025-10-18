# -----------------------
# Python PyCurl Module
# -----------------------
$(call PKG_INIT_BIN,7.43.0)
# Note: Versions >=7.43 only support Python3
$(PKG)_SOURCE:=pycurl-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=aa975c19b79b6aa6c0518c0cc2ae33528900478f0b500531dbcdbf05beec584c
$(PKG)_SITE:=https://pypi.python.org/packages/source/p/pycurl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl.so
$(PKG)_DEPENDS_ON += python curl
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += $(CURL_REBUILD_SUBOPTS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

# Build & install
$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: pycurl ==="
	@echo "Source: $(PYTHON_PYCURL_DIR)"
	@echo "Dest: $(PYTHON_PYCURL_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_PYCURL_DIR) && \
		echo "Current directory: $$(pwd)" && \
		echo "Files: $$(ls -la)" && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--curl-config=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl-config \
			$(if $(FREETZ_LIB_libcurl_WITH_OPENSSL),--with-ssl) \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_PYCURL_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl.so 2>/dev/null || true

# Targets
$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_PYCURL_DIR) clean
$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl.so \
		$(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl-*.egg-info \
		$(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/curl

$(PKG_FINISH)
