$(call PKG_INIT_LIB, $(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),2.32.4,2.88.3))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),0.3200.4,0.8800.3)
$(PKG)_MAJOR_VERSION:=2.0
$(PKG)_SOURCE:=glib-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=a5d742a4fda22fb6975a8c0cfcd2499dd1c809b8afd4ef709bda4d11b167fae2
$(PKG)_HASH_CURRENT:=ab24d24e698dfa1e408b7bcdb508f4aafc906185a8b8ce72fdf79bbbdc9b383b
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://download.gnome.org/sources/glib/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION)),ftp://ftp.gnome.org/pub/gnome/sources/glib/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### VERSION:=2.32.4/2.88.3
### WEBSITE:=https://www.gnu.org/software/libc/
### MANPAGE:=https://docs.gtk.org/glib/
### CHANGES:=https://gitlab.gnome.org/GNOME/glib/blob/main/NEWS
### CVSREPO:=https://gitlab.gnome.org/GNOME/glib

$(PKG)_CATEGORY_LIBS:=libc##GLib2

$(PKG)_LIBNAMES_SHORT := glib gio gobject gmodule gthread $(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),,girepository)
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT:%=lib%-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)
$(PKG)_PKGCONFIGS_SHORT := $($(PKG)_LIBNAMES_SHORT) gmodule-no-export gmodule-export gio-unix

$(PKG)_DEPENDS_ON += wget-host
$(PKG)_DEPENDS_ON += libffi zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),abandon,current)

ifeq ($(strip $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON)),y)
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/%/.libs/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_DEPENDS_ON += pcre

# NB: glib2 does require iconv-functions, see glib/gconvert.c
# The configure option "--with-libiconv=no" means
# "do use the implementation provided by C library", i.e. by uClibc.
# As freetz' builds of uClibc prior to and excluding 0.9.29 do not
# provide them, we must use an extra library - the gnu-libiconv.
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=gnu
else
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv=no
endif

$(PKG)_CONFIGURE_ENV += glib_cv_stack_grows=no
$(PKG)_CONFIGURE_ENV += glib_cv_uscore=no
$(PKG)_CONFIGURE_ENV += glib_cv_long_long_format=11
$(PKG)_CONFIGURE_ENV += glib_cv_have_strlcpy=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_mmap_fixed=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_printf_unix98=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_vsnprintf_c99=yes
$(PKG)_CONFIGURE_ENV += glib_cv_pcre_has_unicode=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-debug=no
$(PKG)_CONFIGURE_OPTIONS += --disable-mem-pools
$(PKG)_CONFIGURE_OPTIONS += --disable-rebuilds
$(PKG)_CONFIGURE_OPTIONS += --with-threads=posix
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-html
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-doc-pdf
$(PKG)_CONFIGURE_OPTIONS += --disable-man
$(PKG)_CONFIGURE_OPTIONS += --disable-fam
$(PKG)_CONFIGURE_OPTIONS += --disable-gcov
$(PKG)_CONFIGURE_OPTIONS += --disable-included-printf
$(PKG)_CONFIGURE_OPTIONS += --disable-selinux
$(PKG)_CONFIGURE_OPTIONS += --disable-xattr
$(PKG)_CONFIGURE_OPTIONS += --disable-dtrace
$(PKG)_CONFIGURE_OPTIONS += --disable-systemtap
$(PKG)_CONFIGURE_OPTIONS += --with-pcre=system

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

else
$(PKG)_LIBS_BUILD_DIR := $(join $($(PKG)_LIBNAMES_SHORT:%=$($(PKG)_DIR)/builddir/%/),$($(PKG)_LIBNAMES_LONG))
$(PKG)_DEPENDS_ON += python3-host python3-packaging-host meson-host
$(PKG)_DEPENDS_ON += pcre2 gettext

#$(PKG)_CONFIGURE_OPTIONS += -D iconv=libc
$(PKG)_CONFIGURE_OPTIONS += -D selinux=disabled
$(PKG)_CONFIGURE_OPTIONS += -D xattr=false
$(PKG)_CONFIGURE_OPTIONS += -D libmount=disabled
$(PKG)_CONFIGURE_OPTIONS += -D man-pages=disabled
$(PKG)_CONFIGURE_OPTIONS += -D dtrace=disabled
$(PKG)_CONFIGURE_OPTIONS += -D systemtap=disabled
$(PKG)_CONFIGURE_OPTIONS += -D sysprof=disabled
$(PKG)_CONFIGURE_OPTIONS += -D documentation=false
$(PKG)_CONFIGURE_OPTIONS += -D bsymbolic_functions=false
$(PKG)_CONFIGURE_OPTIONS += -D tests=false
$(PKG)_CONFIGURE_OPTIONS += -D installed_tests=false
$(PKG)_CONFIGURE_OPTIONS += -D nls=disabled
$(PKG)_CONFIGURE_OPTIONS += -D oss_fuzz=disabled
$(PKG)_CONFIGURE_OPTIONS += -D glib_debug=disabled
$(PKG)_CONFIGURE_OPTIONS += -D glib_assert=false
$(PKG)_CONFIGURE_OPTIONS += -D glib_checks=false
$(PKG)_CONFIGURE_OPTIONS += -D libelf=disabled
$(PKG)_CONFIGURE_OPTIONS += -D multiarch=false
#$(PKG)_CONFIGURE_OPTIONS += -D force_posix_threads=true

$(PKG)_CONFIGURE_POST_CMDS += $(call PKG_PREVENT_MESON_BUILD_RPATH,builddir/build.ninja)
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(if $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON),$(PKG_CONFIGURED_CONFIGURE),$(PKG_CONFIGURED_MESON))

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
ifeq ($(strip $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON)),y)
	$(SUBMAKE) -C $(GLIB2_DIR) \
		all
else
	$(SUBMESON) compile \
		-C $(GLIB2_DIR)/builddir/
endif

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
ifeq ($(strip $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON)),y)
	$(SUBMAKE) -C $(GLIB2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%-$(GLIB2_MAJOR_VERSION).la) \
		$(GLIB2_PKGCONFIGS_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc)
else
	$(SUBMESON) install \
		--destdir "$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(GLIB2_DIR)/builddir/
	$(PKG_FIX_LIBTOOL_LA) \
		$(GLIB2_PKGCONFIGS_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc)
endif

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
ifeq ($(strip $(FREETZ_LIB_libglib_2_WITH_VERSION_ABANDON)),y)
	-$(SUBMAKE) -C $(GLIB2_DIR) clean
else
	-$(SUBNINJA) -C $(GLIB2_DIR)/builddir/ clean
endif
	$(RM) -r \
		$(GLIB2_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%-$(GLIB2_MAJOR_VERSION)*) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/gdbus-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/gio \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gio-unix-$(GLIB2_MAJOR_VERSION) \
		\
		$(GLIB2_PKGCONFIGS_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%-$(GLIB2_MAJOR_VERSION).pc) \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/glib-* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gio-* \
		\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/glib-$(GLIB2_MAJOR_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/glib*

$(pkg)-uninstall:
	$(RM) $(GLIB2_LIBNAMES_SHORT:%=$(GLIB2_TARGET_DIR)/lib%-$(GLIB2_MAJOR_VERSION).so*)

$(PKG_FINISH)
