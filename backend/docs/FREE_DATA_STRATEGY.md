# Strategi Data Destinasi Full Gratis - JogjaSplorasi

JogjaSplorasi menggunakan pendekatan **database lokal yang dikurasi** sebagai sumber utama data destinasi. Pendekatan ini dipilih agar aplikasi tetap stabil untuk demo tugas akhir tanpa bergantung pada Google Places API berbayar.

## Arsitektur data

```txt
Flutter App
  -> Backend Express API
  -> PostgreSQL lokal
  -> Seed destinasi kurasi Jogja
  -> Link rute Google Maps/OSM tanpa API key
```

## Yang gratis dan tidak membutuhkan billing

- Data destinasi utama disimpan di PostgreSQL lokal.
- Link rute Google Maps dibuat dari koordinat: `https://www.google.com/maps/search/?api=1&query=lat,lng`.
- Link OpenStreetMap dibuat dari koordinat: `https://www.openstreetmap.org/?mlat=lat&mlon=lng#map=17/lat/lng`.
- Aplikasi tidak memakai Google Places API, tidak memakai scraping Google Maps, dan tidak membutuhkan billing Google.

## Isi data destinasi

Seed destinasi di `backend/prisma/seed.js` sekarang berisi data lebih lengkap:

- nama destinasi,
- kategori,
- tipe destinasi,
- koordinat,
- alamat,
- deskripsi bergaya tour guide,
- cerita/narasi tempat,
- insight lokal,
- estimasi tiket,
- jam operasional estimasi,
- waktu terbaik berkunjung,
- durasi rekomendasi,
- rating kurasi,
- nilai budaya,
- tag pencarian.

Data ini kemudian masuk ke PostgreSQL lewat:

```bash
cd backend
npm run db:seed
```

Setelah masuk PostgreSQL, Flutter mengambil destinasi melalui API `/api/destinations`, bukan dari file hardcoded frontend.

## Endpoint tambahan

Backend menambahkan field link peta di response destinasi:

```json
{
  "mapsUrl": "https://www.google.com/maps/search/?api=1&query=-7.8053,110.3642",
  "osmUrl": "https://www.openstreetmap.org/?mlat=-7.8053&mlon=110.3642#map=17/-7.8053/110.3642",
  "dataSource": "CURATED_LOCAL_DATABASE"
}
```

Endpoint kategori/tags juga tersedia untuk pengembangan filter dinamis:

```txt
GET /api/destinations/meta/categories
GET /api/destinations/meta/tags
```

## Catatan presentasi

Penjelasan yang disarankan saat presentasi:

> Data destinasi JogjaSplorasi tidak ditanam langsung di UI Flutter. Data awal disiapkan sebagai seed backend, dimasukkan ke PostgreSQL lokal, lalu aplikasi membaca data melalui web service/API. Untuk rute, aplikasi memakai link Google Maps dan OpenStreetMap berbasis koordinat sehingga tidak membutuhkan Google Places API berbayar.

## Jika ingin menambah gambar gratis

Untuk versi lanjutan, gambar bisa ditambah secara legal melalui:

- aset lokal buatan sendiri di `assets/images/destinations`,
- Wikimedia Commons dengan memperhatikan lisensi dan atribusi,
- foto dokumentasi pribadi/kelompok.

Hindari scraping gambar Google Maps karena melanggar praktik penggunaan yang aman.
