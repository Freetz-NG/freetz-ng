$(call PKG_INIT_LIB, 0.15.1)
$(PKG)_SHLIB_VERSION:=8.1.0
$(PKG)_SOURCE:=userspace-rcu-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=98d66cc12f2c5881879b976f0c55d10d311401513be254e3bd28cf3811fb50c8
$(PKG)_SITE:=https://lttng.org/files/urcu
### WEBSITE:=https://www.liburcu.org/
### CHANGES:=https://github.com/urcu/userspace-rcu/tags
### CVSREPO:=https://git.liburcu.org/?p=userspace-rcu.git;a=summary

$(PKG)_LIBNAMES_SHORT   := liburcu-bp liburcu-cds liburcu-common liburcu-mb liburcu-memb liburcu-qsbr liburcu
$(PKG)_LIBNAMES_LONG    := $($(PKG)_LIBNAMES_SHORT:%=%.so.$($(PKG)_SHLIB_VERSION))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF) -i;

$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBURCU_DIR)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(LIBURCU_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liburcu*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/liburcu*.pc

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBURCU_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liburcu*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/urcu*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/urcu/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/liburcu*.pc

$(pkg)-uninstall:
	$(RM) $(LIBURCU_TARGET_DIR)/liburcu*.so*

$(PKG_FINISH)
