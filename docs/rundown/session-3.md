# Sesi 3: Backend Hono + Neon, Dio Integration & Login

## Info
- **Tanggal:** Sabtu, 22 Agustus (pagi 09:30–12:00, siang 13:00–14:30; break 12:00–13:00)
- **Mulai dari:** `session-3-start` (= hasil sesi 2, re-arch lengkap)
- **Target akhir:** `session-3-final` (+ login screen + timeout handling, backend-ready)
- **Branch pembanding:** `session-3-final`

## Hasil Akhir Sesi (peserta bisa)
- Memahami arsitektur backend: Hono + Drizzle + Neon PostgreSQL
- Membuat & menjalankan API lokal (register, login, CRUD tugas)
- Menghubungkan Flutter (Dio) ke API sungguhan
- Login dengan NIP/NIK + password, simpan sesi via `shared_preferences`

---

## Storyboard Menit-per-Menit

### BLOK PAGI (09:30–12:00) — Backend Foundation

#### 09:30–09:40 — Review & Preview (10 min)
- [ ] Recap sesi 2 (layer, Dio, role UI)
- [ ] Tampilkan **demo akhir sesi 3**: app login → dashboard → buat tugas → kumpul (end-to-end)
- [ ] Jelaskan arsitektur: Flutter ↔ Hono API ↔ Neon PostgreSQL

#### 09:40–10:10 — Setup Backend Project (30 min)
- [ ] `flutter-task-api/` structure: `src/index.ts`, `src/db/*`, `drizzle/`, `neon.ts`
- [ ] `npm install`, `npm run dev`
- [ ] `.env` + `DATABASE_URL` (dari Neon setup)
- [ ] **Checkpoint:** server jalan di `localhost:3000`, `/api/classes` merespons

#### 10:10–10:55 — Database Schema & Migration (45 min)
- [ ] 5 tabel: classes, users, tasks, submissions, submission_members
- [ ] Drizzle ORM: definisi schema di `schema.ts`
- [ ] Jalankan migration: `neon db push` (atau drizzle-kit)
- [ ] **Checkpoint:** tabel terbuat di Neon (cek via `neon` / dashboard)

#### 10:55–11:25 — Hono Routes: Auth & Classes (30 min)
- [ ] `POST /api/auth/register` — validasi, hash password, insert
- [ ] `POST /api/auth/login` — cek NIP/NIK + password
- [ ] `GET /api/classes` — list kelas
- [ ] **Latihan:** implement register & login (ikut `session-3-final` sebagai panduan)
- [ ] **Checkpoint:** register/login sukses via curl/Postman

#### 11:25–11:50 — Hono Routes: Tasks & Submissions (25 min)
- [ ] `POST /api/tasks`, `GET /api/tasks`, `POST /api/submissions`, `GET /api/tasks/:id/submissions`
- [ ] **Latihan:** implement minimal task CRUD
- [ ] **Checkpoint:** bisa buat tugas via API

#### 11:50–12:00 — Review Pagi (10 min)
- [ ] Recap: backend structure, schema, routes
- [ ] Q&A

---

### BREAK 12:00–13:00

---

### BLOK SIANG (13:00–14:30) — Flutter ↔ Backend & Login

#### 13:00–13:25 — Dio Integration: Auth Repository (25 min)
- [ ] `AuthRepository.login()` — POST ke `/api/auth/login`
- [ ] `AuthRepository.register()` — POST ke `/api/auth/register`
- [ ] `ApiResponse` wrapper: parse success/data/message
- [ ] **Latihan:** implement login dari Flutter (cek respons sukses/gagal)
- [ ] **Checkpoint:** login berhasil dari app (token/sesi tersimpan)

#### 13:25–13:50 — Session Persistence: shared_preferences (25 min)
- [ ] Tambah `shared_preferences` dependency
- [ ] Simpan user data (nama, role, nipNik) setelah login
- [ ] Auto-login saat app dibuka (cek sesi tersimpan)
- [ ] **Latihan:** implement session persistence + logout
- [ ] **Checkpoint:** tutup & buka app → tetap login

#### 13:50–14:10 — Login Screen & Timeout Handling (20 min)
- [ ] `LoginScreen` UI (NIP/NIK + password field, loading state, error message)
- [ ] Dio timeout handling: `DioExceptionType.connectionTimeout` → pesan ramah
- [ ] **Checkpoint:** app menampilkan pesan timeout yang rapi jika server mati

#### 14:10–14:30 — Review, Merge & Preview Sesi 4 (20 min)
- [ ] Bandingkan `session-3-final`:
  ```bash
  git merge session-3-final
  ```
- [ ] Recap: backend, Dio integration, login, session
- [ ] Preview Sesi 4 (besok): workshop — replikasi project, improvement, Q&A
- [ ] Jelaskan bahwa app sudah **end-to-end lengkap**

---

## Checklist Kesiapan Instruktur
- [ ] Neon project & database ready (region `aws-us-east-2`)
- [ ] `flutter-task-api` bisa `npm run dev` di mesin instruktur
- [ ] Slide: arsitektur Flutter↔Hono↔Neon, contoh JSON request/response
- [ ] Backup plan: jika Neon Functions bermasalah, fallback ke local Postgres/Docker

## Common Pitfalls & Solusi
| Masalah | Solusi |
|---|---|
| `neon link` gagal | Pastikan `neon auth` sudah jalan (cek `neon me`) |
| CORS error | Tambahkan middleware CORS di Hono |
| Password hash | Pakai `bcrypt`/`argon2` (lihat `session-3-final` implementation) |
| Sesion hilang setelah restart | Cek `shared_preferences` persist (Android: app data) |
| Port 3000 dipakai | Ganti port di `.env` / `npm run dev -- --port 3001` |
