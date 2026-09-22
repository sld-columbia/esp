#!/usr/bin/env bash
# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

# Board Makefiles provide the repo refs, overlay path, and output locations.

die() {
	echo "ERROR: $*" >&2
	exit 1
}

info() {
	echo "INFO: $*"
}

need_var() {
	local name=$1
	if [ -z "${!name:-}" ]; then
		die "$name is not set"
	fi
}

need_tool() {
	command -v "$1" >/dev/null 2>&1 || die "$1 not found in PATH"
}

default_jobs() {
	local jobs

	if jobs=$(nproc 2>/dev/null); then
		echo "$jobs"
	elif jobs=$(getconf _NPROCESSORS_ONLN 2>/dev/null); then
		echo "$jobs"
	else
		echo 4
	fi
}

default_atf_ldflags() {
	local ld_help

	if ld_help=$("${CROSS_COMPILE}ld" --help 2>/dev/null); then
		case "$ld_help" in
		*--no-warn-rwx-segments*) echo "--no-warn-rwx-segments" ;;
		esac
	fi
}

checkout_repo() {
	local name=$1
	local url=$2
	local ref=$3
	local dst=$4

	if [ -d "$dst/.git" ]; then
		info "refreshing $name in $dst"
		git -C "$dst" remote set-url origin "$url"
		if [ "${HPS_BOOT_OFFLINE:-0}" != "1" ]; then
			git -C "$dst" fetch --tags --prune origin
		fi
	else
		info "cloning $name from $url"
		mkdir -p "$(dirname "$dst")"
		git clone "$url" "$dst"
	fi

	info "checking out $name ref $ref"
	git -C "$dst" checkout --detach "$ref"
	git -C "$dst" reset --hard
	git -C "$dst" clean -fdx
}

copy_overlay() {
	local overlay=$1
	local dst=$2
	local copied=0

	if [ -z "$overlay" ]; then
		return
	fi
	[ -d "$overlay" ] || die "overlay directory not found: $overlay"

	info "copying U-Boot overlay from $overlay"
	while IFS= read -r -d '' src; do
		local rel=${src#"$overlay"/}
		mkdir -p "$dst/$(dirname "$rel")"
		cp "$src" "$dst/$rel"
		copied=$((copied + 1))
	done < <(find "$overlay" -type f -print0)

	[ "$copied" -gt 0 ] || die "overlay directory contains no files: $overlay"
}

need_var HPS_BOOT_BOARD
need_var HPS_BOOT_WORK
need_var HPS_BOOT_OUT
need_var HPS_BOOT_UBOOT_REPO
need_var HPS_BOOT_UBOOT_REF
need_var HPS_BOOT_UBOOT_DEFCONFIG
need_var HPS_BOOT_ATF_REPO
need_var HPS_BOOT_ATF_REF
need_var HPS_BOOT_ATF_PLAT

need_tool git
need_tool make
need_tool cp
need_tool find
need_tool bison
need_tool flex
need_tool m4

M4=${M4:-$(command -v m4)}
export M4

CROSS_COMPILE=${CROSS_COMPILE:-${HPS_BOOT_CROSS_COMPILE:-aarch64-linux-gnu-}}
HPS_BOOT_JOBS=${HPS_BOOT_JOBS:-${JOBS:-$(default_jobs)}}
HPS_BOOT_ATF_DEBUG=${HPS_BOOT_ATF_DEBUG:-0}
HPS_BOOT_UBOOT_DIR=${HPS_BOOT_UBOOT_DIR:-$HPS_BOOT_WORK/u-boot-socfpga}
HPS_BOOT_ATF_DIR=${HPS_BOOT_ATF_DIR:-$HPS_BOOT_WORK/arm-trusted-firmware}
HPS_BOOT_UBOOT_OVERLAY=${HPS_BOOT_UBOOT_OVERLAY:-}

command -v "${CROSS_COMPILE}gcc" >/dev/null 2>&1 || \
	die "${CROSS_COMPILE}gcc not found in PATH. Install an AArch64 Linux cross compiler or run 'make hps-toolchain' from the DE10-Pro SX SoC folder."
command -v "${CROSS_COMPILE}ld" >/dev/null 2>&1 || \
	die "${CROSS_COMPILE}ld not found in PATH. Install an AArch64 Linux cross compiler or run 'make hps-toolchain' from the DE10-Pro SX SoC folder."

HPS_BOOT_ATF_LDFLAGS=${HPS_BOOT_ATF_LDFLAGS:-$(default_atf_ldflags)}

case "$HPS_BOOT_ATF_DEBUG" in
0) HPS_BOOT_ATF_BUILD_MODE=release ;;
1) HPS_BOOT_ATF_BUILD_MODE=debug ;;
*) die "HPS_BOOT_ATF_DEBUG must be 0 or 1" ;;
esac

