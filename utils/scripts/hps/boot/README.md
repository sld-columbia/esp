# DE10-Pro SX HPS Boot Overlay

`make hps-boot` copies the files in `u-boot-overlay/` on top of the pinned
Altera U-Boot source before building the DE10-Pro SX SPL HEX and U-Boot FIT
image.

The overlay is board specific. It currently carries the DE10-Pro SX changes
needed by ESP:

- disable the Stratix 10 SPL watchdog configuration used by the stock
  defconfig
- account for the board's DDR4 clamshell rank encoding when calculating SDRAM
  size
- enable the HPS-to-FPGA and FPGA-to-SDRAM bridge path needed by the ESP HPS
  loader
- select the Stratix 10 F2SDRAM reset-manager branch in SPL builds
- open non-secure MPU access to the F2SDRAM sideband manager after DDR setup
- open the F2SDRAM0 DDR firewall window used by ESP's FPGA-to-SDRAM traffic

The U-Boot replacement files retain their upstream GPL-2.0 license. Generated
artifacts are written under `local/boot/` and must not be committed.
