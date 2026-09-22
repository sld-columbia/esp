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
  from inside the working folders in `socs`. Vivado timing-closure
  controls are documented in `make/README.md`.

* `scripts` contains a few useful scripts that can come in handy,
  including the Quartus project and programming helpers in
  `scripts/quartus` and the HPS boot artifact flow, U-Boot overlay and
  device tree sources in `scripts/hps`.

* `toolchain` contains the scripts to install the software toolchain
  for each of the available processors. Host prerequisites and the
  workarounds needed on newer distributions are documented in
  `toolchain/README.md`.

* `zynq` contains various software utilities for the ARM core on the
  Xilinx Zynq UltraScale+ MPSoC ZCU102 and ZCU106. These are needed
  when deploying an ESP SoC on the programmable logic of these Zynq
  boards.

## Host tools

Beyond a compiler and the usual build utilities, a few Make targets shell out
to host programs that are not always installed by default:

* `make uart` and `make xuart` open a console on the UART of a remote FPGA.
  They need `socat`, which bridges the board's TCP UART to a local pty, and
  `minicom`, which attaches to it. `make xuart` additionally needs `xterm`,
  since it runs `minicom` in its own window. Both targets require `UART_IP`
  and `UART_PORT` to be set in the board Makefile.

* `make grlib-xconfig` and the other Tk configuration targets need `wish`.
  Non-interactive regeneration falls back to `tclsh` when `xvfb-run` is not
  available, so a headless host needs neither `wish` nor an X display.

* The toolchain build scripts have their own prerequisites, including some
  that are easy to miss on recent distributions. See `toolchain/README.md`.

```sh
# Debian / Ubuntu
sudo apt-get install minicom socat xterm

# RHEL / AlmaLinux / Rocky
sudo dnf install minicom socat xterm
```
