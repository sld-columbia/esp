# Terasic DE10-Pro SX

This directory contains ESP board support for the Terasic DE10-Pro SX with an
Intel/Altera Stratix 10 SX 280 FPGA (`1SX280HU2F50E1VG`).

Quartus Prime Pro 19.4 is the validated FPGA tool version. HPS boot-artifact
generation is validated with Intel SoC EDS 19.1. Newer tool versions may work,
but the tracked Tcl, SDC, Verilog, and Platform Designer generation inputs are
maintained against those versions.

The port supports Quartus synthesis and programming, remote JTAG programming,
ESP payload loading through HPS Linux, Ariane bare-metal and Linux payloads,
Ibex bare-metal payloads, and LEON3 bare-metal payloads. The Intel/Altera flow
currently supports accelerators built with the RTL or Third Party flow. HLS
flows are not supported yet because they rely on Xilinx/AMD HLS mappings and
components that are incompatible with Intel/Altera.

## Bring-Up Guide

Run ESP board targets from this directory:

```sh
cd socs/terasic-de10-pro-sx
```

Use a shell configured for Quartus when running Quartus targets. Use the SoC EDS
19.1 embedded command shell when building HPS boot artifacts.

### 1. Install the Required Tools (First Time per Build Host)

You need:

- Quartus Prime Pro 19.4
- Intel SoC EDS 19.1 for `make hps`
- `bison`, `dtc`, `flex`, `git`, `m4`, `make`, and an AArch64 Linux cross compiler in `PATH`
- Terasic's stock DE10-Pro SX Linux SD-card image
- native `gcc` on HPS Linux for the ESP HPS utility binaries

If the HPS boot-artifact host does not provide a working
`aarch64-linux-gnu-gcc`, build a local cross compiler before running `make hps`:

```sh
make hps-toolchain
```

This is a first-time setup step for each build host.

### 2. Configure ESP

```sh
make esp-defconfig
```

Adjust the ESP configuration as usual for the CPU and accelerators you want to
test. The listed CPU payload configurations have been validated on this board.

### 3. Build the HPS Boot Artifacts

```sh
make hps
```

This target builds the project-specific HPS boot files and writes them under
`local/boot/`:

```text
local/boot/u-boot.itb
local/boot/u-boot-spl-dtb.hex
local/boot/socfpga_stratix10_de10_pro.dtb
```

`local/boot/` is ignored by git. These files are generated locally and should
not be committed.

### 4. Stage Files on the SD Card (First Time, Then after HPS Rebuilds)

For first-time setup, write Terasic's stock Linux SD-card image to the card.
Terasic's DE10-Pro SX boot image is listed under the Linux BSP heading on the
resources tab of the
[DE10-Pro overview page](https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=1144).
Keep the stock copies of these files from that image:

```text
Image
u-boot/u-boot.img
u-boot/u-boot.scr
```

After each `make hps` run, copy the ESP-generated FIT and DTB to the boot
partition:

```sh
BOOT_PARTITION=/path/to/mounted/boot-partition
cp local/boot/u-boot.itb "$BOOT_PARTITION"/u-boot.itb
cp local/boot/socfpga_stratix10_de10_pro.dtb "$BOOT_PARTITION"/
sync
```

For first-time setup, or whenever the HPS utility sources change, copy the HPS
utility sources to the root partition. The utilities are built later on HPS
Linux:

```sh
ROOT_PARTITION=/path/to/mounted/root-partition
sudo cp hps/Makefile hps/esp_peek.c hps/esp_load_bootrom_edcl.c \
  "$ROOT_PARTITION/home/terasic"/
sync
```

### 5. Build and Program the FPGA Image

The Quartus project is generated locally from the tracked inputs and ESP's
current RTL graph:

```sh
make quartus-syn
make fpga-program
```

`make quartus-syn` consumes `local/boot/u-boot-spl-dtb.hex` when producing the
HPS-enabled SOF, so run `make hps` first after changing the HPS boot flow.

### 6. Configure U-Boot (First Time per SD-Card Image)

