#!/bin/bash

export ARCH=arm  
export KERNEL_VERSION=4.4.1
export BUSYBOX_VERSION=1.25.1
export CROSS_COMPILE=arm-linux-gnueabihf-

function prepare() {
  apt-get -y install qemu gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
}

function download_linux() {
  if [ -e linux-${KERNEL_VERSION}.tar.xz ]
  then 
    echo linux-${KERNEL_VERSION}.tar.xz exist
  else 
    wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-${KERNEL_VERSION}.tar.xz
  fi

  tar xf linux-${KERNEL_VERSION}.tar.xz
}

function build_linux() {
  cd linux-${KERNEL_VERSION}
  make vexpress_defconfig  
  make zImage -j8  
  make modules -j8  
  make dtbs 
  cd -
}
  
function copy_linux() {
  rm -rf arm-linux-kernel
  mkdir arm-linux-kernel  
  cp -fv linux-${KERNEL_VERSION}/arch/arm/boot/zImage arm-linux-kernel/  
  cp -fv linux-${KERNEL_VERSION}/arch/arm/boot/dts/*ca9.dtb arm-linux-kernel/  
  cp -fv linux-${KERNEL_VERSION}/.config  arm-linux-kernel/ 
}

function download_busybox() {
  if [ -e busybox-${BUSYBOX_VERSION}.tar.bz2 ]
  then 
    echo busybox-${BUSYBOX_VERSION}.tar.bz2 exist
  else 
    wget https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2
  fi
  tar xf busybox-${BUSYBOX_VERSION}.tar.bz2
}

function build_busybox() {
  cd busybox-${BUSYBOX_VERSION}
  make defconfig  
  make CROSS_COMPILE=${CROSS_COMPILE}
  make install CROSS_COMPILE=${CROSS_COMPILE}
  cd -
}

function make_rootfs() {
 rm -rf tmpdir
 rm -rf rootfs
 mkdir -p rootfs/lib
 mkdir -p rootfs/dev

 cp -Pvf /usr/arm-linux-gnueabihf/lib/* rootfs/lib
 cp busybox-${BUSYBOX_VERSION}/_install/* rootfs/ -rf

 dd if=/dev/zero of=rootfs.ext3 bs=1M count=128
 mkfs.ext3 rootfs.ext3

 mkdir tmpdir  
 mount -t ext3 rootfs.ext3 tmpdir/ -o loop  
 cp -r rootfs/*  tmpdir/ 
 mknod tmpdir/dev/tty1 c 4 1  
 mknod tmpdir/dev/tty2 c 4 2  
 mknod tmpdir/dev/tty3 c 4 3  
 mknod tmpdir/dev/tty4 c 4 4  
 umount tmpdir 
}

function build() {
 prepare
 download_linux
 build_linux
 copy_linux 
 build_busybox
 make_rootfs
}

echo "Done"


