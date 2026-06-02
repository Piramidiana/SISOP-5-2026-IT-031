# Praktikum Sistem Operasi Modul 5

## Identitas

| Nama                        | NRP        |
| --------------------------- | ---------- |
| Dian Piramidiana Rachmatika | 5027251031 |

---

## Soal 1 - Farewell Party

### Penjelasan

Pada soal ini praktikan diminta untuk membangun sebuah sistem operasi Linux sederhana menggunakan kernel Linux 6.1.1 yang dikompilasi sendiri. Sistem operasi dijalankan menggunakan QEMU dan memiliki dua mode operasi, yaitu Single User Mode dan Multi User Mode.

Selain membuat kernel dan filesystem, praktikan juga diminta membuat ISO bootable yang berisi kedua mode tersebut, membuat script otomatisasi build, menyediakan koneksi internet di dalam sistem operasi, membuat package manager bernama `party`, serta melakukan instalasi FUSE sebagai bukti bahwa package manager dapat digunakan.

Sistem terdiri dari enam script utama:

* `kernel.sh` — Mengunduh, mengonfigurasi, dan mengompilasi kernel Linux
* `single.sh` — Membuat filesystem Single User
* `multi.sh` — Membuat filesystem Multi User
* `iso.sh` — Membuat ISO bootable menggunakan GRUB
* `qemu.sh` — Menjalankan sistem operasi menggunakan QEMU
* `backup.sh` — Membuat backup seluruh hasil build

---

### Penjelasan File

#### `kernel.sh`

Script ini bertugas membangun kernel Linux 6.1.1 yang nantinya digunakan sebagai inti dari sistem operasi.

Alur pengerjaannya:

1. Mengecek apakah source kernel sudah ada.
2. Jika belum ada maka mengunduh dari kernel.org.
3. Mengekstrak source kernel.
4. Menjalankan konfigurasi default menggunakan `make defconfig`.
5. Mengaktifkan driver-driver yang dibutuhkan QEMU.
6. Mengompilasi kernel menggunakan seluruh core CPU yang tersedia.
7. Menyalin hasil compile berupa `bzImage`.

Konfigurasi tambahan yang diaktifkan:

```bash
CONFIG_VIRTIO
CONFIG_VIRTIO_PCI
CONFIG_VIRTIO_NET
CONFIG_VIRTIO_BLK
CONFIG_VIRTIO_CONSOLE
CONFIG_EXT4_FS
CONFIG_FUSE_FS
CONFIG_DEVTMPFS
CONFIG_DEVTMPFS_MOUNT
```

Konfigurasi tersebut diperlukan agar kernel dapat mengenali perangkat virtual milik QEMU, mendukung networking, filesystem, serta FUSE.

---

#### `single.sh`

Script ini digunakan untuk membuat filesystem Single User.

Filesystem dibuat menggunakan BusyBox sehingga seluruh utilitas dasar Linux tersedia dalam satu binary.

Struktur direktori yang dibuat:

```text
bin
dev
proc
sys
etc
tmp
root
sbin
```

Selain itu script juga:

* Membuat device file seperti `/dev/null`, `/dev/zero`, `/dev/tty`, dan `/dev/console`
* Menyalin BusyBox ke dalam filesystem
* Menyalin package manager `party`
* Menambahkan repository Alpine Linux
* Mengatur konfigurasi jaringan secara otomatis

Pada file `init`, sistem akan:

1. Mount `/proc`
2. Mount `/sys`
3. Mount `/dev`
4. Mengaktifkan interface jaringan
5. Mengatur default gateway
6. Menambahkan DNS Google (8.8.8.8)
7. Menampilkan pesan:

```text
Welcome to Single User Mode!
```

8. Membuka shell root secara langsung tanpa login

Filesystem kemudian dikemas menjadi:

```text
single.gz
```

---

#### `multi.sh`

Script ini digunakan untuk membuat filesystem Multi User.

Berbeda dengan Single User Mode, pada mode ini terdapat lima akun yang dapat digunakan untuk login.

Daftar user:

```text
root
henn
hann
viii
kids
```

Password masing-masing user dibuat menggunakan:

```bash
openssl passwd -1
```

sehingga password tersimpan dalam bentuk hash dan tidak ditulis secara langsung.

Script juga membuat:

* `/etc/passwd`
* `/etc/group`

untuk menyimpan informasi akun dan grup.

