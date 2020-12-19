# Utils

This directory contains various scripts and utilities, including the
main Makefiles, the RTL file lists, and the toolchains installation
scripts for each of the available processors.

* `flist` contains RTL file lists useful for compiling the RTL source
  code. These lists do not contain the RTL files generated during the
  ESP accelerators and SoC design flows. The generated RTL files get
  discovered dynamically by the Makefiles in `utils/make`.

* `grlib_tkconfig` contains a tool part of GRLIB by Cobham Gaisler. In
  the context of ESP this tools is used mainly to configure the
  Ethernet MAC and IP of the debug unit, which allows a host machine
  to control the ESP SoC via Ethernet.

* `Makefile`, together with the Makefiles in `make`, are the main
  Makefiles of the repository. All Make targets should be launched
  from inside the working folders in `socs`.

* `scripts` contains a few useful scripts that can come in handy.

* `toolchain` contains the scripts to install the software toolchain
  for each of the available processors.

* `zynq` contains various software utilities for the ARM core on the
  Xilinx Zynq UltraScale+ MPSoC ZCU102 and ZCU106. These are needed
  when deploying an ESP SoC on the programmable logic of these Zynq
  boards.
