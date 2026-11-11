$(call PKG_INIT_LIB, 465)
$(PKG)_SOURCE:=lzma$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=c935fd04dd8e0e8c688a3078f3675d699679a90be81c12686837e0880aa0fa1e
$(PKG)_SITE:=@SF/sevenzip

$(PKG)_TARBALL_STRIP_COMPONENTS:=0

$(PKG)_DEPENDS_ON += zlib

$(PKG)_BINARY:=$($(PKG)_DIR)/C/LzmaLib/liblzma.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma1.a

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -W -Wall
$(PKG)_CFLAGS += -Wno-unused-but-set-variable -Wno-unused-parameter
$(PKG)_CFLAGS += -ffunction-sections -fdata-sections
$(PKG)_CFLAGS += -std=c99
$(PKG)_CFLAGS += -fgnu89-inline


ifneq ($(strip $(DL_DIR)/$(LZMA1_SOURCE)),$(strip $(DL_DIR)/$(LZMA1_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LZMA1_DIR)/C/LzmaLib -f makefile.gcc \
		CC=$(TARGET_CC) \
		CFLAGS="$(LZMA1_CFLAGS)" \
		CPPFLAGS="-I ../ -D_GNU_SOURCE" \
		AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp -a $(LZMA1_DIR)/C/LZMA_ZLibCompat.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	$(INSTALL_FILE)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:


$(pkg)-clean:
	-$(SUBMAKE) -C $(LZMA1_DIR)/C/LzmaLib -f makefile.gcc clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma1.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/LZMA_ZLibCompat.h

$(PKG_FINISH)
