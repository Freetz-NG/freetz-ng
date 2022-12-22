$(call PKG_INIT_BIN, 2.0.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=76428e96df0ae9dd964c7a7c74c1e9a837e2f312c39e9a357fa8178f7eff80da
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/jamvm
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/jamvm
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/.libs/libjvm.so
$(PKG)_TARGET_LIB_BINARY:=$($(PKG)_DEST_LIBDIR)/libjvm.so

$(PKG)_CLASSES_ZIP:=$($(PKG)_DIR)/src/classlib/gnuclasspath/lib/classes.zip
$(PKG)_TARGET_CLASSES_ZIP:=$($(PKG)_DEST_DIR)/usr/share/jamvm/classes.zip

$(PKG)_DEPENDS_ON += zlib libffi classpath

$(PKG)_CONFIGURE_OPTIONS += --enable-ffi
$(PKG)_CONFIGURE_OPTIONS += --disable-int-threading
$(PKG)_CONFIGURE_OPTIONS += --with-classpath-install-dir="/usr"

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JAMVM_DIR)/src

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_LIB_BINARY): $($(PKG)_LIB_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_CLASSES_ZIP): $($(PKG)_CLASSES_ZIP)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIB_BINARY) $($(PKG)_TARGET_CLASSES_ZIP)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JAMVM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(JAMVM_TARGET_BINARY) $(JAMVM_DEST_LIBDIR)/libjvm*.so* $(JAMVM_TARGET_CLASSES_ZIP)

$(PKG_FINISH)
