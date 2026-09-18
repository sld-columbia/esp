# Manual Bambu dataflow accelerator

`peek_dd` squares unsigned 32-bit words modulo 2^32. Load, compute and store
execute concurrently, with two 16-word banks at each stage boundary. A depth-one
control FIFO carries the bank index: `peek()` claims a bank and `read()` releases
it. The producer can fill the other bank while the consumer owns the first, but
cannot publish it and reuse the first bank until the consumer releases it.

Use Bambu `feature/unified_ac_channels`. Validation used revision
`4150ff6e20d543eb5d241df7085046b6a355f283`, Clang 16 and Verilator 4.038.

## ESP contract

The generated core exports active-low reset, start/done and four AXIS channels.
The handwritten `peek_dd_basic_dma64` wrapper adapts those channels to ESP. APB
registers, interrupt/status handling, scatter-gather translation and NoC DMA are
provided by ESP's generated socket and `esp_acc_dma`, not by the Bambu core.

| Register | Offset | Meaning |
|---|---|---|
| len | 0x40 | Positive multiple of 16, in 32-bit words |
| base_in | 0x44 | Input offset in 64-bit DMA beats |
| base_out | 0x48 | Output offset in 64-bit DMA beats |

Every request transfers eight 64-bit beats (16 words); descriptor bits 63:32
hold length, bits 31:0 hold index. The wrapper supplies `size=3`, `user=0`.
Use disjoint input/output regions. The caller must enforce valid lengths and
allocated address bounds. Invalid lengths are not rejected by hardware.

## Build and validate

From the ESP root, with the normal ESP CAD/RISC-V environment enabled:

```bash
export BAMBU=/path/to/unified_ac_channels/install/bin/bambu
export BAMBU_ENV=/path/to/unified_ac_channels/install/settings.sh
make -C socs/xilinx-vc707-xc7vx485t peek_dd-hls
make -C socs/xilinx-vc707-xc7vx485t peek_dd-sim
bash accelerators/bambu_hls/peek_dd/hw/tb/run_dma_test.sh
make -C socs/xilinx-vc707-xc7vx485t esp-defconfig \
  ESP_DEFCONFIG="$PWD/socs/defconfig/esp_xilinx-vc707-peek_dd_defconfig"
make -C socs/xilinx-vc707-xc7vx485t socketgen peek_dd-baremetal
make -C socs/xilinx-vc707-xc7vx485t sim \
  TEST_PROGRAM="$PWD/socs/xilinx-vc707-xc7vx485t/soft-build/ariane/baremetal/peek_dd.exe"
make -C socs/xilinx-vc707-xc7vx485t vivado-syn
```

The SoC configuration selects one Ariane CPU, one memory tile, one IO tile and
one `PEEK_DD basic_dma64` tile, with caches disabled and 64-bit DMA.
ModelSim must match the version used to compile the cached Xilinx libraries.
For an existing Vivado project, use `vivado-update` to rebuild it.

`peek_dd-exe` is a one-bank native smoke test. Sequential C execution cannot
represent concurrent shared-array ownership over many batches. `peek_dd-sim`
therefore uses `BAMBU_SKIP_VERIFICATION` to disable Bambu's sequential C model
comparison while retaining the testbench's independent descriptor and numerical
checks on RTL outputs. It checks 272 distinct words. Bambu co-simulation needs
32-bit C++ linking support; the validation report documents this machine's
local linker-path workaround. Do not interpret the skip flag as numerical
validation: the explicit oracle and separate DMA test provide that evidence.

The DMA test runs six invocations for each of three seeds, checks every memory
word (including untouched input and guards), descriptor indices/lengths/size,
stable payloads under stalls, done ordering, repeated starts and a watchdog.
Lengths are 16, 48, 128 and 272 words. Read and write delays vary independently;
the final write beat is stalled for up to 257 cycles. The test requires observed
load/store overlap and nonzero stall coverage. It runs against installed RTL.

The baremetal application allocates a DMA buffer/page table, programs the ESP
and accelerator registers, runs three 272-word invocations on RISC-V, and checks
unsigned square results with a bounded completion poll. The expected final UART
line is `peek_dd PASS total_errors=0`. ESP's simulation harness subsequently
prints `Failure: Program Completed!` as its normal termination assertion; check
the application verdict before treating that assertion as success.

The validation campaign deployed this design on a VC707 and observed the
baremetal PASS verdict. Board programming remains environment-specific; use
the project's normal `fpga-program` and `fpga-run` targets with the connection
details for the reserved board.
