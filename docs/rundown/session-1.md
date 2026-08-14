# Sesi 1: Perencanaan & Desain Aplikasi + Dart & Flutter Dasar

## Info
- **Tanggal:** Sabtu, 15 Agustus (pagi 09:30–12:00, siang 13:00–14:30; break 12:00–13:00)
- **Mulai dari:** scaffold kosong (`fvm flutter create`)
- **Target akhir:** `session-1-final` (~340 LOC: main + model + provider + home screen + api service)
- **Branch pembanding:** `session-1-final`
- **Materi pembuka:** [Perencanaan & Desain Aplikasi](planning) — walk through 30 menit (09:40–10:10)

## Hasil Akhir Sesi (peserta bisa)
- Menjelaskan **gambaran aplikasi**: alur pengguna, arsitektur Flutter↔Hono↔Neon, dan ERD 5 tabel
- Menjelaskan widget tree, Stateless vs Stateful, dan dasar Dart (variabel, fungsi, class, async)
- Membuat UI task sederhana (ListView, Card, Checkbox) dengan data statis
- Memahami Provider (ChangeNotifier) sebagai pengelola state sederhana
- (Opsional) Paham alur HTTP dasar — `http` package untuk ambil data dari API

---

## Rundown Menit-per-Menit

### BLOK PAGI (09:30–12:00) — Perencanaan, Dart & Widget Dasar

#### 09:30–09:40 — Pembukaan & Ice-breaking (10 min)
- [ ] Perkenalan singkat, tujuan 4 sesi, hasil akhir yang akan dicapai
- [ ] Tunjukkan **demo hasil akhir** (jalankan app `session-1-final`) — "ini yang akan kita bangun hari ini"
- [ ] Cek semua peserta sudah: Flutter SDK (FVM), VS Code, emulator/device siap
- [ ] Clone repo, checkout `session-1-start`

#### 09:40–10:10 — Perencanaan & Desain Aplikasi (30 min)
> Walk through halaman [Perencanaan & Desain Aplikasi](planning) secara live (buka di RTD/browser) — ini memberi peserta **gambaran besar** sebelum mulai coding.
- [ ] **Gambaran Proyek** — Aplikasi Pengumpulan Tugas: role Guru (NIP) & Siswa (NIK), fitur (kelas, tugas, pengumpulan URL, tugas kelompok)
- [ ] **Alur Pengguna** — tunjukkan diagram mermaid flowchart: daftar → login → dashboard (role) → buat tugas → kumpulkan → cek status
- [ ] **Arsitektur Aplikasi** — diagram mermaid: Flutter ↔ Hono API ↔ Neon PostgreSQL; jelaskan peran tiap layer
- [ ] **ERD Database** — diagram mermaid 5 tabel (classes, users, tasks, submissions, submission_members); jelaskan relasi & onDelete (SET NULL vs CASCADE)
- [ ] **Ringkasan API** — tabel endpoint (register, login, classes, tasks, submissions) — *hanya preview*, detail di Sesi 3
- [ ] **Peta 4 Sesi & Branch** — jadwal 2 hari, branch start/final, cara `git merge` mengejar ketertinggalan
- [ ] **Checkpoint:** peserta bisa menjawab "apa yang akan kita bangun?" & "data apa saja yang disimpan?" (tanya 2-3 peserta)

#### 10:10–10:35 — `fvm flutter create` & Struktur Project (25 min)
- [ ] Demo: `fvm flutter create --org com.flutter_training --platforms android,ios,web flutter_training`
- [ ] Jelaskan struktur folder: `lib/`, `android/`, `ios/`, `web/`, `pubspec.yaml`, `analysis_options.yaml`
- [ ] **Checkpoint:** semua berhasil `fvm flutter run` di emulator (counter app bawaan)
- [ ] Eksplorasi `main.dart` bawaan: `MyApp`, `MyHomePage`, `_incrementCounter`

#### 10:35–11:00 — Dart Dasar (25 min)
- [ ] Variabel: `var`, `final`, `const`, tipe data (`String`, `int`, `double`, `bool`, `List`, `Map`)
- [ ] Fungsi: parameter, return, arrow function `=>`
- [ ] Class: property, constructor, `this.`
- [ ] **Latihan kecil:** buat class `Task` sederhana (title, description, completed) di file terpisah
- [ ] **Checkpoint:** class `Task` dikompilasi tanpa error

