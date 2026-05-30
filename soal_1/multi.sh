#!/bin/bash

BASEDIR=~/SISOP-5-2026-IT-031/soal_1
OSBOOT=$BASEDIR/osboot
RAMDISK=$OSBOOT/multi_dir

rm -rf $RAMDISK
mkdir -p $RAMDISK/{bin,dev,proc,sys,etc,tmp,root}
mkdir -p $RAMDISK/home/{henn,hann,viii,kids}

cp /usr/bin/busybox $RAMDISK/bin/
cd $RAMDISK/bin
./busybox --install .
cp $BASEDIR/party $RAMDISK/bin/party
# Setup apk repositories
mkdir -p $RAMDISK/etc/apk
cat > $RAMDISK/etc/apk/repositories << 'REPOEOF'
https://dl-cdn.alpinelinux.org/alpine/v3.18/main
https://dl-cdn.alpinelinux.org/alpine/v3.18/community
REPOEOF

ROOT_PASS=$(openssl passwd -1 "root123")
HENN_PASS=$(openssl passwd -1 "henn123")
HANN_PASS=$(openssl passwd -1 "hann123")
VIII_PASS=$(openssl passwd -1 "viii123")
KIDS_PASS=$(openssl passwd -1 "kids123")

cat > $RAMDISK/etc/passwd << EOF
root:$ROOT_PASS:0:0:root:/root:/bin/sh
henn:$HENN_PASS:1001:1001:henn:/home/henn:/bin/sh
hann:$HANN_PASS:1002:1002:hann:/home/hann:/bin/sh
viii:$VIII_PASS:1003:1003:viii:/home/viii:/bin/sh
kids:$KIDS_PASS:1004:1004:kids:/home/kids:/bin/sh
EOF

cat > $RAMDISK/etc/group << EOF
root:x:0:
henn:x:1001:
hann:x:1002:
viii:x:1003:
kids:x:1004:
users:x:100:henn,hann,viii,kids
EOF

chmod 755 $RAMDISK/home
chmod 700 $RAMDISK/root

cat > $RAMDISK/etc/banner.sh << 'EOF'
#!/bin/sh
cat << 'BANNER'
  _____                          _ _   ____            _         
 |  ___|_ _ _ __ _____      ____| | | |  _ \ __ _ _ __| |_ _   _ 
 | |_ / _` | '__/ _ \ \ /\ / / _ \ | | |_) / _` | '__| __| | | |
 |  _| (_| | | |  __/\ V  V /  __/ | |  __/ (_| | |  | |_| |_| |
 |_|  \__,_|_|  \___| \_/\_/ \___|_|_|_|   \__,_|_|   \__|\__, |
                                                             |___/ 
BANNER
echo "Welcome, $(whoami)."
EOF
chmod +x $RAMDISK/etc/banner.sh

cat > $RAMDISK/etc/profile << 'EOF'
/etc/banner.sh
EOF

cat > $RAMDISK/init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev 2>/dev/null

# Setup network otomatis
ip link set eth0 up
ip addr add 10.0.2.15/24 dev eth0
ip route add default via 10.0.2.2 dev eth0
echo "nameserver 8.8.8.8" > /etc/resolv.conf

while true; do
    echo "Login:"
    /bin/login
    sleep 1
done
EOF
chmod +x $RAMDISK/init

cd $RAMDISK
find . | cpio -oHnewc | gzip > $OSBOOT/multi.gz
rm -rf $RAMDISK

echo "===== Multi filesystem berhasil dibuat! ====="
ls -lh $OSBOOT/multi.gz
