# Session 4: Workshop — Replikasi, Improvement & Q&A

> **Hari 4 — Minggu, 23 Agustus** (09:00–12:00 pagi, 13:00–15:00 siang, break 12:00–13:00)

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-4-start`** (= hasil akhir `session-3-final`)
> - **Tidak ada target kode** — ini sesi workshop
> - Referensi lengkap: **`session-4-final`** (aplikasi lengkap end-to-end)

## Tujuan Sesi 4
Peserta tidak lagi *mengikuti instruksi* — mereka **berkreasi**:
1. Mampu **mereplikasi** project dari nol (tanpa bantuan)
2. Mampu melakukan **improvement** (fitur baru, perbaikan)
3. Tanya-jawab terbuka & diskusi

## Agenda (4 jam efektif)
1. Recap 3 sesi & peta lengkap project (30 menit)
2. Challenge: replikasi mandiri (90 menit)
3. Improvement session (45 menit)
4. Q&A terbuka (60 menit)
5. Penutupan (15 menit)

---

## 1. Recap 3 Sesi (09:00–09:30)

**Perjalanan yang sudah dilalui:**

| Sesi | Yang dibangun | Hasil |
|---|---|---|
| 1 | `fvm flutter create` → app tugas minimal (Dart, widget, Provider, http) | App statis |
| 2 | Re-arch berlapis: models, repositories, providers, screens + Dio | Arsitektur bersih |
| 3 | Backend Hono+Neon (5 tabel), login, session persist | App end-to-end |

**Alur end-to-end yang sudah jadi:**
```text
Register → Login → Dashboard (role) → Buat tugas → Kumpulkan → Cek status
```

**Struktur akhir (`session-4-final`):**
```text
lib/
├── main.dart                    # DI + MultiProvider + role routing
├── core/network/                # DioClient, ApiResponse
├── models/                      # TaskModel, UserModel, ClassModel, SubmissionModel
├── providers/                   # AuthProvider, SchoolProvider, TaskProvider
├── repositories/                # AuthRepository, SchoolRepository, TaskRepository
└── screens/
    ├── auth/                    # login, register
    ├── guru/                    # teacher home
    └── siswa/                   # student home
```

---

## 2. Challenge: Replikasi Mandiri (09:30–11:00)

**Tantangan:** tutup semua materi, buat ulang project dari `fvm flutter create` — **hanya dengan hint dari instruktur, tanpa kode jadi**.

### Tingkat Kesulitan Bertahap

| Level | Target | Perkiraan Waktu |
|---|---|---|
| **1** | UI statis: ListView tugas + Checkbox (data hardcoded) | 20 menit |
| **2** | + Model `Task` + `TaskProvider` (ChangeNotifier) | 20 menit |
| **3** | + `DioClient` + `TaskRepository` (panggil API) | 25 menit |
| **4** | + Backend integration + login (NIP/NIK + password) | 25 menit |

### Aturan untuk Instruktur
- Beri **hint** (arah, konsep, "coba cek `session-2-final`"), jangan kasih kode
- Biarkan peserta *gagal dulu* — learning by doing
- **Checkpoint 10:30:** siapa sudah level 2?
- **Checkpoint 11:00:** siapa sudah level 3/4?

### Untuk Peserta yang Macet
```bash
# Bandingkan dengan referensi
git diff session-4-start -- flutter_training/lib

# Lihat file referensi tertentu
git show session-4-final:flutter_training/lib/providers/task_provider.dart

# Atau ambil seluruh folder referensi
git checkout session-4-final -- flutter_training/
```

---

## 3. Improvement Session (11:00–11:45)

Pilih **1-2 improvement** per peserta (atau berpasangan), kerjakan mandiri:

| # | Improvement | Level | File utama |
|---|---|---|---|
| 1 | Tambah `DELETE /api/tasks/:id` + tombol hapus di UI | Mudah | `task_repository.dart`, `teacher_home_screen.dart` |
| 2 | Validasi register: tolak NIP/NIK duplikat (status 409) + pesan ramah | Mudah | `register_screen.dart`, `auth_repository.dart` |
| 3 | Filter tugas berdasarkan status (belum/sudah dikumpulkan) | Sedang | `student_home_screen.dart`, `task_provider.dart` |
| 4 | Search tugas (query param `?q=`) | Sedang | `index.ts`, `task_repository.dart` |
| 5 | Dark mode / tema custom | Sedang | `main.dart`, `theme.dart` |
| 6 | Pagination daftar tugas | Sulit | `index.ts`, `task_provider.dart` |
| 7 | Halaman detail tugas (tap → lihat deskripsi & link) | Mudah | `student_home_screen.dart` |

### Progress Check (11:45–12:00)
- Masing-masing peserta tunjukkan 1 improvement yang sedang dikerjakan
- Catat kendala umum → bahas di sesi Q&A siang

---

### BREAK 12:00–13:00

---

## 4. Q&A Terbuka (13:00–14:00)

### Topik yang Siap Dibahas

| Topik | Poin |
|---|---|
| **Deployment** | Flutter → Play Store / web (Firebase Hosting, Netlify) |
| **Backend deploy** | Hono → Neon Functions / Vercel / Railway |
| **Testing** | Unit test, widget test, integration test (dasar) |
| **State management lain** | Riverpod, Bloc — kapan pilih yang mana |
| **Git workflow** | Branch, PR, merge conflict |
| **Debugging** | DevTools, logging, hot reload |
| **Performa** | Lazy loading, caching, image optimization |
| **Roadmap belajar** | Lanjutan setelah Flutter dasar |

### Demo Deploy (opsional, 14:00–14:30)
Jika waktu & jaringan memungkinkan: demo deploy backend ke **Neon Functions** + Flutter web.

---

## 5. Penutupan (14:45–15:00)

- Recap perjalanan 4 sesi
- Bagikan link materi: repo, docs online (ReadTheDocs), rundown
- Feedback form / evaluasi
- Sertifikat / penutup

---

## Checklist Kesiapan Instruktur
- [ ] Daftar improvement siap (print / slide)
- [ ] Jawaban Q&A siap (lihat tabel topik)
- [ ] (Opsional) Demo deploy siap dijalankan
- [ ] Feedback form siap

## Tips Mengajar
- Jangan terlalu banyak membantu di challenge replikasi — biarkan peserta *gagal dulu*
- Peserta cepat: kasih improvement lebih menantang (mis. filter + search sekaligus)
- Peserta lambat: arahkan ke `git checkout session-4-final -- flutter_training/` untuk mengejar, lalu fokus 1 improvement kecil