Selain itu ditambahkan banner khusus Farewell Party yang ditampilkan ketika user berhasil login.

Banner tersebut dijalankan otomatis melalui:

```bash
/etc/profile
```

Pada file `init`, sistem akan terus menjalankan:

```bash
/bin/login
```

sehingga setiap user harus melakukan autentikasi sebelum masuk ke shell.

Output akhir script:

```text
multi.gz
```

---

#### `iso.sh`

Script ini digunakan untuk membuat file ISO bootable.

Langkah yang dilakukan:

1. Membuat struktur direktori ISO.
2. Menyalin kernel (`bzImage`).
3. Menyalin filesystem Single User (`single.gz`).
4. Menyalin filesystem Multi User (`multi.gz`).
5. Membuat konfigurasi GRUB.

GRUB berisi dua menu:

```text
Farewell Party - Single User
Farewell Party - Multi User
```

Sehingga pengguna dapat memilih mode yang ingin dijalankan saat boot.

ISO kemudian dibuat menggunakan:

```bash
grub-mkrescue
```

Output akhir:

```text
farewell.iso
```

---

#### `qemu.sh`

Script ini digunakan untuk mempermudah proses boot sistem operasi.

Script menerima tiga parameter:

```bash
--single
--multi
--all
```

Mode `--single` menjalankan filesystem Single User.

Mode `--multi` menjalankan filesystem Multi User.

Mode `--all` melakukan boot menggunakan file ISO sehingga menu GRUB muncul terlebih dahulu.

Seluruh mode dijalankan menggunakan:

```bash
qemu-system-x86_64
```

dengan memori 256 MB dan 2 virtual CPU.

---

#### `backup.sh`

Script ini digunakan untuk membuat backup seluruh hasil build.

File yang dibackup:

```text
bzImage
single.gz
multi.gz
farewell.iso
```

Nama file backup dibuat otomatis menggunakan timestamp:

```text
farewell_backup_DDMMYYYY-HHMMSS.zip
```

Setelah proses zip selesai, file build asli dihapus sehingga hanya tersisa file backup.

---

### Fitur

| Fitur                 | Keterangan                                                   |
| --------------------- | ------------------------------------------------------------ |
| Linux Kernel 6.1.1    | Kernel dikompilasi sendiri dari source code Linux 6.1.1      |
| Single User Mode      | Sistem langsung masuk ke shell root tanpa login              |
| Multi User Mode       | Sistem menyediakan 5 akun pengguna yang dapat login          |
| BusyBox               | Menyediakan utilitas dasar Linux dalam ukuran ringan         |
| Custom Banner         | Menampilkan banner Farewell Party saat login                 |
| Internet Access       | Sistem dapat melakukan ping dan wget melalui jaringan QEMU   |
| Package Manager Party | Package manager dengan nama party tersedia di dalam sistem   |
| FUSE Support          | Kernel dan filesystem mendukung penggunaan FUSE              |
| Bootable ISO          | Sistem dapat dijalankan melalui file ISO menggunakan GRUB    |
| GRUB Boot Menu        | Pengguna dapat memilih Single User atau Multi User saat boot |
| QEMU Integration      | Sistem dapat dijalankan langsung menggunakan QEMU            |
| Backup Automation     | Hasil build dapat dibackup menjadi file ZIP otomatis         |

---
---

### Cara Menjalankan

Sebelum menjalankan sistem operasi, pastikan seluruh dependency sudah terinstall seperti:

```bash
sudo apt update

sudo apt install -y \
qemu-system \
build-essential \
bison \
flex \
libelf-dev \
libssl-dev \
busybox \
cpio \
grub-pc-bin \
xorriso
```

---

#### 1. Build Kernel

```bash
./kernel.sh
```

**Penjelasan**

Script ini akan mengunduh source code Linux Kernel 6.1.1 apabila belum tersedia, kemudian melakukan konfigurasi kernel dan proses compile.

Selama proses ini terminal akan menampilkan ribuan baris output karena seluruh source code Linux sedang dikompilasi.

Jika berhasil akan muncul output seperti:

```text
Kernel: arch/x86/boot/bzImage is ready
===== Kernel berhasil dibuat! =====
```

Artinya kernel berhasil dibuat dan file hasil compile tersimpan pada:

```text
osboot/bzImage
```

---

#### 2. Membuat Filesystem Single User

```bash
./single.sh
```

**Penjelasan**

Script ini membuat filesystem sederhana berbasis BusyBox.

