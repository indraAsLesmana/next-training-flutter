# Requirements - Aplikasi Pengumpulan Tugas

Dokumen ini berisi spesifikasi kebutuhan aplikasi berdasarkan `scratch/app_idea.md`.

## Overview

**Aplikasi Pengumpulan Tugas** adalah sistem manajemen tugas berbasis mobile untuk sekolah SMK yang menghubungkan Guru dan Siswa. Aplikasi ini memungkinkan Guru membuat tugas untuk kelas tertentu, dan Siswa mengumpulkan tugas secara digital dengan tracking status pengumpulan.

**Tech Stack:** Flutter + Neon Functions (Serverless API) + PostgreSQL

---

## User Roles

Aplikasi memiliki dua role utama:

| Role | Identifikasi | Akses |
|------|--------------|-------|
| **Guru** | NIP | Create/manage tugas, view submissions |
| **Siswa** | NIK | View tugas, submit assignments |

---

## Screen Flow & Features

### Screen 1: Onboarding
- Welcome screen dengan pengenalan aplikasi
- Call-to-action untuk Register atau Sign In

### Screen 2: Register / Sign In

#### Registration Fields:
- **Nama** (required)
- **Role selection**: Guru / Siswa
- **Identifikasi**:
  - Jika Guru → **NIP Guru**
  - Jika Siswa → **NIK Siswa**
- **Kelas information**:
  - Jika Siswa → **Tingkat** selection [X, XI, XII] + **Nama kelas** selection [a, b, c, d]
  - Jika Guru → **Tingkat** selection [X, XI, XII] + **Nama kelas** selection [a, b, c, d]
- **Email** (optional)

#### Login:
- NIP/NIK + password (or email-based login)

### Screen 3: Home (Guru)

- **List tugas table** / empty screen
- **Add tugas** button dengan form:
  - Tingkat: selection [X, XI, XII]
  - Kelas: selection [a, b, c, d]
  - Description: free text
  - Due date: start and end date
  - Attachment URL: free public URL (can be file, image, or repo URL)
- View submission status per tugas

### Screen 3: Home (Siswa)

- **List tugas** untuk kelasnya
- Klik tugas → melihat:
  - Tugas description
  - Due date
  - Table who already submit and not (status pengumpulan)

---

## Future Features (Backlog)

- **Notification system** with topic-based broadcast
  - Subscribe by: Mata Pelajaran → Tingkat → Nama Kelas
  - Push notification untuk tugas baru atau deadline reminder

---

## Database Entities

1. **User** - Guru & Siswa dengan role-based fields
2. **Class** - Tingkat (X, XI, XII) + Section (a, b, c, d)
3. **Task** - Tugas dengan description, due date, attachment
4. **Submission** - Pengumpulan dari siswa dengan status tracking

---

## API Endpoints (Planned)

```
# Authentication
POST   /api/auth/register     → Register Guru/Siswa
POST   /api/auth/login        → Login

# Users
GET    /api/users/profile     → Get user profile

# Classes
GET    /api/classes           → Get all classes (Guru)
POST   /api/classes           → Create class (Guru)
GET    /api/classes/:id       → Get class details

# Tasks
GET    /api/tasks             → Get tasks (filter by class/grade)
POST   /api/tasks             → Create task (Guru only)
PUT    /api/tasks/:id         → Update task (Guru only)
DELETE /api/tasks/:id         → Delete task (Guru only)

# Submissions
POST   /api/tasks/:id/submit  → Submit assignment (Siswa)
GET    /api/tasks/:id/submissions → Get submission status
```
