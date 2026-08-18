#!/bin/bash
# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

CURRENT_DIR=${PWD}
export SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
RISCV_GNU_TOOLCHAIN_SHA=afcc8bc655d30cf6af054ac1d3f5f89d0627aa79

DEFAULT_TARGET_DIR="/home/${USER}/riscv32imc"

# Helper functions
yesno () {
    while true; do
        read -p "$1 [y|n]? y: " yn
        yn=${yn:-y}
        case $yn in
            [Yy]* ) echo "y"; break;;
            [Nn]* ) echo "n"; break;;
            * ) ;;
        esac
    done
}

noyes () {
    while true; do
        read -p "$1 [y|n]? n: " yn
        yn=${yn:-n}
        case $yn in
            [Yy]* ) echo "y"; break;;
            [Nn]* ) echo "n"; break;;
            * ) ;;
        esac
    done
}

configure_git_url_rewrites () {
    # Keep legacy URL compatibility local to this script and its child processes.
    export GIT_CONFIG_COUNT=3
    export GIT_CONFIG_KEY_0=url.https://.insteadOf
    export GIT_CONFIG_VALUE_0=git://
    export GIT_CONFIG_KEY_1=url.https://github.com/qemu/.insteadOf
    export GIT_CONFIG_VALUE_1=git://git.qemu-project.org/
    export GIT_CONFIG_KEY_2=url.https://gitlab.freedesktop.org/pixman/pixman.insteadOf
    export GIT_CONFIG_VALUE_2=git://anongit.freedesktop.org/pixman
}

# Begin
if [ -w ${PWD} ] ; then
    echo "*** This script will build and install the riscv tool chain for RISC-V ***"
    if [ $(yesno "Do you wish to continue") == "n" ]; then
        exit
    fi
else
    echo "Please run this script from a folder where user has write permission\n"
    exit
fi


# Prompt target folder
read -p "Target folder? ${DEFAULT_TARGET_DIR}: " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-${DEFAULT_TARGET_DIR}}
TARGET_DIR=$(realpath -m "${TARGET_DIR}")
TMP=${RISCV32IMC_BUILD_DIR:-${TARGET_DIR}/_riscv32imc_build}
echo "*** Installing to ${TARGET_DIR} ... ***"
echo "*** Using build directory ${TMP} ... ***"

# Prompt number of cores to use
read -p "Number of threads for Make (defaults to as many as possible)? : " NTHREADS
NTHREADS=${NTHREADS:-""}

# Tool chain environment
export PATH=${TARGET_DIR}/bin:$PATH
export RISCV=${TARGET_DIR}

runsudo () {
    if [ -w $1 ]; then
        $2
    else
        sudo PATH=${TARGET_DIR}/bin:$PATH $2 || exit
    fi
}

# Create target folder
if test ! -e ${TARGET_DIR}; then
    pdir=${TARGET_DIR}
    while test ! -e $pdir; do
        pdir=$(dirname $pdir)
    done;
    cmd="mkdir -p ${TARGET_DIR}"
    runsudo $pdir "$cmd"
fi

# Remove and create temporary folder
rm -rf "$TMP"
mkdir -p "$TMP"
cd "$TMP"

configure_git_url_rewrites

# Bare-metal compiler
src=riscv-gnu-toolchain
echo "*** Installing baremetal newlib tool chain... ***"
if [ $(noyes "Skip ${src}") == "n" ]; then
    if test -e $src; then
        cd $src
        git checkout .
    else
        git clone https://github.com/riscv/riscv-gnu-toolchain.git
        cd $src
    fi

    git reset --hard ${RISCV_GNU_TOOLCHAIN_SHA}
    git submodule update --init --recursive
    ./configure --prefix=${TARGET_DIR} --disable-gdb --with-arch=rv32imc --with-abi=ilp32 --with-cmodel=medlow --enable-multilib
    cmd="make -j ${NTHREADS}"
    runsudo ${TARGET_DIR} "$cmd"

fi


# Keep the build tree under the install prefix. Some upstream toolchain builds
# leave absolute symlinks into their build output, so deleting this directory can
# make an otherwise successful install depend on the ESP checkout that built it.
echo "*** Keeping RISC-V build directory at ${TMP} ***"

cd ${ESP_ROOT}

#Riscv
echo ""
echo ""
echo "=== Use the following to load RISC-V environment ==="
echo -n "  export PATH=${RISCV}/bin:"; echo '$PATH'
echo "  export RISCV=${RISCV}"
echo ""

echo "*** Successfully installed RISC-V (rv32imc) toolchain to $TARGET_DIR ***"
