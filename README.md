# Aplikasi Pengumpulan Tugas dengan Flutter & Neon Database

## Overview
Training program untuk guru SMK tentang pengembangan aplikasi mobile dengan Flutter dan koneksi ke database cloud PostgreSQL menggunakan Neon. Program ini dirancang untuk memberikan pengalaman langsung membangun aplikasi pengumpulan tugas yang dapat digunakan di sekolah.

## Target Audience
- Guru SMK jurusan RPL/TKJ
- Peserta: 3-4 orang per sesi
- Platform: Windows & macOS
- Level: Beginner to Intermediate

## Aplikasi Contoh
**Aplikasi Pengumpulan Tugas dengan Neon Database** - Sistem manajemen tugas berbasis role (Guru/Siswa) yang terhubung ke database cloud PostgreSQL di Neon.

## Fitur Utama
- ✅ Role-based authentication (Guru/Siswa)
- ✅ Registration dengan NIP (Guru) dan NIK (Siswa)
- ✅ Management kelas dan tingkat (X, XI, XII dengan section a,b,c,d)
- ✅ Sistem pengumpulan tugas dengan attachment URL
- ✅ Tracking submission status (sudah/belum kumpul)
- ✅ Dukungan tugas kelompok (team task) dengan anggota tim
- ✅ Koneksi ke Neon PostgreSQL
- ✅ State management dengan Provider
- ✅ REST API integration dengan Dio

## Struktur Training (2 Sesi x 4 Jam)

Training disusun dalam **2 sesi pertemuan, masing-masing 4 jam**, membangun aplikasi nyata di folder `flutter_training/` (mobile) dan `flutter-task-api/` (backend):

1. **Session 1: Dasar Flutter & Dashboard Siswa (4 Jam)**
   - Dart essentials: null-safety, class, factory constructor
   - Widget & layout Flutter: Stateless/Stateful, BuildContext
   - Membangun UI dashboard siswa (login, list tugas, empty state)
   - Hasil: aplikasi statis tanpa backend

2. **Session 2: Backend API, Dio & Provider (4 Jam)**
   - REST API dengan Hono + Drizzle + Neon Functions
   - Schema database 5 tabel (classes, users, tasks, submissions, submission_members)
   - Dio client & repository pattern di Flutter
   - State management dengan Provider (Auth, School, Task)
   - Hasil: aplikasi lengkap end-to-end (register → login → buat tugas → kumpulkan)

### Branch Workflow per Sesi

Setiap sesi memiliki branch **sebelum** (start) dan **sesudah** (final) pengerjaan, sehingga peserta bisa membandingkan hasil dan mengejar ketertinggalan:

| Branch | Isi | Untuk |
|---|---|---|
| `session-1-start` | Skeleton project sebelum Session 1 | Peserta clone & mulai coding |
| `session-1-final` | Hasil akhir Session 1 (dashboard statis) | Referensi / diff / merge |
| `session-2-start` | = `session-1-final` (lanjutan) | Peserta clone & mulai coding |
| `session-2-final` | Aplikasi lengkap (setara `build-project`) | Referensi / diff / merge |

Alur per sesi: peserta bekerja dari branch `start`, lalu di akhir sesi membandingkan dengan `git diff` dan mengambil hasil referensi dengan `git merge <branch-final>`.

## Teknologi Stack
- **Frontend:** Flutter 3.x (Dart) + Provider + Dio
- **Backend:** Hono + Drizzle ORM di Neon Functions
- **Database:** Neon PostgreSQL (serverless)
- **Tools:** VS Code, Android Studio, Postman, FVM

## Setup Requirements

### Untuk Peserta:
1. Laptop Windows/macOS dengan Flutter SDK terinstall (via FVM)
2. VS Code atau Android Studio
3. Akun Neon (gratis) — buat project di region `aws-us-east-2` (satu-satunya region yang mendukung Neon Functions)
4. Git untuk version control
5. Node.js >= 20 (untuk backend di Session 2)

### Untuk Instruktur:
1. Contoh kode lengkap (Flutter + Backend) di branch `build-project`
2. Database schema ready (Drizzle + migration)
3. Environment variables template (`.env.example`)
4. Slide presentasi per session

## Struktur Proyek
```text
next-training-flutter/
├── flutter_training/           # Aplikasi Flutter (mobile)
│   └── lib/
│       ├── main.dart           # Entry point + MultiProvider + routing role
│       ├── core/
│       │   ├── network/        # dio_client.dart, api_response.dart
│       │   └── utils/          # url_launcher_utils.dart
│       ├── models/             # user_model, task_model, class_model, submission_model
│       ├── providers/          # auth_provider, school_provider, task_provider
│       ├── repositories/       # auth_repository, school_repository, task_repository
│       ├── screens/
│       │   ├── auth/           # login_screen, register_screen
│       │   ├── guru/           # teacher_home_screen, task_detail_screen
│       │   └── siswa/          # student_home_screen
│       └── widgets/            # empty_state_widget
├── flutter-task-api/           # Backend API (Hono + Drizzle + Neon)
│   └── src/
│       ├── index.ts            # Semua routes API
│       └── db/                 # schema.ts, seed.ts, reset.ts, client.ts
└── docs/                       # Dokumentasi ReadTheDocs (Sphinx + MyST)
    ├── index.md
    ├── setup.md
    ├── session-1.md
    └── session-2.md
```

## Database Schema

5 tabel (definisi lengkap di `flutter-task-api/src/db/schema.ts`, migration di `flutter-task-api/drizzle/`):

