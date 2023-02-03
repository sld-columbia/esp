# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a
Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Calendar Versioning](https://calver.org/) with format
`YYYY.MINOR.MICRO`.

## [2023.1.0]

### Added
- **Architecture**
  - New custom I/O Link for ASIC designs and its coexistence with Ethernet (#183)

- **Accelerators**
  - Stratus HLS flow
    - _Sinkhorn_: iterative algorithm used in machine learning to evaluate the correlation and alignment of two different datasets with a focus on their data distribution. (#185)
  - Vivado HLS flow
    - _SVD_ (Singular Value Decomposition): linear algebra algorithm that decomposes/factorizes matrices according to their eigenvalues; commonly used as part of dimensionality reduction algorithms. (#185)

- **Accelerator design flows**
  - Catapult HLS with SystemC and Matchlib flow (#165)

- **ASIC Design, Verification, and Testing**
  - New minimal, technology-independent ASIC design example
  - Synthesizable FPGA proxy design for providing DRAM access to ASIC designs; also used to stimulate JTAG test unit (#177)
  - FPGA emulation of ASIC designs; dual-FPGA emulation infrastructure including FPGA proxy design (#177)

### Improved
- **Architecture**
  - SLM+DDR Tile: fix clock assignments, add configurable delay cells, support accelerator execution (#169)
  - Spandex Caches: fixes and performance improvements (#163)
  - Flexible ASIC clocking strategy with 3 choices: external clock only, single global clock generator, per-tile clock generator
  - JTAG-based debug unit: new implementation to improve robustness (#177)
  - JTAG and NoC synchronizers are now optional for ASIC designs

- **Infrastructure**
  - ESP GUI: add more configuration options and remove dependence on GRLIB GUI

### Fixed
- **Architecture**
  - Various Genus errors and warnings
  - Busy handling from AHB bus in _ahbslv2noc_
  - Combinational loop in Ibex AHB wrapper
  - Ariane L1 cacheable length to support SoCs with and without ESP caches

- **Accelerators**
  - Use correct RTL sources for NVDLA in ASIC designs

- **Infrastructure**
  - Xcelium simulation support
  - Toolchains: fix cloning issue for RISC-V, change default install path to remove _sudo_ dependence

## [2022.1.0]

### Added

- **Architecture**
  - Ariane SMP: enabled by adding ACE bus for L1 invalidations and modifying the ESP cache hierarchy (#146)
  - Hardware monitoring system: new implementation to enable easy access from software (#140)
  - Coherence modes for third-party accelerators: non-coherent DMA, llc-coherent-DMA, coherent-DMA

- **Accelerators**
  - Stratus HLS flow
    - _FFT2_: improves upon the _FFT_ accelerator with support for batching, FFT sizes larger than accelerator private local memory, and inverse FFT

- **Accelerator design flows**
  - RTL accelerator design flow (#123)

- **Software**
  - Python3 support (#124)
  - Monitors API for performance evaluation (#140)
  - OpenSBI support for Ariane-based SoCs (#146)
  - Creation of a baremetal test library for baremetal applications not tied to an ESP accelerator
    - NVDLA with coherence selection
    - Monitors API
    - SLM tile test

### Improved

- **Architecture**
  - Move NoC and JTAG to the top level of the tile (#122)
  - Reset of asynchronous FIFOs

- **Accelerators**
  - Stratus HLS flow
    - _FFT_: add batching
    - _Nightvision_: handle larger image sizes (#130)
  - Increase number of accelerator configuration registers from 14 to 48
  - Ensure accelerator reset is synchronous by adding register to DMA FSM

- **Infrastructure**
  - Use local paths for toolchain installation (#119)
  - Standardize selection of the number of LLC sets across cache implementations

- **Software**
  - Upgrade _riscv-pk_ and update baremetal probe library (#120)

### Fixed
- **Architecture**
  - Overflow issue in _axislv2noc_
  - CPU DMA to SLM tile
  - Proxies for ASIC memory link
  - Various latches and incomplete sensitivity lists

- **Infrastructure**
  - Xcelium compilation

- **Software**
  - RCU stall issue during Linux boot on Ariane mitigated with new kernel configuration
  - Various accelerator applications

## [2021.2.0]

### Added

- **Accelerators**
  - Stratus HLS flow
    - _MRI-Q_: advanced MRI reconstruction algorithm (#112)
    - _Cholesky_: Cholesky decomposition (#113)
    - _Conv2D_: 2D convolution with optional pooling (max or avg), bias addition, and ReLU; supported kernel sizes 1x1, 3x3, or 5x5; supported stride 1x1, or 2x2 (#115)
    - _GeMM_: dense matrix multiplication supporting arbitrary input size and optional ReLU (#115)

- **Accelerator design flows**
  - Bump Stratus HLS version to 20.24 (#114)
  - Bump Xcelium version to 19.03 (#114)
  - Require Xcelium to run unit test of accelerators for Stratus HLS (#114)

- **Cache hierarchy**
  - Handle RISC-V atomic operations (#114)
  - Preliminary support for Spandex caches [[Alsop et al., ISCA'18](https://dl.acm.org/doi/10.1109/ISCA.2018.00031)] (#114)
    (FPGA implementation needs to improve to meet timing)

- **Scratchpad (shared-local memory) tile**
  - Optional LPDDR controller from Basejump STL [[Taylor, DAC'18](https://dl.acm.org/doi/10.1145/3195970.3199848)] (#114)

- **ASIC Design**
  - Template design for ASIC flow (requires access to GF12 technology) (#114)
  - Chip-to-FPGA link that replaces on-chip DDR controllers when not available for the target technology (#114)
  - Digital clock oscillator (DCO) instance (#114)
  - Technology-specific SRAM wrappers (#114)
  - Technology-specific PAD wrappers with configuration pins and orientation selection (#114)
  - Preliminary FPGA proxy design to simulate the chip-to-FPGA link (#114)
  - Single tile, trace-based simulation target to test the chip JTAG debug interface (#114)
  - SDF back-annotation of user-selected IPs (#114)

- **NoC Architecture**
  - Increased reserved field of the packet headers from 4 to 8 bits (#114)
    - Support up to 256 interrupt lines
    - Support Spandex extended message types

### Fixed

- **Cache hierarchy**
  - Fix NoC header parsing in LLC wrapper (#103)
  - Update HLS constraints for the ESP caches in SystemC


## [2021.1.1]

### Added

- **Ibex**
        - Enable ESP cache hierarchy with Ibex core (#92)

### Fixed

- **Toolchain scripts**
        - Update URL of Leon3 prebuilt files (#96)

- **Cache hierarchy**
        - Fix endianness of the SystemC implementation for instances of ESP using a RISC-V core (#92)

- **Ibex**
        - Use Xilinx primitives for Ibex implementation on FPGA
        - Disable ESP L2 invalidation master port on AHB bus (#92)

- **Infrastructure*
        - Fix link update of the object dump used in full-system RTL simulations (#93)
        - Save HLS log files for the cache hierarchy into log folder
        - Restore optimized floorplanning for proFPGA XCVU440 (#94)


## [2021.1.0]

### Added

- **Accelerator design flows**
  - Keras/Pytorch/ONNX with [hls4ml](https://fastmachinelearning.org/hls4ml/)
    - Accelerator templates
    - Accelerator and test applications generation with AccGen
    - [Tutorial](https://www.esp.cs.columbia.edu/docs/hls4ml/)
  - C/C++ with Xilinx Vivado HLS
    - Accelerator templates
    - Accelerator and test applications skeleton generation with AccGen
    - [Tutorial](https://www.esp.cs.columbia.edu/docs/cpp_acc/)
    - Sample accelerators: adder (element-wise addition)
  - C/C++ with Mentor Catapult HLS
    - [Tutorial](https://www.esp.cs.columbia.edu/docs/mentor_cpp_acc/)
  - SystemC with Cadence Stratus HLS
    - Accelerator templates ([includes](https://github.com/sld-columbia/esp-accelerator-templates), skeleton templates)
    - Accelerator and test applications skeleton generation with AccGen
    - [Tutorial](https://www.esp.cs.columbia.edu/docs/systemc_acc/)
    - Sample accelerators: dummy (identity mapping), fft (Fast Fourier Transform 1D), sort, spmv (sparse matrix-vector multiplication), synth (synthetic traffic generator), nightvision (night-vision kernels), vitbfly2 (Viterbi butterfly), vitdodec (Viterbi decoder)
  - Chisel
      - [Accelerator templates](https://github.com/sld-columbia/esp-chisel-accelerators)
      - Sample accelerators: adder (element-wise addition), counter, fft (Fast Fourier Transform 1D)
- **Third-party accelerator integration flow**
  - Supported accelerator interfaces: AXI for the memory interface, AXI-Lite and APB for the configuration interface
  - [Tutorial](https://www.esp.cs.columbia.edu/docs/thirdparty_acc/)
  - Sample accelerators: [NVDLA](http://nvdla.org/)
- **SoC design flow**
  - High-level SoC configuration (batch or GUI)
  - Automatic SoC generation
  - Push-button full-system RTL simulation of bare-metal programs
    - Supported simulators: Mentor Modelsim SE, Cadence Incisive, Cadence Xcelium
  - Push-button FPGA bitstream generation
    - Supported FPGA tools: Xilinx Vivado
- **Architecture**
  - NoC
    - Packet-switched NoC with lookahead routing, single-cycle hop, and configurable bitwidth
    - ESP SoCs use 6 bidirectional physical NoC planes
      - 3 for cache coherence messages (32-bits or 64-bits based on processor architecture)
      - 2 for DMA messages (32-bits or 64-bits based on processor architecture)
      - 1 32-bit plane for the other messages (interrupts, memory-mapped IO and configuration registers)
  - Processor tile
    - Processor
      - Available options: 32-bit [Leon3](https://www.gaisler.com/index.php/products/processors/leon3) (Sparc v8) with ESP FPU, 64-bit [Ariane](https://github.com/openhwgroup/cva6) (RISC-V), 32-bit [Ibex](https://github.com/lowRISC/ibex) (RISC-V)
    - L2 private cache (optional)
      - NoC-based directory-based MESI protocol
      - Available implementations: [SystemVerilog](https://github.com/sld-columbia/esp-caches/tree/master/l2), [SystemC](https://github.com/sld-columbia/esp-caches/tree/master/systemc/l2)
    - Bus
      - Memory request bus options: AXI, AHB
      - Memory-mapped IO requests bus options: APB
    - Support for SoCs with multiple processor tiles
  - Accelerator tile
    - Accelerator (see accelerator design flow options above)
    - Accelerator socket
      - Accelerator configuration registers (default registers + user-defined registers)
      - Miss-free accelerator TLB for low-overhead virtual memory support
      - Accelerator DMA engine
      - Private cache (optional)
        - Same as the L2 private cache in the processor tile
      - Cache coherence
        - Supported options: coherent with private cache, coherent DMA, LLC-coherent DMA, non-coherent DMA
        - Configurable at run-time
      - Point-to-point accelerator communication
        - Configurable at run-time
    - Support for SoCs with multiple accelerator tiles
  - Third-party accelerator tile
    - Accelerator socket
      - Bus-to-NoC bridges
        - Memory requests bus options: AXI
        - Memory-mapped IO requests bus options: AXI-Lite, APB
    - Support for SoCs with multiple third-party accelerator tiles
  - Memory tile
    - Last-level cache (LLC) slice (optional)
      - NoC-based directory-based MESI protocol
      - Support for coherent DMA and LLC-coherent DMA
      - Available implementations: [SystemVerilog](https://github.com/sld-columbia/esp-caches/tree/master/llc), [SystemC](https://github.com/sld-columbia/esp-caches/tree/master/systemc/llc)
    - Memory channel
      - Optionally include AHB bus and memory controller in the memory tile
    - Memory simulation model for full-system RTL simulation
    - Support for all accelerator cache-coherence options
    - Support for SoCs with multiple memory tiles
      - Up to 2 memory tiles on proFPGA Virtex7 XC7V2000T FPGA module and up to 4 memory tiles on proFPGA Virtex UltraScale XCVU440 FPGA module
  - Auxiliary tile
    - Peripherals: Ethernet, UART, DVI (only on proFPGA FPGA modules with DVI interface board)
    - ESP Link debug unit
    - SoC initialization unit
    - Interrupt controller: Leon3 multiprocessor interrupt controller or RISC-V platform interrupt controller
    - Timer: GRLIB general-purpose timer or [RISC-V core-local interrupt controller](https://github.com/sld-columbia/ariane/tree/master/src/clint)
    - Frame buffer
  - Scratchpad (shared-local memory) tile
    - Shared software-managed addressable memory
    - Support for multiple SLM tiles
    - SLM can replace external memory when configuring ESP with no memory tiles and selecting the Ibex core
  - Additional SoC services
    - ESP tile CSRs: memory mapped and accessible from software
      - Configuration registers: PADs configuration, clock generators configuration, tile ID configuration, core ID configuration (processor tile only), Ethernet and UART scalers configuration (auxiliary tile only), soft reset
      - Performance counters: accelerators activity, caches hit and miss rates, memory accesses, NoC routers traffic, dynamic voltage-frequency scaling operation
      - With proFPGA FPGA modules, performance counters can be accessed via Ethernet as well through an MMI64-based monitor interface (see ESP software tools below)
    - NoC adapters: AXI (to-NoC), AHB (to-NoC, from-NoC), APB (to-NoC, from-NoC), DMA (to/from-NoC), interrupt line (to-NoC, from-NoC)
    - Other adapters: APB-to-AXI-Lite, custom memory link for ESP instances w/o integrated DDR controller (link-to-AHB, cache/DMA-to-link)
    - NoC queues in every tile (processor, accelerator, memory, auxiliary, scratchpad)
    - Dynamic Voltage-Frequency Scaling controller in every tile
    - Single-tile test unit in every tile
- **ESP software stack**
  - Support for Ariane, Leon3, and Ibex processors
  - Linux SMP support (Ariane and Leon3 only)
  - Bare-metal support
  - Multi-core support (Leon3 only)
    - Leon3 bare-metal multi-core test suite
  - Accelerator-specific software
    - ESP accelerator device driver
    - LibESP: the ESP accelerator invocation API
      - 3 functions: `esp_alloc`, `esp_run`, `esp_free`
      - Manage the execution of multiple accelerators in parallel and/or in a pipeline
    - Bare-metal unit-test sample applications for accelerators
    - Linux unit-test sample applications for accelerators
    - Multi-accelerator Linux applications examples
- **ESP software tools**
  - AccGen: accelerator skeleton generator, including testbench, device driver and test applications
  - PLMGen: multi-port and multi-bank memory generator for SystemC accelerators
    - SoCGen: configure and generate an ESP SoC (batch or GUI)
  - SocketGen: generate the RTL for some of the ESP tile sockets
  - ESPLink: debug link via Ethernet from a host machine
  - ESPMon: collection of hardware performance monitors accessed via Ethernet through the proFPGA MMI64 interface (batch or GUI)
- **Supported FPGA development boards**
  - Xilinx Virtex UltraScale+ FPGA VCU118
  - Xilinx Virtex UltraScale+ FPGA VCU128
  - Xilinx Virtex-7 FPGA VC707
  - proFPGA [Virtex7 XC7V2000T](https://www.profpga.com/products/fpga-modules-overview/virtex-7-based/profpga-xc7v2000t)
  - proFPGA [Virtex Ultrascale XCVU440](https://www.profpga.com/products/fpga-modules-overview/virtex-ultrascale-based/profpga-xcvu440)
    - Xilinx Zynq UltraScale+ MPSoC ZCU102 (WIP)
    - Xilinx Zynq UltraScale+ MPSoC ZCU106 (WIP)
- **Supported OS**
  - CentOS 7 (recommended)
  - Red Hat Enterprise Linux 7.8
  - Ubuntu 18.04 (Cadence Stratus HLS not fully supported)
