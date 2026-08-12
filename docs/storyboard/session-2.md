# Sesi 2: State Management (Provider), HTTP & Re-Arch Project

## Info
- **Tanggal:** Minggu, 16 Agustus (pagi 09:00–12:00, siang 13:00–15:00; break 12:00–13:00)
- **Mulai dari:** `session-2-start` (= hasil sesi 1, app minimal)
- **Target akhir:** `session-2-final` (~1,120 LOC: Dio, model lengkap, repo, provider, screens guru/siswa)
- **Branch pembanding:** `session-2-final`

## Hasil Akhir Sesi (peserta bisa)
- Memahami arsitektur layer: `models/` → `repositories/` → `providers/` → `screens/`
- Membuat model Dart lengkap dengan fromJson/toJson (manual serialization)
- Mengganti `http` → **Dio** (interceptors, error handling)
- Membuat 2 halaman (siswa & guru) dengan role-based navigation

---

## Storyboard Menit-per-Menit

### BLOK PAGI (09:00–12:00) — Arsitektur & Model

#### 09:00–09:15 — Review Sesi 1 & Preview
- [ ] Recap singkat: apa yang sudah dibangun kemarin
- [ ] Kenapa perlu re-arch? (app sekarang satu file besar, sulit dikembangkan)
- [ ] Tampilkan **struktur target** (`session-2-final` tree) — peta perjalanan hari ini

#### 09:15–09:45 — Arsitektur Berlapis (30 min)
- [ ] Layer concept: Screen → Provider → Repository → Model → (HTTP/API)
- [ ] Kenapa dipisah? (testability, reusability, maintainability)
- [ ] Buat struktur folder kosong: `core/`, `models/`, `repositories/`, `providers/`, `screens/`

#### 09:45–10:30 — Model Lengkap: fromJson/toJson (45 min)
- [ ] Model `User` (id, nama, role, nipNik, email, classId)
- [ ] Model `Task` lengkap (id, guruId, classId, description, startDate, endDate, attachmentUrl, isTeamTask, maxTeamMembers)
- [ ] Model `Class` & `Submission`
- [ ] **Latihan:** implementasi `fromJson`/`toJson` untuk setiap model
- [ ] **Checkpoint:** model terkompilasi & unit-testable

#### 10:30–11:00 — Repository Pattern (30 min)
- [ ] Apa itu repository? (abstraksi sumber data)
- [ ] `TaskRepository`, `AuthRepository`, `SchoolRepository` — method & kontrak
- [ ] **Latihan:** implement `TaskRepository.fetchTasks()` dengan data mock dulu
- [ ] **Checkpoint:** repository bisa dipanggil dari provider

#### 11:00–11:45 — Dio Client & Error Handling (45 min)
- [ ] Kenapa Dio? (interceptor, timeout, logging, lebih ringkas dari http)
- [ ] Tambah dependency `dio`
- [ ] `DioClient` singleton: base URL, interceptor (log request/response), timeout
- [ ] **Latihan:** `ApiResponse` wrapper (success/data/message) + `getErrorMessage()`
- [ ] **Checkpoint:** Dio client bisa GET ke endpoint (bisa mock server)

#### 11:45–12:00 — Review Pagi (15 min)
- [ ] Recap: layer, model, repository, Dio
- [ ] Q&A

---

### BREAK 12:00–13:00

---

### BLOK SIANG (13:00–15:00) — Screens & Navigation

#### 13:00–13:40 — Home Screen Siswa (40 min)
- [ ] `StudentHomeScreen`: tampilkan daftar tugas dari `TaskProvider`
- [ ] `EmptyStateWidget`, loading, error state
- [ ] **Latihan:** build UI sesuai `session-2-final` (siswa: list tugas + status)
- [ ] **Checkpoint:** UI siswa tampil dengan data

#### 13:40–14:20 — Home Screen Guru (40 min)
- [ ] `TeacherHomeScreen`: beda konten (buat tugas, lihat kelas)
- [ ] Role-based: `main.dart` menentukan screen berdasarkan role user
- [ ] **Latihan:** implement guru screen + routing sederhana
- [ ] **Checkpoint:** bisa navigasi siswa ↔ guru

#### 14:20–14:40 — Integrasi & Polish (20 min)
- [ ] Hubungkan semua layer (screen → provider → repo → model → Dio)
- [ ] Pastikan `main.dart` pakai `MultiProvider`
- [ ] **Checkpoint:** app jalan end-to-end dengan struktur bersih

#### 14:40–15:00 — Review, Merge & Preview Sesi 3 (20 min)
- [ ] Bandingkan `session-2-final`:
  ```bash
  git merge session-2-final
  ```
- [ ] Recap: layer architecture, model serialization, Dio, role-based UI
- [ ] Preview Sesi 3 (Sabtu depan): backend Hono+Neon, login sungguhan, sesi persisten

---

## Checklist Kesiapan Instruktur
- [ ] Demo `session-2-final` jalan (siswa & guru screen)
- [ ] Mock API / endpoint siap untuk latihan Dio
- [ ] Slide: layer diagram, JSON→model mapping

## Common Pitfalls & Solusi
| Masalah | Solusi |
|---|---|
| fromJson error (null) | Jelaskan nullable vs non-nullable, `??` default |
| Dio timeout | Cek base URL, tambah `connectTimeout`/`receiveTimeout` |
| Provider not found | Pastikan `MultiProvider` di `main.dart` membungkus seluruh app |
| Peserta bingung layer | Analogi restoran: screen=meja, provider=pelayan, repo=dapur, model=menu |
