# Rundown Pelatihan — 4 Sesi (2 Hari)

> **Cara pakai:** Rundown ini adalah **panduan mengajar menit-per-menit** (seperti naskah film/sutradara). Setiap sesi punya blok waktu, apa yang *Anda demonstrasikan*, apa yang *peserta ketik*, checkpoint ("layar harus menampilkan X"), dan branch pembanding.

## Jadwal & Tanggal

| Hari | Tanggal | Sesi | Jam | Materi |
|---|---|---|---|---|
| Sabtu | **15 Agustus** | Sesi 1 | 09:00–15:00 | Perencanaan & Desain Aplikasi + Dart & Flutter dasar |
| Minggu | **16 Agustus** | Sesi 2 | 09:00–15:00 | State management, HTTP, re-arch project |
| Sabtu | **22 Agustus** | Sesi 3 | 09:00–15:00 | Backend Hono+Neon, Dio, login |
| Minggu | **23 Agustus** | Sesi 4 | 09:00–15:00 | Workshop: replikasi, improvement, Q&A |

> Break **12:00–13:00** (1 jam). Jam efektif mengajar **4 jam per sesi** (09:00–12:00 pagi + 13:00–15:00 siang).

## Topologi Branch (rantai hasil akhir)

```
session-1-start ──► session-1-final ──► session-2-start ──► session-2-final
                                                                     │
session-3-start ◄── session-2-final ◄── (chained)                   │
session-3-final ──► session-4-start ──► session-4-final
```

| Branch | Isi | Untuk Sesi |
|---|---|---|
| `session-1-start` | Scaffold `fvm flutter create` (kosong) | 1 — mulai dari nol |
| `session-1-final` | App minimal: main + task model + provider + home screen + api service (~340 LOC) | 1 — target akhir |
| `session-2-start` | = session-1-final | 2 |
| `session-2-final` | Re-arch penuh: Dio, model, repo, provider, screens (~1,120 LOC) | 2 — target akhir |
| `session-3-start` | = session-2-final | 3 |
| `session-3-final` | + login screen + timeout (backend-ready) | 3 — target akhir |
| `session-4-start` | = session-3-final | 4 — workshop |
| `session-4-final` | = session-3-final (tidak ada target kode) | 4 — workshop |

## Aturan Emas Mengajar

1. **Demo dulu, ketik setelah** — selalu tunjukkan hasil akhir dulu, baru jelaskan cara membuatnya.
2. **Checkpoint setiap 20-30 menit** — "semua orang harus melihat layar X sekarang".
3. **Jangan pernah menulis kode untuk peserta** — tunjukkan, jelaskan, biarkan mereka mengetik.
4. **Gunakan branch pembanding** — jika peserta tertinggal, `git merge session-X-final` untuk mengejar.
5. **Break 12:00–13:00** — jadwal mengajar menyesuaikan (blok pagi 09:00–12:00, blok siang 13:00–15:00).

---

## Ringkasan Per Sesi

- [**Sesi 1**](session-1.md) — Perencanaan & Desain Aplikasi + Dart & Flutter dasar, widget tree, dari `fvm flutter create` sampai app tugas statis (09:00–12:00, 13:00–15:00)
- [**Sesi 2**](session-2.md) — State management (Provider), HTTP (http package), re-arch ke struktur model/repo/provider/screens (09:00–12:00, 13:00–15:00)
- [**Sesi 3**](session-3.md) — Backend Hono+Neon, Dio client, repository, login (09:00–12:00, 13:00–15:00)
- [**Sesi 4**](session-4.md) — Workshop: replikasi project, improvement, Q&A (09:00–12:00, 13:00–15:00)
