rustup:
	@# if RUST_STATIC_TARGET_TRIPLE is set then add the target to the toolchain
	@[ -n "$(RUST_STATIC_TARGET_TRIPLE)" ] && rustup target add $(RUST_STATIC_TARGET_TRIPLE) || true
		