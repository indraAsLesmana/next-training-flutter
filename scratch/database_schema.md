# Database Schema Documentation & ER Diagram

This document contains the complete database schema structure and Entity-Relationship (ER) diagram formatted in Mermaid for the Flutter Task Management application.

---

## Mermaid ER Diagram

```mermaid
erDiagram
    CLASSES ||--o{ USERS : "contains (role=siswa)"
    CLASSES ||--o{ TASKS : "assigned to"
    USERS ||--o{ TASKS : "creates (role=guru)"
    USERS ||--o{ SUBMISSIONS : "submits (role=siswa)"
    TASKS ||--o{ SUBMISSIONS : "has"
    SUBMISSIONS ||--o{ SUBMISSION_MEMBERS : "includes"
    USERS ||--o{ SUBMISSION_MEMBERS : "member of"

    CLASSES {
        uuid id PK "Primary Key"
        varchar tingkat "Tingkat kelas: X, XI, XII"
        varchar nama_kelas "Nama kelas: a, b, c, d"
        timestamp created_at "Timestamp pembuatan"
    }

    USERS {
        uuid id PK "Primary Key"
        varchar nama "Nama lengkap user"
        varchar role "Role user: 'guru' | 'siswa'"
        varchar nip_nik "Unique NIP/NIK"
        varchar email "Email user (Opsional)"
        text password_hash "Password hash / plain"
        uuid class_id FK "Foreign Key -> classes.id (Siswa Only)"
        timestamp created_at "Timestamp pendaftaran"
    }

    TASKS {
        uuid id PK "Primary Key"
        uuid guru_id FK "Foreign Key -> users.id (Guru)"
        uuid class_id FK "Foreign Key -> classes.id"
        text description "Deskripsi tugas"
        timestamp start_date "Tanggal & waktu mulai"
        timestamp end_date "Tenggat waktu pengumpulan"
        text attachment_url "Link file lampiran (Opsional)"
        boolean is_team_task "Flag tugas kelompok"
        integer max_team_members "Maksimal anggota per tim"
        timestamp created_at "Timestamp pembuatan"
    }

    SUBMISSIONS {
        uuid id PK "Primary Key"
        uuid task_id FK "Foreign Key -> tasks.id"
        uuid siswa_id FK "Foreign Key -> users.id (Siswa/Leader)"
        text submit_url "URL hasil tugas (Drive/GitHub)"
        text notes "Catatan tambahan (Opsional)"
        timestamp submitted_at "Waktu pengumpulan"
    }

    SUBMISSION_MEMBERS {
        uuid id PK "Primary Key"
        uuid submission_id FK "Foreign Key -> submissions.id"
        uuid siswa_id FK "Foreign Key -> users.id (Siswa Anggota)"
        timestamp created_at "Timestamp penambahan"
    }
```

---

## Detailed Table Dictionary

### 1. `classes` Table
Stores high school grade levels and class designations.
- **Constraints**: `UNIQUE(tingkat, nama_kelas)`

### 2. `users` Table
Stores both Teacher (`guru`) and Student (`siswa`) accounts.
- **Constraints**: `nip_nik` is UNIQUE. `class_id` references `classes(id)` ON DELETE SET NULL.

### 3. `tasks` Table
Stores tasks assigned by teachers to specific target classes.
- **Foreign Keys**: `guru_id` -> `users(id)`, `class_id` -> `classes(id)`.
- **Team Fields**: `is_team_task` (boolean), `max_team_members` (integer).

### 4. `submissions` Table
Stores student task submissions (individual or team leader submissions).
- **Foreign Keys**: `task_id` -> `tasks(id)`, `siswa_id` -> `users(id)`.

### 5. `submission_members` Table
Junction table mapping all group members participating in a team task submission.
- **Foreign Keys**: `submission_id` -> `submissions(id)`, `siswa_id` -> `users(id)`.
- **Constraints**: `UNIQUE(submission_id, siswa_id)`

---

## Optional Extension: `notifications` Table (Drafted)

```mermaid
erDiagram
    USERS ||--o{ NOTIFICATIONS : "receives"
    TASKS ||--o{ NOTIFICATIONS : "refers to"

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK "FK -> users.id"
        uuid task_id FK "FK -> tasks.id"
        varchar title
        text message
        boolean is_read
        timestamp created_at
    }
```