#### 11:00–11:25 — Widget Dasar & Widget Tree (25 min)
- [ ] Apa itu widget tree — tampilkan visualisasi (tangkapan layar/whiteboard)
- [ ] `StatelessWidget` vs `StatefulWidget` — kapan pakai apa
- [ ] Widget umum: `Scaffold`, `AppBar`, `Text`, `Container`, `Row`, `Column`, `Padding`
- [ ] **Latihan:** modifikasi `MyApp` — ganti judul jadi "Aplikasi Pengumpulan Tugas", ubah warna tema
- [ ] **Checkpoint:** app menampilkan judul baru

#### 11:25–11:50 — Layout & ListView (25 min)
- [ ] `ListView.builder` — daftar dinamis
- [ ] `Card`, `ListTile`, `Checkbox`
- [ ] **Latihan:** tampilkan 3 task statis (hardcoded List<Task>) di ListView dengan Card
- [ ] **Checkpoint:** layar menampilkan 3 task dengan checkbox

#### 11:50–12:00 — Review Pagi (10 min)
- [ ] Recap: gambaran aplikasi, widget tree, Stateless/Stateful, ListView, setState
- [ ] Q&A singkat

---

### BREAK 12:00–13:00

---

### BLOK SIANG (13:00–14:30) — setState, Provider, HTTP & Target Akhir

#### 13:00–13:15 — State Sederhana: setState (15 min)
- [ ] `setState()` — mengubah data & rebuild UI
- [ ] **Latihan:** klik checkbox → coret judul task (TextDecoration.lineThrough)
- [ ] **Checkpoint:** checkbox bisa toggle strikethrough

#### 13:15–13:40 — State Management: Provider (25 min)
- [ ] Kenapa setState tidak cukup untuk app besar? (state dibagi antar screen)
- [ ] `ChangeNotifier` + `ChangeNotifierProvider` + `Consumer`
- [ ] **Latihan:** pindahkan `List<Task>` ke `TaskProvider` (extends ChangeNotifier), tampilkan via `Consumer`
- [ ] **Checkpoint:** app tetap jalan, tapi state ada di provider

#### 13:40–14:00 — HTTP Dasar: `http` Package (20 min)
- [ ] Tambah dependency `http` di `pubspec.yaml`
- [ ] GET request, decode JSON, tampilkan di ListView
- [ ] **Latihan:** `ApiService` dengan method `fetchTasks()` (opsional — bisa mock/local)
- [ ] **Checkpoint:** app menampilkan data dari API (atau error state yang rapi)

#### 14:00–14:15 — Polish & Target Akhir (15 min)
- [ ] `RefreshIndicator` — pull-to-refresh
- [ ] Error state & empty state (tampilkan pesan ramah)
- [ ] Rapikan struktur: `models/`, `screens/`, `providers/`, `services/`
- [ ] **Checkpoint:** struktur folder sesuai `session-1-final`

#### 14:15–14:30 — Review, Merge & Penutup (15 min)
- [ ] Bandingkan dengan `session-1-final`:
  ```bash
  git merge session-1-final   # (atau git diff untuk lihat perbedaan)
  ```
- [ ] Recap seluruh sesi 1
- [ ] Preview Sesi 2 (besok): re-arch, Dio, model lengkap
- [ ] Q&A & penutup

---

## Checklist Kesiapan Instruktur (sebelum sesi)
- [ ] Demo app `session-1-final` sudah bisa dijalankan di emulator
- [ ] Semua peserta sudah clone repo & checkout `session-1-start`
- [ ] Network stabil (untuk `fvm flutter create` download packages)
- [ ] Halaman **Perencanaan & Desain Aplikasi** (`planning.md`) terbuka di RTD/browser untuk blok 09:40
- [ ] Materi tambahan: slide/widget tree visual, contoh JSON response

## Common Pitfalls & Solusi
| Masalah | Solusi |
|---|---|
| `fvm flutter create` lambat | Siapkan cache/offline packages, atau pakai `flutter create` langsung |
| Peserta tertinggal | `git merge session-1-final` (tapi jelaskan dulu kodenya) |
| Emulator tidak muncul | Cek `fvm flutter doctor`, restart emulator |
| Error `provider` not found | `fvm flutter pub add provider` |
