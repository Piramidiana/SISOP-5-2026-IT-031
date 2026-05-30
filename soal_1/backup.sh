#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot

# Buat nama file dengan timestamp
TIMESTAMP=$(date +"%d%m%Y-%H%M%S")
ZIPNAME="farewell_backup_${TIMESTAMP}.zip"

# Zip semua file hasil build
zip -j $OSBOOT/$ZIPNAME \
    $OSBOOT/bzImage \
    $OSBOOT/single.gz \
    $OSBOOT/multi.gz \
    $OSBOOT/farewell.iso

# Hapus file asli
rm -f $OSBOOT/bzImage
rm -f $OSBOOT/single.gz
rm -f $OSBOOT/multi.gz
rm -f $OSBOOT/farewell.iso

echo "===== Backup berhasil dibuat! ====="
ls -lh $OSBOOT/$ZIPNAME
