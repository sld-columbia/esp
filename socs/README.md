# SoC Working Directories

Each directory under `socs` is a build workspace for one supported FPGA board
or ASIC target. Run ESP configuration, software, simulation, synthesis, and
programming targets from the selected directory.

## FPGA Boards

| Directory | Target |
| --- | --- |
| `terasic-de10-pro-sx` | Terasic DE10-Pro SX, Intel Stratix 10 SX 280 |
| `profpga-xc7v2000t` | proFPGA Virtex-7 XC7V2000T |
| `profpga-xcvu440` | proFPGA Virtex UltraScale XCVU440 |
| `profpga-xcvu19p` | proFPGA Virtex UltraScale+ XCVU19P |
| `xilinx-vc707-xc7vx485t` | Xilinx VC707, Virtex-7 XC7VX485T |
| `xilinx-vcu118-xcvu9p` | Xilinx VCU118, Virtex UltraScale+ XCVU9P |
| `xilinx-vcu128-xcvu37p` | Xilinx VCU128, Virtex UltraScale+ XCVU37P |
| `xilinx-zcu102-xczu9eg` | Xilinx ZCU102, Zynq UltraScale+ XCZU9EG (work in progress) |
| `xilinx-zcu106-xczu7ev` | Xilinx ZCU106, Zynq UltraScale+ XCZU7EV (work in progress) |

## ASIC Targets

| Directory | Target |
| --- | --- |
| `esp_asic_generic` | Generic ASIC project template |
| `blitzcoin_asic_3x3` | BlitzCoin 3x3 ASIC example |
| `epochs0-gf12` | EPOCHS-0 GlobalFoundries 12LP project |

The board or technology wrapper normally lives in `top.vhd` and instantiates
the ESP tile array from `rtl/tiles/esp.vhd`. Default ESP configurations are
stored in `socs/defconfig` and selected through the `BOARD` value in each local
Makefile.
