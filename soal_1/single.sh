#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot
RAMDISK=$OSBOOT/single_dir

rm -rf $RAMDISK
mkdir -p $RAMDISK/{bin,dev,proc,sys,etc,tmp,root,sbin}

mknod -m 666 $RAMDISK/dev/null c 1 3 2>/dev/null
mknod -m 666 $RAMDISK/dev/zero c 1 5 2>/dev/null
mknod -m 666 $RAMDISK/dev/tty c 5 0 2>/dev/null
mknod -m 666 $RAMDISK/dev/console c 5 1 2>/dev/null

cp /usr/bin/busybox $RAMDISK/bin/
cd $RAMDISK/bin
./busybox --install .

cp $BASEDIR/party $RAMDISK/bin/party

# Setup apk repositories
mkdir -p $RAMDISK/etc/apk
cat > $RAMDISK/etc/apk/repositories << 'EOF'
https://dl-cdn.alpinelinux.org/alpine/v3.18/main
https://dl-cdn.alpinelinux.org/alpine/v3.18/community
EOF

cat > $RAMDISK/init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null

ip link set eth0 up
ip addr add 10.0.2.15/24 dev eth0
ip route add default via 10.0.2.2 dev eth0
echo "nameserver 8.8.8.8" > /etc/resolv.conf

echo "Welcome to Single User Mode!"
exec /bin/sh
EOF

chmod +x $RAMDISK/init

cd $RAMDISK
find . | cpio -oHnewc | gzip > $OSBOOT/single.gz
rm -rf $RAMDISK

echo "===== Single filesystem berhasil dibuat! ====="
ls -lh $OSBOOT/single.gz
