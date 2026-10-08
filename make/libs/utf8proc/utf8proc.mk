$(call PKG_INIT_LIB, 2.12.0)
$(PKG)_SHLIB_VERSION:=3.3.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=a393fbef160835fb315bc3e91ba8d86f7a73a7cec9e6198b6c60b848b498bfeb
$(PKG)_SITE:=https://github.com/JuliaStrings/utf8proc/releases/download/v$($(PKG)_VERSION)
### VERSION:=2.12.0
### WEBSITE:=https://juliastrings.github.io/utf8proc/
### MANPAGE:=https://juliastrings.github.io/utf8proc/doc/
### CHANGES:=https://juliastrings.github.io/utf8proc/releases/
### CVSREPO:=https://github.com/JuliaStrings/utf8proc

$(PKG)_CATEGORY_LIBS:=Charsets & Internationalization

$(PKG)_LIBNAME=lib$(pkg).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_MAKE_VARS += CC="$(TARGET_CC)"
$(PKG)_MAKE_VARS += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_VARS += AR="$(TARGET_AR)"
$(PKG)_MAKE_VARS += prefix=""


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UTF8PROC_DIR) \
		$(UTF8PROC_MAKE_VARS)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(UTF8PROC_DIR) \
		$(UTF8PROC_MAKE_VARS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libutf8proc.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(UTF8PROC_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libutf8proc.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/utf8proc.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libutf8proc.pc

$(pkg)-uninstall:
	$(RM) $(UTF8PROC_TARGET_DIR)/libutf8proc.so*

$(PKG_FINISH)

