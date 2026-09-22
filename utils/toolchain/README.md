# Toolchain

This directory contains the scripts that build the software toolchains for
each of the processors ESP supports, plus the Buildroot configurations and
patches they use.

```sh
utils/toolchain/build_riscv_toolchain.sh        # Ariane (RV64)
utils/toolchain/build_riscv32imc_toolchain.sh   # Ibex (RV32IMC)
utils/toolchain/build_leon3_toolchain.sh        # Leon3 (SPARC)
utils/toolchain/build_aarch64_toolchain.sh      # HPS of Intel SoC FPGAs
```

## Host prerequisites

The scripts build GCC, Buildroot and a Linux kernel from source, so they need
a working host toolchain and the usual Buildroot dependencies:

```sh
# Debian / Ubuntu
sudo apt-get install bash bc binutils bison build-essential bzip2 cpio \
    diffutils fakeroot file findutils flex gawk gcc g++ gzip m4 make patch \
    perl python3 rsync sed tar unzip wget which xz-utils

# RHEL / AlmaLinux / Rocky (fakeroot is in EPEL)
sudo dnf install epel-release
sudo dnf install bash bc binutils bison bzip2 cpio diffutils fakeroot file \
    findutils flex gawk gcc gcc-c++ git gzip m4 make patch perl python3 \
    rsync sed tar unzip wget which xz
```

Three of these are easy to miss because nothing else in ESP needs them:

* `fakeroot` is required by `build_riscv_toolchain.sh` on hosts with
  glibc >= 2.33. Buildroot bundles fakeroot 1.20.2, which still compiles but
  cannot intercept `mknod()` at runtime because glibc removed `__xmknod()`.
  The script substitutes the host's fakeroot for the bundled one before the
  rootfs step, and checks for it up front.

* `patch` is required by every script that applies one of the fixes under
  `patches/`, and by `make linux` for the in-tree device tree compiler.

* `dtc` is required to build a device tree blob, including the HPS boot DTB
  for Intel SoC FPGA boards.

## Newer host distributions

Recent distributions need workarounds that these scripts apply for you:

* GNU Make 4.4 and newer can loop forever rebuilding the old glibc snapshot
  pinned by the RISC-V GNU toolchain. `glibc-make-4.4.patch` fixes it.

* GCC 10 and newer default to `-fno-common`, which breaks the in-tree device
  tree compiler and some host packages. See `patches/`.

* Buildroot's `host-m4` and `host-fakeroot` need source patches on newer
  glibc. See `patches/` and `patch_buildroot_host_fakeroot` in the Leon3
  script.
