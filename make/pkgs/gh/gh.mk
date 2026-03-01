$(call PKG_INIT_BIN, 2.83.2)
$(PKG)_SOURCE:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=c031ca887d3aaccb40402a224d901c366852f394f6b2b60d1158f20569e33c89
$(PKG)_HASH:=$($(PKG)_SOURCE_SHA256)
$(PKG)_SITE:=https://github.com/cli/cli/archive/refs/tags
$(PKG)_DIR:=$(SOURCE_DIR)/cli-$($(PKG)_VERSION)
### WEBSITE:=https://cli.github.com/
### MANPAGE:=https://cli.github.com/manual/
### CHANGES:=https://github.com/cli/cli/releases
### CVSREPO:=https://github.com/cli/cli
### SUPPORT:=ircama

$(PKG)_BINARY:=$($(PKG)_DIR)/bin/gh
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/gh

$(PKG)_GO_VERSION := 1.23.4

$(PKG)_DEPENDS_ON += go-host

# Rebuild when target architecture changes
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_ARCH_MIPS
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_ARCH_ARM
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_ARCH_X86
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_ARCH_AARCH64

# Set Go cross-compilation environment variables based on target architecture
# MIPS: GOARCH=mips, GOMIPS=softfloat (for MIPS32 compatibility)
# ARM: GOARCH=arm, GOARM=6 (or 7 with NEON)
# X86: GOARCH=386
# AARCH64: GOARCH=arm64
$(PKG)_GO_OS := linux
$(PKG)_GO_ARCH := $(if $(FREETZ_TARGET_ARCH_MIPS),mips,$(if $(FREETZ_TARGET_ARCH_ARM),arm,$(if $(FREETZ_TARGET_ARCH_X86),386,$(if $(FREETZ_TARGET_ARCH_AARCH64),arm64,unknown))))
$(PKG)_GO_MIPS := $(if $(FREETZ_TARGET_ARCH_MIPS),softfloat,)
$(PKG)_GO_ARM := $(if $(FREETZ_TARGET_ARCH_ARM),$(if $(FREETZ_TARGET_ARCH_ARM_NEON),7,6),)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	@echo "Building gh with Go $(GH_GO_VERSION)..."
	cd $(GH_DIR); \
	export PATH=$(TOOLS_DIR)/go-host/bin:$$PATH; \
	GOOS=$(GH_GO_OS) \
	GOARCH=$(GH_GO_ARCH) \
	$(if $(GH_GO_MIPS),GOMIPS=$(GH_GO_MIPS),) \
	$(if $(GH_GO_ARM),GOARM=$(GH_GO_ARM),) \
	CGO_ENABLED=0 \
	go build \
		-v \
		-ldflags="-s -w -X github.com/cli/cli/v2/internal/build.Version=$(GH_VERSION)" \
		-o bin/gh \
		./cmd/gh

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $($(PKG)_DIR) clean
	$(RM) $($(PKG)_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
