# -----------------------
# YENC Python Module
# -----------------------
$(call PKG_INIT_BIN,0.4.0)
$(PKG)_SOURCE:=yenc-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=075f6c4e4f43b7c6dafac579eabb17287b62d80e9147cbea0b046bc3ee8edd2f
$(PKG)_SITE:=http://www.golug.it/pub/yenc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_yenc.so
$(PKG)_DEPENDS_ON += python
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@echo "=== Building Python module: yenc ==="
	@echo "Source: $(PYTHON_YENC_DIR)"
	@echo "Dest: $(PYTHON_YENC_DEST_DIR)"
	@echo "Python include: $(PYTHON_STAGING_INC_DIR)"
	( \
		export PYTHONHOME="$(HOST_TOOLS_DIR)/usr"; \
		export PYTHONPATH="$(PYTHON_STAGING_LIB_DIR):$(TARGET_TOOLCHAIN_STAGING_DIR)/$(PYTHON_SITE_PKG_DIR)"; \
		export PYTHONOPTIMIZE=""; \
		export PYTHONDONTWRITEBYTECODE="x"; \
		cd $(PYTHON_YENC_DIR) && \
		$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(HOST_PYTHON_BIN) ./setup.py build_ext \
			--include-dirs=$(PYTHON_STAGING_INC_DIR) \
			--library-dirs=$(PYTHON_STAGING_LIB_DIR) \
			--force --verbose \
		&& $(HOST_PYTHON_BIN) ./setup.py install \
			--prefix=/usr \
			--root=$(abspath $(PYTHON_YENC_DEST_DIR)) \
			--install-lib=$(PYTHON_SITE_PKG_DIR) \
	)
	$(TARGET_STRIP) $(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_yenc.so 2>/dev/null || true

$(pkg):
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
$(pkg)-clean:
	$(RM) -r $(PYTHON_YENC_DIR)/build
$(pkg)-uninstall:
	$(RM) -r $(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/yenc* $(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_yenc.so

$(PKG_FINISH)
