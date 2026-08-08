<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://neon.com/brand/neon-logo-dark-color.svg">
  <source media="(prefers-color-scheme: light)" srcset="https://neon.com/brand/neon-logo-light-color.svg">
  <img width="250px" alt="Neon Logo fallback" src="https://neon.com/brand/neon-logo-dark-color.svg">
</picture>

# flutter-task-api — Backend Aplikasi Pengumpulan Tugas

Backend API untuk **Aplikasi Pengumpulan Tugas** (Guru/Siswa) menggunakan [Hono](https://hono.dev) + [Neon](https://neon.com) Postgres + [Drizzle ORM](https://orm.drizzle.team) dijalankan di **Neon Functions**.

Fitur keamanan: password di-hash dengan **bcrypt**, autentikasi **JWT**, dan role-based access control (guru/siswa).

## Project structure

```
flutter-task-api/
├── neon.ts             # Neon Functions policy (defineConfig) — what gets deployed
├── drizzle.config.ts   # Drizzle Kit config (schema location + DB credentials)
├── tsconfig.json
├── .env.example        # Required environment variables (termasuk JWT_SECRET)
├── src/
│   ├── index.ts        # Hono app + routes
│   ├── auth.ts         # bcrypt + JWT helpers & middleware (authMiddleware, requireRole)
│   └── db/
│       ├── schema.ts   # Drizzle schema (users, classes, tasks, submissions)
│       ├── client.ts   # Drizzle client (node-postgres)
│       ├── seed.ts     # Seeder idempotent (kelas + akun demo)
│       └── reset.ts    # Reset seluruh tabel
└── package.json
```

## Install and authenticate the Neon CLI

```bash
npm i -g neon
neon login
```

## Install dependencies

```bash
npm install
```

## Link your Neon project

Link (or create) a Neon project by running the `link` command from the workspace root:

```bash
neon link
```

If you let your agent drive this, add `--agent` to skip interactive mode.

`neon link` pulls your branch-scoped environment variables — including `DATABASE_URL` — into `.env.local`. You can also find your connection string in the [Neon Console](https://console.neon.tech).

## Apply the schema

Push the Drizzle schema to your Neon database:

```bash
npm run db:push
```

## Run locally

```bash
neon dev
```

## Launch Drizzle Studio (Database Visualizer)

Inspect and manage your Neon database tables (users, classes, tasks, submissions) visually:

```bash
npm run db:studio
```

This will automatically launch Drizzle Studio in your browser (usually at `https://local.drizzle.studio` or `http://127.0.0.1:4983`).


### Endpoint publik: daftar kelas

`GET /api/classes` bersifat publik (dibutuhkan saat registrasi):

```bash
curl http://localhost:8787/api/classes
```

## Deploy to Neon Functions

Deploy hono app as a Neon Function to your branch

```bash
neon deploy
```

## Test your deployed function

Grab the function's invocation URL and call it:

```bash
# List the function to find its invocation URL
neon functions get task-api
```

Kemudian panggil endpoint yang sudah diautentikasi dengan header `Authorization: Bearer <token>` (lihat contoh di bagian Autentikasi).

## Autentikasi (JWT)

Sejak versi ini, API menggunakan autentikasi berbasis token **JWT**:

- **Register** (`POST /api/auth/register`) — menyimpan password sebagai **hash bcrypt** (bukan plaintext) dan langsung mengembalikan token.
- **Login** (`POST /api/auth/login`) — memverifikasi bcrypt, lalu mengembalikan `{ data, token }`.
- **Endpoint yang dilindungi** (`/api/tasks`, `/api/submissions`) — wajib mengirim header `Authorization: Bearer <token>`.
- **Role-based access**: hanya role `guru` yang bisa membuat tugas (`/api/tasks`), hanya role `siswa` yang bisa mengumpulkan (`/api/submissions`). Role & id user diambil dari token, bukan dari body request.

### Environment variable

Tambahkan `JWT_SECRET` di `.env.local` (lihat `.env.example`):

```bash
JWT_SECRET="ganti-dengan-secret-acak-yang-kuat"
```

> ⚠️ Default fallback `dev-insecure-secret-change-in-production` hanya untuk pengembangan lokal. **Wajib** diganti di produksi.

### Contoh pemakaian (curl)

```bash
# 1. Login sebagai demo guru
curl -X POST http://localhost:8787/api/auth/login \
  -H 'content-type: application/json' \
  -d '{"nipNik":"GURU001","password":"demo123"}'

# 2. Buat tugas (pakai token dari response login)
curl -X POST http://localhost:8787/api/tasks \
  -H 'content-type: application/json' \
  -H 'Authorization: Bearer <TOKEN>' \
  -d '{"classId":"<UUID>","description":"Tugas 1","startDate":"2026-08-01T00:00:00.000Z","endDate":"2026-08-08T00:00:00.000Z"}'
```

### Akun demo (seed)

Jalankan `npm run db:seed` untuk membuat akun demo:

| NIP/NIK  | Role  | Password |
|----------|-------|----------|
| `GURU001` | guru  | `demo123` |
| `SISWA001`| siswa | `demo123` |