This is a first-time setup step for each SD-card image. After the HPS reaches
the U-Boot prompt, configure the persistent environment from the serial console:

```text
setenv fdtimage socfpga_stratix10_de10_pro.dtb
setenv bootimagesize 0x01400000
setenv bootcmd 'run esp_h2f_fix; run mmcload; run linux_qspi_enable; run mmcboot'
setenv mmcboot 'setenv bootargs earlycon console=ttyS0,115200n8 panic=-1 root=${mmcroot} rw rootwait; booti ${loadaddr} - ${fdt_addr}'
setenv esp_h2f_fix 'mw.l 0xffd1102c 0x00000000'
saveenv
reset
```

For a consistent network identity, optionally run `setenv ethaddr <mac-address>`
before `saveenv`.

### 7. Build the HPS Utilities on the Board (First Time, Then after Utility Changes)

Build the ESP HPS utilities directly on the DE10-Pro HPS Linux system so they
link against the same glibc as the target image. This is a first-time setup
step, and should be repeated whenever the utility sources change.

If you staged the utilities on the SD-card root partition in step 4, boot Linux
on the HPS and run:

```sh
cd ~
make
```

From a full repo checkout on the HPS, run:

```sh
cd socs/terasic-de10-pro-sx/hps
make
```

Place `esp_peek` and `esp_load_bootrom_edcl` in `INTEL_HPS_RUN_DIR` on the HPS,
or set `INTEL_HPS_PEEK` and `INTEL_HPS_LOADER` to their paths.

### 8. Run ESP Payloads Through HPS Linux

The Intel FPGA run backend copies the generated bootrom and payload to HPS
Linux over SSH, performs the required wake reads, and invokes the HPS loader:

```sh
make fpga-run INTEL_HPS_HOST=<hps-host>
make fpga-run-linux INTEL_HPS_HOST=<hps-host>
```

`INTEL_HPS_HOST` specifies the IP address or hostname of the HPS Linux instance
on the DE10-Pro. `HPS_HOST` is accepted as an alias. If no user is included,
the flow connects as `terasic@<hps-host>`. The upload step asks for the selected
Linux user's password.

## Common Targets

```sh
make quartus-setup       # Generate or refresh the local Quartus project
make quartus-gui         # Generate the project and open Quartus
make quartus-jtag-list   # List local or remote JTAG cables
make quartus-program     # Command called by the standard fpga-program alias
make quartus-rbf         # Produce an RBF from the generated SOF
make quartus-jic         # Produce a JIC programming image
make hps-dtb             # Rebuild only the HPS Linux DTB
make hps-clean           # Remove generated HPS boot artifacts and checkouts
```

The `quartus/` directory is generated locally. The repository tracks the inputs
used to regenerate the project, but it does not track `*.qpf`, `*.qsf`,
`*.qsys`, generated IP output, reports, or bitstreams. Quartus command output
is captured under `logs/quartus/`.

Quartus source assignments are generated from ESP's current RTL graph by
`make quartus-srcs`. Do not add a second hand-maintained ESP source list to the
Quartus project.

## HPS Boot Reference

`make hps` rebuilds the generated boot files even when copies already exist,
and removes stale outputs before invoking the boot-artifact flow. The target
clones the pinned Altera U-Boot and TF-A repositories under `local/hps-boot/`,
copies the DE10-Pro SX U-Boot overlay from `hps/boot/`, builds TF-A BL31,
builds U-Boot and SPL, and writes the generated files under `local/boot/`.

After `make hps-toolchain`, the HPS boot targets automatically prefer the local
Buildroot `aarch64-buildroot-linux-gnu-` compiler prefix. The toolchain is
installed under:

```text
local/toolchain/aarch64-linux-gnu/buildroot-output/host/bin
```

The script also installs `aarch64-linux-gnu-*` convenience wrapper aliases
under:

```text
local/toolchain/aarch64-linux-gnu/bin
```

Install the normal Buildroot host dependencies first, for example:

```sh
sudo dnf install bash bc binutils bison bzip2 cpio diffutils file findutils flex gawk gcc gcc-c++ git gzip m4 make patch perl python3 rsync sed tar unzip wget which xz
```

