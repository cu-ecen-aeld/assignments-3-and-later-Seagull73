#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
PWD_SAVE=$(pwd)

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j32 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
fi

echo "Adding the Image in outdir"

cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}/Image

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
cd "$OUTDIR"
mkdir -p rootfs
cd "$OUTDIR/rootfs"
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/lib usr/bin usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git --depth 1 --single-branch --branch ${BUSYBOX_VERSION}
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} distclean
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    sed -i 's/^CONFIG_TC=y/CONFIG_TC=n/' .config
else
    cd busybox
fi

# TODO: Make and install busybox
make -j32 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX="$OUTDIR/rootfs" ARCH=ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
${CROSS_COMPILE}readelf -a busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
cp $(dirname $(which ${CROSS_COMPILE}gcc))/../aarch64-none-linux-gnu/libc/lib64/libm.so.6  ${OUTDIR}/rootfs/lib64/libm.so.6
cp $(dirname $(which ${CROSS_COMPILE}gcc))/../aarch64-none-linux-gnu/libc/lib64/libc.so.6  ${OUTDIR}/rootfs/lib64/libc.so.6
cp $(dirname $(which ${CROSS_COMPILE}gcc))/../aarch64-none-linux-gnu/libc/lib64/libresolv.so.2  ${OUTDIR}/rootfs/lib64/libresolv.so.2
cp $(dirname $(which ${CROSS_COMPILE}gcc))/../aarch64-none-linux-gnu/libc/lib/ld-linux-aarch64.so.1  ${OUTDIR}/rootfs/lib/ld-linux-aarch64.so.1

# TODO: Make device nodes

# TODO: Clean and build the writer utility
cd ${PWD_SAVE}
echo ${PWD_SAVE}
make -f Makefile CROSS_COMPILE=${CROSS_COMPILE} clean
make -f Makefile CROSS_COMPILE=${CROSS_COMPILE} all

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp ./writer $OUTDIR/rootfs/home/writer
cp ./autorun-qemu.sh $OUTDIR/rootfs/home/autorun-qemu.sh
cp ./finder.sh $OUTDIR/rootfs/home/finder.sh
cp ./finder-test.sh $OUTDIR/rootfs/home/finder-test.sh
cp -rL ./conf $OUTDIR/rootfs/home/conf

# TODO: Chown the root directory
sudo chown -R root:root $OUTDIR/rootfs

# TODO: Create initramfs.cpio.gz
cd $OUTDIR/rootfs
find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz
