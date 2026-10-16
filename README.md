# SERASI — Sistem Informasi Servis dan Garansi Elektronik

Prototipe interaktif sistem manajemen servis elektronik untuk demonstrasi alur kerja dari penerimaan perangkat hingga garansi. Antarmuka dan data contoh menggunakan Bahasa Indonesia, nama fiktif, Rupiah, dan format tanggal DD/MM/YYYY.

## Coba prototipe

Setelah GitHub Pages selesai diterapkan, buka: **https://agniaarf.github.io/serasi/**

Masuk dengan salah satu akun demo dan gunakan kata sandi `demo1234`. Pilih peran Admin, Teknisi, QC, Pemilik, atau Pelanggan melalui pemilih peran. Data demo disimpan di local storage browser masing-masing, jadi perubahan dari satu orang tidak tersinkron ke pengguna lain.

## Alur utama

1. Admin menerima perangkat, mencatat keluhan, kondisi, dan membuat tiket.
2. Teknisi memeriksa perangkat, mengisi diagnosis, dan menyusun kebutuhan perbaikan.
3. Admin menerbitkan estimasi; pelanggan menyetujui atau menolak.
4. Teknisi hanya dapat memulai perbaikan normal setelah estimasi disetujui.
5. QC menguji hasil. Jika gagal, tiket kembali ke teknisi; jika lolos, perangkat siap ditagihkan.
6. Admin mencatat pembayaran dan melakukan serah terima setelah QC lolos serta tagihan lunas.
7. Serah terima menghasilkan bukti dan garansi. Klaim garansi ditinjau staf dan dapat membuat tiket terkait.

## Menjalankan secara lokal

Buka `site/index.html` di browser. Tidak membutuhkan backend atau proses build.

## Isi repository

- `site/` — berkas statis yang dipublikasikan lewat GitHub Pages.
- `outputs/` — rancangan ERD dan skema MySQL untuk tahap pengembangan berikutnya.
- `.github/workflows/deploy-pages.yml` — workflow untuk menerbitkan situs saat ada perubahan di branch `main`.

Prototipe ini memakai data lokal untuk keperluan akademik dan belum terhubung ke basis data atau payment gateway.
