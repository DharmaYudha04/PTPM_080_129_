# JogjaSplorasi

JogjaSplorasi adalah aplikasi mobile pariwisata Yogyakarta yang membantu pengguna menemukan destinasi wisata, kuliner, budaya, aktivitas, dan informasi pendukung perjalanan dalam satu pengalaman aplikasi. Aplikasi ini dibangun sebagai proyek Teknologi dan Pemrograman Mobile dengan fokus pada integrasi fitur mobile modern, data destinasi lokal, autentikasi aman, sensor perangkat, notifikasi, konverter perjalanan, mini game, dan AI tour guide.

## Latar Belakang

Yogyakarta memiliki banyak destinasi wisata yang tersebar di berbagai kategori, mulai dari budaya, alam, kuliner, belanja, edukasi, hingga aktivitas keluarga. Informasi tersebut sering tersebar di banyak sumber sehingga pengguna perlu berpindah-pindah aplikasi untuk mencari tempat, membaca detail, menghitung kebutuhan perjalanan, menyimpan favorit, atau meminta rekomendasi.

JogjaSplorasi dirancang sebagai solusi eksplorasi wisata yang lebih terarah. Aplikasi ini menggabungkan katalog destinasi terkurasi, rekomendasi, pencarian, peta, cuaca, konversi mata uang dan waktu, AI guide, serta fitur pendukung perangkat mobile seperti biometrik, sensor, dan notifikasi. Tujuannya adalah memberi pengalaman menjelajah Jogja yang praktis, aman, informatif, dan nyaman digunakan.

## Tujuan Aplikasi

- Membantu pengguna menemukan destinasi Jogja berdasarkan kategori, kata kunci, dan preferensi.
- Menyediakan detail destinasi seperti deskripsi, cerita lokal, alamat, rating, harga tiket, jam buka, durasi rekomendasi, dan tautan peta.
- Menyediakan fitur pendukung perjalanan seperti cuaca, konversi kurs, konversi waktu, dan rekomendasi destinasi.
- Memberikan pengalaman akun yang aman dengan login, penyimpanan sesi, dan kunci biometrik.
- Mengintegrasikan fitur khas mobile seperti sensor, notifikasi lokal, penyimpanan lokal, dan galeri foto.
- Menjadi aplikasi pembelajaran terpadu untuk praktik pengembangan Flutter, backend API, database, dan integrasi layanan eksternal.

## Fitur Utama

### Autentikasi dan Keamanan

- Register dan login akun pengguna.
- Sesi login berbasis token JWT dari backend.
- Penyimpanan token menggunakan `flutter_secure_storage`.
- Kunci aplikasi biometrik menggunakan fingerprint atau face unlock perangkat.
- Login biometrik untuk memulihkan sesi akun yang pernah aktif.
- App lock saat aplikasi dibuka kembali jika biometrik aktif.

### Beranda

- Ringkasan pengalaman eksplorasi Jogja.
- Cuaca lokal untuk membantu pengguna merencanakan perjalanan.
- Kategori destinasi seperti Budaya, Alam, Kuliner, Belanja, Seni, Aktivitas, Sejarah, dan Foto.
- Destinasi unggulan dan destinasi terdekat.
- Akses cepat ke fitur penting seperti AI guide, kurs, waktu, mini game, dan profil.

### Eksplorasi Destinasi

- Daftar destinasi dari backend dan cache lokal.
- Pencarian destinasi berdasarkan nama, kategori, tag, dan kata kunci terkait.
- Filter kategori dan mode tampilan.
- Kartu destinasi compact dan large.
- Favorit destinasi.
- Label jarak berbasis lokasi pengguna jika izin lokasi tersedia.
- Preview peta menggunakan `flutter_map`.

### Detail Destinasi

- Detail lengkap destinasi, termasuk gambar, deskripsi, cerita, alamat, rating, kategori, dan informasi praktis.
- Tautan peta atau rute berbasis koordinat destinasi.
- Rekomendasi destinasi serupa.
- Teaser AI guide untuk bertanya lebih lanjut tentang destinasi.

### Kanca Jogja AI Guide

- Chat AI guide untuk membantu pengguna bertanya tentang wisata Jogja.
- Jawaban berbasis database destinasi JogjaSplorasi agar tetap relevan dengan data aplikasi.
- Fallback lokal jika provider AI eksternal tidak tersedia.
- Dukungan itinerary suggestion dari backend.
- Riwayat percakapan melalui endpoint backend.

### Profil Pengguna

