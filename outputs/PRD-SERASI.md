# PRD SERASI

**Nama:** SERASI — Sistem Informasi Servis dan Garansi Elektronik
**Jenis:** Prototipe frontend interaktif untuk proyek akademik
**Metode pengembangan:** Prototype (iteratif)
**Target pengguna:** usaha servis elektronik skala kecil hingga menengah

## 1. Ringkasan produk

SERASI membantu pusat servis mencatat dan memantau proses servis elektronik dari perangkat diterima sampai diserahkan kembali beserta garansinya. Admin, Teknisi, QC, Pemilik, dan Pelanggan memakai alur dan data tiket yang saling terhubung.

Prototipe web yang tersedia memakai data simulasi di `localStorage`. Figma menjadi artefak prototype interaktif untuk validasi dan presentasi; rancangan basis data MySQL merupakan rancangan implementasi lanjutan dan belum tersambung ke aplikasi.

## 2. Masalah dan tujuan

Pencatatan servis yang tersebar menyulitkan staf mengetahui status perangkat, keputusan biaya, pekerjaan yang telah dilakukan, hasil QC, pembayaran, dan garansi.

SERASI bertujuan untuk:

- Menyatukan informasi pelanggan, perangkat, dan tiket servis.
- Menjaga urutan kerja: diagnosis, persetujuan estimasi, perbaikan, QC, pembayaran, serah terima, dan garansi.
- Mencatat setiap percobaan pekerjaan perbaikan, termasuk pekerjaan yang dikembalikan QC.
- Membatasi informasi dan tindakan sesuai peran.
- Menyajikan ringkasan operasional yang bersumber dari tiket dan pembayaran yang sama.

## 3. Ruang lingkup

### Termasuk

- Login simulasi secara manual untuk Admin, Teknisi, QC, Pemilik, dan Pelanggan. Pengguna keluar lalu masuk dengan akun peran lain untuk berganti perspektif.
- Pelanggan mendaftarkan perangkat miliknya melalui menu Perangkat Saya; pendaftaran perangkat tidak otomatis membuat tiket servis.
- Penerimaan pelanggan/perangkat dan pembuatan tiket oleh Admin.
- Diagnosis, estimasi, persetujuan/penolakan pelanggan.
- Pencatatan satu atau lebih percobaan perbaikan per tiket.
- QC lolos/gagal; kegagalan membuat pekerjaan perbaikan berikutnya tanpa menghapus riwayat sebelumnya.
- Pencatatan pembayaran penuh/sebagian, serah terima, garansi, dan klaim.
- Pelacakan status pelanggan dan dashboard/laporan Pemilik.
- Prototype layar serta alur klik di Figma.

### Tidak termasuk

- Autentikasi sungguhan, server, dan sinkronisasi data antar pengguna.
- Pembayaran nyata, email/WhatsApp, inventaris gudang, pembelian suku cadang, serta integrasi pihak ketiga.
- Penyimpanan foto di cloud. Lampiran foto pada prototype dapat berupa placeholder.

## 4. Peran dan kewenangan

| Peran | Tanggung jawab utama |
|---|---|
| Admin | Menerima perangkat, membuat tiket, menerbitkan estimasi, mencatat pembayaran dan serah terima, meninjau klaim. |
| Teknisi | Mendiagnosis, mengerjakan tiket yang disetujui, mencatat setiap percobaan, dan menindaklanjuti QC gagal. |
| QC | Mengisi checklist dan meloloskan atau mengembalikan pekerjaan dengan alasan. |
| Pemilik | Melihat performa, antrean, pendapatan, produktivitas, dan laporan. |
| Pelanggan | Mendaftarkan dan melihat perangkat miliknya, melacak servis, menyetujui/menolak estimasi, melihat invoice/garansi, dan mengajukan klaim. |

## 5. Alur utama

