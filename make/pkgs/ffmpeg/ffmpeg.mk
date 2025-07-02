$(call PKG_INIT_BIN, 7.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=733984395e0dbbe5c046abda2dc49a5544e7e0e1e2366bba849222ae9e3a03b1
$(PKG)_SITE:=https://www.ffmpeg.org/releases
### WEBSITE:=https://www.ffmpeg.org/
### MANPAGE:=https://www.ffmpeg.org/documentation.html
### CHANGES:=https://www.ffmpeg.org/index.html#news
### CVSREPO:=https://git.ffmpeg.org/ffmpeg.git

$(PKG)_DEPENDS_ON += zlib
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg),openjpeg)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_FFMPEG_LZMA),xz)

$(PKG)_BINARIES_ALL        := ffmpeg ffprobe
$(PKG)_BINARIES            := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_LIBNAMES_SHORT      := avcodec avdevice avfilter avformat avutil postproc swresample swscale
$(PKG)_LIBVERSIONS_MAJOR   := 61      61       10       61       59     58       5          8
$(PKG)_LIBVERSIONS_MINOR   := 19.101  3.100    4.100    7.100    39.100 3.100    3.100      3.100

$(PKG)_LIBNAMES_LONG_MAJOR := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.),$($(PKG)_LIBVERSIONS_MAJOR))
$(PKG)_LIBNAMES_LONG       := $(join $($(PKG)_LIBNAMES_LONG_MAJOR:%=%.),$($(PKG)_LIBVERSIONS_MINOR))
$(PKG)_LIBS_BUILD_DIR      := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/lib%/),$($(PKG)_LIBNAMES_LONG_MAJOR))
$(PKG)_LIBS_STAGING_DIR    := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR     := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_LIBDIR)/%)

$(PKG)_ENCODERS  := ac3 jpegls mjpeg mpeg1video mpeg2video mpeg4 pcm_s16be pcm_s16le png tiff vorbis zlib
$(PKG)_DECODERS  := aac ac3 atrac3 gif h264 jpegls libopenjpeg mjpeg mjpegb mp2 mp3 mpeg1video mpeg2video mpeg4 mpegvideo pcm_s16be pcm_s16le png tiff vorbis wmav1 wmav2 zlib
$(PKG)_MUXERS    := ac3 avi flv h264 matroska mjpeg mov mp3 mp4 mpeg1video mpeg2video mpegts ogg rtp
$(PKG)_DEMUXERS  := ac3 avi flv h264 image2 matroska mjpeg mov mp3 mpegps mpegts mpegvideo ogg rm rtsp sdp v4l2
$(PKG)_PARSERS   := aac ac3 h264 mjpeg mpegaudio mpegvideo mpeg4video
$(PKG)_PROTOCOLS := file http https pipe rtp tcp udp

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_ffmpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_ffprobe
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_LZMA
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_SSL_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_SSL_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FFMPEG_SSL_GNUTLS
$(foreach i,encoder decoder muxer demuxer parser protocol, \
	$(eval $(PKG)_REBUILD_SUBOPTS += $(patsubst %,FREETZ_PACKAGE_FFMPEG_$(call TOUPPER_NAME,$(i))_%,$($(PKG)_$(call TOUPPER_NAME,$(i))S))) \
	$(eval $(PKG)_CONFIGURE_$(call TOUPPER_NAME,$(i))S := $(foreach c,$($(PKG)_$(call TOUPPER_NAME,$(i))S),$(if $(FREETZ_PACKAGE_FFMPEG_$(call TOUPPER_NAME,$(i))_$(c)),--enable-$(i)="$(c)"))) \
)

$(PKG)_CONFIGURE_DEFOPTS := n

$(PKG)_CONFIGURE_OPTIONS += --enable-cross-compile
$(PKG)_CONFIGURE_OPTIONS += --cross-prefix="$(TARGET_CROSS)"
$(PKG)_CONFIGURE_OPTIONS += --arch="$(TARGET_ARCH_ENDIANNESS_DEPENDENT)"
$(PKG)_CONFIGURE_OPTIONS += --disable-mips32r2
$(PKG)_CONFIGURE_OPTIONS += --disable-mipsdsp
$(PKG)_CONFIGURE_OPTIONS += --disable-mipsdspr2
$(PKG)_CONFIGURE_OPTIONS += --disable-mipsfpu