- Tampilan profil, email, foto, dan bio singkat.
- Edit profil dan foto menggunakan galeri perangkat.
- Statistik favorit, jumlah destinasi, dan skor kuis terbaik.
- Pengaturan kunci biometrik.
- Logout akun.

### Favorit

- Menyimpan destinasi favorit.
- Melihat daftar destinasi favorit dari profil atau navigasi notifikasi.
- Favorit tetap dipertahankan di cache lokal agar pengalaman tetap responsif.

### Konverter Perjalanan

- Konversi kurs mata uang berbasis ExchangeRate-API v6.
- Mode open access tanpa API key dan mode keyed endpoint jika `CURRENCY_KEY` tersedia.
- Cache kurs mengikuti jadwal update provider melalui `time_next_update_unix`.
- Informasi waktu update, sumber data, status online/cache, dan jadwal update berikutnya.
- Konversi waktu untuk zona waktu Indonesia dan kota dunia.

### Mini Game

- Kuis bertema Jogja.
- Skor berbasis jawaban dan waktu.
- Penyimpanan skor terbaik di lokal.
- Integrasi dengan data/backend quiz.

### Sensor dan Notifikasi

- Demo sensor accelerometer dan gyroscope.
- Visualisasi gerakan perangkat.
- Deteksi gerakan tertentu untuk pengalaman interaktif.
- Notifikasi lokal untuk pengingat eksplorasi, quiz, dan favorit.
- Navigasi dari payload notifikasi ke halaman terkait.

### Feedback

- Pengguna dapat mengirim masukan atau laporan melalui aplikasi.
- Backend menyediakan endpoint feedback dan admin dapat membaca feedback.

### Pencarian Global

- Pencarian cepat untuk fitur aplikasi seperti Profil, Konversi Kurs, Konversi Waktu, Favorit, AI Guide, dan destinasi.

### Admin dan Backend

- Backend menyediakan endpoint admin untuk destinasi, quiz, feedback, statistik, audit log, dan ekspor data.
- Admin web sederhana tersedia melalui folder `backend/public/admin`.
- Dokumentasi API backend tersedia di `backend/docs/API.md` dan OpenAPI JSON.

## Spesifikasi Teknis

### Frontend

- Framework: Flutter
- Dart SDK: `>=3.0.0 <4.0.0`
- Flutter SDK: `>=3.10.0`
- State management: Riverpod
- Routing: GoRouter
- Dependency injection: GetIt
- Local database/cache: Hive
- Preference storage: SharedPreferences
- Secure storage: Flutter Secure Storage
- HTTP client: Dio
- UI style: Cupertino/iOS Liquid Glass inspired interface
- Map: `flutter_map` dan `latlong2`
- Sensor: `sensors_plus`, `shake`
- Notification: `flutter_local_notifications`, `timezone`
- Location: `geolocator`
- Media picker: `image_picker`

### Backend

- Runtime: Node.js
- Framework: Express
- Database ORM: Prisma
- Database: PostgreSQL
- Authentication: JWT
- Password hashing: bcryptjs
- Validation: Zod
- Security middleware: Helmet, CORS, rate limiter
- Logging: Pino, Morgan
- API documentation: OpenAPI JSON dan dokumentasi Markdown

### Layanan Eksternal

- ExchangeRate-API untuk kurs mata uang.
- OpenWeather untuk data cuaca jika `WEATHER_KEY` disediakan.
- AI provider opsional melalui konfigurasi backend, dengan fallback lokal.

### Platform Target

- Android
- iOS
- Web Chrome untuk mode demo lokal
- Windows desktop scaffold tersedia dari template Flutter

## Struktur Proyek

```txt
PTPM_080_129_/
  android/              Konfigurasi Android Flutter
  assets/               Branding dan gambar destinasi
  backend/              Express API, Prisma, seed database, admin web
  ios/                  Konfigurasi iOS Flutter
  lib/                  Source code Flutter
    bootstrap/          Inisialisasi Hive, dependency, notifikasi
    core/               Router, theme, constants, network, utils
    features/           Modul fitur aplikasi
    shared/             Model dan widget reusable
  test/                 Test Flutter
  web/                  Konfigurasi Flutter Web
  windows/              Konfigurasi Windows Flutter
  Run_All.bat           Runner lokal backend + Flutter Chrome
```

## Arsitektur Aplikasi

JogjaSplorasi memakai pola modular berbasis fitur. Setiap fitur utama berada di folder `lib/features`, sedangkan komponen lintas fitur seperti model, widget, utilitas, router, tema, dan konfigurasi jaringan berada di folder `lib/core` dan `lib/shared`.

Alur data utama:

