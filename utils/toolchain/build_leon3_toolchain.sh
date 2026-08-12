#!/bin/bash
# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

CURRENT_DIR=${PWD}
export SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
LINUXSRC=${ESP_ROOT}/soft/leon3/linux
export SYSROOT=${ESP_ROOT}/soft/leon3/sysroot
BUILDROOT_SHA=d6fa6a45e196665d6607b522f290b1451b949c2c
MAKE_CMD=${MAKE:-make}

DEFAULT_TARGET_DIR="/home/${USER}/leon"

# Bare-metal compiler from Frontgrade Gaisler. BCC 1 used 32-bit x86 host
# binaries, which cannot run on Linux distributions that no longer ship i686
# runtime libraries. BCC 2 provides native x86_64 host binaries.
SRC_MIRROR="https://espdev.cs.columbia.edu/stuff/leon3"
BCC_MIRROR="https://download.gaisler.com/anonftp/bcc2/bin"
BCC_VERSION="2.3.1"
BCC_ARCHIVE="bcc-${BCC_VERSION}-gcc-sparc-linux64.tar.xz"
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

patch_buildroot_host_fakeroot () {
    local fakeroot_src
    local tmp_src

    # Older Buildroot releases mis-detect setgroups() on newer hosts and use
    # glibc interfaces that are no longer exposed through public headers.
    ${MAKE_CMD} host-fakeroot-patch

    fakeroot_src=$(find output/build -maxdepth 2 -type f \
        -path '*/host-fakeroot-*/libfakeroot.c' -print -quit)
    if [ -z "${fakeroot_src}" ]; then
        echo "Unable to find Buildroot host-fakeroot libfakeroot.c."
        exit 1
    fi

    if grep -q "ESP_FAKEROOT_GLIBC_COMPAT" "${fakeroot_src}"; then
        return
    fi

    tmp_src=${fakeroot_src}.esp-tmp
    awk '
        {
            line = $0
            gsub(/SEND_GET_STAT64\(r->fts_statp, _STAT_VER\);/,
                 "SEND_GET_STAT64((struct stat64 *)r->fts_statp, _STAT_VER);",
                 line)
            print line
            if (line == "#include \"communicate.h\"" && !done) {
                print ""
                print "/* ESP_FAKEROOT_GLIBC_COMPAT: host compatibility for newer glibc. */"
                print "#include <sys/types.h>"
                print "#undef SETGROUPS_SIZE_TYPE"
                print "#define SETGROUPS_SIZE_TYPE size_t"
                print "#if defined(__GLIBC__) && !defined(_STAT_VER)"
                print "# if defined(__x86_64__)"
                print "#  define _STAT_VER 1"
                print "# elif defined(__i386__)"
                print "#  define _STAT_VER 3"
                print "# endif"
                print "#endif"
                done = 1
            }
        }
        END { if (!done) exit 1 }
    ' "${fakeroot_src}" > "${tmp_src}" || {
        rm -f "${tmp_src}"
        echo "Unable to patch ${fakeroot_src} for newer host glibc."
        exit 1
    }
    mv "${tmp_src}" "${fakeroot_src}"
    echo "*** Patched Buildroot host-fakeroot for newer host GlibC ***"
}