ifeq ($(strip $(FREETZ_TARGET_ARCH_MIPS)),y)
#$(PKG)_CONFIGURE_OPTIONS += --disable-asm
$(PKG)_CONFIGURE_OPTIONS += --disable-inline-asm
# {standard input}:31: Error: opcode not supported on this processor: mips32r2 (mips32r2) `dmult $2,$3'
# {standard input}:33: Error: opcode not supported on this processor: mips32r2 (mips32r2) `dsrl $2,$2,32'
endif

$(PKG)_CONFIGURE_OPTIONS += --target-os=linux
$(PKG)_CONFIGURE_OPTIONS += --prefix="/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug

$(PKG)_CONFIGURE_OPTIONS += --enable-gpl
$(PKG)_CONFIGURE_OPTIONS += --enable-version3
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_NONFREE),--enable-nonfree,--disable-nonfree)

$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-htmlpages
$(PKG)_CONFIGURE_OPTIONS += --disable-manpages
$(PKG)_CONFIGURE_OPTIONS += --disable-podpages
$(PKG)_CONFIGURE_OPTIONS += --disable-txtpages

$(PKG)_CONFIGURE_OPTIONS += --disable-mmx
$(PKG)_CONFIGURE_OPTIONS += --disable-mmxext
$(PKG)_CONFIGURE_OPTIONS += --enable-pthreads
$(PKG)_CONFIGURE_OPTIONS += --disable-optimizations
$(PKG)_CONFIGURE_OPTIONS += --enable-small
$(PKG)_CONFIGURE_OPTIONS += --disable-stripping
$(PKG)_CONFIGURE_OPTIONS += --enable-zlib

ifeq ($(strip $(FREETZ_PACKAGE_FFMPEG_SSL_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --enable-openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_FFMPEG_SSL_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
$(PKG)_CONFIGURE_OPTIONS += --enable-mbedtls
endif

ifeq ($(strip $(FREETZ_PACKAGE_FFMPEG_SSL_GNUTLS)),y)
$(PKG)_DEPENDS_ON += gnutls
$(PKG)_CONFIGURE_OPTIONS += --enable-gnutls
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-postproc
$(PKG)_CONFIGURE_OPTIONS += --enable-swscale
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_DECODER_libopenjpeg),--enable-libopenjpeg,--disable-libopenjpeg)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_LZMA),--enable-lzma,--disable-lzma)
$(PKG)_CONFIGURE_OPTIONS += --disable-bsfs
$(PKG)_CONFIGURE_OPTIONS += --disable-devices
$(PKG)_CONFIGURE_OPTIONS += --disable-filters
$(PKG)_CONFIGURE_OPTIONS += --disable-hwaccels

ifeq ($(strip $(FREETZ_PACKAGE_FFMPEG_EVERYTHING)),y)
ifeq ($(strip $(FREETZ_TARGET_GCC_4_8_MIN)),y)
$(PKG)_DEPENDS_ON += libatomic
$(PKG)_CONFIGURE_OPTIONS += --extra-libs="-latomic"
endif
else
$(PKG)_CONFIGURE_OPTIONS += --disable-everything
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_ENCODERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_DECODERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_MUXERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_DEMUXERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_PARSERS)
$(PKG)_CONFIGURE_OPTIONS += $($(PKG)_CONFIGURE_PROTOCOLS)
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_ffmpeg),--enable-ffmpeg,--disable-ffmpeg)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_FFMPEG_ffprobe),--enable-ffprobe,--disable-ffprobe)
$(PKG)_CONFIGURE_OPTIONS += --disable-ffplay


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FFMPEG_DIR) V=1

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(FFMPEG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(call PKG_FIX_LIBTOOL_LA,prefix) $(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lib%.pc)
	$(RM) -r $(FFMPEG_BINARIES_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/%) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/ffmpeg

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(FFMPEG_DIR) clean
	$(RM) -r \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lib%) \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lib%.pc) \
		$(FFMPEG_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*)

$(pkg)-uninstall:
	$(RM) $(FFMPEG_BINARIES_ALL:%=$(FFMPEG_DEST_DIR)/usr/bin/%) $(FFMPEG_LIBNAMES_SHORT:%=$(FFMPEG_TARGET_LIBDIR)/lib%*)

$(PKG_FINISH)
