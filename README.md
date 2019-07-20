

![Open-ESP](esp-logo-small.png)

ESP is an open-source platform for heterogeneous SoC design and prototype on
FPGA. It provides a flexible tile-based architecture built on a multi-plane
network-on-chip.

In addition to the architecture, ESP provides users with templates and scripts
to create new accelerators from SystemC, Chisel, and C.
The ESP design methodology eases the integration process by offering platform
services, such as DMA, distributed interrupt, and run-time coherence selection,
that hide the complexity of hardware and software integration from the
accelerator designer.

Currently, ESP supports multi-core [Leon3](https://www.gaisler.com/index.php/downloads/leongrlib) processor from GRLIB, based on the
SPARC V8 32-bits ISA, and single-core [Ariane](https://github.com/pulp-platform/ariane) processor from Pulp Platform,
based on the RISC-V 64-bits ISA.

In addition to processor cores, ESP embeds accelerator design examples created
with Stratus HLS in SystemC, and Chisel.

A [Quick Start Guide](www.esp.cs.columbia.edu/docs) is available on the [Open-ESP website](www.esp.cs.columbia.edu).
Complete documentation and tutorials will be released periodically to help users
get the most out of ESP.

## Stay tuned for the new features under development:

   - Multi-core [Ariane](https://github.com/pulp-platform/ariane) RISC-V
   - NVDIA Deep Learning Accelerator [NVDLA](http://nvdla.org/) integration
   - Vivado HLS accelerator design and integration
