$(call PKG_INIT_BIN, $(if $(FREETZ_AVM_GCC_13),13.4.0,$(if $(FREETZ_AVM_GCC_14),14.3.0,15.2.0)))
$(PKG)_CONDITIONAL:=y
$(PKG)_CATEGORY:=Debug helpers

# Package definition for GCC toolchain on target device
# This packages the GCC cross-compiler for installation on target MIPS Fritz!Box

# Hardcoded paths for simplicity and reliability
TOPDIR?=.
GCC_TOOLCHAIN_TARGET_UTILS_DIR:=$(TOPDIR)/toolchain/build/mips_gcc-13.4.0_uClibc-1.0.55-nptl_kernel-4.9/mips-linux-uclibc/target-utils
GCC_TOOLCHAIN_DEST_DIR:=$(TOPDIR)/packages/target-mips_gcc-13.4.0_uClibc-1.0.55-nptl_kernel-4.9/gcc-toolchain-13.4.0/root
GCC_TOOLCHAIN_BINARY:=$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/gcc
GCC_TOOLCHAIN_TARGET_BINARY:=$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/gcc
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/gcc

$(PKG)_EXTERNALIZE_FILES:=usr/bin/* usr/lib/* usr/libexec/* $(if $(FREETZ_PACKAGE_GCC_TOOLCHAIN_HEADERS),usr/include/*)


# Determine the toolchain target triplet
GCC_TOOLCHAIN_TARGET_TRIPLET := $(REAL_GNU_TARGET_NAME)


# No source to download - we reuse the existing toolchain
# So we skip PKG_SOURCE_DOWNLOAD, PKG_UNPACKED, PKG_CONFIGURED_NOP

# Ensure the native MIPS toolchain is built
$($(PKG)_BINARY): gcc_target binutils_target uclibc_target

$(GCC_TOOLCHAIN_TARGET_BINARY): $(GCC_TOOLCHAIN_BINARY)
	@echo "Packaging GCC toolchain from $(GCC_TOOLCHAIN_TARGET_UTILS_DIR)..."
	
	# Create necessary directories
	mkdir -p $(GCC_TOOLCHAIN_DEST_DIR)/usr/bin
	mkdir -p $(GCC_TOOLCHAIN_DEST_DIR)/usr/lib
	mkdir -p $(GCC_TOOLCHAIN_DEST_DIR)/usr/libexec
	
	# Copy GCC compiler binaries (gcc, g++, cpp)
	@echo "  - Copying GCC binaries..."
	for bin in gcc g++ cpp gcov gcov-tool gcov-dump; do \
		if [ -f "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" ]; then \
			cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" \
			      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/$$bin"; \
		fi; \
	done
	
	# Create symlinks for C++ (c++ -> g++, cc -> gcc)
	ln -sf gcc "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/cc"
	[ -f "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/g++" ] && ln -sf g++ "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/c++" || true
	
	# Copy binutils if not minimal
ifneq ($(strip $(FREETZ_PACKAGE_GCC_TOOLCHAIN_MINIMAL)),y)
	@echo "  - Copying binutils..."
	for bin in as ld ar ranlib nm objdump objcopy strip strings readelf addr2line; do \
		if [ -f "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" ]; then \
			cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" \
			      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/$$bin"; \
		fi; \
	done
else
	@echo "  - Copying essential binutils (minimal mode)..."
	for bin in as ld ar ranlib; do \
		if [ -f "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" ]; then \
			cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/bin/$$bin" \
			      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/bin/$$bin"; \
		fi; \
	done
endif
	
	# Copy GCC libraries (libgcc_s, libstdc++, etc.)
	@echo "  - Copying GCC libraries..."
	if [ -d "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/lib/gcc" ]; then \
		cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/lib/gcc" \
		      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/lib/"; \
	fi
	
	# Copy runtime libraries
	for lib in libgcc_s.so* libstdc++.so* libgomp.so* libatomic.so*; do \
		if [ -e "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/lib/$$lib" ]; then \
			cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/lib/$$lib" \
			      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/lib/"; \
		fi; \
	done
	
	# Copy libexec (compiler internal programs: cc1, cc1plus, collect2, lto1)
	@echo "  - Copying compiler internals..."
	if [ -d "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/libexec/gcc" ]; then \
		cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/libexec/gcc" \
		      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/libexec/"; \
	fi
	
	# Copy headers if requested
	@echo "  - Copying development headers..."
	mkdir -p $(GCC_TOOLCHAIN_DEST_DIR)/usr/include
	
	# Copy C/C++ standard library headers
	if [ -d "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/include" ]; then \
		for dir in c++ bits gnu linux asm asm-generic; do \
			if [ -e "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/include/$$dir" ]; then \
				cp -a "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/include/$$dir" \
				      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/include/"; \
			fi; \
		done; \
		find "$(GCC_TOOLCHAIN_TARGET_UTILS_DIR)/usr/include" -maxdepth 1 -type f \
		     -exec cp -a {} "$(GCC_TOOLCHAIN_DEST_DIR)/usr/include/" \; ; \
	fi
	
	# Copy Python headers if requested
	@echo "  - Copying Python headers..."
	if [ -d "toolchain/target/usr/include/python3.13" ]; then \
		cp -a "toolchain/target/usr/include/python3.13" \
		      "$(GCC_TOOLCHAIN_DEST_DIR)/usr/include/"; \
	fi
	
	@echo "GCC toolchain packaged successfully!"
	
	@echo "GCC toolchain packaged successfully!"

gcc-toolchain: $(GCC_TOOLCHAIN_TARGET_BINARY)

gcc-toolchain-precompiled: $(GCC_TOOLCHAIN_TARGET_BINARY)

gcc-toolchain-clean:
	$(RM) -r $(GCC_TOOLCHAIN_DEST_DIR)

gcc-toolchain-uninstall:
	$(RM) -r $(GCC_TOOLCHAIN_DEST_DIR)

.PHONY: gcc-toolchain gcc-toolchain-precompiled gcc-toolchain-clean gcc-toolchain-uninstall
