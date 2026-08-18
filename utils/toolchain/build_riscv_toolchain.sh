#!/bin/bash
# Copyright (c) 2011-2025 Columbia University, System Level Design Group
# SPDX-License-Identifier: Apache-2.0

set -e

CURRENT_DIR=${PWD}
export SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
LINUXSRC=${ESP_ROOT}/soft/ariane/linux
LINUX_VERSION=4.20.0
export SYSROOT=${ESP_ROOT}/soft/ariane/sysroot
RISCV_GNU_TOOLCHAIN_SHA_DEFAULT=afcc8bc655d30cf6af054ac1d3f5f89d0627aa79
RISCV_GNU_TOOLCHAIN_SHA_PYTHON=2c037e631e27bc01582476f5b3c5d5e9e51489b8
BUILDROOT_SHA_DEFAULT=d6fa6a45e196665d6607b522f290b1451b949c2c
BUILDROOT_SHA_PYTHON=fbff7d7289cc95db991184f890f4ca1fcf8a101e

# GNU Make 4.4+ can loop forever while rebuilding the old GlibC snapshot
# pinned by the RISC-V GNU toolchain above (typically in stdio-common).
# Honor an explicit MAKE override and patch the temporary GlibC checkout with
# the upstream dependency fix when GNU Make 4.4 or newer is selected.
MAKE_CMD=${MAKE:-make}
GLIBC_MAKE_4_4_PATCH=${SCRIPT_PATH}/glibc-make-4.4.patch

# A patch for buildroot RISCV64 with numpy enabled
BUILDROOT_PATCH=${ESP_ROOT}/utils/toolchain/python-patches/python-numpy.patch

DEFAULT_TARGET_DIR="/home/${USER}/riscv"

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

is_make_4_4_or_newer () {
    local make_cmd=$1
    local version_line
    local major
    local minor

    version_line=$("${make_cmd}" --version 2>/dev/null | head -n 1) || return 1
    if [[ ! ${version_line} =~ ^GNU[[:space:]]Make[[:space:]]([0-9]+)\.([0-9]+) ]]; then
	return 1
    fi

    major=${BASH_REMATCH[1]}
    minor=${BASH_REMATCH[2]}
    (( major > 4 || (major == 4 && minor >= 4) ))
}

patch_glibc_for_make_4_4 () {
    local glibc_dir

    if ! is_make_4_4_or_newer "${MAKE_CMD}"; then
	return
    fi

    for glibc_dir in glibc riscv-glibc; do
	if [ -d "${glibc_dir}" ]; then
	    if git -C "${glibc_dir}" apply --check "${GLIBC_MAKE_4_4_PATCH}"; then
		git -C "${glibc_dir}" apply "${GLIBC_MAKE_4_4_PATCH}"
		echo "*** Patched legacy GlibC for GNU Make 4.4+ ***"
		return
	    fi
	    if git -C "${glibc_dir}" apply --reverse --check "${GLIBC_MAKE_4_4_PATCH}"; then
		echo "*** Legacy GlibC GNU Make 4.4+ patch is already applied ***"
		return
	    fi
	fi
    done

    echo "Unable to apply ${GLIBC_MAKE_4_4_PATCH} to the pinned GlibC checkout."
    echo "Use GNU Make 4.3 or older as a fallback, for example:"
    echo "  MAKE=/path/to/make-4.3 $0"
    exit 1
}

patch_buildroot_host_fakeroot () {
    local fakeroot_src
    local tmp_src

    # Older Buildroot releases pull a fakeroot version whose configure tests can
    # mis-detect setgroups() on newer host distributions. Newer glibc also hides
    # the private _STAT_VER macro that this fakeroot still uses on x86 hosts.
    # Patch the extracted host-fakeroot source before Buildroot configures it.
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
TARGET_DIR=$(realpath -m "${TARGET_DIR}")
TMP=${RISCV_BUILD_DIR:-${TARGET_DIR}/_riscv_build}
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

# Python
echo "*** Python ... ***"
if [ $(noyes "Do you want to enable Python") == "y" ]; then
    python_en=1
    RISCV_GNU_TOOLCHAIN_SHA=$RISCV_GNU_TOOLCHAIN_SHA_PYTHON
    BUILDROOT_SHA=$BUILDROOT_SHA_PYTHON
else
    python_en=0
    RISCV_GNU_TOOLCHAIN_SHA=$RISCV_GNU_TOOLCHAIN_SHA_DEFAULT
    BUILDROOT_SHA=$BUILDROOT_SHA_DEFAULT
fi
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
    cmd="${MAKE_CMD} -j ${NTHREADS}"
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
    patch_glibc_for_make_4_4
    ./configure --prefix=${TARGET_DIR} --disable-gdb
    cmd="${MAKE_CMD} linux -j ${NTHREADS}"
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

if [[ "$python_en" -eq 1 ]]; then       # python enable
    git reset --hard ${BUILDROOT_SHA}
    git submodule update --init --recursive
    git apply ${BUILDROOT_PATCH}
    ${MAKE_CMD} distclean
    ${MAKE_CMD} defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/riscv_buildroot_python_defconfig
    patch_buildroot_host_fakeroot
    patch_buildroot_host_m4
    ${MAKE_CMD} -j ${NTHREADS}
else                                    # default
    git reset --hard ${BUILDROOT_SHA}
    git submodule update --init --recursive
    ${MAKE_CMD} distclean
    ${MAKE_CMD} defconfig BR2_DEFCONFIG=${SCRIPT_PATH}/riscv_buildroot_defconfig
    patch_buildroot_host_fakeroot
    patch_buildroot_host_m4
    ${MAKE_CMD} -j ${NTHREADS}
fi

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
echo "*** Keeping RISC-V build directory at ${TMP} ***"

cd ${ESP_ROOT}

#Riscv
echo ""
git checkout HEAD -- ${ESP_ROOT}/soft/ariane/sysroot/etc/init.d/S65drivers
if [[ "$python_en" -eq 1 ]]; then       # python enable
    echo 'echo root:openesp | chpasswd' >> ${ESP_ROOT}/soft/ariane/sysroot/etc/init.d/S65drivers
    echo "This build comes with Python"
else                                    # default
    echo "This build doesn't have Python"
fi
echo ""
echo "=== Use the following to load RISC-V environment ==="
echo -n "  export PATH=${RISCV}/bin:"; echo '$PATH'
echo "  export RISCV=${RISCV}"
echo ""

echo "*** Successfully installed RISC-V toolchain to $TARGET_DIR ***"