For local source mirrors or already-cloned trees, override the clone URLs:

```sh
make hps \
  HPS_BOOT_UBOOT_REPO=/path/to/u-boot-socfpga \
  HPS_BOOT_ATF_REPO=/path/to/arm-trusted-firmware
```

If the AArch64 compiler uses a different prefix, set
`HPS_BOOT_CROSS_COMPILE`, for example:

```sh
make hps HPS_BOOT_CROSS_COMPILE=aarch64-none-linux-gnu-
```

Set `HPS_BOOT_OFFLINE=1` to reuse an existing `local/hps-boot/` checkout
without fetching from the network.

The SPL HEX and FIT image must come from the same U-Boot/TF-A build whenever
the Stratix 10 SPL handoff changes. The SPL HEX is consumed by Quartus when
producing the HPS-enabled SOF; the FIT image is copied to the boot partition as
`u-boot.itb`.

The repository tracks a standalone GPL-2.0-only DTS derived from Terasic's
public `linux-socfpga` `de10_pro_revD` device-tree sources, with ESP
reserved-memory and HPS-to-FPGA MMIO nodes added. The compiled DTB is generated
locally and is not tracked.

## HPS Run Reference

Set these variables when the HPS Linux setup differs from the default Terasic
image:

| Variable | Purpose |
| --- | --- |
| `INTEL_HPS_HOST` | HPS Linux host or `user@host` target |
| `INTEL_HPS_USER` | SSH user when `INTEL_HPS_HOST` has no user |
| `INTEL_HPS_SSH_PORT` | SSH port |
| `INTEL_HPS_RUN_DIR` | HPS directory used for uploads and execution |
| `INTEL_HPS_SUDO` | Privilege command used for `/dev/mem` access |
| `INTEL_HPS_PEEK` | Path to `esp_peek` on the HPS |
| `INTEL_HPS_LOADER` | Path to `esp_load_bootrom_edcl` on the HPS |

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

## Directory Layout

| Path | Purpose |
| --- | --- |
| `top.vhd` | ESP wrapper and HPS FPGA-to-SDRAM connection |
| `fpga/` | Quartus top-level wrapper, programming scripts, and board-only RTL |
| `fpga/fan/` | Autonomous Terasic fan-controller logic |
| `hps/` | HPS-side ESP image loader and register access utility |
| `hps/boot/` | Board-specific U-Boot overlay used by `make hps` |
| `hps/devicetree/` | Standalone GPL DTS source for the boot DTB |
| `local/boot/` | Ignored output directory for generated HPS boot files |
| `quartus/` | Ignored generated Quartus project output |

## Hardware Integration Notes

`top.vhd` is the canonical ESP wrapper. `fpga/ghrd_s10_top.v` is the Quartus
board shell that instantiates ESP, HPS, DDR4A, and the fan controller. The
generated Quartus project consumes both through generated source assignments.
Shared Intel bridge RTL remains under `rtl/sockets/adapters/intel` because
those adapters describe Intel HPS interfaces rather than this specific board.

The Qsys clock interface is named `clk_100` for Platform Designer
compatibility, but the board shell drives it from the `CLK_50_B3C` input. Keep
the generated Tcl clock-rate parameters consistent with that top-level wiring.

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
logic under `fpga/fan`. It is an autonomous I2C master and is not exposed on
the ESP bus. The default target speed is 2200 RPM in `fpga/ghrd_s10_top.v`.

## Known Issue

Sustained Vortex workloads under HPS Linux can intermittently trigger CPU
faults or kernel panics, sometimes after several kernels complete successfully.
Short or basic tests may therefore pass without demonstrating stable operation.
Vortex configurations with 2 cores, 4 warps, and 4 threads, both with and
without L2, have also failed before normal payload execution on this board.

The equivalent Vortex workloads are stable on the validated Xilinx flow, so
this remains a DE10-Pro SX integration issue. Identifying and fixing the root
cause is a priority. Until it is resolved, treat Vortex Linux execution on this
board as experimental.