patch_buildroot_host_m4 () {
    local m4_src
    local tmp_src

    # GNU m4 1.4.18 assumes SIGSTKSZ is a preprocessor constant. Newer glibc
    # may define it through sysconf(), which is valid C but invalid in #elif.
    ${MAKE_CMD} host-m4-patch

    m4_src=$(find output/build -maxdepth 3 -type f \
        -path '*/host-m4-*/lib/c-stack.c' -print -quit)
    if [ -z "${m4_src}" ]; then
        echo "Unable to find Buildroot host-m4 c-stack.c."
        exit 1
    fi

    if grep -q "ESP_M4_SIGSTKSZ_COMPAT" "${m4_src}"; then
        return
    fi

    tmp_src=${m4_src}.esp-tmp
    awk '
        {
            if ($0 == "#elif HAVE_LIBSIGSEGV && SIGSTKSZ < 16384") {
                print "#elif HAVE_LIBSIGSEGV"
                print "/* ESP_M4_SIGSTKSZ_COMPAT: SIGSTKSZ may not be #if-safe on newer glibc. */"
                next
            }
            print
        }
    ' "${m4_src}" > "${tmp_src}" || {
        rm -f "${tmp_src}"
        echo "Unable to patch ${m4_src} for newer host glibc."
        exit 1
    }
    if ! grep -q "ESP_M4_SIGSTKSZ_COMPAT" "${tmp_src}"; then
        rm -f "${tmp_src}"
        echo "Unable to find SIGSTKSZ check in ${m4_src}."
        exit 1
    fi
    mv "${tmp_src}" "${m4_src}"
    echo "*** Patched Buildroot host-m4 for newer host GlibC ***"
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
TARGET_DIR=$(realpath -m "${TARGET_DIR}")
TMP=${LEON_BUILD_DIR:-${TARGET_DIR}/_leon3_build}
LEON_BUILDROOT_HOST_CXXFLAGS=${LEON_BUILDROOT_HOST_CXXFLAGS:-"-O2 -I${TARGET_DIR}/include -std=gnu++14"}
echo "*** Installing to ${TARGET_DIR} ... ***"
echo "*** Using build directory ${TMP} ... ***"

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
rm -rf "$TMP"
mkdir -p "$TMP"
cd "$TMP"

configure_git_url_rewrites

# Bare-metal compiler
src=bcc-${BCC_VERSION}-gcc
tar=${BCC_ARCHIVE}
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
	    wget ${BCC_MIRROR}/$tar
	fi
	archive_root=$(tar tf "$tar" | awk -F/ '
	    $1 != "" && $1 != "." { print $1; exit }
	    $1 == "." && $2 != "" { print $2; exit }
	')
	case "$archive_root" in
	""|.|..|*/*|*[!A-Za-z0-9._+-]*)
	    echo "Unable to determine the top-level directory in $tar"
	    exit 1
	    ;;
	esac
	extract_dir="${TMP}/bcc-${BCC_VERSION}-extract"
	rm -rf "$extract_dir"
	mkdir -p "$extract_dir"
	tar xf "$tar" -C "$extract_dir"
	if [ ! -x "$extract_dir/$archive_root/bin/sparc-gaisler-elf-gcc" ]; then
	    echo "$tar does not contain the expected Gaisler BCC compiler"
	    exit 1
	fi
	cmd="mv ${extract_dir}/${archive_root} ${dst}"
	runsudo $TARGET_DIR "$cmd"
	rm -rf "$extract_dir"
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

    ${MAKE_CMD} distclean
    ${MAKE_CMD} defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/leon3_buildroot_toolchain_defconfig
    patch_buildroot_host_m4
    ${MAKE_CMD} HOST_CXXFLAGS="${LEON_BUILDROOT_HOST_CXXFLAGS}" \
	toolchain -j ${NTHREADS}
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

    ${MAKE_CMD} distclean
    ${MAKE_CMD} defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/leon3_buildroot_defconfig
    patch_buildroot_host_fakeroot
    patch_buildroot_host_m4
    ${MAKE_CMD} HOST_CXXFLAGS="${LEON_BUILDROOT_HOST_CXXFLAGS}" \
	-j ${NTHREADS}

    # Populate repository sysroot overlay w/ generated files (git ignores them)
    rm output/target/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM
    cp -r output/target/* ${SYSROOT}/
    if [ ! -e ${SYSROOT}/init ]; then
        /usr/bin/install -m 0755 fs/cpio/init ${SYSROOT}/init;
    fi

    cd $TMP
fi

# Keep the build tree under the install prefix. Some upstream toolchain builds
# leave absolute symlinks into their build output, so deleting this directory can
# make an otherwise successful install depend on the ESP checkout that built it.
echo "*** Keeping LEON build directory at ${TMP} ***"

cd ${ESP_ROOT}

#Leon
echo ""
echo ""
echo "=== Use the following to load LEON environment ==="
echo -n "  export PATH=${LEON}/sparc-elf/bin:${LEON}/bin:"; echo '$PATH'
echo ""

echo "*** Successfully installed LEON toolchain to $TARGET_DIR ***"
