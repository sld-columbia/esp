

![Open-ESP](esp-logo-small.png)

The [ESP website](https://www.esp.cs.columbia.edu) contains the complete information on the ESP project. The [documentation](https://www.esp.cs.columbia.edu/docs) page contains detailed guides and video tutorials that will be released periodically to help users get the most out of ESP.

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

Furthermore, ESP can serve as a platform to integrate third-party IP blocks.
As an example, ESP integrates the NVDIA Deep Learning Accelerator [NVDLA](http://nvdla.org/),
which can be placed on any ESP accelerator tile.

## Stay tuned for the new features under development:

   - Multi-core [Ariane](https://github.com/pulp-platform/ariane) RISC-V
   - Automatic integration of accelerators generated with hls4ml from Keras/Tensorflow and Pytorch
   - Support for Digilent Genesys2 FPGA board
