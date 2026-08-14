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

## Struktur Training (4 Sesi x 4 Jam — 2 Hari)

Training disusun dalam **4 sesi pertemuan, masing-masing 4 jam** (2 hari: Sabtu–Minggu), membangun aplikasi nyata di folder `flutter_training/` (mobile) dan `flutter-task-api/` (backend):

1. **Session 1: Dart & Flutter Dasar (4 Jam)** — 15 Agustus
   - Dari `fvm flutter create` (scaffold kosong), bangun aplikasi tugas statis
   - Dart essentials, widget tree, Stateless/Stateful, ListView, setState
   - State sederhana dengan Provider (ChangeNotifier) + HTTP dasar (`http` package)
   - Hasil: aplikasi tugas statis (~340 LOC)

2. **Session 2: State Management, HTTP & Re-Arch (4 Jam)** — 16 Agustus
   - Arsitektur berlapis: models/ → repositories/ → providers/ → screens/
   - Model lengkap dengan fromJson/toJson, repository pattern
   - Dio client (interceptor, error handling, ApiResponse wrapper)
   - UI role-based (siswa & guru) + navigation
   - Hasil: re-arch lengkap (~1,120 LOC)

3. **Session 3: Backend Hono + Neon, Dio & Login (4 Jam)** — 22 Agustus
   - Backend Hono + Drizzle + Neon PostgreSQL (5 tabel, migration)
   - Routes: register, login, classes, tasks, submissions
   - Flutter ↔ backend via Dio (AuthRepository), session persistence (shared_preferences)
   - Login screen + timeout handling
   - Hasil: aplikasi lengkap end-to-end (register → login → buat tugas → kumpulkan)

4. **Session 4: Workshop — Replikasi & Improvement (4 Jam)** — 23 Agustus
   - Challenge: replikasi project dari nol (bertahap, tanpa bantuan)
   - Improvement session (fitur baru: delete, filter, search, dark mode, dll)
   - Q&A terbuka + demo deploy (opsional)
   - Hasil: tidak ada target kode — peserta berkreasi

### Branch Workflow per Sesi

Setiap sesi memiliki branch **sebelum** (start) dan **sesudah** (final) pengerjaan, sehingga peserta bisa membandingkan hasil dan mengejar ketertinggalan:

| Branch | Isi | Untuk |
|---|---|---|
| `session-1-start` | Scaffold `fvm flutter create` (kosong) | Peserta mulai dari nol |
| `session-1-final` | App tugas statis minimal (~340 LOC) | Referensi / diff / merge |
| `session-2-start` | = `session-1-final` (lanjutan) | Peserta clone & mulai coding |
| `session-2-final` | Re-arch lengkap: Dio, model, repo, provider, screens | Referensi / diff / merge |
| `session-3-start` | = `session-2-final` (lanjutan) | Peserta clone & mulai coding |
| `session-3-final` | + login screen + timeout (backend-ready) | Referensi / diff / merge |
| `session-4-start` | = `session-3-final` (lanjutan) | Peserta clone & mulai coding |
| `session-4-final` | = `session-3-final` (workshop — tidak ada target kode) | Referensi |

Alur per sesi: peserta bekerja dari branch `start`, lalu di akhir sesi membandingkan dengan `git diff` dan mengambil hasil referensi dengan `git merge <branch-final>`.

> **Rundown mengajar** (panduan menit-per-menit untuk instruktur) ada di folder [`docs/rundown/`](docs/rundown/README.md).

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
6. Neon CLI (`neon`/`neonctl`) — install via `brew install neonctl` (macOS) atau `npm install -g neon@latest` (Windows), lalu `neon auth` + `neon me` (lihat `docs/setup.md` Bagian 5)

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
    ├── session-2.md
    ├── session-3.md
    ├── session-4.md
    └── rundown/                 # Panduan mengajar instruktur (tidak di RTD)
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
- `session-1.md` - Materi Sesi 1: Perencanaan & Desain + Dasar Flutter (Sabtu, 15 Agu)
- `session-2.md` - Materi Sesi 2: Arsitektur Berlapis, Model, Repository & Dio (Minggu, 16 Agu)
- `session-3.md` - Materi Sesi 3: Backend Hono + Neon, Dio Integration & Login (Sabtu, 22 Agu)
- `session-4.md` - Materi Sesi 4: Workshop Replikasi, Improvement & Q&A (Minggu, 23 Agu)
- `rundown/` - Panduan mengajar instruktur (menit-per-menit, tidak ditampilkan di RTD)

> **ℹ️ Versi live (ReadTheDocs) hanya menampilkan halaman Setup** untuk peserta training.
> Materi sesi (session-1..4) tersedia penuh di branch `build-project` atau saat build lokal.

### 📖 **Menjalankan ReadTheDocs Secara Lokal (Python & Sphinx)**

Gunakan Python Virtual Environment (`venv`) agar `pip` dan `sphinx-build` ter-install dengan benar tanpa error `command not found`:

```bash
# 1. Buat & aktifkan virtual environment
python3 -m venv .venv
source .venv/bin/activate        # macOS / Linux
# .venv\Scripts\activate          # (Khusus Windows PowerShell)

# 2. Install dependensi Sphinx
pip install -r docs/requirements.txt

# 3. Build HTML documentation dari folder docs
sphinx-build -b html docs docs/_build/html

# 4. Jalankan HTTP Server lokal dengan Python
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
