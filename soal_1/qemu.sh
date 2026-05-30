#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot

if [ "$1" == "--single" ]; then
    echo "Booting Single User Mode..."
    qemu-system-x86_64 \
        -smp 2 \
        -m 256 \
        -nographic \
        -kernel $OSBOOT/bzImage \
        -initrd $OSBOOT/single.gz \
        -append "console=ttyS0 root=/dev/ram rdinit=/init"

elif [ "$1" == "--multi" ]; then
    echo "Booting Multi User Mode..."
    qemu-system-x86_64 \
        -smp 2 \
        -m 256 \
        -nographic \
        -kernel $OSBOOT/bzImage \
        -initrd $OSBOOT/multi.gz \
        -append "console=ttyS0 root=/dev/ram rdinit=/init"

elif [ "$1" == "--all" ]; then
    echo "Booting dari ISO..."
    qemu-system-x86_64 \
        -smp 2 \
        -m 256 \
        -nographic \
        -cdrom $OSBOOT/farewell.iso \
        -boot d

else
    echo "Usage: ./qemu.sh [--single|--multi|--all]"
    echo "  --single  : Boot single user mode"
    echo "  --multi   : Boot multi user mode"
    echo "  --all     : Boot dari ISO dengan menu GRUB"
fi
