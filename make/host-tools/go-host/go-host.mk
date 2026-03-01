$(call TOOLS_INIT, 1.23.4)
$(PKG)_SOURCE:=go$($(PKG)_VERSION).linux-amd64.tar.gz
$(PKG)_HASH:=6924efde5de86fe277676e929dc9917d466efa02fb934197bc2eba35d5680971
$(PKG)_SITE:=https://go.dev/dl
### WEBSITE:=https://go.dev/
### MANPAGE:=https://go.dev/doc/
### CHANGES:=https://go.dev/doc/devel/release
### CVSREPO:=https://github.com/golang/go
### SUPPORT:=ircama

$(PKG)_BINARY:=$($(PKG)_DIR)/bin/go
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/go-host/bin/go

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	@echo "Using pre-built Go toolchain"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	@mkdir -p $(TOOLS_DIR)/go-host
	cp -a $(GO_HOST_DIR)/bin $(TOOLS_DIR)/go-host/
	cp -a $(GO_HOST_DIR)/src $(TOOLS_DIR)/go-host/
	cp -a $(GO_HOST_DIR)/pkg $(TOOLS_DIR)/go-host/ 2>/dev/null || true
	cp -a $(GO_HOST_DIR)/lib $(TOOLS_DIR)/go-host/ 2>/dev/null || true
	cp -a $(GO_HOST_DIR)/go.env $(TOOLS_DIR)/go-host/ 2>/dev/null || true

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) -r $(TOOLS_DIR)/go-host

$(pkg)-dirclean:
	$(RM) -r $(GO_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(TOOLS_DIR)/go-host

$(TOOLS_FINISH)
