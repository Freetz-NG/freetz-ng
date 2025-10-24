$(call PKG_INIT_LIB, $(if $(FREETZ_LIB_libiconv_WITH_VERSION_ABANDON),1.13.1,1.18))
$(PKG)_LIB_VERSION_ABANDON:=2.5.0
$(PKG)_LIB_VERSION_CURRENT:=2.7.0
$(PKG)_LIB_VERSION:=$($(PKG)_LIB_VERSION_$(if $(FREETZ_LIB_libiconv_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SOURCE:=lib$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=55a36168306089009d054ccdd9d013041bfc3ab26be7033d107821f1c4949a49
$(PKG)_HASH_CURRENT:=3b08f5f4f9b4eb82f151a7040bfd6fe6c6fb922efe4b1659c66ea933276965e8
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libiconv_WITH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@GNU/lib$(pkg)
### VERSION:=1.13.1/1.18
### WEBSITE:=https://www.gnu.org/software/libiconv/
### MANPAGE:=https://www.gnu.org/savannah-checkouts/gnu/libiconv/documentation/
### CHANGES:=https://ftp.gnu.org/pub/gnu/libiconv/
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=libiconv.git

$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv/lib/libiconv.so.$($(PKG)_LIB_VERSION)

# Depend on the iconv package which builds the library
$(PKG)_DEPENDS_ON += iconv

$($(PKG)_STAGING_BINARY): iconv

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:

$(pkg)-clean:

$(pkg)-uninstall:

$(PKG_FINISH)