#!/usr/bin/env bash
# Copyright (c) 2011-2026 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

SCRIPT_PATH=$(realpath "$(dirname "$0")")
ESP_ROOT=$(realpath "${SCRIPT_PATH}/../..")

DEFAULT_TARGET_DIR="/home/${USER}/aarch64-linux-gnu"
BUILDROOT_REPO=${AARCH64_BUILDROOT_REPO:-https://gitlab.com/buildroot.org/buildroot.git}
BUILDROOT_REF=${AARCH64_BUILDROOT_REF:-2025.02.15}
BUILDROOT_DEFCONFIG=${AARCH64_BUILDROOT_DEFCONFIG:-${SCRIPT_PATH}/aarch64_buildroot_toolchain_defconfig}
MAKE_CMD=${MAKE:-make}

info() {
	echo "INFO: $*"
}

die() {
	echo "ERROR: $*" >&2
	exit 1
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

prompt_target_dir() {
	local target_dir=${AARCH64_TARGET_DIR:-}

	if [ -n "$target_dir" ]; then
		echo "$target_dir"
		return
	fi

	read -r -p "Target folder? ${DEFAULT_TARGET_DIR}: " target_dir
	echo "${target_dir:-${DEFAULT_TARGET_DIR}}"
}

make_alias_links() {
	local host_bin=$1
	local alias_bin=$2
	local buildroot_prefix=${AARCH64_BUILDROOT_PREFIX:-aarch64-buildroot-linux-gnu}
	local alias_prefix=${AARCH64_ALIAS_PREFIX:-aarch64-linux-gnu}
	local src base tool real_src wrapper

	[ -d "$host_bin" ] || die "Buildroot host bin directory not found: $host_bin"
	mkdir -p "$alias_bin"

	for src in "$host_bin"/"${buildroot_prefix}"-*; do
		[ -e "$src" ] || continue
		base=$(basename "$src")
		tool=${base#"${buildroot_prefix}-"}
		real_src=$(realpath "$src")
		wrapper="$alias_bin/${alias_prefix}-${tool}"
		rm -f "$wrapper"
		cat > "$wrapper" <<EOF
#!/usr/bin/env bash
exec "$real_src" "\$@"
EOF
		chmod +x "$wrapper"
	done

	[ -x "$alias_bin/${alias_prefix}-gcc" ] || \
		die "failed to create ${alias_prefix}-gcc alias in $alias_bin"
}

need_tool git
need_tool "$MAKE_CMD"
need_tool awk
need_tool bash
need_tool bc
need_tool bzip2
need_tool cpio
need_tool diff
need_tool file
need_tool find
need_tool gcc
need_tool g++
need_tool gzip
need_tool patch
need_tool perl
need_tool python3
need_tool rsync
need_tool sed
need_tool tar
need_tool unzip
need_tool wget
need_tool which
need_tool xz

TARGET_DIR=$(prompt_target_dir)
TARGET_DIR=$(realpath -m "$TARGET_DIR")
JOBS=${AARCH64_BUILD_JOBS:-${JOBS:-$(default_jobs)}}
BUILDROOT_DIR=${AARCH64_BUILDROOT_DIR:-${TARGET_DIR}/src/buildroot}
BUILDROOT_OUTPUT=${AARCH64_BUILDROOT_OUTPUT:-${TARGET_DIR}/buildroot-output}
ALIAS_BIN=${AARCH64_ALIAS_BIN:-${TARGET_DIR}/bin}
BUILDROOT_PREFIX=${AARCH64_BUILDROOT_PREFIX:-aarch64-buildroot-linux-gnu}
BUILDROOT_CROSS_COMPILE=${BUILDROOT_OUTPUT}/host/bin/${BUILDROOT_PREFIX}-

[ -r "$BUILDROOT_DEFCONFIG" ] || die "Buildroot defconfig not found: $BUILDROOT_DEFCONFIG"

info "installing AArch64 Linux cross compiler under $TARGET_DIR"
info "using Buildroot ref $BUILDROOT_REF"

mkdir -p "$TARGET_DIR/src"

if [ -d "$BUILDROOT_DIR/.git" ]; then
	info "refreshing Buildroot checkout in $BUILDROOT_DIR"
	git -C "$BUILDROOT_DIR" remote set-url origin "$BUILDROOT_REPO"
	if [ "${AARCH64_BUILD_OFFLINE:-0}" != "1" ]; then
		git -C "$BUILDROOT_DIR" fetch --tags --prune origin
	fi
else
	info "cloning Buildroot from $BUILDROOT_REPO"
	git clone "$BUILDROOT_REPO" "$BUILDROOT_DIR"
fi

info "checking out Buildroot ref $BUILDROOT_REF"
git -C "$BUILDROOT_DIR" checkout --detach "$BUILDROOT_REF"
git -C "$BUILDROOT_DIR" reset --hard
git -C "$BUILDROOT_DIR" clean -fdx

mkdir -p "$BUILDROOT_OUTPUT"

info "configuring Buildroot toolchain"
"$MAKE_CMD" -C "$BUILDROOT_DIR" O="$BUILDROOT_OUTPUT" \
	BR2_DEFCONFIG="$BUILDROOT_DEFCONFIG" defconfig

info "building Buildroot host toolchain"
"$MAKE_CMD" -C "$BUILDROOT_DIR" O="$BUILDROOT_OUTPUT" -j"$JOBS" toolchain

make_alias_links "$BUILDROOT_OUTPUT/host/bin" "$ALIAS_BIN"

cat > "$TARGET_DIR/aarch64-toolchain.env" <<EOF
export PATH=$BUILDROOT_OUTPUT/host/bin:$ALIAS_BIN:\$PATH
export HPS_BOOT_CROSS_COMPILE=$BUILDROOT_CROSS_COMPILE
EOF

cat > "$TARGET_DIR/aarch64-toolchain-manifest.txt" <<EOF
buildroot_repo=$BUILDROOT_REPO
buildroot_ref=$BUILDROOT_REF
buildroot_commit=$(git -C "$BUILDROOT_DIR" rev-parse HEAD)
buildroot_output=$BUILDROOT_OUTPUT
alias_bin=$ALIAS_BIN
cross_compile=$BUILDROOT_CROSS_COMPILE
EOF

info "wrote $TARGET_DIR/aarch64-toolchain.env"
info "AArch64 compiler: ${BUILDROOT_CROSS_COMPILE}gcc"
info "Convenience aliases: $ALIAS_BIN/aarch64-linux-gnu-*"
info "Use this prefix for HPS builds:"
echo "  HPS_BOOT_CROSS_COMPILE=$BUILDROOT_CROSS_COMPILE"
