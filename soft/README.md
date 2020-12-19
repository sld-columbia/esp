# Soft

This directory contains the software source code for running
bare-metal programs and Linux applications on each of the available
processor cores. It also contains the software libraries for invoking
and managing accelerators.

* `ariane`: bootloader, Linux kernel and root file system, and
  bare-metal library for the 64-bit RISC-V
  [_CVA6_](https://github.com/openhwgroup/cva6) processor, maintained
  by the OpenHW Group and originally developed by ETH Zurich under the
  name _Ariane_.

* `ibex`: bootloader and bare-metal library for the 32-bit RISC-V
  [_Ibex_](https://github.com/lowRISC/ibex) processor, maintained by
  lowRISC and originally developed by ETH Zurich under the name
  _Zero-riscy_.

* `leon3`: bootloader, Linux kernel and root file system, and
  bare-metal library for the
  [_LEON3_](https://www.gaisler.com/index.php/products/processors/leon3)
  processor by Cobham Gaisler.

* `common`: bare-metal and Linux user space and kernel space libraries
  for invoking and managing accelerators.