Ketika dijalankan script akan:

* Membuat struktur direktori Linux
* Membuat device file
* Menyalin BusyBox
* Menyalin package manager `party`
* Mengatur jaringan otomatis
* Membuat file init

Jika berhasil akan muncul:

```text
===== Single filesystem berhasil dibuat! =====
```

Output yang dihasilkan:

```text
osboot/single.gz
```

Filesystem ini digunakan untuk mode Single User.

---

#### 3. Membuat Filesystem Multi User

```bash
./multi.sh
```

**Penjelasan**

Script ini membuat filesystem Multi User yang berisi beberapa akun pengguna.

User yang tersedia:

```text
root
henn
hann
viii
kids
```

Script juga membuat banner Farewell Party serta sistem login menggunakan BusyBox.

Jika berhasil akan muncul:

```text
===== Multi filesystem berhasil dibuat! =====
```

Output yang dihasilkan:

```text
osboot/multi.gz
```

---

#### 4. Membuat ISO Bootable

```bash
./iso.sh
```

**Penjelasan**

Script ini menggabungkan:

* Kernel (`bzImage`)
* Single User Filesystem (`single.gz`)
* Multi User Filesystem (`multi.gz`)

ke dalam satu file ISO menggunakan GRUB.

Jika berhasil akan muncul:

```text
===== ISO berhasil dibuat! =====
```

Output:

```text
osboot/farewell.iso
```

ISO ini dapat digunakan untuk boot melalui menu GRUB.

---

#### 5. Menjalankan Single User Mode

```bash
./qemu.sh --single
```

**Penjelasan**

Mode ini akan menjalankan kernel menggunakan filesystem Single User.

Saat boot berhasil, sistem akan menampilkan:

```text
Welcome to Single User Mode!
```

kemudian langsung masuk ke shell root:

```text
#
```

Karena mode ini tidak menggunakan login, pengguna langsung mendapatkan akses root setelah boot selesai.

---

#### 6. Menjalankan Multi User Mode

```bash
./qemu.sh --multi
```

**Penjelasan**

Mode ini akan menjalankan kernel menggunakan filesystem Multi User.

Setelah boot selesai akan muncul:

```text
Login:
```

Masukkan username dan password yang tersedia.

Contoh:

```text
Username : henn
Password : henn123
```

Setelah login berhasil, banner Farewell Party akan ditampilkan dan pengguna masuk ke shell sesuai akun yang digunakan.

---

#### 7. Menjalankan ISO dengan Menu GRUB

```bash
./qemu.sh --all
```

**Penjelasan**

Mode ini melakukan boot dari file ISO yang sudah dibuat sebelumnya.

Ketika berhasil dijalankan akan muncul menu GRUB:

```text
Farewell Party - Single User
Farewell Party - Multi User
```

Pengguna dapat memilih mode yang ingin dijalankan menggunakan tombol panah pada keyboard.

---

#### 8. Menguji Koneksi Internet

Setelah berhasil masuk ke sistem operasi, koneksi internet dapat diuji menggunakan:

```bash
ping 8.8.8.8
```

Jika muncul balasan seperti:

```text
64 bytes from 8.8.8.8
```

maka koneksi jaringan berhasil berjalan.

Selain itu dapat diuji menggunakan:

```bash
wget example.com
```

Jika file berhasil diunduh maka konfigurasi DNS dan routing telah berjalan dengan benar.

---

#### 9. Menggunakan Package Manager Party

Package manager yang tersedia bernama:

```bash
party
```

Contoh penggunaan:

```bash
party --help
```

atau

```bash
party --version
```

Package manager ini digunakan untuk mengelola instalasi package di dalam sistem operasi.

---

#### 10. Menguji FUSE

Setelah package FUSE berhasil dipasang, keberadaannya dapat dicek menggunakan:

```bash
fusermount3 --version
```

Jika muncul informasi versi FUSE maka dukungan FUSE pada kernel dan filesystem telah berhasil berjalan.

---

#### 11. Membuat Backup

```bash
./backup.sh
```

**Penjelasan**

Script ini akan membuat file backup berisi seluruh hasil build.

Output yang dihasilkan:

```text
farewell_backup_DDMMYYYY-HHMMSS.zip
```

Setelah file ZIP berhasil dibuat, file hasil build sebelumnya akan dihapus sehingga backup menjadi satu-satunya salinan hasil build.

---

---

### Cara Menjalankan

