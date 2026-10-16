-- Skema awal SERASI — MySQL 8 / MariaDB
-- Seluruh nilai uang adalah Rupiah (bilangan bulat).
CREATE DATABASE IF NOT EXISTS serasi_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE serasi_db;

CREATE TABLE pelanggan (
  pelanggan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(120) NOT NULL,
  telepon VARCHAR(30) NOT NULL,
  email VARCHAR(160) NULL,
  alamat TEXT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pelanggan_email (email),
  KEY idx_pelanggan_nama (nama)
) ENGINE=InnoDB;

CREATE TABLE pengguna (
  pengguna_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  hash_kata_sandi VARCHAR(255) NULL,
  peran ENUM('admin','teknisi','qc','pemilik') NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT TRUE,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pengguna_email (email),
  KEY idx_pengguna_peran_aktif (peran, aktif)
) ENGINE=InnoDB;

CREATE TABLE teknisi (
  teknisi_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pengguna_id BIGINT UNSIGNED NOT NULL,
  spesialisasi VARCHAR(120) NULL,
  tanggal_bergabung DATE NULL,
  UNIQUE KEY uq_teknisi_pengguna (pengguna_id),
  CONSTRAINT fk_teknisi_pengguna FOREIGN KEY (pengguna_id)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE kategori_perangkat (
  kategori_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(60) NOT NULL,
  aktif BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_kategori_nama (nama)
) ENGINE=InnoDB;

CREATE TABLE perangkat (
  perangkat_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pelanggan_id BIGINT UNSIGNED NOT NULL,
  kategori_id SMALLINT UNSIGNED NOT NULL,
  merek VARCHAR(80) NOT NULL,
  model VARCHAR(120) NOT NULL,
  nomor_seri VARCHAR(100) NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_perangkat_pelanggan (pelanggan_id),
  KEY idx_perangkat_model (merek, model),
  UNIQUE KEY uq_perangkat_seri_merek (merek, nomor_seri),
  CONSTRAINT fk_perangkat_pelanggan FOREIGN KEY (pelanggan_id)
    REFERENCES pelanggan(pelanggan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_perangkat_kategori FOREIGN KEY (kategori_id)
    REFERENCES kategori_perangkat(kategori_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE status_tiket (
  kode_status VARCHAR(32) PRIMARY KEY,
  nama_status VARCHAR(60) NOT NULL,
  urutan SMALLINT UNSIGNED NOT NULL,
  status_akhir BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE KEY uq_status_tiket_nama (nama_status)
) ENGINE=InnoDB;

INSERT INTO status_tiket (kode_status,nama_status,urutan,status_akhir) VALUES
('diterima','Diterima',1,FALSE),
('dalam_inspeksi','Sedang diperiksa',2,FALSE),
('menunggu_estimasi','Menunggu estimasi',3,FALSE),
('menunggu_persetujuan','Menunggu persetujuan pelanggan',4,FALSE),
('estimasi_ditolak','Estimasi ditolak',5,FALSE),
('menunggu_suku_cadang','Menunggu suku cadang',6,FALSE),
('dalam_perbaikan','Sedang diservis',7,FALSE),
('menunggu_qc','Menunggu QC',8,FALSE),
('qc_gagal','QC gagal',9,FALSE),
('siap_diambil','Siap diambil',10,FALSE),
('selesai','Selesai',11,TRUE),
('dibatalkan','Dibatalkan',12,TRUE);

CREATE TABLE tiket_servis (
  tiket_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_tiket VARCHAR(24) NOT NULL,
  pelanggan_id BIGINT UNSIGNED NOT NULL,
  perangkat_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NULL,
  diterima_oleh BIGINT UNSIGNED NOT NULL,
  kode_status VARCHAR(32) NOT NULL DEFAULT 'diterima',
  prioritas ENUM('rendah','normal','tinggi','mendesak') NOT NULL DEFAULT 'normal',
  keluhan TEXT NOT NULL,
  kondisi_saat_diterima TEXT NULL,
  aksesori_diterima TEXT NULL,
  tanggal_diterima DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  target_selesai DATE NULL,
  tiket_garansi_asal_id BIGINT UNSIGNED NULL,
  versi_baris INT UNSIGNED NOT NULL DEFAULT 1,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  diperbarui_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tiket_nomor (nomor_tiket),
  KEY idx_tiket_status_target (kode_status, target_selesai),
  KEY idx_tiket_teknisi_status (teknisi_id, kode_status),
  KEY idx_tiket_pelanggan_tanggal (pelanggan_id, tanggal_diterima),
  CONSTRAINT fk_tiket_pelanggan FOREIGN KEY (pelanggan_id)
    REFERENCES pelanggan(pelanggan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_perangkat FOREIGN KEY (perangkat_id)
    REFERENCES perangkat(perangkat_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_teknisi FOREIGN KEY (teknisi_id)
    REFERENCES teknisi(teknisi_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_penerima FOREIGN KEY (diterima_oleh)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_status FOREIGN KEY (kode_status)
    REFERENCES status_tiket(kode_status) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_garansi_asal FOREIGN KEY (tiket_garansi_asal_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE diagnosis (
  diagnosis_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NOT NULL,
  versi SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  dugaan_penyebab TEXT NOT NULL,
  temuan_pemeriksaan TEXT NOT NULL,
  saran_perbaikan TEXT NOT NULL,
  estimasi_durasi_hari SMALLINT UNSIGNED NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_diagnosis_versi (tiket_id, versi),
  CONSTRAINT fk_diagnosis_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_diagnosis_teknisi FOREIGN KEY (teknisi_id)
    REFERENCES teknisi(teknisi_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE estimasi (
  estimasi_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  diagnosis_id BIGINT UNSIGNED NOT NULL,
  versi SMALLINT UNSIGNED NOT NULL,
  status ENUM('draf','dikirim','disetujui','ditolak','kedaluwarsa') NOT NULL DEFAULT 'draf',
  perkiraan_selesai DATE NULL,
  syarat_ketentuan TEXT NULL,
  diterbitkan_oleh BIGINT UNSIGNED NULL,
  diterbitkan_pada DATETIME NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_estimasi_versi (tiket_id, versi),
  KEY idx_estimasi_status (status, diterbitkan_pada),
  CONSTRAINT fk_estimasi_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_estimasi_diagnosis FOREIGN KEY (diagnosis_id)
    REFERENCES diagnosis(diagnosis_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_estimasi_penerbit FOREIGN KEY (diterbitkan_oleh)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detail_estimasi (
  detail_estimasi_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  estimasi_id BIGINT UNSIGNED NOT NULL,
  jenis ENUM('jasa','suku_cadang','biaya_lain') NOT NULL,
  deskripsi VARCHAR(200) NOT NULL,
  jumlah DECIMAL(10,2) NOT NULL DEFAULT 1,
  harga_satuan BIGINT UNSIGNED NOT NULL,
  subtotal BIGINT UNSIGNED GENERATED ALWAYS AS (ROUND(jumlah * harga_satuan)) STORED,
  KEY idx_detail_estimasi (estimasi_id),
  CONSTRAINT fk_detail_estimasi_estimasi FOREIGN KEY (estimasi_id)
    REFERENCES estimasi(estimasi_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_detail_estimasi_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

CREATE TABLE keputusan_estimasi (
  keputusan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  estimasi_id BIGINT UNSIGNED NOT NULL,
  keputusan ENUM('disetujui','ditolak') NOT NULL,
  diputuskan_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  alasan TEXT NULL,
  kanal ENUM('portal_pelanggan','dicatat_admin') NOT NULL DEFAULT 'portal_pelanggan',
  UNIQUE KEY uq_keputusan_estimasi (estimasi_id),
  CONSTRAINT fk_keputusan_estimasi FOREIGN KEY (estimasi_id)
    REFERENCES estimasi(estimasi_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE aktivitas_tiket (
  aktivitas_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  pelaku_id BIGINT UNSIGNED NULL,
  nama_pelaku_saat_itu VARCHAR(120) NOT NULL,
  kode_status_sebelum VARCHAR(32) NULL,
  kode_status_sesudah VARCHAR(32) NULL,
  deskripsi VARCHAR(500) NOT NULL,
  visibilitas ENUM('internal','pelanggan') NOT NULL DEFAULT 'internal',
  terjadi_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_aktivitas_tiket_waktu (tiket_id, terjadi_pada),
  CONSTRAINT fk_aktivitas_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_pelaku FOREIGN KEY (pelaku_id)
    REFERENCES pengguna(pengguna_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_status_sebelum FOREIGN KEY (kode_status_sebelum)
    REFERENCES status_tiket(kode_status) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_status_sesudah FOREIGN KEY (kode_status_sesudah)
    REFERENCES status_tiket(kode_status) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pekerjaan_perbaikan (
  pekerjaan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  diagnosis_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NOT NULL,
  percobaan_ke SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('berjalan','selesai','dikembalikan_qc') NOT NULL DEFAULT 'berjalan',
  catatan_internal TEXT NULL,
  dimulai_pada DATETIME NULL,
  selesai_pada DATETIME NULL,
  UNIQUE KEY uq_pekerjaan_percobaan (tiket_id, percobaan_ke),
  CONSTRAINT fk_pekerjaan_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pekerjaan_diagnosis FOREIGN KEY (diagnosis_id)
    REFERENCES diagnosis(diagnosis_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pekerjaan_teknisi FOREIGN KEY (teknisi_id)
    REFERENCES teknisi(teknisi_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE suku_cadang (
  suku_cadang_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  kode_suku_cadang VARCHAR(40) NULL,
  nama VARCHAR(160) NOT NULL,
  merek_kompatibel VARCHAR(100) NULL,
  stok INT UNSIGNED NOT NULL DEFAULT 0,
  harga_beli BIGINT UNSIGNED NULL,
  harga_jual BIGINT UNSIGNED NOT NULL DEFAULT 0,
  aktif BOOLEAN NOT NULL DEFAULT TRUE,
  UNIQUE KEY uq_suku_cadang_kode (kode_suku_cadang),
  KEY idx_suku_cadang_nama (nama)
) ENGINE=InnoDB;

CREATE TABLE pemakaian_suku_cadang (
  pemakaian_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pekerjaan_id BIGINT UNSIGNED NOT NULL,
  suku_cadang_id BIGINT UNSIGNED NOT NULL,
  detail_estimasi_id BIGINT UNSIGNED NULL,
  jumlah INT UNSIGNED NOT NULL,
  harga_satuan_saat_pakai BIGINT UNSIGNED NOT NULL,
  dicatat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_pemakaian_pekerjaan (pekerjaan_id),
  CONSTRAINT fk_pemakaian_pekerjaan FOREIGN KEY (pekerjaan_id)
    REFERENCES pekerjaan_perbaikan(pekerjaan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pemakaian_suku_cadang FOREIGN KEY (suku_cadang_id)
    REFERENCES suku_cadang(suku_cadang_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pemakaian_detail_estimasi FOREIGN KEY (detail_estimasi_id)
    REFERENCES detail_estimasi(detail_estimasi_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_pemakaian_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

CREATE TABLE item_qc (
  item_qc_id SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(160) NOT NULL,
  wajib BOOLEAN NOT NULL DEFAULT TRUE,
  aktif BOOLEAN NOT NULL DEFAULT TRUE,
  urutan SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  UNIQUE KEY uq_item_qc_nama (nama)
) ENGINE=InnoDB;

INSERT INTO item_qc (nama,wajib,urutan) VALUES
('Perangkat dapat menyala',TRUE,1),
('Keluhan utama telah teratasi',TRUE,2),
('Fungsi perangkat keras berjalan baik',TRUE,3),
('Kondisi fisik telah diperiksa',TRUE,4),
('Aksesori telah diperiksa',TRUE,5);

CREATE TABLE pemeriksaan_qc (
  pemeriksaan_qc_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  pekerjaan_id BIGINT UNSIGNED NOT NULL,
  pemeriksa_id BIGINT UNSIGNED NOT NULL,
  hasil ENUM('lolos','gagal') NOT NULL,
  catatan TEXT NOT NULL,
  diperiksa_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_qc_tiket_waktu (tiket_id, diperiksa_pada),
  CONSTRAINT fk_qc_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_qc_pekerjaan FOREIGN KEY (pekerjaan_id)
    REFERENCES pekerjaan_perbaikan(pekerjaan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_qc_pemeriksa FOREIGN KEY (pemeriksa_id)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE hasil_item_qc (
  pemeriksaan_qc_id BIGINT UNSIGNED NOT NULL,
  item_qc_id SMALLINT UNSIGNED NOT NULL,
  lolos BOOLEAN NOT NULL,
  catatan VARCHAR(300) NULL,
  PRIMARY KEY (pemeriksaan_qc_id, item_qc_id),
  CONSTRAINT fk_hasil_item_pemeriksaan FOREIGN KEY (pemeriksaan_qc_id)
    REFERENCES pemeriksaan_qc(pemeriksaan_qc_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_hasil_item_item FOREIGN KEY (item_qc_id)
    REFERENCES item_qc(item_qc_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tagihan (
  tagihan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_tagihan VARCHAR(32) NOT NULL,
  tiket_id BIGINT UNSIGNED NOT NULL,
  estimasi_id BIGINT UNSIGNED NOT NULL,
  status_pembayaran ENUM('belum_dibayar','dibayar_sebagian','lunas') NOT NULL DEFAULT 'belum_dibayar',
  total_akhir BIGINT UNSIGNED NOT NULL,
  diterbitkan_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tagihan_nomor (nomor_tagihan),
  UNIQUE KEY uq_tagihan_tiket (tiket_id),
  CONSTRAINT fk_tagihan_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tagihan_estimasi FOREIGN KEY (estimasi_id)
    REFERENCES estimasi(estimasi_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detail_tagihan (
  detail_tagihan_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tagihan_id BIGINT UNSIGNED NOT NULL,
  detail_estimasi_id BIGINT UNSIGNED NULL,
  deskripsi_salinan VARCHAR(200) NOT NULL,
  jumlah DECIMAL(10,2) NOT NULL DEFAULT 1,
  harga_satuan BIGINT UNSIGNED NOT NULL,
  subtotal BIGINT UNSIGNED GENERATED ALWAYS AS (ROUND(jumlah * harga_satuan)) STORED,
  CONSTRAINT fk_detail_tagihan_tagihan FOREIGN KEY (tagihan_id)
    REFERENCES tagihan(tagihan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_detail_tagihan_estimasi FOREIGN KEY (detail_estimasi_id)
    REFERENCES detail_estimasi(detail_estimasi_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pembayaran (
  pembayaran_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tagihan_id BIGINT UNSIGNED NOT NULL,
  dicatat_oleh BIGINT UNSIGNED NOT NULL,
  metode ENUM('tunai','transfer_bank','qris','kartu_debit','lainnya') NOT NULL,
  jumlah BIGINT UNSIGNED NOT NULL,
  nomor_referensi VARCHAR(100) NULL,
  dibayar_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_pembayaran_tagihan (tagihan_id, dibayar_pada),
  CONSTRAINT fk_pembayaran_tagihan FOREIGN KEY (tagihan_id)
    REFERENCES tagihan(tagihan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pembayaran_pencatat FOREIGN KEY (dicatat_oleh)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_pembayaran_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

CREATE TABLE serah_terima (
  serah_terima_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_bukti VARCHAR(32) NOT NULL,
  tiket_id BIGINT UNSIGNED NOT NULL,
  pemeriksaan_qc_id BIGINT UNSIGNED NOT NULL,
  dicatat_oleh BIGINT UNSIGNED NOT NULL,
  nama_penerima VARCHAR(120) NOT NULL,
  konfirmasi_pelanggan TEXT NOT NULL,
  diserahkan_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_serah_terima_nomor (nomor_bukti),
  UNIQUE KEY uq_serah_terima_tiket (tiket_id),
  CONSTRAINT fk_serah_terima_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_serah_terima_qc FOREIGN KEY (pemeriksaan_qc_id)
    REFERENCES pemeriksaan_qc(pemeriksaan_qc_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_serah_terima_pencatat FOREIGN KEY (dicatat_oleh)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE garansi (
  garansi_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_garansi VARCHAR(32) NOT NULL,
  tiket_id BIGINT UNSIGNED NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_berakhir DATE NOT NULL,
  cakupan TEXT NOT NULL,
  status ENUM('aktif','kedaluwarsa','dicabut') NOT NULL DEFAULT 'aktif',
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_garansi_nomor (nomor_garansi),
  UNIQUE KEY uq_garansi_tiket (tiket_id),
  KEY idx_garansi_masa (status, tanggal_mulai, tanggal_berakhir),
  CONSTRAINT fk_garansi_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_garansi_tanggal CHECK (tanggal_berakhir >= tanggal_mulai)
) ENGINE=InnoDB;

CREATE TABLE klaim_garansi (
  klaim_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_klaim VARCHAR(32) NOT NULL,
  garansi_id BIGINT UNSIGNED NOT NULL,
  diajukan_pelanggan_id BIGINT UNSIGNED NOT NULL,
  isu_yang_dilaporkan TEXT NOT NULL,
  hasil_pemeriksaan_kelayakan VARCHAR(300) NULL,
  status ENUM('diajukan','ditinjau','disetujui','ditolak','dalam_perbaikan','selesai') NOT NULL DEFAULT 'diajukan',
  diajukan_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  peninjau_id BIGINT UNSIGNED NULL,
  keputusan_pada DATETIME NULL,
  alasan_keputusan TEXT NULL,
  tiket_servis_lanjutan_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_klaim_nomor (nomor_klaim),
  KEY idx_klaim_status_tanggal (status, diajukan_pada),
  CONSTRAINT fk_klaim_garansi FOREIGN KEY (garansi_id)
    REFERENCES garansi(garansi_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_pelanggan FOREIGN KEY (diajukan_pelanggan_id)
    REFERENCES pelanggan(pelanggan_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_peninjau FOREIGN KEY (peninjau_id)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_tiket_lanjutan FOREIGN KEY (tiket_servis_lanjutan_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE lampiran_perangkat (
  lampiran_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_id BIGINT UNSIGNED NOT NULL,
  diunggah_oleh BIGINT UNSIGNED NOT NULL,
  nama_berkas VARCHAR(255) NOT NULL,
  lokasi_berkas VARCHAR(500) NOT NULL,
  tipe_mime VARCHAR(100) NULL,
  ukuran_byte BIGINT UNSIGNED NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_lampiran_tiket (tiket_id),
  CONSTRAINT fk_lampiran_tiket FOREIGN KEY (tiket_id)
    REFERENCES tiket_servis(tiket_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_lampiran_pengunggah FOREIGN KEY (diunggah_oleh)
    REFERENCES pengguna(pengguna_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Catatan: validasi lintas tabel (persetujuan sebelum perbaikan, QC dan pelunasan sebelum
-- serah terima, serta pembuatan garansi sesudah serah terima) harus memakai transaksi
-- layanan aplikasi. Jangan mengandalkan antarmuka atau CHECK tunggal untuk aturan tersebut.
