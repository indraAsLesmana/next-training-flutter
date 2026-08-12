# Sesi 1: Dart & Flutter Dasar — Dari `fvm flutter create` sampai Aplikasi Tugas Statis

## Info
- **Tanggal:** Sabtu, 15 Agustus (pagi 09:00–12:00, siang 13:00–15:00; break 12:00–13:00)
- **Mulai dari:** scaffold kosong (`fvm flutter create`)
- **Target akhir:** `session-1-final` (~340 LOC: main + model + provider + home screen + api service)
- **Branch pembanding:** `session-1-final`

## Hasil Akhir Sesi (peserta bisa)
- Menjelaskan widget tree, Stateless vs Stateful, dan dasar Dart (variabel, fungsi, class, async)
- Membuat UI task sederhana (ListView, Card, Checkbox) dengan data statis
- Memahami Provider (ChangeNotifier) sebagai pengelola state sederhana
- (Opsional) Paham alur HTTP dasar — `http` package untuk ambil data dari API

---

## Storyboard Menit-per-Menit

### BLOK PAGI (09:00–12:00) — Dart & Widget Dasar

#### 09:00–09:15 — Pembukaan & Ice-breaking
- [ ] Perkenalan singkat, tujuan 4 sesi, hasil akhir yang akan dicapai
- [ ] Tunjukkan **demo hasil akhir** (jalankan app `session-1-final`) — "ini yang akan kita bangun hari ini"
- [ ] Cek semua peserta sudah: Flutter SDK (FVM), VS Code, emulator/device siap
- [ ] Clone repo, checkout `session-1-start`

#### 09:15–09:45 — `fvm flutter create` & Struktur Project (30 min)
- [ ] Demo: `fvm flutter create --org com.flutter_training --platforms android,ios,web flutter_training`
- [ ] Jelaskan struktur folder: `lib/`, `android/`, `ios/`, `web/`, `pubspec.yaml`, `analysis_options.yaml`
- [ ] **Checkpoint:** semua berhasil `fvm flutter run` di emulator (counter app bawaan)
- [ ] Eksplorasi `main.dart` bawaan: `MyApp`, `MyHomePage`, `_incrementCounter`

#### 09:45–10:15 — Dart Dasar (30 min)
- [ ] Variabel: `var`, `final`, `const`, tipe data (`String`, `int`, `double`, `bool`, `List`, `Map`)
- [ ] Fungsi: parameter, return, arrow function `=>`
- [ ] Class: property, constructor, `this.`
- [ ] **Latihan kecil:** buat class `Task` sederhana (title, description, completed) di file terpisah
- [ ] **Checkpoint:** class `Task` dikompilasi tanpa error

#### 10:15–10:45 — Widget Dasar & Widget Tree (30 min)
- [ ] Apa itu widget tree — tampilkan visualisasi (tangkapan layar/whiteboard)
- [ ] `StatelessWidget` vs `StatefulWidget` — kapan pakai apa
- [ ] Widget umum: `Scaffold`, `AppBar`, `Text`, `Container`, `Row`, `Column`, `Padding`
- [ ] **Latihan:** modifikasi `MyApp` — ganti judul jadi "Aplikasi Pengumpulan Tugas", ubah warna tema
- [ ] **Checkpoint:** app menampilkan judul baru

#### 10:45–11:15 — Layout & ListView (30 min)
- [ ] `ListView.builder` — daftar dinamis
- [ ] `Card`, `ListTile`, `Checkbox`
- [ ] **Latihan:** tampilkan 3 task statis (hardcoded List<Task>) di ListView dengan Card
- [ ] **Checkpoint:** layar menampilkan 3 task dengan checkbox

#### 11:15–11:45 — State Sederhana: setState (30 min)
- [ ] `setState()` — mengubah data & rebuild UI
- [ ] **Latihan:** klik checkbox → coret judul task (TextDecoration.lineThrough)
- [ ] **Checkpoint:** checkbox bisa toggle strikethrough

#### 11:45–12:00 — Review Pagi (15 min)
- [ ] Recap: widget tree, Stateless/Stateful, ListView, setState
- [ ] Q&A singkat

---

### BREAK 12:00–13:00

---

### BLOK SIANG (13:00–15:00) — Provider, HTTP & Target Akhir

#### 13:00–13:30 — State Management: Provider (30 min)
- [ ] Kenapa setState tidak cukup untuk app besar? (state dibagi antar screen)
- [ ] `ChangeNotifier` + `ChangeNotifierProvider` + `Consumer`
- [ ] **Latihan:** pindahkan `List<Task>` ke `TaskProvider` (extends ChangeNotifier), tampilkan via `Consumer`
- [ ] **Checkpoint:** app tetap jalan, tapi state ada di provider

#### 13:30–14:00 — HTTP Dasar: `http` Package (30 min)
- [ ] Tambah dependency `http` di `pubspec.yaml`
- [ ] GET request, decode JSON, tampilkan di ListView
- [ ] **Latihan:** `ApiService` dengan method `fetchTasks()` (opsional — bisa mock/local)
- [ ] **Checkpoint:** app menampilkan data dari API (atau error state yang rapi)

#### 14:00–14:40 — Polish & Target Akhir (40 min)
- [ ] `RefreshIndicator` — pull-to-refresh
- [ ] Error state & empty state (tampilkan pesan ramah)
- [ ] Rapikan struktur: `models/`, `screens/`, `providers/`, `services/`
- [ ] **Checkpoint:** struktur folder sesuai `session-1-final`

#### 14:40–15:00 — Review, Merge & Penutup (20 min)
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
- [ ] Materi tambahan: slide/widget tree visual, contoh JSON response

## Common Pitfalls & Solusi
| Masalah | Solusi |
|---|---|
| `fvm flutter create` lambat | Siapkan cache/offline packages, atau pakai `flutter create` langsung |
| Peserta tertinggal | `git merge session-1-final` (tapi jelaskan dulu kodenya) |
| Emulator tidak muncul | Cek `fvm flutter doctor`, restart emulator |
| Error `provider` not found | `fvm flutter pub add provider` |