#### 1. Build Kernel

Jalankan:

```bash
./kernel.sh
```

Script ini bakal download source Linux Kernel 6.1.1 (kalau belum ada), ngatur konfigurasi kernel yang dibutuhkan, lalu compile kernel.

Proses ini paling lama dibanding langkah lainnya karena harus compile source Linux yang ukurannya cukup besar.

Kalau berhasil biasanya bakal muncul:

```text
Kernel: arch/x86/boot/bzImage is ready
```

Hasilnya tersimpan di:

```text
osboot/bzImage
```

---

#### 2. Buat Filesystem Single User

Jalankan:

```bash
./single.sh
```

Script ini bikin filesystem sederhana menggunakan BusyBox.

Mode ini nantinya langsung masuk ke shell root tanpa perlu login.

Kalau berhasil akan menghasilkan:

```text
osboot/single.gz
```

---

#### 3. Buat Filesystem Multi User

Jalankan:

```bash
./multi.sh
```

Script ini membuat filesystem yang memiliki beberapa user yaitu:

```text
root
henn
hann
viii
kids
```

Selain itu juga menambahkan banner Farewell Party dan sistem login.

Outputnya:

```text
osboot/multi.gz
```

---

#### 4. Buat ISO

Jalankan:

```bash
./iso.sh
```

Script ini menggabungkan kernel, filesystem single user, dan filesystem multi user ke dalam satu file ISO.

Kalau berhasil akan menghasilkan:

```text
osboot/farewell.iso
```

---

#### 5. Menjalankan Single User Mode

Jalankan:

```bash
./qemu.sh --single
```

Kalau boot berhasil akan muncul:

```text
Welcome to Single User Mode!
```

Setelah itu langsung masuk ke shell root tanpa login.

---

#### 6. Menjalankan Multi User Mode

Jalankan:

```bash
./qemu.sh --multi
```

Kalau berhasil boot akan muncul prompt login.

Masukkan salah satu user yang tersedia, misalnya:

```text
Username : henn
Password : henn123
```

Setelah login berhasil akan muncul banner Farewell Party.

---

#### 7. Menjalankan ISO

Jalankan:

```bash
./qemu.sh --all
```

Mode ini boot menggunakan file ISO yang sudah dibuat sebelumnya.

Nanti akan muncul menu GRUB yang berisi:

```text
Farewell Party - Single User
Farewell Party - Multi User
```

Tinggal pilih mode yang ingin dijalankan.

---

#### 8. Test Internet

Setelah berhasil masuk ke sistem operasi, internet bisa dicek menggunakan:

```bash
ping 8.8.8.8
```

atau

```bash
wget example.com
```

Kalau ada balasan berarti konfigurasi jaringan berhasil.

---

#### 9. Test Party

Untuk memastikan package manager sudah tersedia, jalankan:

```bash
party --help
```

atau

```bash
party --version
```

Kalau muncul output berarti package manager berhasil terpasang.

---

#### 10. Test FUSE

Untuk memastikan FUSE berhasil digunakan:

```bash
fusermount3 --version
```

Kalau versi FUSE muncul berarti dukungan FUSE sudah berjalan dengan baik.

---

#### 11. Backup Hasil Build

Jalankan:

```bash
./backup.sh
```

Script ini akan menggabungkan hasil build ke dalam file ZIP dengan format:

```text
farewell_backup_DDMMYYYY-HHMMSS.zip
```

Sehingga hasil build bisa disimpan sebagai backup jika sewaktu-waktu diperlukan.

---

---

### Kendala

1. **Compile kernel sempat gagal** karena beberapa warning dianggap error oleh compiler. Solusinya menggunakan:

   ```bash
   make -j$(nproc) KCFLAGS="-w"
   ```

2. **Konfigurasi VIRTIO cukup membingungkan** saat menggunakan `menuconfig` karena banyak dependency yang belum aktif. Akhirnya menggunakan `make defconfig` dan `./scripts/config --enable`.

3. **WSL tidak bisa langsung menyalin device file** dari `/dev`, sehingga harus membuat device file secara manual menggunakan `mknod`.

4. **cpio belum terinstall** sehingga pembuatan initramfs gagal. Diselesaikan dengan menginstall package `cpio`.

5. **Compile kernel memakan waktu cukup lama** karena ukuran source Linux yang besar, tetapi dapat dipercepat menggunakan seluruh core CPU dengan `make -j$(nproc)`.

---


