# SoCs

This directory contains the working folders where all ESP Make targets
are launched from. There is one working folder for each supported FPGA
board or ASIC technology:

* `profpga-xc7v2000t`: proFPGA [Virtex7 XC7V2000T
  FPGA](https://www.profpga.com/products/fpga-modules-overview/virtex-7-based/profpga-xc7v2000t)

* `profpga-xcvu440`: proFPGA [Virtex Ultrascale XCVU440
  FPGA](https://www.profpga.com/products/fpga-modules-overview/virtex-ultrascale-based/profpga-xcvu440)

* `xilinx-vc707-xc7vx485t`: Xilinx Virtex-7 FPGA VC707

* `xilinx-vcu118-xcvu9p`: Xilinx Virtex UltraScale+ FPGA VCU118

* `xilinx-vcu128-xcvu37p`: Xilinx Virtex UltraScale+ FPGA VCU128

* `xilinx-zcu102-xczu9eg`: Xilinx Zynq UltraScale+ MPSoC ZCU102 (WIP)

* `xilinx-zcu106-xczu7ev`: Xilinx Zynq UltraScale+ MPSoC ZCU106 (WIP)

Each working folder contains `top.vhd`, a wrapper specific to each FPGA
or ASIC target. `top.vhd` wraps the top level module of the SoC
(`rtl/tiles/esp.vhd`), which combines tiles into a tile grid, based
on the selected SoC configuration.

The `defconfig` folder contains the default SoC configurations for
each of the FPGA or ASIC targets.
