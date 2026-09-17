# GT_VORTEX Integration in ESP

## Integration Overview

The Vortex integration in ESP is intentionally split into two parts:

* `esp/accelerators/third-party/GT_VORTEX`
  * Third-party accelerator package.
  * Contains the Vortex hardware source tree (ESP fork), wrapper logic, and runtime backend sources.
* `esp/accelerators/rtl/gt_vortex_rtl`
  * Dummy ESP accelerator used to plug Vortex into ESP's existing Linux driver and app build flow.
  * Contains the Linux kernel driver and Linux app build hooks used by `make linux`.

This split is what allows Vortex (which does not ship with ESP-native Linux drivers) to work with ESP's existing `*-driver` and `*-app` infrastructure.

## Software Locations and Existing Tests

To write software for Vortex, it is recommended you clone/use the ESP fork of Vortex, add a new test for your workload, and compile 64-bit Vortex artifacts.

This can produce a C byte-array image flow (legacy), and also `.vxbin` kernels for the Vortex runtime flow.

Software locations:

* Bare-metal apps: `esp/soft/common/apps/baremetal`
* Linux apps (dummy accelerator flow): `esp/accelerators/rtl/gt_vortex_rtl/sw/linux`
* Important Linux note: only `sw/linux/app` is compiled and staged by the ESP Linux flow. `app-fib` and `app-mem` are legacy reference variants.

Available bare-metal tests for Vortex:

* Fibonacci test: `gt_vortex-baremetal`
* Memory read/write test: `gt_vortex_mem-baremetal`
* Floating-point test: `gt_vortex_float-baremetal`

Important note: the checked-in bare-metal tests use prebuilt byte-array images
that are intended for single-core Vortex runs. Unlike the Linux regression tests,
they are not written to be multi-core aware by default, so shared-memory result
checks can produce misleading failures on multi-core configurations unless the
embedded kernel image is updated accordingly.

Available Linux tests for Vortex:

* Regression build/staging flow: `app`
* Fibonacci test: `app-fib`
* Memory read/write test: `app-mem`
* Systolic transformer comparison test: `vortex/tests/regression/systolic_transformer`
* `sw/linux/app` is the canonical regression build entry point used by `make linux`.

## ESP Vortex Runtime Backend

Vortex includes an ESP runtime backend that talks to the `gt_vortex_rtl` driver and uses `/dev/mem` to access the shared Vortex memory window. The backend is built as `libvortex-esp.so` and loaded by the stub `libvortex.so`.

Environment variables:

* `VORTEX_ESP_BASE_ADDR`: physical base address for the Vortex memory window (default `0xA5000000`).
* `VORTEX_ESP_DEV`: accelerator device node (default `/dev/gt_vortex_rtl.0`).
* `VORTEX_ESP_MEM_DEV`: memory device (default `/dev/mem`).
* `VORTEX_ESP_CONTIG_DEV`: contig allocator device (default `/dev/contig_alloc`).

## Vivado Timing-Closure Notes

The ESP `GT_VORTEX_wrapper` no longer enables Xilinx `mark_debug` attributes by
default during synthesis. This avoids preserving large numbers of wrapper nets
in normal timing-closure builds.

If you explicitly want those debug attributes for Vivado/ILA work, enable them
with:

```bash
make vivado-syn GT_VORTEX_ENABLE_MARK_DEBUG=1
```

For timing work on Vivado 2023.2, you can enable the shared ESP timing-closure
profile with:

```bash
make vivado-syn VIVADO_ENABLE_ALL_OPTIMIZATIONS=1
```

Per-knob Vivado optimization controls are documented in
`../../../utils/make/README.md`.

## Build and Stage Vortex Linux Artifacts in ESP

The regression host apps are built via the dummy RTL accelerator flow in:
`esp/accelerators/rtl/gt_vortex_rtl/sw/linux/app`.

1. (Optional, once per Vortex tree) set up Vortex toolchain on a supported host.

```bash
cd esp/accelerators/third-party/GT_VORTEX/vortex
./configure --xlen=64
./ci/toolchain_install.sh --all
# recommended before kernel builds:
source ./ci/toolchain_env.sh
```

2. Build ESP Linux and stage artifacts.

```bash
cd esp/socs/<soc-name>
make linux
```

`make linux` implicitly runs `make gt_vortex_rtl-app` as part of sysroot update. You can also run `make gt_vortex_rtl-app` directly to rebuild only Vortex app/kernel staging.

`gt_vortex_rtl-app` does the following:

* Ensures Vortex is configured (runs `./configure` when needed).
* Builds `libvortex.so` and `libvortex-esp.so`.
* Cross-compiles Vortex regression host apps.
* If kernels are missing and toolchain is available, builds the Vortex kernel support library and regression kernels.
* Copies shared libraries into sysroot `/lib`.
* Installs available kernels into `/applications/test/vortex_kernels/<test>.vxbin`.
* Installs a helper launcher at `/applications/test/vortex-regression` and `/usr/bin/vortex-regression`.

### Configuration consistency requirement (important)

The Vortex software artifacts must be compiled with the same configuration used by the instantiated Vortex hardware.

In ESP this refers to:

* `CONFIG_GT_VORTEX_NUM_CORES`
* `CONFIG_GT_VORTEX_NUM_WARPS`
* `CONFIG_GT_VORTEX_NUM_THREADS`

If host/runtime libraries or `kernel.vxbin` files are built with different values than the hardware instance, tests may fail or behave unpredictably.

`make gt_vortex_rtl-app` forwards these values automatically from the ESP SoC configuration. If you build directly in the Vortex tree, pass matching defines explicitly, for example:

