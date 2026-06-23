# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

CROSS_COMPILE ?= riscv64-unknown-linux-gnu-

# ESP tree roots and integration paths.
ESP_ROOT ?= $(abspath ../../../../../..)
VORTEX_ROOT ?= $(ESP_ROOT)/accelerators/third-party/GT_VORTEX/vortex
DRIVERS ?= $(ESP_ROOT)/soft/common/drivers/linux
DESIGN_PATH ?= $(ESP_ROOT)

BUILD_PATH ?= $(abspath ./build)
SYSROOT ?= $(abspath $(BUILD_PATH)/../../../..)/sysroot

CXX := $(CROSS_COMPILE)g++
CC := $(CROSS_COMPILE)gcc

# Runtime libraries produced from the Vortex tree.
VORTEX_RT_OUT ?= $(BUILD_PATH)/vortex_runtime
LIBVORTEX := $(VORTEX_RT_OUT)/libvortex.so
LIBVORTEX_ESP := $(VORTEX_RT_OUT)/libvortex-esp.so

VORTEX_CONFIGURE_ARGS ?= --xlen=64
VORTEX_BUILD_KERNELS ?= auto
VORTEX_KERNELS_DIR ?=
GT_VORTEX_CONFIGS ?=
ifeq ($(strip $(GT_VORTEX_CONFIGS)),)
GT_VORTEX_CONFIGS := -DESP_GT_VORTEX_NUM_CORES=1
GT_VORTEX_CONFIGS += -DESP_GT_VORTEX_NUM_WARPS=4
GT_VORTEX_CONFIGS += -DESP_GT_VORTEX_NUM_THREADS=4
endif

# Regression tests to cross-compile and stage into ESP sysroot.
VORTEX_TESTS ?= basic demo dogfood mstress io_addr printf diverge sort fence vecaddx sgemmx conv3x sgemm2x stencil3d systolic_transformer

VORTEX_TEST_BINS := $(addprefix $(BUILD_PATH)/vortex_,$(addsuffix .exe,$(VORTEX_TESTS)))

CXXFLAGS += -std=c++11 -O2 -DNDEBUG -Wall -Wextra -pedantic
CXXFLAGS += -I$(VORTEX_ROOT)/runtime/include
CXXFLAGS += -I$(VORTEX_ROOT)/hw
CXXFLAGS += $(GT_VORTEX_CONFIGS)

VORTEX_HW_CONFIG := $(VORTEX_ROOT)/hw/VX_config.h
VORTEX_HW_TYPES := $(VORTEX_ROOT)/hw/VX_types.h

VORTEX_LDFLAGS += -L$(VORTEX_RT_OUT) -lvortex -ldl -pthread

VORTEX_CONFIG_MK := $(VORTEX_ROOT)/config.mk
VORTEX_MAKEFILE := $(VORTEX_ROOT)/Makefile
VORTEX_CONFIGURE := $(VORTEX_ROOT)/configure
VORTEX_BUILD_CONFIG_STAMP := $(BUILD_PATH)/.esp_gt_vortex_configs
VORTEX_KERNEL_CONFIG_STAMP := $(VORTEX_ROOT)/tests/regression/.esp_gt_vortex_configs
VORTEX_KERNEL_BUILD_SIGNATURE := $(strip $(GT_VORTEX_CONFIGS))

all: legacy_apps vortex_libs vortex_tests install_kernels install_runner

# Build legacy C sample app(s) if present in this folder.
legacy_apps:
	@if [ -f gt_vortex.c ]; then \
		APPNAME=gt_vortex BUILD_PATH=$(BUILD_PATH) DRIVERS=$(DRIVERS) DESIGN_PATH=$(DESIGN_PATH) \
			CROSS_COMPILE=$(CROSS_COMPILE) CPU_ARCH=$(CPU_ARCH) \
			$(MAKE) -f $(DRIVERS)/common.mk; \
	fi

vortex_config:
	@if [ ! -f "$(VORTEX_CONFIG_MK)" ] || [ ! -f "$(VORTEX_MAKEFILE)" ]; then \
		if [ ! -x "$(VORTEX_CONFIGURE)" ]; then \
			echo "[WARN] Vortex configure script not found: $(VORTEX_CONFIGURE)"; \
			exit 1; \
		fi; \
		echo "[Vortex] configuring ($(VORTEX_CONFIGURE_ARGS))"; \
		(cd "$(VORTEX_ROOT)" && ./configure $(VORTEX_CONFIGURE_ARGS)); \
	fi

