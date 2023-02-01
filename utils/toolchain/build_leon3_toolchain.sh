#!/bin/bash
# Copyright (c) 2011-2023 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

CURRENT_DIR=${PWD}
export SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
LINUXSRC=${ESP_ROOT}/soft/leon3/linux
export SYSROOT=${ESP_ROOT}/soft/leon3/sysroot
BUILDROOT_SHA=d6fa6a45e196665d6607b522f290b1451b949c2c

DEFAULT_TARGET_DIR="/home/${USER}/leon"
TMP=${ESP_ROOT}/_leon3_build

# Prebuilt from Cobham Gaisler
SRC_MIRROR="https://espdev.cs.columbia.edu/stuff/leon3"
BAREC_GCC_VERSION="4.4.2"
MKLINUXIMG_VERSION="2.0.10"


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
    echo "*** This script will build and install the leon tool chain for Leon3 ***"
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
    echo "Target root file system ${SYSROOT} does not exist! Run \"git checkout soft/leon3/sysroot\""
    exit
fi

# Prompt target folder
read -p "Target folder? ${DEFAULT_TARGET_DIR}: " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-${DEFAULT_TARGET_DIR}}
echo "*** Installing to ${TARGET_DIR} ... ***"

# Prompt number of cores to use
read -p "Number of threads for Make (defaults to as many as possible)? : " NTHREADS
NTHREADS=${NTHREADS:-""}

# Tool chain environment
export PATH=${TARGET_DIR}/bin:$PATH
export LEON=${TARGET_DIR}

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


# Assign User ownership of target folder (needed to create toolchain through buildroot)
# Users can restore the ownership to root:root after running the script
cmd="chown $USER:$(id -gn) ${TARGET_DIR}"
runsudo ${TARGET_DIR} "$cmd"

# Remove and create temporary folder
rm -rf $TMP
mkdir $TMP
cd $TMP

git config --global url.https://.insteadOf git://
git config --global url.https://github.com/qemu/.insteadOf git://git.qemu-project.org/
git config --global url.https://anongit.freedesktop.org/git/.insteadOf git://anongit.freedesktop.org/

# Bare-metal compiler
src=sparc-elf-${BAREC_GCC_VERSION}
tar=$src.tar
ovwrt="n"
dst="${TARGET_DIR}/${src}"

echo "*** Installing bare-metal compiler... ***"
if [ $(noyes "Skip ${src}") == "n" ]; then
    if test -e $dst; then
	if [ $(noyes "Re-install ${dst}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	cmd="rm -rf ${dst} ${TARGET_DIR}/sparc-elf"
	runsudo $TARGET_DIR "$cmd"
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
	cmd="mv ${src} ${TARGET_DIR}"
	runsudo $TARGET_DIR "$cmd"
	cmd="ln -s ${dst} ${TARGET_DIR}/sparc-elf"
	runsudo $TARGET_DIR "$cmd"
    fi
fi
cd $TMP

# MKLINUXIMG debugger
src=mklinuximg-${MKLINUXIMG_VERSION}
tar=$src.tar.bz2
ovwrt="n"
dst="${TARGET_DIR}/${src}"

echo "*** Installing mklinuximg ... ***"
if [ $(noyes "Skip ${src}") == "n" ]; then
    if test -e $dst; then
	if [ $(noyes "Re-install ${dst}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	cmd="rm -rf ${dst} ${TARGET_DIR}/mklinuximg"
	runsudo $TARGET_DIR "$cmd"
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
	cmd="mv ${src} ${TARGET_DIR}"
	runsudo $TARGET_DIR "$cmd"
	cmd="ln -s ${dst} ${TARGET_DIR}/mklinuximg"
	runsudo $TARGET_DIR "$cmd"
    fi
fi
cd $TMP

# # Linux headers
# echo "*** Installing Linux headers... ***"
# if [ $(noyes "Skip Linux headers?") == "n" ]; then
#     cd $LINUXSRC
#     make mrproper
#     ARCH=sparc make leon3_smp_defconfig
#     make ARCH=sparc headers_check
#     cmd="mkdir -p ${TARGET_DIR}/usr"
#     runsudo $TARGET_DIR "$cmd"
#     cmd="make ARCH=sparc INSTALL_HDR_PATH=${TARGET_DIR}/usr headers_install"
#     runsudo $TARGET_DIR "$cmd"
#     make mrproper
# fi
# cd $TMP


# Linux toolchain
src=buildroot
echo "*** Installing Linux uClibC tool chain w/ buildroot ... ***"
if [ $(noyes "Skip Linux toolchain") == "n" ]; then
    if test -e $src; then
	cd $src
	git checkout .
	git pull
    else
    	git clone git://git.buildroot.net/buildroot
	cd $src
    fi

    git reset --hard ${BUILDROOT_SHA}
    git submodule update --init --recursive

    make distclean
    make defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/leon3_buildroot_toolchain_defconfig
    make toolchain -j ${NTHREADS}
fi
cd $TMP


# Root file system
src=buildroot
echo "*** Populating root file system w/ buildroot ... ***"
if [ $(noyes "Skip buildroot?") == "n" ]; then
    # Reset sysroot overlay to committed content TODO: restore
    cd $ESP_ROOT
    rm -rf ${SYSROOT}/*
    git checkout ${SYSROOT}
    cd $TMP

    if test -e $src; then
	cd $src
	git checkout .
	git pull
    else
    	git clone git://git.buildroot.net/buildroot
	cd $src
    fi

    git reset --hard ${BUILDROOT_SHA}
    git submodule update --init --recursive

    make distclean
    make defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/leon3_buildroot_defconfig
    make -j ${NTHREADS}

    # Populate repository sysroot overlay w/ generated files (git ignores them)
    rm output/target/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM
    cp -r output/target/* ${SYSROOT}/
    if [ ! -e ${SYSROOT}/init ]; then
        /usr/bin/install -m 0755 fs/cpio/init ${SYSROOT}/init;
    fi

    cd $TMP
fi

# Remove temporary folder
rm -rf $TMP

cd ${ESP_ROOT}

#Leon
echo ""
echo ""
echo "=== Use the following to load LEON environment ==="
echo -n "  export PATH=${LEON}/bin:"; echo '$PATH'
echo ""

echo "*** Successfully installed LEON toolchain to $TARGET_DIR ***"


git config --global --remove-section url."https://"
git config --global --remove-section url."https://github.com/qemu/"
git config --global --remove-section url."https://anongit.freedesktop.org/git/"
