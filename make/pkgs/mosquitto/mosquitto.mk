$(call PKG_INIT_BIN, 2.0.18)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d665fe7d0032881b1371a47f34169ee4edab67903b2cd2b4c083822823f4448a
$(PKG)_SITE:=https://mosquitto.org/files/source
### WEBSITE:=https://www.mosquitto.org/
### MANPAGE:=https://www.mosquitto.org/documentation/
### CHANGES:=https://mosquitto.org/blog/
### CVSREPO:=https://github.com/eclipse/mosquitto

$(PKG)_BINARY_BROKER:=$($(PKG)_DIR)/src/mosquitto
$(PKG)_BINARY_MOSQUITTO_PASSWD:=$($(PKG)_DIR)/src/mosquitto_passwd
$(PKG)_BINARY_CLIENT_PUB:=$($(PKG)_DIR)/client/mosquitto_pub
$(PKG)_BINARY_CLIENT_SUB:=$($(PKG)_DIR)/client/mosquitto_sub

$(PKG)_TARGET_BINARY_BROKER:=$($(PKG)_DEST_DIR)/usr/bin/mosquitto
$(PKG)_TARGET_BINARY_MOSQUITTO_PASSWD:=$($(PKG)_DEST_DIR)/usr/bin/mosquitto_passwd
$(PKG)_TARGET_BINARY_CLIENT_PUB:=$($(PKG)_DEST_DIR)/usr/bin/mosquitto_pub
$(PKG)_TARGET_BINARY_CLIENT_SUB:=$($(PKG)_DEST_DIR)/usr/bin/mosquitto_sub

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/libmosquitto.so.1
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libmosquitto.so.1

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOSQUITTO_BROKER),,usr/bin/mosquitto etc/default.mosquitto/mosquitto.cfg etc/default.mosquitto/mosquitto_conf etc/default.mosquitto/mosquitto_extra.def etc/init.d/rc.mosquitto usr/lib/cgi-bin/mosquitto.cgi)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOSQUITTO_PASSWD),,usr/bin/mosquitto_passwd)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOSQUITTO_CLIENT_PUB),,usr/bin/mosquitto_pub)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOSQUITTO_CLIENT_SUB),,usr/bin/mosquitto_sub)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_MOSQUITTO_CLIENTS),,$(FREETZ_LIBRARY_DIR)/libmosquitto.so.1)

$(PKG)_MAKE_OPTIONS += -C $(MOSQUITTO_DIR)
$(PKG)_MAKE_OPTIONS += CC="$(TARGET_CC)"
$(PKG)_MAKE_OPTIONS += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_OPTIONS += WITH_DOCS=no
$(PKG)_MAKE_OPTIONS += WITH_SRV=no
$(PKG)_MAKE_OPTIONS += WITH_UUID=$(if $(FREETZ_PACKAGE_MOSQUITTO_WITH_UUID),yes,no)
$(PKG)_MAKE_OPTIONS += WITH_TLS=$(if $(FREETZ_PACKAGE_MOSQUITTO_WITH_SSL),yes,no)
$(PKG)_MAKE_OPTIONS += WITH_MEMORY_TRACKING=no  # Note: Setting this to "yes" requires uClibc >= 1.0.29
$(PKG)_MAKE_OPTIONS += WITH_CJSON=no

$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_MOSQUITTO_WITH_UUID),e2fsprogs)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_MOSQUITTO_WITH_SSL),openssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MOSQUITTO_WITH_UUID
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MOSQUITTO_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += $(if $(FREETZ_PACKAGE_MOSQUITTO_WITH_SSL),FREETZ_OPENSSL_SHLIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY_BROKER) $($(PKG)_BINARY_MOSQUITTO_PASSWD) $($(PKG)_BINARY_CLIENT_PUB) $($(PKG)_BINARY_CLIENT_SUB) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(MOSQUITTO_MAKE_OPTIONS)

$($(PKG)_TARGET_BINARY_BROKER): $($(PKG)_BINARY_BROKER)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_MOSQUITTO_PASSWD): $($(PKG)_BINARY_MOSQUITTO_PASSWD)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_CLIENT_PUB): $($(PKG)_BINARY_CLIENT_PUB)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY_CLIENT_SUB): $($(PKG)_BINARY_CLIENT_SUB)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY_BROKER) $(if $(FREETZ_PACKAGE_MOSQUITTO_PASSWD),$($(PKG)_TARGET_BINARY_MOSQUITTO_PASSWD)) $($(PKG)_TARGET_BINARY_CLIENT_PUB) $($(PKG)_TARGET_BINARY_CLIENT_SUB) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) $(MOSQUITTO_MAKE_OPTIONS) clean
	$(RM) $(MOSQUITTO_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(MOSQUITTO_TARGET_BINARY_BROKER) $(MOSQUITTO_TARGET_BINARY_MOSQUITTO_PASSWD) $(MOSQUITTO_TARGET_BINARY_CLIENT_PUB) $(MOSQUITTO_TARGET_BINARY_CLIENT_SUB) $(MOSQUITTO_LIB_TARGET_BINARY)

$(PKG_FINISH)
