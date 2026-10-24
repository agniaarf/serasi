# LRS SERASI (Logical Record Structure)

LRS menerjemahkan ERD SERASI menjadi struktur relasi/tabel. Rancangan ini menggunakan 12 tabel inti dan mengikuti DDL pada [Skema MySQL SERASI](Skema-MySQL-SERASI.sql). `PK` = primary key, `FK` = foreign key, `UK` = unique key. Atribut uang memakai bilangan Rupiah bulat (`BIGINT UNSIGNED`).

## 1. Notasi relasi

Format: `NAMA_RELASI(PK, atribut, FK → tabel.referensi)`. Atribut dengan `?` boleh bernilai NULL. Atribut bertanda `UK` memiliki nilai unik. `total` pada estimasi adalah kolom generated dari biaya jasa + biaya suku cadang + biaya lain.

## 2. Skema relasi

### 2.1 Pelanggan dan perangkat

```text
PELANGGAN(
  PK id BIGINT UNSIGNED,
  nama VARCHAR(120),
  telepon VARCHAR(30),
  email VARCHAR(160)? UK,
  alamat TEXT?,
  dibuat_pada DATETIME
)

PENGGUNA(
  PK id BIGINT UNSIGNED,
  nama VARCHAR(120),
  email VARCHAR(160) UK,
  hash_kata_sandi VARCHAR(255)?,
  peran ENUM(admin, teknisi, qc, pemilik),
  spesialisasi VARCHAR(120)?,
  aktif BOOLEAN,
  dibuat_pada DATETIME
)

PERANGKAT(
  PK id BIGINT UNSIGNED,
  FK pelanggan_id → PELANGGAN.id,
  kategori VARCHAR(60),
  merek VARCHAR(80),
  model VARCHAR(120),
  nomor_seri VARCHAR(100)? UK per pelanggan,
  tanggal_pembelian DATE?,
  catatan TEXT?,
  dibuat_pada DATETIME
)
```

### 2.2 Tiket dan proses diagnosis/estimasi

```text
TIKET_SERVIS(
  PK id BIGINT UNSIGNED,
  nomor_tiket VARCHAR(24) UK,
  FK pelanggan_id → PELANGGAN.id,
  FK perangkat_id → PERANGKAT.id,
  FK teknisi_id → PENGGUNA.id?,
  FK diterima_oleh_id → PENGGUNA.id,
  status ENUM(diterima, dalam_inspeksi, menunggu_estimasi, menunggu_persetujuan,
              estimasi_ditolak, menunggu_suku_cadang, dalam_perbaikan,
              menunggu_qc, qc_gagal, siap_diambil, selesai, dibatalkan),
  prioritas ENUM(rendah, normal, tinggi, mendesak),
  keluhan TEXT,
  kondisi_saat_diterima TEXT?,
  aksesori_diterima TEXT?,
  tanggal_diterima DATETIME,
  target_selesai DATE?,
  FK tiket_servis_asal_id → TIKET_SERVIS.id?,
  nama_penerima VARCHAR(120)?,
  pengakuan_pelanggan TEXT?,
  FK diserahkan_oleh_id → PENGGUNA.id?,
  diserahkan_pada DATETIME?,
  dibuat_pada DATETIME,
  diperbarui_pada DATETIME
)

DIAGNOSIS(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK teknisi_id → PENGGUNA.id,
  versi SMALLINT UNSIGNED,
  dugaan_penyebab TEXT,
  temuan_pemeriksaan TEXT,
  saran_perbaikan TEXT,
  estimasi_durasi_hari SMALLINT UNSIGNED?,
  dibuat_pada DATETIME,
  UK (tiket_servis_id, versi)
)

ESTIMASI(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK diagnosis_id → DIAGNOSIS.id,
  versi SMALLINT UNSIGNED,
  biaya_jasa BIGINT UNSIGNED,
  biaya_suku_cadang BIGINT UNSIGNED,
  biaya_lain BIGINT UNSIGNED,
  total BIGINT UNSIGNED [generated],
  status ENUM(draf, dikirim, disetujui, ditolak, kedaluwarsa),
  perkiraan_selesai DATE?,
  syarat_ketentuan TEXT?,
  FK diterbitkan_oleh_id → PENGGUNA.id?,
  diterbitkan_pada DATETIME?,
  diputuskan_pada DATETIME?,
  alasan_keputusan TEXT?,
  dibuat_pada DATETIME,
  UK (tiket_servis_id, versi)
)
```

### 2.3 Aktivitas, perbaikan, QC, dan pembayaran

```text
AKTIVITAS_TIKET(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK pelaku_id → PENGGUNA.id?,
  nama_pelaku_saat_itu VARCHAR(120),
  status_sebelum VARCHAR(32)?,
  status_sesudah VARCHAR(32)?,
  deskripsi VARCHAR(500),
  visibilitas ENUM(internal, pelanggan),
  terjadi_pada DATETIME
)

PEKERJAAN_PERBAIKAN(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK diagnosis_id → DIAGNOSIS.id,
  FK teknisi_id → PENGGUNA.id,
  percobaan_ke SMALLINT UNSIGNED,
  status ENUM(berjalan, menunggu_qc, dikembalikan_qc, lolos_qc),
  catatan_internal TEXT?,
  ringkasan_suku_cadang TEXT?,
  dimulai_pada DATETIME?,
  selesai_pada DATETIME?,
  UK (tiket_servis_id, percobaan_ke)
)

PEMERIKSAAN_QC(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK pekerjaan_perbaikan_id → PEKERJAAN_PERBAIKAN.id,
  FK pemeriksa_id → PENGGUNA.id,
  perangkat_menyala BOOLEAN,
  keluhan_teratasi BOOLEAN,
  fungsi_hardware_baik BOOLEAN,
  kondisi_fisik_baik BOOLEAN,
  aksesori_lengkap BOOLEAN,
  hasil ENUM(lolos, gagal),
  catatan TEXT,
  diperiksa_pada DATETIME
)

PEMBAYARAN(
  PK id BIGINT UNSIGNED,
  FK tiket_servis_id → TIKET_SERVIS.id,
  FK estimasi_id → ESTIMASI.id,
  FK dicatat_oleh_id → PENGGUNA.id,
  metode ENUM(tunai, transfer_bank, qris, kartu_debit, lainnya),
  jumlah BIGINT UNSIGNED,
  nomor_referensi VARCHAR(100)?,
  dibayar_pada DATETIME
)
```

