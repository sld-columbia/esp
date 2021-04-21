#!/bin/bash
# Copyright (c) 2011-2021 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

CURRENT_DIR=${PWD}
export SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
LINUXSRC=${ESP_ROOT}/soft/ariane/linux
LINUX_VERSION=4.20.0
export SYSROOT=${ESP_ROOT}/soft/ariane/sysroot
RISCV_GNU_TOOLCHAIN_SHA=afcc8bc655d30cf6af054ac1d3f5f89d0627aa79
BUILDROOT_SHA=d6fa6a45e196665d6607b522f290b1451b949c2c

DEFAULT_TARGET_DIR="/opt/riscv"
TMP=/tmp/_riscv_build

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

# Begin
if [ -w ${PWD} ] ; then
    echo "*** This script will build and install the riscv tool chain for Ariane ***"
    if [ $(yesno "Do you wish to continue") == "n" ]; then
	exit
    fi
else
    echo "Please run this script from a folder where user has write permission\n"
    exit
fi

if test ! -e ${LINUXSRC}; then
    echo "Linux source files are missing. Please clone ESP with \"git clone --recursive\""
    exit
fi

if test ! -e $SYSROOT; then
    echo "Target root file system ${SYSROOT} does not exist! Run \"git checkout soft/ariane/sysroot\""
    exit
fi

# Prompt target folder
read -p "Target folder? ${DEFAULT_TARGET_DIR}: " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-${DEFAULT_TARGET_DIR}}
echo "*** Installing to ${TARGET_DIR} ... ***"

# Prompt number of cores to use
read -p "Number of threads for Make (defaults to as many as possible)? :" NTHREADS
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

# Create temporary folder
mkdir -p $TMP
cd $TMP

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
    ./configure --prefix=${TARGET_DIR} --disable-gdb
    cmd="make -j ${NTHREADS}"
    runsudo ${TARGET_DIR} "$cmd"

fi
cd $TMP

# Linux compiler
echo "*** Installing Linux GlibC tool chain... ***"
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
    ./configure --prefix=${TARGET_DIR} --disable-gdb
    cmd="make linux -j ${NTHREADS}"
    runsudo ${TARGET_DIR} "$cmd"

fi
cd $TMP


# Root file system
src=buildroot
echo "*** Populating root file system w/ buildroot ... ***"
if [ $(noyes "Skip buildroot?") == "n" ]; then
    # Reset sysroot overlay to committed content
    cd $ESP_ROOT
    rm -rf ${SYSROOT}/*
    git checkout ${SYSROOT}
    cd $TMP

    if test -e $src; then
    	cd $src
    	git checkout .
    	git pull
    else
    	git clone https://git.buildroot.net/buildroot
    	cd $src
    fi

    git reset --hard ${BUILDROOT_SHA}
    git submodule update --init --recursive

    make distclean
    make defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/riscv_buildroot_defconfig
    make -j ${NTHREADS}

    # Populate repository sysroot overlay w/ generated files (git ignores them)
    rm output/target/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM
    cp -r output/target/* ${SYSROOT}/
    if [ ! -e ${SYSROOT}/init ]; then
        /usr/bin/install -m 0755 fs/cpio/init ${SYSROOT}/init;
    fi

    cd $TMP
fi

#Riscv
echo ""
echo ""
echo "=== Use the following to load RISC-V environment ==="
echo -n "  export PATH=${RISCV}/bin:"; echo '$PATH'
echo "  export RISCV=${RISCV}"
echo ""

cd $CURRENT_DIR

echo "*** Successfully installed RISC-V toolchain to $TARGET_DIR ***"
