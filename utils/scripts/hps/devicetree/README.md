# DE10-Pro SX Device Tree

This directory tracks the standalone GPL-2.0-only DTS for the DE10-Pro SX boot
DTB. It is derived from Terasic's public `linux-socfpga` `de10_pro_revD`
device-tree sources and adds the ESP reserved-memory and HPS-to-FPGA MMIO
nodes.

The standalone file follows Terasic's DE10-Pro board DTS plus the shared
Stratix 10 include, with the Linux reset, clock, and GPIO binding constants
inlined numerically so it can be built directly with `dtc`. The ESP-specific
board-level additions are:

```text
esp_mem: esp-mem@180000000
esp: esp@2000000000
```

Unused HPS USB0 and HPS LED user I/O are not enabled because the board shell
does not expose those HPS pins.

Build the local DTB from the board directory:

```sh
make hps-dtb
```

The full HPS boot-artifact flow also builds this DTB as part of `make hps`.
The generated DTB is written to `local/boot/socfpga_stratix10_de10_pro.dtb`;
compiled `*.dtb` files are not tracked.