vortex_config_state: vortex_config
	@mkdir -p $(BUILD_PATH)
	@if [ ! -f "$(VORTEX_BUILD_CONFIG_STAMP)" ] || ! grep -Fqx -- "$(strip $(GT_VORTEX_CONFIGS))" "$(VORTEX_BUILD_CONFIG_STAMP)"; then \
		echo "[Vortex] configuration changed; rebuilding host/runtime artifacts"; \
		rm -f "$(LIBVORTEX)" "$(LIBVORTEX_ESP)" "$(VORTEX_HW_CONFIG)" "$(VORTEX_HW_TYPES)"; \
		rm -f $(VORTEX_TEST_BINS); \
		printf '%s\n' "$(strip $(GT_VORTEX_CONFIGS))" > "$(VORTEX_BUILD_CONFIG_STAMP)"; \
	fi

vortex_libs: vortex_config_state $(VORTEX_HW_CONFIG) $(VORTEX_HW_TYPES) $(LIBVORTEX) $(LIBVORTEX_ESP)
	@cp -f $(LIBVORTEX) $(LIBVORTEX_ESP) .

$(LIBVORTEX): vortex_config_state
	@mkdir -p $(VORTEX_RT_OUT)
	$(MAKE) -C $(VORTEX_ROOT)/runtime/stub DESTDIR=$(VORTEX_RT_OUT) CXX=$(CXX) CONFIGS="$(GT_VORTEX_CONFIGS)"

$(LIBVORTEX_ESP): vortex_config_state
	@mkdir -p $(VORTEX_RT_OUT)
	$(MAKE) -C $(VORTEX_ROOT)/runtime/esp DESTDIR=$(VORTEX_RT_OUT) CXX=$(CXX) ESP_ROOT=$(ESP_ROOT) DESIGN_PATH=$(DESIGN_PATH) CONFIGS="$(GT_VORTEX_CONFIGS)"

vortex_tests: $(VORTEX_TEST_BINS)

$(BUILD_PATH)/vortex_%.exe: vortex_config_state $(VORTEX_ROOT)/tests/regression/%/main.cpp $(LIBVORTEX) $(VORTEX_HW_CONFIG) $(VORTEX_HW_TYPES)
	@mkdir -p $(BUILD_PATH)
	$(CXX) $(CXXFLAGS) -I$(VORTEX_ROOT)/tests/regression/$* $(VORTEX_ROOT)/tests/regression/$*/main.cpp -o $@ $(VORTEX_LDFLAGS)

$(VORTEX_HW_CONFIG) $(VORTEX_HW_TYPES): vortex_config_state
	$(MAKE) -C $(VORTEX_ROOT)/hw config CONFIGS="$(GT_VORTEX_CONFIGS)"

