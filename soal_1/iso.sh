#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot
ISODIR=$OSBOOT/isodir

# Hapus folder lama
rm -rf $ISODIR

# Buat struktur direktori ISO
mkdir -p $ISODIR/boot/grub

# Copy kernel dan filesystem
cp $OSBOOT/bzImage $ISODIR/boot/
cp $OSBOOT/single.gz $ISODIR/boot/
cp $OSBOOT/multi.gz $ISODIR/boot/

# Buat konfigurasi GRUB
cat > $ISODIR/boot/grub/grub.cfg << 'EOF'
set timeout=10
set default=0

menuentry "Farewell Party - Single User" {
    linux /boot/bzImage console=ttyS0 root=/dev/ram rdinit=/init
    initrd /boot/single.gz
}

menuentry "Farewell Party - Multi User" {
    linux /boot/bzImage console=ttyS0 root=/dev/ram rdinit=/init
    initrd /boot/multi.gz
}
EOF

# Buat ISO
grub-mkrescue -o $OSBOOT/farewell.iso $ISODIR 2>/dev/null

# Bersihkan
rm -rf $ISODIR

echo "===== ISO berhasil dibuat! ====="
ls -lh $OSBOOT/farewell.iso
