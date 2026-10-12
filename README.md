# School OS

Sistem manajemen pendidikan terpadu untuk KB/TK, SD, SMP, SMA/SMK, dan satuan pendidikan yang relevan.

## Prinsip proyek

- Satu platform modular lintas jenjang; fitur dan alur kerja dikonfigurasi menurut jenis satuan pendidikan.
- Prioritas biaya operasional rendah dan penggunaan layanan yang sudah dipilih pemilik proyek.
- GitHub sebagai sumber kode dan riwayat perubahan.
- Neon PostgreSQL sebagai basis data target; koneksi aktual, branch, schema, dan kredensial harus diverifikasi sebelum migrasi atau perubahan data.
- Dapodik 2027 diintegrasikan melalui format ekspor resmi atau API yang secara resmi tersedia dan diizinkan. Installer Windows `.exe` bukan source code dan tidak digabungkan ke repository.
- Data anak, wali, keuangan, dan kepegawaian dilindungi dengan akses berbasis peran, RLS/otorisasi server, validasi, audit log, dan prinsip minimisasi data.
- AI hanya menyusun draf atau rekomendasi; keputusan sensitif dan laporan akademik harus ditinjau serta disetujui manusia.

## Fondasi teknis awal

- Next.js + TypeScript untuk aplikasi web responsif.
- PostgreSQL di Neon untuk data inti.
- SQL migrations tersimpan di `database/migrations/`.
- Integrasi eksternal berada di `src/integrations/` dan tidak boleh melewati kontrol otorisasi aplikasi.

## Status

Repositori diinisialisasi. Implementasi aplikasi, migrasi database, autentikasi, otorisasi, dan integrasi Dapodik masih perlu dibangun dan diuji. Jangan menganggap aplikasi production-ready sampai CI, migrasi pada branch yang benar, kontrol akses, dan smoke test deployment lulus.
