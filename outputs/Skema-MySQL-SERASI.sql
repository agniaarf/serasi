-- Skema ringkas SERASI — MySQL 8 / MariaDB
-- 12 tabel inti untuk prototype akademik; nilai uang disimpan dalam Rupiah bulat.
CREATE DATABASE IF NOT EXISTS serasi_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE serasi_db;

CREATE TABLE pelanggan (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(120) NOT NULL,
  telepon VARCHAR(30) NOT NULL,
  email VARCHAR(160) NULL,
  alamat TEXT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pelanggan_email (email)
) ENGINE=InnoDB;

CREATE TABLE pengguna (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  hash_kata_sandi VARCHAR(255) NULL,
  peran ENUM('admin','teknisi','qc','pemilik') NOT NULL,
  spesialisasi VARCHAR(120) NULL,
  aktif BOOLEAN NOT NULL DEFAULT TRUE,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_pengguna_email (email)
) ENGINE=InnoDB;

CREATE TABLE perangkat (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  pelanggan_id BIGINT UNSIGNED NOT NULL,
  kategori VARCHAR(60) NOT NULL,
  merek VARCHAR(80) NOT NULL,
  model VARCHAR(120) NOT NULL,
  nomor_seri VARCHAR(100) NULL,
  tanggal_pembelian DATE NULL,
  catatan TEXT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_perangkat_pelanggan_serial (pelanggan_id, nomor_seri),
  CONSTRAINT fk_perangkat_pelanggan FOREIGN KEY (pelanggan_id)
    REFERENCES pelanggan(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tiket_servis (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_tiket VARCHAR(24) NOT NULL,
  pelanggan_id BIGINT UNSIGNED NOT NULL,
  perangkat_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NULL,
  diterima_oleh_id BIGINT UNSIGNED NOT NULL,
  status ENUM('diterima','dalam_inspeksi','menunggu_estimasi','menunggu_persetujuan','estimasi_ditolak','menunggu_suku_cadang','dalam_perbaikan','menunggu_qc','qc_gagal','siap_diambil','selesai','dibatalkan') NOT NULL DEFAULT 'diterima',
  prioritas ENUM('rendah','normal','tinggi','mendesak') NOT NULL DEFAULT 'normal',
  keluhan TEXT NOT NULL,
  kondisi_saat_diterima TEXT NULL,
  aksesori_diterima TEXT NULL,
  tanggal_diterima DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  target_selesai DATE NULL,
  tiket_servis_asal_id BIGINT UNSIGNED NULL,
  nama_penerima VARCHAR(120) NULL,
  pengakuan_pelanggan TEXT NULL,
  diserahkan_oleh_id BIGINT UNSIGNED NULL,
  diserahkan_pada DATETIME NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  diperbarui_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_tiket_nomor (nomor_tiket),
  KEY idx_tiket_status_target (status, target_selesai),
  KEY idx_tiket_teknisi_status (teknisi_id, status),
  KEY idx_tiket_pelanggan_tanggal (pelanggan_id, tanggal_diterima),
  CONSTRAINT fk_tiket_pelanggan FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_perangkat FOREIGN KEY (perangkat_id) REFERENCES perangkat(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_teknisi FOREIGN KEY (teknisi_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_penerima FOREIGN KEY (diterima_oleh_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_pencatat_serah FOREIGN KEY (diserahkan_oleh_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tiket_asal_garansi FOREIGN KEY (tiket_servis_asal_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE diagnosis (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NOT NULL,
  versi SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  dugaan_penyebab TEXT NOT NULL,
  temuan_pemeriksaan TEXT NOT NULL,
  saran_perbaikan TEXT NOT NULL,
  estimasi_durasi_hari SMALLINT UNSIGNED NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_diagnosis_versi (tiket_servis_id, versi),
  CONSTRAINT fk_diagnosis_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_diagnosis_teknisi FOREIGN KEY (teknisi_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE estimasi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  diagnosis_id BIGINT UNSIGNED NOT NULL,
  versi SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  biaya_jasa BIGINT UNSIGNED NOT NULL DEFAULT 0,
  biaya_suku_cadang BIGINT UNSIGNED NOT NULL DEFAULT 0,
  biaya_lain BIGINT UNSIGNED NOT NULL DEFAULT 0,
  total BIGINT UNSIGNED GENERATED ALWAYS AS (biaya_jasa + biaya_suku_cadang + biaya_lain) STORED,
  status ENUM('draf','dikirim','disetujui','ditolak','kedaluwarsa') NOT NULL DEFAULT 'draf',
  perkiraan_selesai DATE NULL,
  syarat_ketentuan TEXT NULL,
  diterbitkan_oleh_id BIGINT UNSIGNED NULL,
  diterbitkan_pada DATETIME NULL,
  diputuskan_pada DATETIME NULL,
  alasan_keputusan TEXT NULL,
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_estimasi_versi (tiket_servis_id, versi),
  CONSTRAINT fk_estimasi_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_estimasi_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_estimasi_penerbit FOREIGN KEY (diterbitkan_oleh_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE aktivitas_tiket (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  pelaku_id BIGINT UNSIGNED NULL,
  nama_pelaku_saat_itu VARCHAR(120) NOT NULL,
  status_sebelum VARCHAR(32) NULL,
  status_sesudah VARCHAR(32) NULL,
  deskripsi VARCHAR(500) NOT NULL,
  visibilitas ENUM('internal','pelanggan') NOT NULL DEFAULT 'internal',
  terjadi_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_aktivitas_tiket_waktu (tiket_servis_id, terjadi_pada),
  CONSTRAINT fk_aktivitas_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_aktivitas_pelaku FOREIGN KEY (pelaku_id) REFERENCES pengguna(id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pekerjaan_perbaikan (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  diagnosis_id BIGINT UNSIGNED NOT NULL,
  teknisi_id BIGINT UNSIGNED NOT NULL,
  percobaan_ke SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  status ENUM('berjalan','menunggu_qc','dikembalikan_qc','lolos_qc') NOT NULL DEFAULT 'berjalan',
  catatan_internal TEXT NULL,
  ringkasan_suku_cadang TEXT NULL,
  dimulai_pada DATETIME NULL,
  selesai_pada DATETIME NULL,
  UNIQUE KEY uq_pekerjaan_percobaan (tiket_servis_id, percobaan_ke),
  KEY idx_pekerjaan_teknisi_status (teknisi_id, status),
  CONSTRAINT fk_pekerjaan_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pekerjaan_diagnosis FOREIGN KEY (diagnosis_id) REFERENCES diagnosis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pekerjaan_teknisi FOREIGN KEY (teknisi_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pemeriksaan_qc (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  pekerjaan_perbaikan_id BIGINT UNSIGNED NOT NULL,
  pemeriksa_id BIGINT UNSIGNED NOT NULL,
  perangkat_menyala BOOLEAN NOT NULL,
  keluhan_teratasi BOOLEAN NOT NULL,
  fungsi_hardware_baik BOOLEAN NOT NULL,
  kondisi_fisik_baik BOOLEAN NOT NULL,
  aksesori_lengkap BOOLEAN NOT NULL,
  hasil ENUM('lolos','gagal') NOT NULL,
  catatan TEXT NOT NULL,
  diperiksa_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_qc_tiket_waktu (tiket_servis_id, diperiksa_pada),
  CONSTRAINT fk_qc_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_qc_pekerjaan FOREIGN KEY (pekerjaan_perbaikan_id) REFERENCES pekerjaan_perbaikan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_qc_pemeriksa FOREIGN KEY (pemeriksa_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_qc_lolos CHECK (hasil <> 'lolos' OR (perangkat_menyala AND keluhan_teratasi AND fungsi_hardware_baik AND kondisi_fisik_baik AND aksesori_lengkap))
) ENGINE=InnoDB;

CREATE TABLE pembayaran (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  estimasi_id BIGINT UNSIGNED NOT NULL,
  dicatat_oleh_id BIGINT UNSIGNED NOT NULL,
  metode ENUM('tunai','transfer_bank','qris','kartu_debit','lainnya') NOT NULL,
  jumlah BIGINT UNSIGNED NOT NULL,
  nomor_referensi VARCHAR(100) NULL,
  dibayar_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_pembayaran_tiket_waktu (tiket_servis_id, dibayar_pada),
  CONSTRAINT fk_pembayaran_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pembayaran_estimasi FOREIGN KEY (estimasi_id) REFERENCES estimasi(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pembayaran_pencatat FOREIGN KEY (dicatat_oleh_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_pembayaran_jumlah CHECK (jumlah > 0)
) ENGINE=InnoDB;

CREATE TABLE garansi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_garansi VARCHAR(32) NOT NULL,
  tiket_servis_id BIGINT UNSIGNED NOT NULL,
  tanggal_mulai DATE NOT NULL,
  tanggal_berakhir DATE NOT NULL,
  cakupan TEXT NOT NULL,
  status ENUM('aktif','kedaluwarsa','dicabut') NOT NULL DEFAULT 'aktif',
  dibuat_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_garansi_nomor (nomor_garansi),
  UNIQUE KEY uq_garansi_tiket (tiket_servis_id),
  CONSTRAINT fk_garansi_tiket FOREIGN KEY (tiket_servis_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_garansi_tanggal CHECK (tanggal_berakhir >= tanggal_mulai)
) ENGINE=InnoDB;

CREATE TABLE klaim_garansi (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nomor_klaim VARCHAR(32) NOT NULL,
  garansi_id BIGINT UNSIGNED NOT NULL,
  pelanggan_id BIGINT UNSIGNED NOT NULL,
  isu_yang_dilaporkan TEXT NOT NULL,
  hasil_pemeriksaan_kelayakan VARCHAR(300) NULL,
  status ENUM('diajukan','ditinjau','disetujui','ditolak','dalam_perbaikan','selesai') NOT NULL DEFAULT 'diajukan',
  diajukan_pada DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  peninjau_id BIGINT UNSIGNED NULL,
  keputusan_pada DATETIME NULL,
  alasan_keputusan TEXT NULL,
  tiket_servis_lanjutan_id BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_klaim_nomor (nomor_klaim),
  UNIQUE KEY uq_klaim_tiket_lanjutan (tiket_servis_lanjutan_id),
  CONSTRAINT fk_klaim_garansi FOREIGN KEY (garansi_id) REFERENCES garansi(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_pelanggan FOREIGN KEY (pelanggan_id) REFERENCES pelanggan(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_peninjau FOREIGN KEY (peninjau_id) REFERENCES pengguna(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_klaim_tiket_lanjutan FOREIGN KEY (tiket_servis_lanjutan_id) REFERENCES tiket_servis(id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Catatan implementasi: tagihan diambil dari estimasi berstatus disetujui; status pembayaran dihitung
-- dari total pembayaran terhadap total estimasi. Serah terima dan garansi hanya boleh dibuat setelah QC
-- lolos dan lunas. Setiap pengulangan perbaikan dibuat sebagai baris pekerjaan_perbaikan baru.
-- Aturan lintas tabel harus divalidasi dalam transaksi di lapisan aplikasi.