1. Admin memilih pelanggan atau mencatat pelanggan baru, memasukkan detail dan kondisi perangkat, keluhan, aksesori, prioritas, lalu membuat tiket.
2. Teknisi yang ditugaskan menyimpan diagnosis, temuan, tindakan yang disarankan, kebutuhan suku cadang, biaya, dan perkiraan durasi.
3. Admin menerbitkan estimasi berdasarkan diagnosis. Pelanggan menyetujui atau menolak estimasi tersebut.
4. Setelah disetujui, Teknisi memulai pekerjaan. Sistem membuat catatan `pekerjaan_perbaikan` baru dengan nomor percobaan, teknisi, waktu mulai, status, catatan, dan suku cadang.
5. Teknisi menyelesaikan percobaan dan mengirimkannya ke QC. QC mencatat checklist dan hasil.
6. Jika QC gagal, percobaan tersebut disimpan sebagai dikembalikan QC. Teknisi memulai baris `pekerjaan_perbaikan` baru untuk percobaan selanjutnya.
7. Jika QC lolos, Admin mencatat pembayaran. Pembayaran sebagian diperbolehkan, tetapi serah terima menunggu pelunasan.
8. Admin mencatat serah terima. Sistem menyelesaikan tiket dan membuat garansi.
9. Pelanggan mengajukan klaim yang terkait dengan garansi. Admin memeriksa kelayakan awal dan mencatat keputusan. Klaim yang disetujui dapat memiliki tiket servis lanjutan.

## 6. Kebutuhan fungsional

- **FR-01 Tiket:** sistem membuat nomor tiket unik dan menyimpan pelanggan, perangkat, keluhan, kondisi awal, prioritas, teknisi, serta target selesai.
- **FR-02 Diagnosis:** Teknisi dapat menyimpan temuan dan saran sebelum estimasi diterbitkan.
- **FR-03 Estimasi:** estimasi memiliki nomor versi, rincian biaya utama, total, syarat, tanggal terbit, status persetujuan, waktu keputusan, dan alasan penolakan.
- **FR-04 Persetujuan:** Teknisi tidak dapat memulai pekerjaan normal tanpa estimasi yang disetujui.
- **FR-05 Riwayat perbaikan:** setiap mulai kerja membuat percobaan baru. Penyelesaian mencatat catatan dan suku cadang; QC gagal mempertahankan catatan lama dan mengizinkan percobaan baru.
- **FR-06 QC:** QC mencatat pemeriksaan daya, penyelesaian keluhan, fungsi perangkat keras, kondisi fisik, aksesori, catatan, dan hasil.
- **FR-07 Pembayaran:** Admin mencatat pembayaran satu atau beberapa kali. Status lunas/sebagian/belum dibayar diturunkan dari jumlah pembayaran dibanding total estimasi disetujui.
- **FR-08 Serah terima dan garansi:** hanya tersedia setelah QC lolos dan pembayaran lunas. Garansi dibuat setelah serah terima.
- **FR-09 Klaim:** setiap klaim terhubung ke garansi, memiliki isu, status, peninjau, keputusan dan alasan; klaim disetujui dapat ditautkan ke tiket lanjutan.
- **FR-10 Riwayat:** perubahan penting dicatat pada aktivitas tiket dengan pelaku, waktu, perubahan status, dan visibilitas internal/pelanggan.
- **FR-11 Privasi:** pelanggan hanya dapat melihat tiket, perangkat, pembayaran, dan garansinya sendiri. Catatan internal teknisi tidak ditampilkan.
- **FR-12 Laporan:** dasbor Pemilik menampilkan jumlah tiket, status, keterlambatan, pendapatan, durasi servis, produktivitas teknisi, serta klaim.
- **FR-13 Perangkat pelanggan:** pelanggan dapat mendaftarkan kategori, merek, model, nomor seri, tanggal pembelian, dan catatan opsional. Perangkat terhubung ke pelanggan pemilik dan pendaftaran tidak membuat tiket servis otomatis.

## 7. Aturan bisnis

