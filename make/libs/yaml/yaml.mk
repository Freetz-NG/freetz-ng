$(call PKG_INIT_LIB, 0.2.7)
$(PKG)_LIB_VERSION:=2.0.11
$(PKG)_SOURCE:=yaml-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0c39256b8be0fc689f5c7bfdea1bc9f3fb1fd648468fd3cc6fd375e09ffb6f13
$(PKG)_SITE:=https://github.com/yaml/libyaml/releases/download/$($(PKG)_VERSION)/
### WEBSITE:=https://pyyaml.org/wiki/LibYAML
### CHANGES:=https://github.com/yaml/libyaml/releases
### CVSREPO:=https://github.com/yaml/libyaml

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libyaml-0.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libyaml-0.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libyaml-0.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(YAML_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(YAML_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libyaml.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/yaml*.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(YAML_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libyaml*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/yaml.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/yaml*.pc

$(pkg)-uninstall:
	$(RM) $(YAML_TARGET_DIR)/libyaml*.so*

$(PKG_FINISH)
