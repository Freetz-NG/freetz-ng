pkg:=ripgrep
$(pkg)_VERSION:="14.1.1"
$(pkg): 
	RUSTFLAGS=$(RUSTFLAGS) cargo install --root $(CARGO_DIR)/ --target $(RUST_STATIC_TARGET_TRIPLE) $@ --version $($(@)_VERSION)
$(pkg)-uninstall:
	cargo uninstall --root $(CARGO_DIR)/ ripgrep

ifeq ($(FREETZ_PACKAGE_RIPGREP),y) 
RUSTPACKAGES+=$(pkg)
endif
