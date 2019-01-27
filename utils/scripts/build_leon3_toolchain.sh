#!/bin/bash

CURRENT_DIR=${PWD}
SCRIPT_PATH=$(realpath $(dirname "$0"))
ESP_ROOT=$(realpath ${SCRIPT_PATH}/../..)
LINUXSRC=${ESP_ROOT}/soft/leon3/linux
SYSROOT=${ESP_ROOT}/soft/leon3/sysroot

DEFAULT_TARGET_DIR="/opt/leon"
SRC_MIRROR="http://espdev.cs.columbia.edu/stuff/leon3"
TMP=${PWD}/_leon3_build

BAREC_GCC_VERSION="4.4.2"
GRMON_VERSION="eval-3.0.9"
MKLINUXIMG_VERSION="2.0.10"

# Tool chain versions for Linux (stable)
LINUX_VERSION="4.9.112"
BINUTILS_VERSION="2.24"
GCC_VERSION="4.9.4"
UCLIBC_VERSION="ng-1.0.28"
BUSYBOX_VERSION="1.25.0"
ZLIB_VERSION="1.2.11"
DROPBEAR_VERSION="2017.75"

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
    echo "*** This script will build and install the Leon3 tool chain ***"
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
read -p "Number of threads for Make (defaults to as many as possible)? :" NTHREADS
NTHREADS=${NTHREADS:-""}

# Tool chain environment
export TOOLS=${TARGET_DIR}/sparc-linux
export PATH=${TOOLS}/usr/bin:$PATH

