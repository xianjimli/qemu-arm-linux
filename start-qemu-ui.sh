#!/bin/bash

qemu-system-arm -M vexpress-a9 -m 512M \
  -dtb ./arm-linux-kernel/vexpress-v2p-ca9.dtb \
  -kernel ./arm-linux-kernel/zImage
  -append "root=/dev/mmcblk0 rw console=ttyAMA0 init=/bin/sh" \
  -sd rootfs.ext3  

