# JogjaSplorasi Backend - Phase 1

Backend ini disiapkan untuk menggantikan data hardcode/mock di Flutter dengan API dan database.

## Fitur Phase 1

- Auth: register, login, logout, `GET /api/auth/me`
- Profil: edit nama, username, bio, email, password, avatar
- Preferensi: theme mode, accent color, bahasa, radius rekomendasi, mood/kategori favorit
- Destinasi: list, detail, search, filter, CRUD admin
- Favorite dan visited places per user
- Rekomendasi hari ini: 1 wisata, 1 kuliner, 1 budaya berdasarkan lokasi dan belum dikunjungi
- Quiz: start 5 soal acak, opsi jawaban diacak, submit skor berbasis waktu
- Feedback: user kirim saran, admin membaca feedback

## Menjalankan

```bash
cp .env.example .env
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run db:seed
npm run dev
```

API jalan di `http://localhost:3000`.

Admin seed:

```txt
email: admin@jogjasplorasi.local
password: Admin12345
```

## Catatan data

Seed berisi data awal destinasi Jogja nyata sebagai starter content, bukan mock UI. Tetap verifikasi berkala untuk harga tiket, jam buka, gambar, dan status operasional sebelum rilis publik.

## Integrasi Flutter

Gunakan token JWT dari `/api/auth/login` sebagai header:

```txt
Authorization: Bearer <token>
```

Endpoint utama ada di `docs/API.md`.

## Phase 6 additions

Phase 6 adds:

- `/health` and `/health/ready` checks
- `/api/sync/bootstrap` for Flutter cache bootstrap
- `/api/sync/push` for offline operation sync
- `/api/export/me` for user data export
- `/api/export/admin/destinations` and `/api/export/admin/quiz` for admin backup/export
- `/api/audit-logs` for admin audit trail

After replacing the project, run:

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev --name phase6_sync_audit_export
npm run db:seed
npm run dev
```

## Phase 8 additions

Phase 8 adds:

- `/api/ai/guide/chat` for database-grounded AI tour guide chat
- `/api/ai/guide/conversations` for conversation history
- `/api/ai/guide/conversations/:id` for conversation detail
- `/api/ai/itinerary/suggest` for AI-style itinerary suggestions from verified destinations
- `AiConversation` and `AiMessage` tables

After replacing the project, run:

```bash
cd backend
npm install
npx prisma generate
npx prisma migrate dev --name phase8_ai_tour_guide
npm run db:seed
npm run dev
```

## Strategi data destinasi full gratis

JogjaSplorasi sekarang memakai database destinasi kurasi sebagai sumber utama agar demo tetap stabil tanpa Google Places API berbayar.

- Data destinasi lengkap ada di `backend/prisma/seed.js` dan masuk ke PostgreSQL melalui `npm run db:seed`.
- API `/api/destinations` mengembalikan data dari database, bukan mock frontend.
- Response destinasi dilengkapi `mapsUrl` dan `osmUrl` berbasis koordinat, sehingga user tetap bisa membuka rute tanpa API berbayar.
- Dokumentasi lengkap ada di `backend/docs/FREE_DATA_STRATEGY.md`.

Untuk update data destinasi, edit seed atau kelola melalui endpoint admin, lalu jalankan ulang seed/migrasi sesuai kebutuhan.
