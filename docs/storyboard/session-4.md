# Sesi 4: Workshop — Replikasi, Improvement & Q&A

## Info
- **Tanggal:** Minggu, 23 Agustus (pagi 09:00–12:00, siang 13:00–15:00; break 12:00–13:00)
- **Mulai dari:** `session-4-start` (= hasil sesi 3, app lengkap end-to-end)
- **Target akhir:** tidak ada target kode — ini sesi workshop
- **Branch pembanding:** — (gunakan `session-4-start` sebagai baseline)

## Tujuan Sesi 4
Peserta tidak lagi *mengikuti instruksi* — mereka **berkreasi**:
1. Mampu **mereplikasi** project dari nol (tanpa bantuan)
2. Mampu melakukan **improvement** (fitur baru, perbaikan)
3. Tanya-jawab terbuka & diskusi

---

## Storyboard Menit-per-Menit

### BLOK PAGI (09:00–12:00) — Replikasi & Improvement

#### 09:00–09:30 — Recap 3 Sesi (30 min)
- [ ] Recap cepat: apa yang dibangun di sesi 1-3 (alur: create → model → provider → Dio → backend → login)
- [ ] Tampilkan **struktur akhir** project (`session-4-start` tree) — peta lengkap
- [ ] Jelaskan alur end-to-end: register → login → buat tugas → kumpul → cek status

#### 09:30–11:00 — Challenge: Replikasi Mandiri (90 min)
- [ ] **Tantangan:** peserta *menutup* semua materi, coba buat ulang project dari `fvm flutter create`
- [ ] Instruktur hanya *memberi hint* jika macet (jangan kasih kode)
- [ ] Tingkat kesulitan bertahap:
  - Level 1: buat UI statis (ListView tugas + checkbox)
  - Level 2: tambah Provider + model
  - Level 3: tambah Dio + repository (panggil API)
  - Level 4: integrasi backend + login
- [ ] **Checkpoint 10:30:** siapa sudah sampai level 2?
- [ ] **Checkpoint 11:00:** siapa sudah level 3/4?

#### 11:00–11:45 — Improvement Session (45 min)
- [ ] **List improvement** (pilih 1-2 per peserta):
  - Tambah `DELETE /api/tasks/:id` + tombol hapus di UI
  - Validasi register (tolak NIP/NIK duplikat dengan pesan ramah)
  - Filter tugas berdasarkan status (belum/sudah dikumpulkan)
  - Search tugas (query param `?q=`)
  - Dark mode / tema custom
  - Pagination daftar tugas
- [ ] Peserta bekerja mandiri/berpasangan, instruktur berkeliling

#### 11:45–12:00 — Progress Check (15 min)
- [ ] Masing-masing peserta tunjukkan 1 improvement yang sedang dikerjakan
- [ ] Catat kendala umum → bahas di sesi Q&A siang

---

### BREAK 12:00–13:00

---

### BLOK SIANG (13:00–15:00) — Q&A & Penutupan

#### 13:00–14:00 — Q&A Terbuka (60 min)
- [ ] **Topik siap-siap:**
  - Deployment: cara deploy Flutter ke Play Store / web (Firebase Hosting, Netlify)
  - Backend: deploy Hono ke Neon Functions / Vercel / Railway
  - Testing: unit test, widget test, integration test (dasar)
  - State management lain: Riverpod, Bloc — kapan pilih yang mana
  - Git workflow: branch, PR, merge conflict
  - Debugging: DevTools, logging, hot reload
  - Performa: lazy loading, caching, image optimization
  - Cara lanjut belajar: roadmap Flutter developer
- [ ] Tampung pertanyaan peserta (bisa juga via sticky notes/mentimeter)

#### 14:00–14:30 — Demo Deploy (opsional) (30 min)
- [ ] Jika waktu & jaringan memungkinkan: demo deploy backend ke Neon Functions + Flutter web

#### 14:30–15:00 — Penutupan (30 min)
- [ ] Recap perjalanan 4 sesi
- [ ] Bagikan link materi: repo, docs online (ReadTheDocs), storyboard
- [ ] Feedback form / evaluasi
- [ ] Sertifikat / penutup

---

## Checklist Kesiapan Instruktur
- [ ] Siapkan daftar improvement (bisa print / slide)
- [ ] Siapkan jawaban Q&A (lihat daftar topik di atas)
- [ ] (Opsional) Demo deploy siap dijalankan
- [ ] Feedback form siap

## Tips
- Jangan terlalu banyak membantu di challenge replikasi — biarkan peserta *gagal dulu* (learning by doing)
- Untuk peserta cepat: kasih improvement lebih menantang (mis. filter + search sekaligus)
- Untuk peserta lambat: arahkan ke merge branch untuk mengejar, lalu fokus 1 improvement kecil
