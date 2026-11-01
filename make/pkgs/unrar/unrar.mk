$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON),6.1.7,7.3.1))
$(PKG)_SOURCE:=unrarsrc-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=de75b6136958173fdfc530d38a0145b72342cf0d3842bf7bb120d336602d88ed
$(PKG)_HASH_CURRENT:=634900842a3737d9cc15bbcc71d4c74cc713437e0bca296a573424fe5f2660ab
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://www.rarlab.com/rar
### WEBSITE:=https://www.rarlab.com/rar_add.htm
### MANPAGE:=https://linux.die.net/man/1/unrar
### CHANGES:=https://www.rarlab.com/rarnew.htm
### CVSREPO:=https://www.rarlab.com/rar_add.htm
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/unrar
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unrar

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON),abandon,current)

ifeq ($(strip $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON)),y)
$(PKG)_DEPENDS_ON += $(STDCXXLIB)
else
$(PKG)_DEPENDS_ON += libstdcxx
endif
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

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -fno-rtti
ifeq ($(strip $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON)),y)
$(PKG)_CFLAGS += -fno-exceptions
else
$(PKG)_CFLAGS += -std=gnu++11
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNRAR_DIR) -f makefile \
		CXX="$(if $(FREETZ_PACKAGE_UNRAR_VERSION_ABANDON),$(TARGET_CXX),$(TARGET_CXX_GNU))" \
		CXXFLAGS="$(UNRAR_CFLAGS)" \
		LDFLAGS="$(UNRAR_LDFLAGS)" \
		DEFINES="$(UNRAR_DEFINES)" \
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
