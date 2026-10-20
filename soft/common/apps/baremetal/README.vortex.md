# Bare-Metal Vortex Tests

This note documents the Vortex-focused bare-metal apps in this folder:

* `gt_vortex/`
* `gt_vortex_mem/`
* `gt_vortex_float/`
* `gt_vortex_wstrb_test/`

## Common Execution Model

All four tests use the same pattern:

1. Probe the accelerator (`DEV_NAME = "GATech,gt_vortex"`).
2. Allocate a DDR buffer with `aligned_malloc`.
3. Initialize that buffer from `input.h`.
4. Program wrapper registers through APB/MMIO:
  * `VX_BASE_ADDR` (`0x50`): base pointer of the DDR image.
  * `VX_SOFT_RESET` (`0x54`): start pulse (`START_VORTEX = 1`).
  * Optional DCR slots (`0x60` onward) are left at `0` in these tests.
5. Poll `VX_BUSY_INT` (`0x58`) until bit 0 goes low.
6. Refresh cache state with `esp_flush(coh)` before CPU-side validation.
7. Read result words at fixed offsets inside the same DDR image.

The `input.h` files are byte-array snapshots of prebuilt Vortex program/data images, embedded directly into C.

## Why Fixed Offsets Are Used

These tests intentionally use known offsets (for example `mem_top + 0x1fa0`) instead of dynamic allocation. The paired Vortex kernels and host code agree on this static layout so bring-up can be validated with minimal software dependencies.

## Test-Specific Notes

### `gt_vortex/vortex_fib_test_all_64.c`

* CPU computes reference Fibonacci.
* Input value is written at `mem_top + 0x1f98`.
* Vortex result is read at `mem_top + 0x1fa0`.
* Test reports mismatch count against CPU golden output.

### `gt_vortex_mem/vortex_mem_test_all_64.c`

* Verifies 64-bit memory pattern updates.
* Reads three slots before and after kernel execution:
  * `0x1b78`, `0x1b70`, `0x1b68`.
* Expected transition is from small seed values (`0xA`, `0xB`, `0xC`) to full 64-bit patterns (`0xAAAAAAAAAAAAAAAA`, etc.).

### `gt_vortex_float/vortex_float_test.c`

* Focuses on floating-point behavior with one 64-bit result slot.
* Observes value at `0x1b38` before/after execution.

### `gt_vortex_wstrb_test/vortex_wstrb_test.c`

* Focuses on write behavior/pattern updates in 32-bit slots.
* Observes:
  * `0x1b58`, `0x1b54`, `0x1b50`
* Expected post-run values are `0xAAAAAAAA`, `0xBBBBBBBB`, `0xCCCCCCCC`.

## Coherence Setup

Before launch, each app reads the accelerator `COHERENCE_REG` capability (`0x20`) and selects mode from the active SoC configuration:

* `ACC_COH_RECALL` when the accelerator reports recall/full coherence support.
* `ACC_COH_LLC` when only LLC-coherent DMA is supported.
* `ACC_COH_NONE` otherwise.

The selected mode is written through ESP monitor registers and then `esp_flush(coh)` is called
both before launch and again after completion. The post-run flush is required for the bare-metal
debug/validation flow because reading seeded output locations before launch can repopulate stale
CPU cache lines when caches are enabled.
