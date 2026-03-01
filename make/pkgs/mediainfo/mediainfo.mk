$(call PKG_INIT_BIN, 25.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2edaff16dfad9ee372d17d6d01eb2e3d2f8ee8dd4af606b1ee6f045c9b009662
$(PKG)_SITE:=https://github.com/MediaArea/MediaInfo/archive/refs/tags
$(PKG)_DIR:=$(SOURCE_DIR)/MediaInfo-$($(PKG)_VERSION)
### WEBSITE:=https://mediaarea.net/en/MediaInfo
### MANPAGE:=https://mediaarea.net/en/MediaInfo
### CHANGES:=https://github.com/MediaArea/MediaInfo/releases
### CVSREPO:=https://github.com/MediaArea/MediaInfo
### SUPPORT:=Ircama

MEDIAINFOLIB_VERSION:=25.10

MEDIAINFOLIB_SOURCE:=MediaInfoLib-v$(MEDIAINFOLIB_VERSION).tar.gz
MEDIAINFOLIB_SITE:=https://github.com/MediaArea/MediaInfoLib/archive/refs/tags
MEDIAINFOLIB_HASH:=e4b2b82f3df8d2c190643d1705ee35c3102674954858d02a2e2b42840f0f07aa

MEDIAINFOLIB_DIR:=$(SOURCE_DIR)/MediaInfoLib-$(MEDIAINFOLIB_VERSION)

# Intermediate variables to avoid double expansion in shell commands
MEDIAINFO_PKG_SOURCE := $($(PKG)_SOURCE)
MEDIAINFO_PKG_VERSION := $($(PKG)_VERSION)
MEDIAINFO_PKG_SITE := $($(PKG)_SITE)
MEDIAINFO_PKG_HASH := $($(PKG)_HASH)

$(PKG)_BINARY:=$($(PKG)_DIR)/Project/GNU/CLI/mediainfo
$(PKG)_BINARY_TARGET:=$($(PKG)_DEST_DIR)/usr/bin/mediainfo

$(PKG)_LIBMEDIAINFO_BINARY:=$(MEDIAINFOLIB_DIR)/Project/GNU/Library/.libs/libmediainfo.so.0.0.0
$(PKG)_LIBMEDIAINFO_STAGING_LIB:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmediainfo.so.0.0.0
$(PKG)_LIBMEDIAINFO_TARGET_LIB:=$($(PKG)_TARGET_LIBDIR)/libmediainfo.so.0.0.0

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared

$(PKG)_DEPENDS_ON += libzen

# Download MediaInfo source.
# Upstream asset name is "v<version>.tar.gz", but we store it locally using a unique
# Freetz-style filename to avoid collisions with other packages.
$(DL_DIR)/$(MEDIAINFO_PKG_SOURCE): | $(DL_DIR)
	$(DL_TOOL) -o $(MEDIAINFO_PKG_SOURCE) $(DL_DIR) v$(MEDIAINFO_PKG_VERSION).tar.gz $(MEDIAINFO_PKG_SITE) $(MEDIAINFO_PKG_HASH)

$(PKG_UNPACKED)

$(DL_DIR)/MediaInfoLib-v$(MEDIAINFOLIB_VERSION).tar.gz: | $(DL_DIR)
	$(DL_TOOL) -o MediaInfoLib-v$(MEDIAINFOLIB_VERSION).tar.gz $(DL_DIR) v$(MEDIAINFOLIB_VERSION).tar.gz $(MEDIAINFOLIB_SITE) $(MEDIAINFOLIB_HASH)

# Build MediaInfoLib
$($(PKG)_LIBMEDIAINFO_BINARY): $(DL_DIR)/MediaInfoLib-v$(MEDIAINFOLIB_VERSION).tar.gz
	$(call UNPACK_TARBALL,$<,$(SOURCE_DIR))
	(cd $(MEDIAINFOLIB_DIR)/Project/GNU/Library && \
		./autogen.sh && \
		CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CXXFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		PKG_CONFIG_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig" \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/usr \
			--enable-static \
			--enable-shared && \
		$(SUBMAKE) \
	) $(SILENT)

$($(PKG)_LIBMEDIAINFO_STAGING_LIB): $($(PKG)_LIBMEDIAINFO_BINARY)
	$(SUBMAKE) -C $(MEDIAINFOLIB_DIR)/Project/GNU/Library \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmediainfo.la

# Build MediaInfo CLI
$(MEDIAINFO_DIR)/.configured: $(MEDIAINFO_DIR)/.unpacked $(MEDIAINFO_LIBMEDIAINFO_STAGING_LIB)
	(cd $(MEDIAINFO_DIR)/Project/GNU/CLI && \
		./autogen.sh && \
		CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CXXFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		PKG_CONFIG_PATH="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig" \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/usr \
			$(MEDIAINFO_CONFIGURE_OPTIONS) \
	) $(SILENT)
	touch $@

$(MEDIAINFO_BINARY): $(MEDIAINFO_DIR)/.configured
	$(SUBMAKE) -C $(MEDIAINFO_DIR)/Project/GNU/CLI

$(MEDIAINFO_BINARY_TARGET): $(MEDIAINFO_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBMEDIAINFO_TARGET_LIB): $($(PKG)_LIBMEDIAINFO_STAGING_LIB)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET)

ifeq ($(strip $(FREETZ_PACKAGE_MEDIAINFO_STATIC)),y)
$(pkg)-precompiled:
else
$(pkg)-precompiled: $($(PKG)_LIBMEDIAINFO_TARGET_LIB)
endif

$(pkg)-clean:
	-[ -d $(MEDIAINFOLIB_DIR)/Project/GNU/Library ] && $(MAKE) -C $(MEDIAINFOLIB_DIR)/Project/GNU/Library clean $(SILENT)
	-[ -d $($(PKG)_DIR)/Project/GNU/CLI ] && $(MAKE) -C $($(PKG)_DIR)/Project/GNU/CLI clean $(SILENT)
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmediainfo* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/MediaInfo* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libmediainfo.pc

$(pkg)-uninstall:
	$(RM) $(MEDIAINFO_BINARY_TARGET) $(MEDIAINFO_LIBMEDIAINFO_TARGET_LIB)

$(PKG_FINISH)

