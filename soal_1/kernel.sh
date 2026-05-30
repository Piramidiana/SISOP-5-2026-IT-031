#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot

cd $OSBOOT

# Download kernel jika belum ada
if [ ! -f "linux-6.1.1.tar.xz" ]; then
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz
fi

# Ekstrak jika belum ada
if [ ! -d "linux-6.1.1" ]; then
    tar -xvf linux-6.1.1.tar.xz
fi

cd linux-6.1.1

# Konfigurasi kernel
make defconfig
./scripts/config --enable CONFIG_VIRTIO
./scripts/config --enable CONFIG_VIRTIO_PCI
./scripts/config --enable CONFIG_VIRTIO_NET
./scripts/config --enable CONFIG_VIRTIO_BLK
./scripts/config --enable CONFIG_VIRTIO_CONSOLE
./scripts/config --enable CONFIG_EXT4_FS
./scripts/config --enable CONFIG_FUSE_FS
./scripts/config --enable CONFIG_DEVTMPFS
./scripts/config --enable CONFIG_DEVTMPFS_MOUNT
make olddefconfig

# Compile kernel
make -j$(nproc) KCFLAGS="-w"

# Copy hasil
cp arch/x86/boot/bzImage $OSBOOT/bzImage
cp .config $BASEDIR/.config

echo "===== Kernel berhasil dibuat! ====="
ls -lh $OSBOOT/bzImage
