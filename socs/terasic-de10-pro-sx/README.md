# Terasic DE10-Pro SX

## Overview

This directory contains ESP board support for the Terasic DE10-Pro SX with an
Altera Stratix 10 SX 280 FPGA (`1SX280HU2F50E1VG`).

Quartus Prime Pro 19.4 is the validated tool version. Newer releases may work,
but the checked-in Quartus Platform Designer project and HPS boot files were
generated with 19.4.

The port supports:

- Quartus synthesis and programming
- Remote JTAG access
- Loading ESP bootrom and payload images from HPS Linux
- Ariane bare-metal and Linux payloads
- Ibex bare-metal payloads
- LEON3 bare-metal payloads

The listed payload configurations have been validated on this board.

The Intel/Altera flow currently supports only accelerators built with the RTL or
Third Party flow. HLS flows are not supported yet because they rely on Xilinx/AMD
HLS mappings and components that are incompatible with Intel/Altera. HLS support
for Intel/Altera may be added in the future.

## Directory Layout

| Path | Purpose |
| --- | --- |
| `top.vhd` | ESP wrapper and HPS FPGA-to-SDRAM connection |
| `quartus/` | Quartus project, Platform Designer system, and programming scripts |
| `quartus/software/` | HPS boot-partition files |
| `quartus/fan/` | Autonomous Terasic fan-controller logic |
| `hps/` | HPS-side ESP image loader and register access utility |

Quartus source assignments are generated from ESP's current RTL graph by
`make quartus-srcs`. Do not add a second hand-maintained ESP source list to the
Quartus project.

## Build and Program

Run board targets from `socs/terasic-de10-pro-sx`:

```sh
make esp-defconfig
make quartus-syn
make fpga-program
```

Useful related targets are:

```sh
make quartus-setup       # Refresh the Quartus source assignments
make quartus-gui         # Refresh assignments and open Quartus
make quartus-jtag-list   # List local or remote JTAG cables
make quartus-program     # Command called by standard fpga-program ESP alias
```

The Quartus subdirectory can also produce derived programming images:

```sh
make -C quartus rbf
make -C quartus jic
```

## Remote JTAG Programming

On the machine connected to the USB-Blaster, start a Quartus JTAG server from a
Quartus-configured shell:

```sh
jtagd &
jtagconfig --enableremote esp
```

Quartus JTAG clients use TCP port 1309 by default. Set `FPGA_HOST` on the build
machine to connect to that server:

```sh
make quartus-jtag-list FPGA_HOST=<jtag-host>
make fpga-program FPGA_HOST=<jtag-host>
```

The ESP flow passes the server to `jtagconfig --addserver` as `<host>:<port>`.
Use `INTEL_JTAG_SERVER_PORT` for a non-default port, or include the port in
`FPGA_HOST` directly:

```sh
make fpga-program FPGA_HOST=<jtag-host> INTEL_JTAG_SERVER_PORT=<port>
make fpga-program FPGA_HOST=<jtag-host>:<port>
```

The default remote password is `esp`; override it with
`INTEL_JTAG_SERVER_PASSWORD`.

When several boards share a server, select one with
`BOARD_CABLE='<exact cable name>'` or `BOARD_CABLE_MATCH='<unique substring>'`.
`BOARD_DEVICE_INDEX` defaults to `1`. Use `INTEL_ISSP_SERVICE_MATCH` only when
the post-program reset service cannot be selected unambiguously.

Quartus 19.4 may not remove remote JTAG server entries reliably with
`jtagconfig --removeserver`. If a temporary server should no longer appear in
`jtagconfig`, remove the matching host or `host:port` entry from `~/.jtag.conf`
manually.

## Run ESP Through HPS Linux

The Intel FPGA run backend copies the generated bootrom and payload to HPS
Linux over SSH, performs the required wake reads, and invokes the HPS loader.
Build the HPS utilities first:

```sh
make -C socs/terasic-de10-pro-sx/hps
```

Place `esp_peek` and `esp_load_bootrom_edcl` in `INTEL_HPS_RUN_DIR` on the HPS,
or set `INTEL_HPS_PEEK` and `INTEL_HPS_LOADER` to their paths.

Once the utilities are installed, run payloads from the board directory in the
same style as the Xilinx flow:

```sh
make fpga-run INTEL_HPS_HOST=<hps-host>
make fpga-run-linux INTEL_HPS_HOST=<hps-host>
```

`INTEL_HPS_HOST` specifies the IP address of the HPS Linux instance on the
DE10-Pro. `HPS_HOST` is accepted as an alias for `INTEL_HPS_HOST`.

If `INTEL_HPS_USER` does not include a user, the flow connects as
`terasic@<hps-host>`. Set `INTEL_HPS_USER`, `INTEL_HPS_SSH_PORT`,
`INTEL_HPS_RUN_DIR`, or `INTEL_HPS_SUDO` when the HPS setup differs from the
default Terasic image. Full configuration options are available in the Makefile
in the board directory.

