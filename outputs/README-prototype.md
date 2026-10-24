# SERASI — Sistem Informasi Servis dan Garansi Elektronik

SERASI adalah aplikasi antarmuka layanan servis elektronik dengan lima peran: Admin, Teknisi, QC, Pemilik, dan Pelanggan. Data contoh menggunakan nama fiktif Indonesia, Rupiah, dan format tanggal DD/MM/YYYY.

## Menjalankan aplikasi

Buka `dist/index.html` dengan peramban modern. Tidak perlu memasang server atau backend. Pilih akun peran di halaman masuk, lalu tekan **Masuk**. Kata sandi semua akun adalah `serasi2026`. Untuk berganti peran, tekan **Keluar** lalu masuk dengan akun peran lain. Data perubahan disimpan di local storage peramban tersebut.

| Peran | Email akun |
|---|---|
| Admin | `maya@serasi.id` |
| Teknisi | `rizky@serasi.id` |
| QC | `nadia@serasi.id` |
| Pemilik | `bima@serasi.id` |
| Pelanggan | `andi@serasi.id` |

## Alur penggunaan

1. Pelanggan (opsional) mendaftarkan perangkat miliknya dari menu **Perangkat Saya**; tindakan ini belum membuat tiket servis.
2. Admin menerima perangkat dan membuat tiket servis.
3. Teknisi menyimpan diagnosis.
4. Admin menerbitkan estimasi.
5. Pelanggan menyetujui atau menolak estimasi.
6. Teknisi mengerjakan servis yang telah disetujui dan mencatat suku cadang.
7. QC meloloskan atau menggagalkan pemeriksaan. QC gagal mengembalikan tiket ke teknisi.
8. Setelah QC lolos, Admin mencatat pembayaran. Serah terima mensyaratkan QC lolos dan pembayaran lunas.
9. Serah terima membuat bukti penerimaan dan catatan garansi 90 hari. Klaim garansi harus ditinjau staf dan dapat membuat tiket servis garansi terkait.

Data contoh mencakup beberapa tahapan servis, estimasi ditolak, QC gagal, garansi aktif dan kedaluwarsa, serta klaim garansi. Pilih **Pengaturan → Pulihkan Data Awal** untuk memulihkan data awal.

## Dokumen rancangan

Lihat [PRD SERASI](../PRD-SERASI.md) untuk tujuan, ruang lingkup, alur, dan kebutuhan prototype.

## Rancangan basis data

Lihat [rancangan dan ERD 12 tabel](../Rancangan-Basis-Data-SERASI.md) dan [DDL MySQL 12 tabel](../Skema-MySQL-SERASI.sql). Riwayat percobaan perbaikan tersimpan pada `pekerjaan_perbaikan`. Skema ini adalah rancangan tahap implementasi, bukan backend yang sudah tersambung ke prototype.

## Berbagi preview

Membuka berkas HTML di komputer hanya memberi akses kepada orang yang menerima berkas tersebut. Untuk berbagi tautan preview, SERASI perlu dipublikasikan sebagai situs dan aksesnya diatur untuk audiens yang Anda pilih. Versi yang diterbitkan memakai local storage masing-masing peramban; perubahan lokal tidak dibagikan antarorang.
