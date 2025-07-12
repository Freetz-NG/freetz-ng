$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_GIT_VERSION_ABANDON),2.26.2,2.50.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=6d65132471df9e531807cb2746f8be317e22a343b9385bbe11c9ce7f0d2fc848
$(PKG)_HASH_CURRENT:=7e3e6c36decbd8f1eedd14d42db6674be03671c2204864befa2a41756c5c8fc4
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_GIT_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@KERNEL/software/scm/git
### WEBSITE:=https://www.git-scm.com/
### MANPAGE:=https://www.git-scm.com/docs
### CHANGES:=https://github.com/git/git/tree/master/Documentation/RelNotes
### CVSREPO:=https://github.com/git/git
### SUPPORT:=fda77

# files to be moved from /usr/lib/git-core to /usr/bin
$(PKG)_FILES_TO_MOVE := git-daemon
# files to be symlinked from /usr/lib/git-core to /usr/bin in order to reduce package size
$(PKG)_FILES_TO_SYMLINK := git git-shell git-upload-pack git-cvsserver $($(PKG)_FILES_TO_MOVE)

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/git
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/git

$(PKG)_DEPENDS_ON += curl expat openssl zlib
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif
ifeq ($(strip $(FREETZ_PACKAGE_GIT_WITH_PCRE)),y)
$(PKG)_DEPENDS_ON += pcre
endif

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_GIT_REMOVE_WEBIF),etc/default.git etc/init.d/rc.git usr/lib/cgi-bin/git.cgi)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_GIT_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_GIT_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_GIT_WITH_PCRE
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHORT_VERSION
$(PKG)_REBUILD_SUBOPTS += $(filter FREETZ_LIB_libcurl_%,$(CURL_REBUILD_SUBOPTS))

$(PKG)_CONFIGURE_ENV += ac_cv_c_c99_format=yes
$(PKG)_CONFIGURE_ENV += ac_cv_fread_reads_directories=no
$(PKG)_CONFIGURE_ENV += ac_cv_snprintf_returns_bogus=no

# https://gitlab.com/gitlab-org/gitlab-git/-/commit/79444c92943048f9ac62e9311038ebe43f5f0982
#
# Makefile option ICONV_OMITS_BOM exists since years but gets tested/set by configure only since 2.25.0
# Note the proper semantic of the option is:
#  iconv implementation does not write a byte-order mark (BOM)
#  when writing UTF-16 or UTF-32 and always writes in big-endian format.
#
# This is true for big-endian uClibc (tested with ac_cv_iconv_omits_bom.c from target-tester).
# The value is unknown for little endian boxes and for libiconv (used by uClibc-0.9.28 based boxes),
# set it to "no" for these boxes as this is what we "did" so far by not setting ICONV_OMITS_BOM.
$(PKG)_CONFIGURE_ENV += ac_cv_iconv_omits_bom=$(if $(FREETZ_TARGET_ARCH_BE),yes,no)

$(PKG)_CONFIGURE_OPTIONS += --with-gitconfig=/tmp/flash/gitconfig
$(PKG)_CONFIGURE_OPTIONS += --enable-pthreads
$(PKG)_CONFIGURE_OPTIONS += --with-curl
$(PKG)_CONFIGURE_OPTIONS += --with-expat
$(PKG)_CONFIGURE_OPTIONS += --with-iconv
$(PKG)_CONFIGURE_OPTIONS += --with-openssl
ifeq ($(strip $(FREETZ_PACKAGE_GIT_WITH_PCRE)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-libpcre="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-perl
$(PKG)_CONFIGURE_OPTIONS += --without-python
$(PKG)_CONFIGURE_OPTIONS += --without-tcltk

$(PKG)_MAKE_PARAMS := V=1 NO_NSEC=1 STRIP="$(TARGET_STRIP)" NO_INSTALL_HARDLINKS=y
$(PKG)_MAKE_PARAMS += NO_LIBPCRE1_JIT=1
$(PKG)_MAKE_PARAMS += EXTRA_CFLAGS="-ffunction-sections -fdata-sections" EXTRA_LDFLAGS="-Wl,--gc-sections"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	for target in all strip; do \
		$(SUBMAKE) -C $(GIT_DIR) $(GIT_MAKE_PARAMS) $$target; \
	done

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(SUBMAKE) -C $(GIT_DIR) $(GIT_MAKE_PARAMS) \
		DESTDIR=$(abspath $(GIT_DEST_DIR)) \
		install \
	&& \
	for binary in $(GIT_FILES_TO_MOVE); do \
		mv $(GIT_DEST_DIR)/usr/lib/git-core/$$binary $(GIT_DEST_DIR)/usr/bin/; \
	done \
	&& \
	for binary in $(GIT_FILES_TO_SYMLINK); do \
		rm -f $(GIT_DEST_DIR)/usr/lib/git-core/$$binary \
		&& ln -fs ../../bin/$$binary $(GIT_DEST_DIR)/usr/lib/git-core/; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(GIT_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(GIT_DEST_DIR)/usr/{bin,lib}/git*

$(PKG_FINISH)