mkdir -p "$HPS_BOOT_WORK" "$HPS_BOOT_OUT"

checkout_repo "U-Boot" "$HPS_BOOT_UBOOT_REPO" "$HPS_BOOT_UBOOT_REF" \
	"$HPS_BOOT_UBOOT_DIR"
checkout_repo "TF-A" "$HPS_BOOT_ATF_REPO" "$HPS_BOOT_ATF_REF" \
	"$HPS_BOOT_ATF_DIR"

copy_overlay "$HPS_BOOT_UBOOT_OVERLAY" "$HPS_BOOT_UBOOT_DIR"
git -C "$HPS_BOOT_UBOOT_DIR" diff --check

info "building TF-A BL31"
make -C "$HPS_BOOT_ATF_DIR" realclean
make -C "$HPS_BOOT_ATF_DIR" \
	CROSS_COMPILE="$CROSS_COMPILE" \
	LDFLAGS="$HPS_BOOT_ATF_LDFLAGS" \
	PLAT="$HPS_BOOT_ATF_PLAT" \
	DEBUG="$HPS_BOOT_ATF_DEBUG" \
	bl31

HPS_BOOT_ATF_BL31=${HPS_BOOT_ATF_BL31:-$HPS_BOOT_ATF_DIR/build/$HPS_BOOT_ATF_PLAT/$HPS_BOOT_ATF_BUILD_MODE/bl31.bin}
[ -s "$HPS_BOOT_ATF_BL31" ] || die "BL31 not found: $HPS_BOOT_ATF_BL31"

info "building U-Boot FIT and SPL HEX"
make -C "$HPS_BOOT_UBOOT_DIR" distclean
make -C "$HPS_BOOT_UBOOT_DIR" \
	CROSS_COMPILE="$CROSS_COMPILE" \
	"$HPS_BOOT_UBOOT_DEFCONFIG"
cp "$HPS_BOOT_ATF_BL31" "$HPS_BOOT_UBOOT_DIR/bl31.bin"
make -C "$HPS_BOOT_UBOOT_DIR" \
	CROSS_COMPILE="$CROSS_COMPILE" \
	-j"$HPS_BOOT_JOBS" \
	all
make -C "$HPS_BOOT_UBOOT_DIR" \
	CROSS_COMPILE="$CROSS_COMPILE" \
	u-boot.itb

[ -s "$HPS_BOOT_UBOOT_DIR/u-boot.itb" ] || die "u-boot.itb was not generated"
[ -s "$HPS_BOOT_UBOOT_DIR/spl/u-boot-spl-dtb.hex" ] || die "SPL HEX was not generated"

cp "$HPS_BOOT_UBOOT_DIR/u-boot.itb" "$HPS_BOOT_OUT/u-boot.itb"
cp "$HPS_BOOT_UBOOT_DIR/spl/u-boot-spl-dtb.hex" "$HPS_BOOT_OUT/u-boot-spl-dtb.hex"

{
	echo "board=$HPS_BOOT_BOARD"
	echo "cross_compile=$CROSS_COMPILE"
	echo "uboot_repo=$HPS_BOOT_UBOOT_REPO"
	echo "uboot_ref=$HPS_BOOT_UBOOT_REF"
	echo "uboot_commit=$(git -C "$HPS_BOOT_UBOOT_DIR" rev-parse HEAD)"
	echo "atf_repo=$HPS_BOOT_ATF_REPO"
	echo "atf_ref=$HPS_BOOT_ATF_REF"
	echo "atf_commit=$(git -C "$HPS_BOOT_ATF_DIR" rev-parse HEAD)"
	echo "atf_ldflags=$HPS_BOOT_ATF_LDFLAGS"
	echo "overlay=$HPS_BOOT_UBOOT_OVERLAY"
} > "$HPS_BOOT_OUT/hps-boot-artifacts.txt"

info "wrote $HPS_BOOT_OUT/u-boot.itb"
info "wrote $HPS_BOOT_OUT/u-boot-spl-dtb.hex"
