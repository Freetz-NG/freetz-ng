$(call PKG_INIT_BIN, 6.2.5)
$(PKG)_SOURCE:=unrarsrc-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9a3974410d1d340e3998dd2a6f98faefbe838cad556266e714adfb0e8cf9377c
$(PKG)_SITE:=https://www.rarlab.com/rar
### WEBSITE:=https://www.rarlab.com/rar_add.htm
### MANPAGE:=https://linux.die.net/man/1/unrar
### CHANGES:=https://www.rarlab.com/rarnew.htm

$(PKG)_BINARY:=$($(PKG)_DIR)/unrar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unrar

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UNRAR_STATIC
ifeq ($(strip $(FREETZ_PACKAGE_UNRAR_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_0_9_28
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_UCLIBC_0_9_29
ifeq ($(strip $(or $(FREETZ_TARGET_UCLIBC_0_9_28),$(FREETZ_TARGET_UCLIBC_0_9_29))),y)
$(PKG)_DEFINES += -DVFWPRINTF_WORKAROUND_REQUIRED
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNRAR_DIR) -f makefile \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS) -fno-rtti -fno-exceptions -std=c++11" \
		DEFINES="$(UNRAR_DEFINES)" \
		LDFLAGS="$(UNRAR_LDFLAGS)" \
		STRIP=true

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(UNRAR_DIR) -f makefile clean

$(pkg)-uninstall:
	$(RM) $(UNRAR_TARGET_BINARY)

$(PKG_FINISH)
