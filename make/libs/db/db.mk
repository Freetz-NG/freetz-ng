$(call PKG_INIT_LIB, 4.8.30)
$(PKG)_LIB_VERSION:=4.8
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e0491a07cdb21fb9aa82773bbbedaeb7639cbd0e7f96147ab46141e0045db72a
$(PKG)_SITE:=http://download.oracle.com/berkeley-db

$(PKG)_LIBNAME:=lib$(pkg)-$($(PKG)_LIB_VERSION).so
$(PKG)_BUILD_SUBDIR:=build_unix
$(PKG)_BINARY:=$($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_PRE_CMDS := ln -sf ../dist/configure $(DB_BUILD_SUBDIR)/ ;
$(PKG)_CONFIGURE_OPTIONS += --srcdir=../dist/

$(PKG)_MUTEX_arm:=ARM/gcc-assembly
$(PKG)_MUTEX_i686:=*x86/gcc-assembly
$(PKG)_MUTEX_mips:=MIPS/gcc-assembly

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-mutex='$($(PKG)_MUTEX_$(call qstrip,$(FREETZ_TARGET_ARCH)))'
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx
$(PKG)_CONFIGURE_OPTIONS += --disable-compat185
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl
$(PKG)_CONFIGURE_OPTIONS += --enable-smallbuild

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		library_install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb*.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{db.h,db_cxx.h,db_int.h}

$(pkg)-uninstall:
	$(RM) $(DB_TARGET_DIR)/libdb*.so*

$(PKG_FINISH)