runsudo () {
    if [ -w $1 ]; then
	$2
    else
	sudo TOOLS=${TARGET_DIR}/sparc-linux PATH=${TOOLS}/usr/bin:$PATH $2 || exit
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


# GRMON debugger
src=grmon-${GRMON_VERSION}
tar=$src.tar.gz
ovwrt="n"
dst="${TARGET_DIR}/${src}"

echo "*** Installing grmon ... ***"
if [ $(noyes "Skip ${src}") == "n" ]; then
    if test -e $dst; then
	if [ $(noyes "Re-install ${dst}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	cmd="rm -rf ${dst} ${TARGET_DIR}/grmon"
	runsudo $TARGET_DIR "$cmd"
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
	cmd="mv ${src} ${TARGET_DIR}"
	runsudo $TARGET_DIR "$cmd"
	cmd="ln -s ${dst} ${TARGET_DIR}/grmon"
	runsudo $TARGET_DIR "$cmd"
    fi
fi

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



# Binutils
src=binutils-${BINUTILS_VERSION}
tar=${src}.tar.gz
ovwr="n"

echo "*** Installing binutils... ***"
if [ $(noyes "Skip ${src}") == "n" ]; then
    if test -e $src; then
	if [ $(noyes "Re-build ${src}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
    fi

    cd $src
    if [ $ovwrt == "y" ]; then
	./configure --prefix=${TOOLS}/usr --target=sparc-leon3-linux --with-sysroot=${TOOLS} --disable-nls --disable-multilib --with-cpu=v8
    fi

    make -j ${NTHREADS}
    cmd="make install"
    runsudo ${TARGET_DIR} "$cmd"

    cd $TMP
fi

# Linux headers
echo "*** Installing Linux headers... ***"
if [ $(noyes "Skip Linux headers?") == "n" ]; then
    cd $LINUXSRC
    make mrproper
    ARCH=sparc make leon3_smp_defconfig
    make ARCH=sparc headers_check
    cmd="make ARCH=sparc INSTALL_HDR_PATH=${TOOLS}/usr headers_install"
    runsudo $TOOLS "$cmd"
    make mrproper
    cd $TMP
fi

# GCC first pass
src=gcc-${GCC_VERSION}
tar=${src}.tar.gz
build=gcc-1

echo "*** Installing GCC (first pass) ... ***"
if [ $(noyes "Skip ${src} first pass?") == "n" ]; then
    if test -e ${build}; then
	if [ $(noyes "Re-build ${build}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${build}
	if test ! -e $src; then
	    if test ! -e $tar; then
		wget ${SRC_MIRROR}/$tar
	    fi
	    tar xf $tar
	fi
	mkdir -p $build
    fi

    cd $build
    if [ $ovwrt == "y" ]; then
	../$src/configure --prefix=${TOOLS}/usr --target=sparc-leon3-linux --disable-nls --disable-shared --disable-multilib --disable-libgomp --disable-libmudflap --disable-libssp --disable-threads --enable-languages=c --with-cpu=v8
    fi

    make gcc_cv_libc_provides_ssp=yes all-gcc all-target-libgcc -j ${NTHREADS}
    cmd="make install-gcc install-target-libgcc"
    runsudo $TOOLS "$cmd"

    cd /$TOOLS/usr/lib/gcc/sparc-leon3-linux/${GCC_VERSION}
    link_name=$(sparc-leon3-linux-gcc -print-libgcc-file-name | sed 's/libgcc/&_eh/')
    if test ! -e $link_name; then
	cmd="ln -vs libgcc.a $link_name"
	runsudo $TOOLS "$cmd"
    fi

    cd $TMP
fi


# uClibC
src=uClibc-${UCLIBC_VERSION}
tar=${src}.tar.gz

echo "*** Installing uClibc ... ***"
if [ $(noyes "Skip ${src}?") == "n" ]; then
    if test -e $src; then
	if [ $(noyes "Re-build ${src}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
    fi

    cd $src
    make -j ${NTHREADS}
    cmd="make PREFIX=${TOOLS} install"
    runsudo $TOOLS "$cmd"

    cd $TMP
fi


# GCC second pass
src=gcc-${GCC_VERSION}
tar=${src}.tar.gz
build=gcc-2

echo "*** Installing GCC (second pass) ... ***"
if [ $(noyes "Skip ${src} second pass?") == "n" ]; then
    if test -e ${build}; then
	if [ $(noyes "Re-build ${build}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${build}
	if test ! -e $src; then
	    if test ! -e $tar; then
		wget ${SRC_MIRROR}/$tar
	    fi
	    tar xf $tar
	fi
	mkdir -p $build
    fi

    cd $build
    if [ $ovwrt == "y" ]; then
	../$src/configure --prefix=${TOOLS}/usr --target=sparc-leon3-linux --with-sysroot=${TOOLS} --disable-nls --enable-shared --disable-multilib --disable-libmudflap --enable-threads=posix --enable-languages="c,c++" --with-gnu-as --disable-libitm --disable-libsanitizer --with-cpu=v8
    fi

    make -j ${NTHREADS}
    cmd="make install-strip"
    runsudo $TOOLS "$cmd"

    cmd="ln -s sparc-leon3-linux-gcc     ${TOOLS}/usr/bin/sparc-linux-gcc"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-ld      ${TOOLS}/usr/bin/sparc-linux-ld"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-objdump ${TOOLS}/usr/bin/sparc-linux-objdump"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-objcopy ${TOOLS}/usr/bin/sparc-linux-objcopy"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-readelf ${TOOLS}/usr/bin/sparc-linux-readelf"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-as ${TOOLS}/usr/bin/sparc-linux-as"
    runsudo $TOOLS "$cmd"
    cmd="ln -s sparc-leon3-linux-ar ${TOOLS}/usr/bin/sparc-linux-ar"
    runsudo $TOOLS "$cmd"

    cd $TMP
fi


# Root file system
echo "*** Populating root file system ... ***"
if [ $(noyes "Skip rootfs?") == "n" ]; then
    if test ! -e ${TOOLS}/lib; then
	echo "Library files not found (${TOOLS}/lib)!"
	exit
    fi

    if test ! -e ${TOOLS}/usr/sparc-leon3-linux/lib/; then
	echo "Library files not found (${TOOLS}/lib)!"
	exit
    fi

    cp -a ${TOOLS}/lib ${SYSROOT}
    cp -a ${TOOLS}/usr/sparc-leon3-linux/lib/*.so* ${SYSROOT}/lib
    cd ${SYSROOT}/lib
    if test ! -e ld-linux.so.2; then
	ln -s ld-uClibc*.so ld-linux.so.2
    fi

    mkdir -p ${SYSROOT}/lib/modules/${LINUX_VERSION}

    cd $TMP
fi

# Busybox
src=busybox-${BUSYBOX_VERSION}
tar=${src}.tar.bz2

echo "*** Building busybox ... ***"
if [ $(noyes "Skip ${src}?") == "n" ]; then
    if test -e $src; then
	if [ $(noyes "Re-build ${src}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
    fi

    cd $src
    make busybox -j ${NTHREADS}
    make CONFIG_PREFIX=${SYSROOT} install
    if test ! -e ${SYSROOT}/init; then
	ln -s bin/busybox ${SYSROOT}/init
    fi
    cd $TMP
fi

# Zlib
src=zlib-${ZLIB_VERSION}
tar=${src}.tar.gz

echo "*** Building zlib ... ***"
if [ $(noyes "Skip ${src}?") == "n" ]; then
    if test -e $src; then
	if [ $(noyes "Re-build ${src}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
    fi

    cd $src

    CROSS_PREFIX=sparc-leon3-linux- CFLAGS=-Os ./configure --prefix=/usr --eprefix=/
    make -j ${NTHREADS}
    sparc-leon3-linux-strip libz.so

    cmd="make prefix=${TOOLS}/usr exec_prefix=${TOOLS}/usr install"
    runsudo $TOOLS "$cmd"

    cp -a ${TOOLS}/usr/lib/libz*.so* ${SYSROOT}/lib

    cd $TMP
fi


# Dropbear
src=dropbear-${DROPBEAR_VERSION}
tar=${src}.tar.bz2

echo "*** Building Dropbear ... ***"
if [ $(noyes "Skip ${src}?") == "n" ]; then
    if test -e $src; then
	if [ $(noyes "Re-build ${src}") == "y" ]; then
	    ovwrt="y"
	fi
    else
	ovwrt="y"
    fi

    if [ $ovwrt == "y" ]; then
	rm -rf ${src}
	if test ! -e $tar; then
	    wget ${SRC_MIRROR}/$tar
	fi
	tar xf $tar
    fi

    cd $src

    CFLAGS=-Os LDFLAGS="-lssp" ./configure --prefix=/ --host=sparc-leon3-linux
    make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
    fakeroot make MULTI=1 PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp" DESTDIR=${SYSROOT} strip install

    mkdir -p ${SYSROOT}/etc/dropbear
    ssh-keygen -t rsa -N "" -f ${SYSROOT}/etc/dropbear/openssh_rsa_host_key

    mkdir -p ${SYSROOT}/usr/bin
    cd ${SYSROOT}/usr/bin
    if test ! -e dbclient; then
	ln -s ../../bin/dbclient
    fi

    cd $TMP
fi



# #Leon3
# # grmon : JTAG debug tool
# export PATH=/opt/leon/grmon/linux/bin64:$PATH
# # sparc-linux- : Linux Cross compiler
# export PATH=/opt/leon/sparc-linux/usr/bin:$PATH
# # mklinuximg : Make bootable linux image (PATCHED TO WORK WITH NEW KERNEL)
# export PATH=/opt/leon/mklinuximg:$PATH
# # mkprom2 : Make PROM bootable image
# export PATH=/opt/leon/mkprom2:$PATH
# # sparc-elf- : Bare metal Cross compiler
# export PATH=/opt/leon/sparc-elf/bin:$PATH

cd $CURRENT_DIR
echo "*** Successfully installed Leon3 toolchain to $TARGET_DIR ***"