vortex_kernels: vortex_config_state
	# Build kernel.vxbin files in the Vortex tree when required/available.
	@VORTEX_ROOT="$(VORTEX_ROOT)"; \
	if [ "$(VORTEX_BUILD_KERNELS)" = "0" ]; then \
		if [ ! -f "$(VORTEX_KERNEL_CONFIG_STAMP)" ] || ! grep -Fqx -- "$(VORTEX_KERNEL_BUILD_SIGNATURE)" "$(VORTEX_KERNEL_CONFIG_STAMP)"; then \
			echo "[WARN] VORTEX_BUILD_KERNELS=0 with config/build-option mismatch; ensure prebuilt kernels match: $(VORTEX_KERNEL_BUILD_SIGNATURE)"; \
		fi; \
		echo "[Vortex] kernel build disabled (VORTEX_BUILD_KERNELS=0)"; \
		exit 0; \
	fi; \
	if [ "$(VORTEX_BUILD_KERNELS)" = "auto" ] && [ -n "$(VORTEX_KERNELS_DIR)" ]; then \
		if [ ! -d "$(VORTEX_KERNELS_DIR)/tests/regression" ]; then \
			echo "[WARN] VORTEX_KERNELS_DIR should contain tests/regression (Vortex layout)"; \
		fi; \
		echo "[Vortex] VORTEX_KERNELS_DIR set; skipping auto kernel build"; \
		exit 0; \
	fi; \
	missing=0; \
	if [ ! -f "$(VORTEX_KERNEL_CONFIG_STAMP)" ] || ! grep -Fqx -- "$(VORTEX_KERNEL_BUILD_SIGNATURE)" "$(VORTEX_KERNEL_CONFIG_STAMP)"; then \
		missing=1; \
		echo "[Vortex] kernel build configuration changed; forcing regression kernel rebuild"; \
	fi; \
	if [ $$missing -eq 0 ]; then \
		for t in $(VORTEX_TESTS); do \
			test_dir="$$VORTEX_ROOT/tests/regression/$$t"; \
			kernel_bin="$$test_dir/kernel.vxbin"; \
			if [ ! -f "$$kernel_bin" ]; then \
				missing=1; \
				break; \
			fi; \
			if find "$$test_dir" -maxdepth 1 -type f \
				\( -name 'Makefile' -o -name '*.h' -o -name '*.hpp' -o -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.S' \) \
				-newer "$$kernel_bin" -print -quit | grep -q .; then \
				missing=1; \
				echo "[Vortex] $$t sources changed; rebuilding regression kernels"; \
				break; \
			fi; \
		done; \
	fi; \
	if [ $$missing -eq 0 ]; then \
		exit 0; \
	fi; \
	if [ "$(VORTEX_BUILD_KERNELS)" = "auto" ]; then \
		tool_dir=$$(awk -F'=' '/^TOOLDIR/ {gsub(/^[ \t]+|[ \t]+$$/, "", $$2); print $$2; exit}' "$(VORTEX_CONFIG_MK)" 2>/dev/null); \
		xlen=$$(awk -F'=' '/^XLEN/ {gsub(/^[ \t]+|[ \t]+$$/, "", $$2); print $$2; exit}' "$(VORTEX_CONFIG_MK)" 2>/dev/null); \
		llvm_bin="$$tool_dir/llvm-vortex/bin/clang"; \
		riscv_bin="$$tool_dir/riscv$${xlen}-gnu-toolchain/bin/riscv$${xlen}-unknown-elf-gcc"; \
		if [ -n "$$tool_dir" ] && [ -n "$$xlen" ] && { [ ! -x "$$llvm_bin" ] || [ ! -x "$$riscv_bin" ]; }; then \
			echo "[WARN] Vortex toolchain not found under $$tool_dir; skipping kernel build"; \
			exit 0; \
		fi; \
		if [ "$$xlen" = "64" ]; then \
			ld64=$$(command -v riscv64-unknown-elf-ld 2>/dev/null || true); \
			gcc64=$$(command -v riscv64-unknown-elf-gcc 2>/dev/null || true); \
			ld32=$$(command -v riscv32-unknown-elf-ld 2>/dev/null || true); \
			if [ -z "$$ld64" ]; then \
				if [ -n "$$ld32" ]; then \
					echo "[ERROR] riscv64-unknown-elf-ld not found on PATH; riscv32-unknown-elf-ld found at $$ld32"; \
				else \
					echo "[ERROR] riscv64-unknown-elf-ld not found on PATH"; \
				fi; \
				echo "[ERROR] Kernel build requires RV64 toolchain. Fix toolchain env or PATH ordering."; \
				exit 1; \
			fi; \
			if [ -z "$$gcc64" ]; then \
				echo "[ERROR] riscv64-unknown-elf-gcc not found on PATH"; \
				echo "[ERROR] Kernel build requires RV64 toolchain. Fix toolchain env or PATH ordering."; \
				exit 1; \
			fi; \
		fi; \
	fi; \
	echo "[Vortex] building regression kernels"; \
	(cd "$$VORTEX_ROOT" && $(MAKE) CONFIGS="$(GT_VORTEX_CONFIGS)" software) || { echo "[WARN] Vortex software build failed"; exit 0; }; \
	(cd "$$VORTEX_ROOT" && $(MAKE) CONFIGS="$(GT_VORTEX_CONFIGS)" tests) || { echo "[WARN] Vortex tests build failed"; exit 0; }; \
	printf '%s\n' "$(VORTEX_KERNEL_BUILD_SIGNATURE)" > "$(VORTEX_KERNEL_CONFIG_STAMP)"

install_kernels: vortex_kernels
	# Stage kernels under the path expected by Linux test executables.
	@mkdir -p $(SYSROOT)/applications/test/vortex_kernels
	@for t in $(VORTEX_TESTS); do \
		if [ -n "$(VORTEX_KERNELS_DIR)" ]; then \
			bin="$(VORTEX_KERNELS_DIR)/tests/regression/$$t/kernel.vxbin"; \
		else \
			bin="$(VORTEX_ROOT)/tests/regression/$$t/kernel.vxbin"; \
		fi; \
		if [ -f "$$bin" ]; then \
			cp -f $$bin $(SYSROOT)/applications/test/vortex_kernels/$$t.vxbin; \
		else \
			echo "[WARN] Missing kernel for $$t: $$bin"; \
		fi; \
	done

install_runner:
	@mkdir -p $(SYSROOT)/applications/test $(SYSROOT)/usr/bin
	@cp -f ./vortex-regression $(SYSROOT)/applications/test/vortex-regression
	@cp -f ./vortex-regression $(SYSROOT)/usr/bin/vortex-regression
	@chmod a+x $(SYSROOT)/applications/test/vortex-regression $(SYSROOT)/usr/bin/vortex-regression

clean:
	@rm -rf $(BUILD_PATH)
	@rm -f ./libvortex.so ./libvortex-esp.so

.PHONY: all legacy_apps vortex_config vortex_config_state vortex_libs vortex_tests vortex_kernels install_kernels install_runner clean
