# Rancangan Basis Data SERASI

Rancangan SERASI terdiri dari 12 tabel inti. Setiap tabel memakai primary key bernama `id`. Foreign key memakai nama entitas yang dirujuk, misalnya `pelanggan_id` mengacu ke `pelanggan.id`, `perangkat_id` ke `perangkat.id`, dan `tiket_servis_id` ke `tiket_servis.id`.

## Berkas rancangan

- [ERD Chen satu diagram lengkap](ERD-Chen-SERASI.md) — seluruh entitas, atribut, relasi, dan kardinalitas dalam satu Mermaid diagram.
- [LRS SERASI](LRS-SERASI.md) — struktur relasi/tabel dengan PK, FK, tipe data, dan kardinalitas.
- [DDL MySQL 8/MariaDB](Skema-MySQL-SERASI.sql) — implementasi struktur tabel dan constraint.

## Entitas

1. `pelanggan`
2. `pengguna`
3. `perangkat`
4. `tiket_servis`
5. `diagnosis`
6. `estimasi`
7. `aktivitas_tiket`
8. `pekerjaan_perbaikan`
9. `pemeriksaan_qc`
10. `pembayaran`
11. `garansi`
12. `klaim_garansi`

## Notasi dan aturan relasi

Diagram memakai notasi Chen: persegi panjang untuk entitas, oval untuk atribut, dan belah ketupat untuk relasi. Kardinalitas dibuat dalam bentuk umum **1:1** atau **1:N**. Model tidak memiliki relasi many-to-many langsung; kebutuhan proses banyak-ke-banyak direpresentasikan melalui entitas proses terkait.

Kunci yang menjadi primary key ditandai `PK`; foreign key ditandai `FK`. Kolom nullable/opsional dan constraint lengkap dijelaskan di LRS serta DDL. Relasi tanpa data belum tentu harus langsung memiliki baris terkait; angka kardinalitas pada diagram menunjukkan pola hubungan maksimum yang digunakan pada rancangan.

## Batas rancangan

Model ini dipadatkan untuk kebutuhan proyek akademik. Rincian inventaris stok, daftar biaya per item, item QC terpisah, lampiran foto, invoice, dan serah terima belum dipisahkan menjadi tabel tersendiri. Ringkasan suku cadang disimpan pada catatan pekerjaan; tagihan dibentuk dari estimasi disetujui dan pembayaran; data serah terima berada di `tiket_servis`.

Pelanggan dapat mendaftarkan perangkat miliknya sebelum memiliki tiket servis. Hal ini tidak menambah entitas atau mengubah kardinalitas: perangkat tetap mengacu ke satu pelanggan melalui `pelanggan_id`, dan satu pelanggan dapat memiliki banyak perangkat. Data tanggal pembelian dan catatan opsional disimpan pada tabel `perangkat`.

Prototipe frontend masih memakai `localStorage`. Rancangan ERD, LRS, dan SQL ini belum tersambung sebagai backend aktif.