```bash
make CONFIGS="-DESP_GT_VORTEX_NUM_CORES=<C> -DESP_GT_VORTEX_NUM_WARPS=<W> -DESP_GT_VORTEX_NUM_THREADS=<T>" -C kernel
make CONFIGS="-DESP_GT_VORTEX_NUM_CORES=<C> -DESP_GT_VORTEX_NUM_WARPS=<W> -DESP_GT_VORTEX_NUM_THREADS=<T>" -C tests/regression
```

For per-test/manual kernel builds, use the same `CONFIGS` flags when running `make kernel.vxbin`.

3. Run on Ariane Linux image.

```bash
vortex-regression <TESTNAME>
```

Examples:

```bash
vortex-regression --list
vortex-regression basic
vortex-regression printf -n1
vortex-regression systolic_transformer -o gemm_bias_gelu -b 1 -m 64 -d 64 -n 64
vortex-regression systolic_transformer -o attn_prefill -b 1 -m 128 -d 64 -q 128
```

Equivalent explicit form, if you want to bypass the helper:

```bash
export VORTEX_DRIVER=esp
/applications/test/gt_vortex_rtl_vortex_<TESTNAME>.exe -k /applications/test/vortex_kernels/<TESTNAME>.vxbin
```

Useful options:

* Skip auto kernel build (for unsupported toolchain hosts):

```bash
make gt_vortex_rtl-app VORTEX_BUILD_KERNELS=0
```

* Use prebuilt kernels from another machine/tree (`tests/regression/<test>/kernel.vxbin` layout expected):

```bash
make gt_vortex_rtl-app VORTEX_BUILD_KERNELS=0 VORTEX_KERNELS_DIR=/path/to/vortex-tree
```

* Override Vortex configure arguments:

```bash
make gt_vortex_rtl-app VORTEX_CONFIGURE_ARGS="--xlen=64 --tooldir=/path"
```

If a kernel binary is missing, build warns and you can still run tests by passing `-k` with a manually copied `.vxbin`.

## Writing, Compiling, and Running a Custom Vortex Program (ESP Linux)

This is the recommended flow for custom programs.

If your comparison workload is the programmer-view systolic-transformer model in
`systolic_programmer_view/`, this repository now includes a ready-made Vortex
regression at `vortex/tests/regression/systolic_transformer`. It accepts the
original single-kernel modes:

* `-o gemm`
* `-o gemm_gelu`
* `-o gemm_bias_gelu`
* `-o attn_prefill`
* `-o attn_decode`

along with the dimension overrides `-b`, `-m`, `-d`, `-n`, and `-q`.

It also now supports the higher-level programmer-view workload runner:

* `--workload`
* `--model pythia-70m|pythia-160m`
* `--input-len <N>`
* `--output-len <N>`
* `--dry-run`

### 1) Create a new Vortex regression test folder

Add a new folder under:

`esp/accelerators/third-party/GT_VORTEX/vortex/tests/regression/<mytest>`

Typical files:

* `main.cpp`: Linux host-side launcher using Vortex runtime APIs (loads `.vxbin`, allocates buffers, starts kernel).
* `kernel.cpp`: Vortex kernel code.
* `common.h`: shared argument struct(s) between host and kernel.
* `Makefile`: usually copy from a simple existing test (for example `demo`).

Practical starting point:

```bash
cd esp/accelerators/third-party/GT_VORTEX/vortex/tests/regression
cp -r demo mytest
```

Then rename `PROJECT := demo` to `PROJECT := mytest` in `mytest/Makefile`, and update sources.

### 2) Build your custom kernel binary (`kernel.vxbin`)

```bash
cd esp/accelerators/third-party/GT_VORTEX/vortex/tests/regression/mytest
make kernel.vxbin
```

This generates `kernel.vxbin` in `.../tests/regression/mytest/`.

Important detail: auto kernel build from `make gt_vortex_rtl-app` uses Vortex `tests/regression`, which only covers tests listed in `vortex/tests/regression/Makefile`. For brand new tests, either:

* Build `kernel.vxbin` manually as above, or
* Add your test to `vortex/tests/regression/Makefile` so the regression build includes it.

### 3) Stage custom host app and kernel into ESP sysroot

From your SoC directory:

```bash
cd esp/socs/<soc-name>
make gt_vortex_rtl-app VORTEX_TESTS="basic demo dogfood mstress io_addr printf diverge sort fence vecaddx sgemmx conv3x sgemm2x stencil3d mytest"
```

You can shorten `VORTEX_TESTS` to only what you need, for example:

```bash
make gt_vortex_rtl-app VORTEX_BUILD_KERNELS=0 VORTEX_TESTS="mytest"
```

Staged outputs:

* Host app: `/applications/test/gt_vortex_rtl_vortex_mytest.exe`
* Kernel: `/applications/test/vortex_kernels/mytest.vxbin`

### 4) Run custom test on ESP Linux

```bash
vortex-regression mytest
```

If your app supports extra arguments, append them as usual.

## Legacy Byte-Array Flow (Bare-Metal and Legacy Linux App)

Legacy Vortex apps in this repository also use a C byte-array image flow (`input.h` style), where a compiled kernel image is embedded in C and copied into the Vortex memory window directly.

This flow is still useful for:

* Bare-metal experiments under `esp/soft/common/apps/baremetal/*`
* Legacy Linux app variants under `esp/accelerators/rtl/gt_vortex_rtl/sw/linux/app*`

For Linux, remember only `sw/linux/app` is built by ESP's automatic accelerator app flow. If you want to revive one of the legacy byte-array samples, copy that content into `app` intentionally before building Linux.
