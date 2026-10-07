$(call TOOLS_INIT, $(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),0.14.5,0.19.2))
# remove patchelf-target-host when fixed !
# BE(?) broken since
# "Rework file shifting to avoid sections crossing multiple segments"
# https://github.com/NixOS/patchelf/commit/109b771f53ee3d37ede8c0f165665605183c0975
# fail: 7390-MIPS(BE) + 6360-ARMEB
# okay: 7170-MISPEL + 4040-ARM(LE) + 6430-Ix86 + 5690XGS-AARCH64(LE)
#for x in source/target-*/busybox-*/busybox; do
# echo "##### $x"
# cp "$x" ./busybox
# tools/patchelf ./busybox --set-interpreter /usr/lib/freetz/ld-uClibc.so.1
# readelf -l ./busybox #>/dev/null
#done
# readelf: Error: the PHDR segment is not covered by a LOAD segment
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=b9a46f2989322eb89fa4f6237e20836c57b455aa43a32545ea093b431d982f5c
$(PKG)_HASH_CURRENT:=d4ad9a4e5c689e09119ce2f30a94b0e8b4f98c78590123ea21665e34c6928801
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION)
### VERSION:=0.14.5/0.19.2
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/releases
### CVSREPO:=https://github.com/NixOS/patchelf
### STEWARD:=fda77

$(PKG)_SRC_BINARY := $($(PKG)_DIR)/src/patchelf
$(PKG)_DST_BINARY := $(TOOLS_DIR)/patchelf

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),abandon,current)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_PATCHELF_VERSION_ABANDON

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)


#
$(TOOLS_SOURCE_DOWNLOAD)
#
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_SRC_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCHELF_HOST_DIR) all

$($(PKG)_DST_BINARY): $($(PKG)_SRC_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_DST_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(PATCHELF_HOST_DST_BINARY)

$(TOOLS_FINISH)
