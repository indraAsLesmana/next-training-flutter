# Perencanaan & Desain Aplikasi

> **Tujuan bagian ini:** Sebelum mulai coding di Session 1 dan Session 2, kita melihat *gambaran besar*: aplikasi apa yang akan dibangun, bagaimana alur penggunaannya, arsitektur sistemnya, dan bagaimana data disimpan di database.

## 1. Gambaran Proyek

Kita akan membangun **Aplikasi Pengumpulan Tugas** — aplikasi mobile (Flutter) untuk sekolah yang menghubungkan **Guru** dan **Siswa**:

| Fitur | Keterangan |
|---|---|
| Role-based authentication | Dua peran: **Guru** (NIP) dan **Siswa** (NIK) |
| Manajemen kelas | Tingkat X, XI, XII dengan section a, b, c, d |
| Pembuatan tugas | Guru membuat tugas untuk kelas tertentu (dengan tanggal mulai/selesai) |
| Pengumpulan tugas | Siswa mengumpulkan melalui URL + catatan |
| Tugas kelompok | Opsi tugas tim (maksimal anggota diatur guru) |
| Tracking status | Status "sudah/belum dikumpulkan" per siswa |

## 2. Alur Pengguna

```{mermaid}
flowchart LR
    A[Daftar: Guru NIP / Siswa NIK] --> B[Login NIP/NIK + Password]
    B --> C{Role?}
    C -->|guru| D[Dashboard Guru]
    C -->|siswa| E[Dashboard Siswa]
    D --> F[Buat Tugas untuk Kelas]
    F --> G[Siswa melihat tugas]
    E --> H[Kumpulkan Tugas: URL + catatan + anggota tim]
    H --> I[Guru cek status pengumpulan]
```

## 3. Arsitektur Aplikasi

```{mermaid}
flowchart LR
    F[Flutter App<br/>flutter_training/] -->|HTTP / JSON| A[Hono API<br/>flutter-task-api/]
    A --> D[(Neon PostgreSQL<br/>5 tabel)]
    F --> S[SharedPreferences<br/>sesi login lokal]
```

- **Flutter** (client) — UI, state management (Provider), HTTP client (Dio)
- **Hono API** (backend) — REST endpoint, validasi, query database
- **Neon PostgreSQL** (database) — serverless, penyimpanan data
- **SharedPreferences** — menyimpan sesi login agar tidak perlu login ulang

## 4. ERD Database

Lima tabel (definisi lengkap: `flutter-task-api/src/db/schema.ts`):

```{mermaid}
erDiagram
    CLASSES ||--o{ USERS : "class_id"
    CLASSES ||--o{ TASKS : "class_id"
    USERS ||--o{ TASKS : "guru_id"
    TASKS ||--o{ SUBMISSIONS : "task_id"
    USERS ||--o{ SUBMISSIONS : "siswa_id"
    SUBMISSIONS ||--o{ SUBMISSION_MEMBERS : "submission_id"
    USERS ||--o{ SUBMISSION_MEMBERS : "siswa_id"

    CLASSES {
        uuid id PK
        varchar tingkat "X, XI, XII"
        varchar nama_kelas "a, b, c, d"
        timestamp created_at
    }

    USERS {
        uuid id PK
        varchar nama
        varchar role "guru | siswa"
        varchar nip_nik UK
        varchar email
        text password_hash
        uuid class_id FK
        timestamp created_at
    }

    TASKS {
        uuid id PK
        uuid guru_id FK
        uuid class_id FK
        text description
        timestamp start_date
        timestamp end_date
        text attachment_url
        boolean is_team_task
        integer max_team_members
        timestamp created_at
    }

    SUBMISSIONS {
        uuid id PK
        uuid task_id FK
        uuid siswa_id FK
        text submit_url
        text notes
        timestamp submitted_at
    }

    SUBMISSION_MEMBERS {
        uuid id PK
        uuid submission_id FK
        uuid siswa_id FK
        timestamp created_at
    }
```

**Relasi & perilaku hapus (onDelete):**

| Relasi | Jenis | onDelete |
|---|---|---|
| `classes` → `users.class_id` | one-to-many | `SET NULL` (kelas dihapus, siswa tetap ada) |
| `classes` → `tasks.class_id` | one-to-many | `CASCADE` |
| `users` → `tasks.guru_id` | one-to-many | `CASCADE` (guru dihapus, tugas ikut hapus) |
| `tasks` → `submissions.task_id` | one-to-many | `CASCADE` |
| `users` → `submissions.siswa_id` | one-to-many | `CASCADE` |
| `submissions` → `submission_members.submission_id` | one-to-many | `CASCADE` |
| `users` → `submission_members.siswa_id` | one-to-many | `CASCADE` |

> **Catatan penting:** Perhatikan perbedaan `SET NULL` (users.class_id) vs `CASCADE` (lainnya) — ini menunjukkan keputusan desain: *kelas bisa dihapus tanpa menghapus siswanya*, tapi *menghapus guru/tugas akan menghapus data turunannya*.

## 5. Ringkasan API

Semua endpoint di `flutter-task-api/src/index.ts` (detail di Session 2):

| Method | Endpoint | Fungsi |
|---|---|---|
| `POST` | `/api/auth/register` | Daftar guru/siswa |
| `POST` | `/api/auth/login` | Login NIP/NIK + password |
| `GET` | `/api/classes` | Ambil daftar kelas |
| `GET` | `/api/students/search` | Cari siswa dalam kelas |
| `GET` | `/api/tasks` | List tugas (filter kelas/guru/siswa) |
| `POST` | `/api/tasks` | Guru membuat tugas |
| `POST` | `/api/submissions` | Siswa mengumpulkan tugas |
| `GET` | `/api/tasks/:id/submissions` | Status pengumpulan per siswa |

## 6. Peta 2 Sesi & Branch

| Sesi | Fokus | Hasil Akhir | Branch |
|---|---|---|---|
| **Setup** | Install toolchain (FVM, VS Code, Android Studio) + akun Neon | Environment siap | — |
| **Session 1** | Dart, widget, UI dashboard siswa | Aplikasi statis tanpa backend | `session-1-start` → `session-1-final` |
| **Session 2** | Hono API, Dio, Provider | Aplikasi lengkap end-to-end | `session-2-start` → `session-2-final` |

---

**Setelah memahami gambaran ini, kita siap mulai membangun — lanjut ke [Session 1](session-1).**