```text
classes 1───* users 1───* tasks 1───* submissions 1───* submission_members
                       │                                  │
                       └────────── users (team members) ──┘
```

- **classes**: `id`, `tingkat` (X/XI/XII), `nama_kelas` (a-d)
- **users**: `id`, `nama`, `role` (guru/siswa), `nip_nik` (unique), `email`, `password_hash`, `class_id` (FK)
- **tasks**: `id`, `guru_id` (FK), `class_id` (FK), `description`, `start_date`, `end_date`, `attachment_url`, `is_team_task`, `max_team_members`
- **submissions**: `id`, `task_id` (FK), `siswa_id` (FK), `submit_url`, `notes`, `submitted_at`
- **submission_members**: `id`, `submission_id` (FK), `siswa_id` (FK)

## API Endpoints

Semua endpoint di `flutter-task-api/src/index.ts`, response berbentuk `{ success, data }`:

```text
# Authentication
POST    /api/auth/register      → Daftar guru (NIP) / siswa (NIK + kelas)
POST    /api/auth/login         → Login dengan NIP/NIK + password

# Classes
GET     /api/classes            → Ambil semua kelas

# Students
GET     /api/students/search    → Cari siswa dalam kelas (query: classId, query)

# Tasks
GET     /api/tasks              → List tugas (filter: classId, guruId, siswaId)
POST    /api/tasks              → Guru membuat tugas baru

# Submissions
POST    /api/submissions        → Siswa kumpulkan/update tugas (support team)
GET     /api/tasks/:id/submissions → Guru lihat status pengumpulan per siswa
```

## Quick Start Guide

### 🖥️ **Setup Environment (Modern Approach)**

```{tabs}
```{tab} Windows (Chocolatey + FVM)
```powershell
# Run PowerShell as Administrator
# 1. Install Chocolatey package manager
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Install all tools in one command
choco install fvm git vscode androidstudio -y

# 3. Setup Flutter SDK via FVM
fvm install stable
fvm global stable

# 4. Add to PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\fvm\default\bin", "User")
```

```{tab} macOS (Homebrew + FVM)
```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install tools via Homebrew
brew install git fvm cocoapods scrcpy
brew install --cask visual-studio-code android-studio google-chrome

# 3. Setup Flutter SDK via FVM
fvm install stable
fvm global stable

# 4. Add to shell PATH
echo 'export PATH="$HOME/fvm/default/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
```

> Panduan setup lengkap (toolchain, Android Studio, VS Code, akun Neon) ada di `docs/setup.md`.

### 🛠️ **Verifikasi Setup**
```bash
# Setup Android SDK Command-line Tools melalui Android Studio
# Kemudian jalankan:
fvm flutter doctor --android-licenses
fvm flutter doctor -v
```

### 🗄️ **Setup Neon Database & Functions**
1. Buat akun di [neon.tech](https://neon.tech)
2. Buat project baru `tugas_db` — **region wajib `aws-us-east-2`** (satu-satunya region yang mendukung Neon Functions)
3. Push schema via Drizzle: `npm run db:push` (di folder `flutter-task-api/`)
4. Seed data kelas: `npm run db:seed`
5. Buat file konfig `config_dev.json` / `config_prod.json` untuk `API_BASE_URL` aplikasi Flutter

### 🚀 **Create & Run App**
```bash
# Clone repository
git clone https://github.com/indraAsLesmana/next-training-flutter.git
cd next-training-flutter

# Jalankan aplikasi Flutter (di folder flutter_training)
fvm flutter pub get
fvm flutter run --dart-define-from-file=config_dev.json   # Development (local API)
fvm flutter run --dart-define-from-file=config_prod.json  # Production (Neon cloud)

# Jalankan backend Hono (di folder flutter-task-api)
npm install
npm run db:push
npm run db:seed
npm run dev
```

## Dokumentasi Lengkap
Lihat folder `docs/` untuk dokumentasi detail, atau kunjungi [dokumentasi online](https://next-training-flutter.readthedocs.io):

- `setup.md` - Setup lengkap toolchain (FVM, Android Studio, VS Code) + akun Neon
- `planning.md` - Perencanaan & desain aplikasi (alur pengguna, arsitektur, ERD database)
- `session-1.md` - Materi Session 1: Dasar Flutter & Dashboard Siswa (4 jam)
- `session-2.md` - Materi Session 2: Backend API, Dio & Provider (4 jam)

### 📖 **Menjalankan ReadTheDocs Secara Lokal (Python & Sphinx)**

```bash
# 1. Install dependensi Sphinx
pip install -r docs/requirements.txt

# 2. Build HTML documentation dari folder docs
sphinx-build -b html docs docs/_build/html

# 3. Jalankan HTTP Server lokal dengan Python
python3 -m http.server 8000 --directory docs/_build/html
```
Buka browser di **`http://localhost:8000`** untuk melihat preview dokumentasi lokal.

> **Tip Live-Reload**: Anda juga bisa menggunakan `sphinx-autobuild` untuk auto-refresh saat mengedit file `.md`:
> ```bash
> pip install sphinx-autobuild
> sphinx-autobuild docs docs/_build/html
> ```

## Support & Resources
- **Dokumentasi Online**: https://next-training-flutter.readthedocs.io
- **GitHub Repository**: https://github.com/indraAsLesmana/next-training-flutter
- **Untuk SMK Labs**: Gunakan strategi offline kit dan scrcpy untuk testing di lab sekolah

## License
Training materials ini tersedia untuk tujuan edukasi.