### 2.4 Garansi dan klaim

```text
GARANSI(
  PK id BIGINT UNSIGNED,
  nomor_garansi VARCHAR(32) UK,
  FK tiket_servis_id → TIKET_SERVIS.id UK,
  tanggal_mulai DATE,
  tanggal_berakhir DATE,
  cakupan TEXT,
  status ENUM(aktif, kedaluwarsa, dicabut),
  dibuat_pada DATETIME
)

KLAIM_GARANSI(
  PK id BIGINT UNSIGNED,
  nomor_klaim VARCHAR(32) UK,
  FK garansi_id → GARANSI.id,
  FK pelanggan_id → PELANGGAN.id,
  isu_yang_dilaporkan TEXT,
  hasil_pemeriksaan_kelayakan VARCHAR(300)?,
  status ENUM(diajukan, ditinjau, disetujui, ditolak, dalam_perbaikan, selesai),
  diajukan_pada DATETIME,
  FK peninjau_id → PENGGUNA.id?,
  keputusan_pada DATETIME?,
  alasan_keputusan TEXT?,
  FK/UK tiket_servis_lanjutan_id → TIKET_SERVIS.id?
)
```

## 3. Relasi dan kardinalitas

| Relasi | Kardinalitas maksimum | Keterangan |
|---|---:|---|
| Pelanggan — Perangkat | 1 : N | Satu pelanggan dapat mendaftarkan banyak perangkat melalui menu Perangkat Saya; setiap perangkat memiliki satu pemilik. |
| Pelanggan — Tiket Servis | 1 : N | Satu pelanggan dapat mengajukan banyak tiket. |
| Perangkat — Tiket Servis | 1 : N | Satu perangkat dapat memiliki riwayat tiket servis. |
| Pengguna — Tiket Servis (teknisi) | 1:N | Satu tiket ditangani paling banyak satu teknisi; FK nullable menandakan teknisi belum ditugaskan. |
| Tiket Servis — Diagnosis | 1 : N | Diagnosis disimpan per versi. |
| Tiket Servis — Estimasi | 1 : N | Estimasi dapat memiliki versi; setiap versi mengacu diagnosis. |
| Tiket Servis — Aktivitas Tiket | 1 : N | Kronologi menyimpan banyak aktivitas. |
| Tiket Servis — Pekerjaan Perbaikan | 1 : N | Setiap percobaan kerja memiliki baris tersendiri. |
| Pekerjaan Perbaikan — Pemeriksaan QC | 1 : N | Pemeriksaan mengacu ke percobaan yang diuji. |
| Tiket Servis — Pembayaran | 1 : N | Pembayaran cicilan disimpan sebagai baris terpisah. |
| Tiket Servis — Garansi | 1 : 1 | Maksimal satu garansi dicatat untuk satu tiket asal. |
| Garansi — Klaim Garansi | 1 : N | Satu garansi dapat memiliki beberapa klaim. |
| Klaim Garansi — Tiket Servis lanjutan | 1:1 | FK opsional dan unik menjamin satu tiket lanjutan hanya terkait ke satu klaim. |

Notasi `1:N` berarti satu entitas induk dapat berelasi dengan banyak entitas anak; `1:1` berarti satu entitas berpasangan dengan paling banyak satu entitas lain. Field FK yang nullable menunjukkan hubungan bisa belum diisi. Model ini tidak memiliki hubungan many-to-many langsung.

## 4. Aturan kunci dan integritas

- `nomor_tiket`, `nomor_garansi`, dan `nomor_klaim` harus unik.
- Versi diagnosis dan estimasi unik per tiket; nomor percobaan pekerjaan unik per tiket.
- `garansi.tiket_servis_id` unik agar satu tiket tidak membuat lebih dari satu garansi; `klaim_garansi.tiket_servis_lanjutan_id` unik agar satu tiket lanjutan tidak terkait ke beberapa klaim.
- Total pembayaran dijumlahkan dan dibandingkan dengan total estimasi yang disetujui; status pembayaran tidak disimpan sebagai status tiket.
- QC lolos mensyaratkan semua checklist lulus (`chk_qc_lolos` pada SQL).
- Pembayaran harus lebih besar dari nol dan periode garansi tidak boleh berakhir sebelum tanggal mulai.
- Aturan lintas tabel, termasuk approval, QC, pelunasan, serah terima, dan garansi, harus divalidasi aplikasi dalam transaksi.

## 5. Batas model

LRS ini mengikuti model ringkas untuk kebutuhan akademik. Ringkasan suku cadang disimpan sebagai teks pada `pekerjaan_perbaikan`; inventaris dan jumlah per item belum dinormalisasi. Invoice dirakit dari estimasi yang disetujui dan pembayaran. Data serah terima berada di `tiket_servis`. Lihat DDL untuk definisi ENUM, nullability, constraint, dan indeks secara lengkap.