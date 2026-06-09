# JogjaSplorasi redesign notes

Perubahan yang diterapkan:

1. Splash screen
   - Route baru `/splash` sebagai entry awal aplikasi.
   - Logo JogjaSplorasi tampil besar selama 3 detik.
   - Setelah splash, aplikasi mengecek session: belum login ke login/register, sudah login ke dashboard.

2. Auth screen
   - Border lingkaran pada logo login/register dihilangkan agar branding terlihat lebih clean.
   - Logo diperbesar sedikit dan tetap memakai glow halus.

3. Dashboard
   - Ditambahkan card “Rekomendasi perjalanan” tepat setelah search bar.
   - Card mengambil destinasi featured pertama jika tersedia, lalu tombol/card mengarah ke detail destinasi.
   - Jika data belum tersedia, card mengajak user ke menu Jelajah.

4. Kanca Jogja / AI assistant
   - Tombol “Tanya Kanca Jogja” dari detail destinasi sekarang mengirim konteks `destination` dan prompt awal.
   - Di halaman Kanca Jogja, prompt awal tampil langsung di input agar user tidak perlu mengetik ulang.
   - Ditambahkan preset chips: cerita tempat, itinerary, dan waktu terbaik.
   - Balasan AI yang menyebut nama destinasi di database akan menampilkan inline card dengan tombol Detail ke halaman destinasi tersebut.

5. Mode tampilan
   - Ditambahkan kontrol Light / Dark / Sistem di Profile > Tampilan.
   - Theme controller yang sebelumnya sudah ada kini punya UI untuk dipilih user.

6. Optimasi Android lama
   - Image cache dikurangi dari 140 item / 72MB menjadi 96 item / 48MB.
   - Sensor gesture global dimatikan secara default untuk mengurangi stream sensor terus-menerus di perangkat lama. Bisa diaktifkan saat build dengan `--dart-define=JOGJA_SENSOR_GESTURES=true`.
   - Splash dan logo memakai cacheWidth/filterQuality yang lebih hemat.

Catatan validasi:
- Environment sandbox ini tidak memiliki Flutter/Dart SDK, jadi `flutter analyze` dan `dart format` tidak bisa dijalankan di sini.
- Saya melakukan pemeriksaan struktur file dan balanced-bracket check sederhana untuk file Dart yang diubah.
