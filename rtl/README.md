# RTL

This directory contains the whole ESP RTL codebase, excluding the
accelerators RTL and the RTL generated in the working folder by the
SoCGen and SocketGen tools.

This directory is organized as follows:

* `tiles` contains the top module of each tile type. It also contains
  the flexible top level module (`esp.vhd`) that combines tiles into a
  tile grid, based on the selected SoC configuration.

* `noc` contains the network-on-chip (NoC) that connects tiles
  together. This is the main on-chip interconnect. Each tile contains
  a NoC rounter with multiple physical planes.

* `sockets` contains the components of the tile sockets. The tile
  socket is placed between the main component of the tile
  (e.g. processor core, accelerator) and the system interconnect. The
  socket decouples the tile content from the rest of the system by
  taking care of the communication with the NoC and by providing
  various services to the tile, like configuration registers,
  performance counters, dynamic voltage-frequency scaling, address
  translation and direct memory access (DMA).

* `cores` contains the available processor cores.

* `caches` contains the directory-based cache hierarchy.

* `peripherals` contains peripheral components (DDR controller,
  Ethernet, UART, DVI) and other centralized components hosted by the
  auxiliary (or I/O) tile (interrupt controller, timer).

* `misc` contains small miscellaneous components, including on-chip
  memory arrays and some minor components of the auxiliary tile.

* `techmap` contains technology specific components for the supported
  FPGA and ASIC targets.

* `sim` contains simulation-only models and components.