When uploading, you will be asked for the password of the Linux user. The
default password for the stock Terasic image is `123`.

The loader profiles are:

| CPU | Bootrom address | Payload address | Reset CSR | Wake CSR |
| --- | --- | --- | --- | --- |
| Ariane | `0x2000010000` | `0x2080000000` | `0x2060000400` | `0x2060090384` |
| Ibex | `0x2000000080` | `0x2080000000` | `0x2060000400` | `0x2060090384` |
| LEON3 | `0x2000000000` | `0x2040000000` | `0x2080000400` | `0x2080090384` |

All profiles use ESP's big-endian 32-bit binary word packing. The loader
accepts `--binary-word-order` and `--dram-binary-word-order` for manual
experiments.

Do not release the HPS bridge reset register (`0xffd1102c`) from Linux. The
U-Boot `esp_h2f_fix` command owns that transition; repeating it through
`/dev/mem` can panic the HPS kernel.

## HPS Boot Media

Start with Terasic's stock Linux SD-card image and replace the FAT boot
partition files with the tracked versions under `quartus/software`:

```text
Image
u-boot/u-boot.itb
u-boot/u-boot.img
u-boot/u-boot.scr
devicetree/socfpga_stratix10_de10_pro.dtb
```

For example, with the boot partition mounted at `/tmp/de10sd`:

```sh
cp quartus/software/Image /tmp/de10sd/Image
cp quartus/software/u-boot/u-boot.itb /tmp/de10sd/u-boot.itb
cp quartus/software/u-boot/u-boot.img /tmp/de10sd/u-boot.img
cp quartus/software/u-boot/u-boot.scr /tmp/de10sd/u-boot.scr
cp quartus/software/devicetree/socfpga_stratix10_de10_pro.dtb /tmp/de10sd/
sync
```

Configure the persistent U-Boot environment from the serial console:

```text
setenv fdtimage socfpga_stratix10_de10_pro.dtb
setenv bootimagesize 0x01400000
setenv bootcmd 'run esp_h2f_fix; run mmcload; run linux_qspi_enable; run mmcboot'
setenv mmcboot 'setenv bootargs earlycon console=ttyS0,115200n8 panic=-1 root=${mmcroot} rw rootwait; booti ${loadaddr} - ${fdt_addr}'
setenv esp_h2f_fix 'mw.l 0xffd1102c 0x00000000'
saveenv
reset
```

The SPL hex and U-Boot FIT image must come from the same U-Boot build whenever
the Stratix 10 SPL handoff changes:

```text
quartus/software/u-boot/spl/u-boot-spl-dtb.hex
quartus/software/u-boot/u-boot.itb
```

The HPS device-tree source and compiled tree are tracked together. Rebuild the
DTB after editing the DTS:

```sh
dtc -I dts -O dtb \
  -o quartus/software/devicetree/socfpga_stratix10_de10_pro.dtb \
  quartus/software/devicetree/socfpga_stratix10_de10_pro.dts
```

Terasic's boot image for the DE10-Pro SX can be found under the Linux BSP
heading on the resources tab of the
[DE10-Pro overview page](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=1144).

## Hardware Integration

`top.vhd` is the canonical ESP wrapper. The Quartus project consumes it through
generated source assignments. Shared Intel bridge RTL remains under
`rtl/sockets/adapters/intel` because those adapters describe Intel HPS
interfaces rather than this specific board.

The HPS `h2f` AXI master reaches ESP's AHB control path through
`hps_h2f_axi_to_esp_ahb_master`. ESP DRAM traffic reaches HPS DDR through the
`f2sdram0` AXI port.

| Address view | Range or base |
| --- | --- |
| Ariane/Ibex local DDR | `0x80000000` - `0xbfffffff` |
| LEON3 local DDR | `0x40000000` - `0x7fffffff` |
| HPS direct DDR alias | `0x180000000` - `0x1bfffffff` |
| HPS Ariane/Ibex payload aperture | `0x2080000000` |
| HPS LEON3 payload aperture | `0x2040000000` |

The LEON3 address translation in `top.vhd` maps its local `0x40000000` DDR
window onto the same HPS-backed high-DDR region used by the RISC-V profiles.
The HPS loader address must remain `0x2040000000` unless the LEON3-visible
memory map is changed as well.

The SPL/U-Boot setup must enable the high `fpga2sdram0` region before Linux
boots. These firewall and bridge writes belong to the boot chain, not the HPS
loader.

The Quartus top level also instantiates the Terasic MAX6650/MAX6651 fan-control
logic under `quartus/fan`. It is an autonomous I2C master and is not exposed on
the ESP bus. The default target speed is 2200 RPM in `quartus/ghrd_s10_top.v`.

## Known Quirks

Upon cold boot of the FPGA, the FPGA must be programmed twice before the ESP
software payload can be uploaded and run successfully. This is not required for
warm boots.