1. Setiap pekerjaan servis berasal dari tiket dengan nomor unik.
2. Diagnosis dibuat sebelum estimasi diterbitkan.
3. Persetujuan pelanggan diperlukan sebelum pekerjaan perbaikan normal dimulai.
4. Estimasi ditolak tidak boleh masuk ke pekerjaan normal.
5. Satu tiket dapat memiliki beberapa pekerjaan perbaikan dengan nomor percobaan berurutan.
6. QC selalu menaut ke percobaan yang diperiksa. QC gagal mengembalikan tiket ke teknisi tanpa menghapus pekerjaan/QC terdahulu.
7. Hanya QC lolos yang mengizinkan proses menuju pembayaran dan penyerahan.
8. Serah terima memerlukan QC lolos dan pembayaran lunas.
9. Garansi hanya dibuat setelah serah terima.
10. Klaim harus merujuk ke garansi yang tercatat; pengecekan masa/cakupan bukan keputusan persetujuan akhir.
11. Status servis, pembayaran, pekerjaan perbaikan, QC, dan klaim disimpan/dihitung secara terpisah.
12. Perubahan status penting masuk kronologi tiket.
13. Perangkat yang didaftarkan pelanggan harus dimiliki oleh akun tersebut; nomor seri yang sama tidak boleh didaftarkan dua kali oleh pelanggan yang sama.

## 8. Kebutuhan nonfungsional prototype

- Teks utama berbahasa Indonesia, mata uang Rupiah, tanggal DD/MM/YYYY.
- Navigasi sesuai peran, responsif untuk desktop/tablet/ponsel, dan konsisten di seluruh layar.
- Validasi formulir dan umpan balik terlihat untuk tindakan utama.
- Tampilan data pelanggan menyembunyikan catatan internal.
- Data contoh fiktif; browser lokal setiap orang menyimpan perubahan sendiri.

## 9. Kriteria penerimaan

Prototype diterima untuk demonstrasi apabila presenter dapat:

- Masuk dan menampilkan kelima peran serta navigasi berbeda.
- Pelanggan mendaftarkan perangkat, melihatnya di Perangkat Saya, dan mendapat validasi saat nomor seri yang sama didaftarkan kembali.
- Membuat tiket, menyimpan diagnosis, menerbitkan estimasi, dan merekam keputusan pelanggan.
- Membuktikan perbaikan terblokir sebelum estimasi disetujui.
- Menyelesaikan satu percobaan perbaikan, menggagalkan QC, lalu membuat percobaan kedua sambil tetap melihat riwayat pertama.
- Meloloskan QC, mencatat pembayaran bertahap sampai lunas, lalu menyelesaikan serah terima dan membuat garansi.
- Mengajukan dan meninjau klaim garansi.
- Melihat perubahan yang sama pada detail tiket, antrean peran, pelacakan pelanggan, dan laporan Pemilik.

## 10. Metode Prototype dan evaluasi

Pengembangan mengikuti siklus komunikasi kebutuhan → rencana cepat → desain cepat → pembuatan prototype → evaluasi pengguna → perbaikan. Layar Figma dan prototype web dievaluasi menggunakan skenario intake sampai garansi, estimasi ditolak, QC gagal dan perbaikan ulang, pembayaran sebagian, serta klaim garansi. Catat tugas yang berhasil, hambatan, masukan pengguna, perubahan yang dibuat, dan hasil evaluasi ulang.

## 11. Rancangan data

ERD ringkas terdiri dari **12 tabel inti**: `pelanggan`, `pengguna`, `perangkat`, `tiket_servis`, `diagnosis`, `estimasi`, `aktivitas_tiket`, `pekerjaan_perbaikan`, `pemeriksaan_qc`, `pembayaran`, `garansi`, dan `klaim_garansi`. Detail field dan relasi tersedia pada [Rancangan Basis Data SERASI](Rancangan-Basis-Data-SERASI.md), sementara DDL tersedia pada [Skema MySQL](Skema-MySQL-SERASI.sql).

Tabel master kategori/status, rincian estimasi per item, katalog stok suku cadang, definisi item QC, tagihan, serah terima terpisah, dan lampiran dikeluarkan dari model inti. Nilai sederhana disimpan di tabel induk/proses; rincian bisa dinormalisasi kembali bila kebutuhan implementasi bertambah.
