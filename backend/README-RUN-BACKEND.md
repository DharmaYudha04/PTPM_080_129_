# Cara Menjalankan Backend JogjaSplorasi

## Cara paling cepat di Windows

Dari root proyek, cukup jalankan:

```bat
run-backend.bat
```

Atau dari folder backend:

```bat
cd backend
run-backend-windows.bat
```

Script ini menjalankan semuanya otomatis:

1. `npm install`
2. `npx prisma@5.22.0 generate`
3. `npx prisma@5.22.0 db push`
4. `npm run db:seed`
5. `npm run dev`

## Cara manual yang lebih ringkas

```bat
cd backend
npm run dev:full
```

## Kalau dependency sudah pernah terinstall

```bat
cd backend
npm run db:prepare
npm run dev
```

## Catatan penting

- `db:seed` sekarang sudah otomatis memperkaya deskripsi destinasi. Tidak perlu lagi menjalankan `node scripts/enrich-destination-descriptions.js`.
- Data destinasi dan 200 soal kuis sekarang disatukan di `backend/prisma/jogjasplorasi_data.js`.
- File `.env` tidak disertakan dalam ZIP final. Simpan konfigurasi lokal Anda di `backend/.env`.