```txt
Flutter UI
  -> Controller / Provider
  -> Usecase / Data Source
  -> Dio API Client
  -> Express Backend
  -> Prisma
  -> PostgreSQL
```

Untuk performa dan pengalaman offline ringan, sebagian data seperti destinasi, user lokal, favorit, skor quiz, dan cache kurs/cuaca disimpan di Hive atau SharedPreferences.

## Backend API Ringkas

Endpoint utama:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/destinations`
- `GET /api/destinations/:id`
- `GET /api/recommendations`
- `POST /api/ai/guide/chat`
- `POST /api/ai/itinerary/suggest`
- `GET /api/quiz`
- `POST /api/feedback`
- `GET /health`
- `GET /api/docs`

Detail lengkap dapat dilihat di:

- `backend/docs/API.md`
- `backend/docs/openapi.json`
- `backend/docs/FREE_DATA_STRATEGY.md`

## Konfigurasi Environment

Backend memakai file `backend/.env`. Contoh nilai development:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/jogjasplorasi?schema=public
JWT_SECRET=local_dev_secret_change_this_32_chars_minimum
JWT_EXPIRES_IN=7d
CORS_ORIGIN=http://localhost:5173
GEMINI_API_KEY=
```

Flutter mendukung `--dart-define`:

```txt
BACKEND_BASE_URL=http://localhost:3000/api
LOCAL_SERVER_IP=<ip-lokal-untuk-device-fisik>
BACKEND_PORT=3000
APP_ENV=development
WEATHER_KEY=<optional>
CURRENCY_KEY=<optional>
JOGJA_REAL_GLASS=false
JOGJA_SENSOR_GESTURES=true
```

Jika `CURRENCY_KEY` kosong, aplikasi memakai endpoint open access ExchangeRate-API. Jika `CURRENCY_KEY` tersedia, aplikasi memakai endpoint ber-key.

## Cara Menjalankan

### Mode Cepat Windows

Jalankan file berikut dari root proyek:

```bat
Run_All.bat
```

Runner ini akan:

- Mengecek Flutter, Node.js, dan npm.
- Membuat `backend/.env` default jika belum ada.
- Menjalankan `npm install` backend jika diperlukan.
- Menjalankan Prisma generate dan db push.
- Menyalakan backend lokal di port `3000`.
- Menjalankan Flutter Web di Chrome pada port `5173`.

### Manual Backend

```bash
cd backend
npm install
npx prisma generate
npx prisma db push
npm run db:seed
npm run dev
```

Backend berjalan di:

```txt
http://localhost:3000
```

### Manual Flutter

```bash
flutter pub get
flutter run -d chrome --dart-define=BACKEND_BASE_URL=http://localhost:3000/api
```

Untuk Android emulator, default backend akan memakai:

```txt
http://10.0.2.2:3000/api
```

Untuk device fisik, jalankan dengan IP komputer:

```bash
flutter run --dart-define=LOCAL_SERVER_IP=192.168.x.x
```

## Data Destinasi

JogjaSplorasi memakai database destinasi kurasi yang berada di backend. Strategi ini dipilih agar aplikasi tetap bisa berjalan tanpa bergantung pada Google Places API berbayar atau scraping Google Maps.

Data utama berada di:

```txt
backend/prisma/jogjasplorasi_data.js
backend/prisma/seed.js
```

Jika ingin memperbarui destinasi, edit seed atau gunakan endpoint/admin backend, lalu jalankan ulang seed sesuai kebutuhan.

## Catatan Pengembangan

- Jalankan `flutter analyze` untuk memeriksa kualitas kode Flutter.
- Jalankan `flutter test` untuk test yang tersedia.
- Di Windows, test/build dengan plugin Flutter membutuhkan Developer Mode agar symlink plugin dapat dibuat.
- Jangan commit file generated seperti `.dart_tool/`, `build/`, `backend/node_modules/`, dan file `.env`.
- Untuk menjaga akurasi data wisata, harga tiket, jam buka, dan status operasional perlu diverifikasi berkala.

## Ringkasan Nilai Aplikasi

JogjaSplorasi bukan hanya katalog wisata, tetapi aplikasi eksplorasi mobile yang menggabungkan:

- Data destinasi lokal yang terkurasi.
- Pengalaman UI modern.
- Akun dan keamanan biometrik.
- Fitur lokasi, peta, cuaca, kurs, waktu, sensor, dan notifikasi.
- AI guide berbasis konteks destinasi.
- Backend API dan database yang dapat dikembangkan lebih lanjut.

Aplikasi ini dapat menjadi dasar pengembangan produk wisata digital Jogja maupun bahan demonstrasi penerapan teknologi mobile secara menyeluruh.
