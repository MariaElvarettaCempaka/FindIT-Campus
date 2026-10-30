# FindIT Campus

Platform *Lost and Found* berbasis mobile untuk civitas akademika Universitas Negeri Surabaya. Mahasiswa, dosen, dan staf dapat melaporkan serta mencari barang hilang atau ditemukan di lingkungan kampus.

> Proyek mata kuliah Pemrograman Aplikasi Bergerak, Program Studi Informasi, Fakultas Teknik, UNESA (2026).

## Latar Belakang

Informasi barang hilang di kampus biasanya disebar lewat grup obrolan seperti WhatsApp. Pesannya cepat tertimbun dan sulit dilacak. FindIt Campus mengumpulkan semua laporan di satu tempat dalam bentuk terstruktur: foto bukti, deskripsi, kategori, lokasi, dan tanggal kejadian.

## Fitur

- [ ] F01 Registrasi akun
- [ ] F02 Login
- [ ] F03 Posting barang hilang
- [ ] F04 Posting barang ditemukan
- [ ] F05 Daftar barang hilang
- [ ] F06 Daftar barang ditemukan
- [ ] F07 Pencarian dan filter kategori
- [ ] F08 Detail barang
- [ ] F09 Hubungi pembuat laporan via WhatsApp
- [ ] F10 Riwayat laporan
- [ ] F11 Edit dan hapus laporan
- [ ] F12 Ubah status laporan (Sudah Ditemukan / Sudah Dikembalikan)

## Teknologi

| Bagian | Teknologi |
|---|---|
| Aplikasi mobile | Flutter (Dart), Android 10 ke atas |
| Autentikasi | Firebase Authentication |
| Database | Cloud Firestore |
| Penyimpanan foto | Firebase Storage (maks. 5 MB per file) |
| Komunikasi | WhatsApp Deep Link |

## Tampilan

Desain antarmuka ada di folder [`docs/design`](docs/design).

## Cara Menjalankan

1. Pasang [Flutter](https://docs.flutter.dev/get-started/install) dan Android Studio.
2. Clone repo:
   ```bash
   git clone https://github.com/MariaElvarettaCempaka/FindIT-Campus.git
   cd findit-campus
   flutter pub get
   ```
3. Hubungkan ke Firebase milik tim (minta file `google-services.json` ke ketua tim, lalu taruh di `android/app/`).
4. Jalankan di emulator atau HP Android:
   ```bash
   flutter run
   ```

## Struktur Folder

- `lib/` kode aplikasi (screens, services, models, widgets)
- `docs/` proposal dan desain UI
- `firebase/` aturan keamanan Firestore dan Storage

## Alur Kerja Tim

- `main`: versi stabil. `develop`: gabungan pekerjaan.
- Setiap fitur dikerjakan di branch `feature/nama-fitur`, lalu digabung lewat Pull Request.
- Pesan commit memakai awalan: `feat:`, `fix:`, `docs:`.

## Tim

| Nama | NIM |
|---|---|
| Ayu Artha Wulan Ndari | 24051214022 |
| Faiq Rayyis Malano | 24051214025 |
| Maria Elvaretta Cempaka Ayu | 24051214033 |
| Farrel Farica Firjaturazza | 24051214034 |

Dosen pengampu: I Gusti Lanang Putra Eka Prismana, S.Kom., M.Kom.

## Lisensi
MIT
Proyek ini dibuat untuk kebutuhan akademik pada Mata Kuliah Pemrograman Aplikasi Bergerak, Program Studi Sistem Informasi, Universitas Negeri Surabaya.

© 2026 Kelompok 2, SI 2024A
