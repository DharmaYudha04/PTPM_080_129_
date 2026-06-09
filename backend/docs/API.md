# API Ringkas

Base URL: `http://localhost:4000/api`

## Auth

- `POST /auth/register`
- `POST /auth/login`
- `GET /auth/me`
- `POST /auth/logout`

## Profil dan Personalisasi

- `PATCH /me/profile`
- `PATCH /me/email`
- `PATCH /me/password`
- `POST /me/avatar` multipart field `avatar`
- `DELETE /me/avatar`
- `GET /me/preferences`
- `PATCH /me/preferences`

## Destinasi

- `GET /destinations`
- `GET /destinations?search=keraton&type=CULTURE&tag=sejarah`
- `GET /destinations/featured`
- `GET /destinations/:slug`
- `POST /destinations` admin
- `PATCH /destinations/:id` admin
- `DELETE /destinations/:id` admin soft delete

Type destinasi:

- `TOURISM`
- `CULINARY`
- `CULTURE`

## Favorite dan Kunjungan

- `GET /me/favorites`
- `POST /me/favorites/:destinationId`
- `DELETE /me/favorites/:destinationId`
- `GET /me/visited-places`
- `POST /me/visited-places/:destinationId`

## Rekomendasi

- `GET /recommendations/today?lat=-7.7956&lng=110.3695`

Response berisi:

```json
{
  "tourism": {},
  "culinary": {},
  "culture": {}
}
```

Destinasi yang sudah ada di `visited_places` user tidak akan direkomendasikan lagi.

## Quiz

- `POST /quiz/start`
- `POST /quiz/submit`
- `GET /quiz/history`
- `GET /quiz/leaderboard`

`/quiz/start` tidak mengirim `isCorrect`, sehingga jawaban tidak bocor ke Flutter.

## Feedback

- `POST /feedback`
- `GET /feedback` admin

## Phase 5 - Reviews

### GET `/api/reviews/destinations/:destinationId`
Public endpoint for destination review list and rating summary.

### POST `/api/reviews/destinations/:destinationId`
Authenticated endpoint to create or update the current user's review.

Body:
```json
{
  "rating": 5,
  "comment": "Tempatnya indah dan cocok untuk wisata budaya.",
  "visitDate": "2026-04-27T09:00:00.000Z"
}
```

### DELETE `/api/reviews/:id`
Authenticated endpoint. Users may delete their own review; admin may delete any review.

## Phase 5 - Itineraries

### GET `/api/itineraries`
List current user's active trip plans.

### POST `/api/itineraries`
Create a new trip plan.

Body:
```json
{
  "title": "Liburan Jogja 2 Hari",
  "description": "Rute budaya dan kuliner",
  "startDate": "2026-05-01T00:00:00.000Z",
  "endDate": "2026-05-02T00:00:00.000Z"
}
```

### GET `/api/itineraries/:id`
Read one trip plan with ordered stops.

### PATCH `/api/itineraries/:id`
Update title, description, dates, or archive status.

### DELETE `/api/itineraries/:id`
Soft-delete/archive an itinerary.

### POST `/api/itineraries/:id/stops`
Add destination to a trip plan.

Body:
```json
{
  "destinationId": "destination_id",
  "dayIndex": 1,
  "orderIndex": 0,
  "note": "Datang pagi agar tidak terlalu ramai",
  "plannedAt": "2026-05-01T08:00:00.000Z"
}
```

### PATCH `/api/itineraries/:id/stops/:stopId`
Update stop day, order, note, or planned time.

### DELETE `/api/itineraries/:id/stops/:stopId`
Remove a stop from a trip plan.

### POST `/api/itineraries/:id/stops/:stopId/check-in`
Mark a planned stop as visited. This also writes to `user_visited_places` so future recommendations avoid that destination.

## Phase 6 - Sync, Audit, Export, Health

### Health

```txt
GET /health
GET /health/ready
```

### Sync

Requires `Authorization: Bearer <token>`.

```txt
GET /api/sync/bootstrap
POST /api/sync/push
```

Supported push operations:

- `favorite.add`
- `favorite.remove`
- `visited.add`
- `preferences.update`

### Export

```txt
GET /api/export/me
GET /api/export/admin/destinations
GET /api/export/admin/quiz
```

Admin endpoints require `ADMIN` role.

### Audit logs

```txt
GET /api/audit-logs?limit=50
```

Admin only.

## Phase 8 AI Tour Guide

### `POST /api/ai/guide/chat`
Chat tour guide berbasis database destinasi.

Body:
```json
{
  "message": "Rekomendasikan tempat budaya Jogja yang cocok sore hari",
  "conversationId": "optional"
}
```

### `GET /api/ai/guide/conversations`
Melihat daftar riwayat chat AI milik user.

### `GET /api/ai/guide/conversations/:id`
Melihat isi conversation AI.

### `POST /api/ai/itinerary/suggest`
Membuat saran itinerary dari database destinasi.

Body:
```json
{
  "days": 2,
  "pace": "normal",
  "types": ["TOURISM", "CULINARY", "CULTURE"],
  "keywords": ["budaya"],
  "excludeVisited": true
}
```
