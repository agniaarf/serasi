# SERASI — Sistem Informasi Servis dan Garansi Elektronik

Prototipe interaktif sistem manajemen servis elektronik untuk alur kerja dari penerimaan perangkat hingga garansi. Antarmuka dan data contoh menggunakan Bahasa Indonesia, nama fiktif, Rupiah, dan format tanggal DD/MM/YYYY.

## Coba prototipe

Buka prototipe: **https://agniaarf.github.io/serasi/**

Pilih akun sesuai peran di halaman masuk, lalu tekan **Masuk**. Kata sandi semua akun adalah `serasi2026`. Untuk berganti peran, tekan **Keluar** lalu masuk dengan akun lain. Perubahan disimpan di local storage browser masing-masing, jadi perubahan dari satu orang tidak tersinkron ke pengguna lain.

## Alur utama

1. Pelanggan dapat mendaftarkan perangkat miliknya dari menu **Perangkat Saya** tanpa membuat tiket servis.
2. Admin menerima perangkat, mencatat keluhan, kondisi, dan membuat tiket.
3. Teknisi memeriksa perangkat, mengisi diagnosis, dan menyusun kebutuhan perbaikan.
3. Admin menerbitkan estimasi; pelanggan menyetujui atau menolak.
4. Teknisi hanya dapat memulai perbaikan normal setelah estimasi disetujui.
5. QC menguji hasil. Jika gagal, tiket kembali ke teknisi; jika lolos, perangkat siap ditagihkan.
6. Admin mencatat pembayaran dan melakukan serah terima setelah QC lolos serta tagihan lunas.
7. Serah terima menghasilkan bukti dan garansi. Klaim garansi ditinjau staf dan dapat membuat tiket terkait.

## Dokumen proyek

- [Dokumentasi Proyek Lengkap](outputs/Dokumentasi-Lengkap-Proyek-SERASI.md)
- [PRD](outputs/PRD-SERASI.md)
- [ERD Chen dengan atribut oval](outputs/ERD-Chen-SERASI.md)
- [LRS (Logical Record Structure)](outputs/LRS-SERASI.md)
- [Rancangan ERD 12 tabel](outputs/Rancangan-Basis-Data-SERASI.md)
- [Skema MySQL](outputs/Skema-MySQL-SERASI.sql)

## Menjalankan secara lokal

Buka `site/index.html` di browser. Tidak membutuhkan backend atau proses build.

## Isi repository

- `site/` — berkas statis yang dipublikasikan lewat GitHub Pages.
- `outputs/` — rancangan ERD dan skema MySQL untuk tahap pengembangan berikutnya.
- `.github/workflows/deploy-pages.yml` — workflow untuk menerbitkan situs saat ada perubahan di branch `main`.

Pekerjaan ulang setelah QC gagal tercatat sebagai percobaan baru. Rancangan database memiliki 12 tabel inti, termasuk `pekerjaan_perbaikan`. Prototipe ini memakai data lokal untuk keperluan akademik dan belum terhubung ke basis data atau payment gateway.
