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
- ✅ Koneksi ke Neon PostgreSQL
- ✅ State management dengan Provider
- ✅ REST API integration
- ✅ Responsive UI dengan Flutter

## Struktur Training
4 sesi pertemuan, masing-masing 4 jam:

1. **Session 1: Flutter Basics & Layouts (4 Jam)**
   - Pengenalan Flutter & Dart
   - Widget fundamental (Stateless/Stateful)
   - Layouting & UI Design dasar
   - Hands-on: Membuat UI Aplikasi To-Do statis

2. **Session 2: HTTP Integration & Model (4 Jam)**
   - Konsep REST API & JSON
   - Data Models & Serialization
   - Menggunakan package `http`
   - Hands-on: Koneksi ke Mock API / JSON placeholder

3. **Session 3: Neon Database & Backend (4 Jam)**
   - Setup Neon PostgreSQL Cloud
   - Pengenalan singkat Backend (Node.js/Express)
   - Koneksi Backend ke Neon
   - Hands-on: Build API dan jalankan server lokal

4. **Session 4: State Management & Finalisasi (4 Jam)**
   - Konsep State Management (Provider)
   - Integrasi penuh: Flutter -> Backend -> Neon Database (CRUD)
   - Error Handling & UI Polish
   - Final Project Review

## Teknologi Stack
- **Frontend:** Flutter 3.x (Dart)
- **Backend:** Neon Functions (Serverless API)
- **Database:** Neon PostgreSQL
- **Tools:** VS Code, Android Studio, Postman

## Setup Requirements

### Untuk Peserta:
1. Laptop Windows dengan Flutter SDK terinstall
2. VS Code atau Android Studio
3. Akun Neon (gratis)
4. Git untuk version control

### Untuk Instruktur:
1. Contoh kode lengkap (Flutter + Backend)
2. Database schema ready
3. Environment variables template
4. Slide presentasi per session

## Struktur Proyek
```
task_collection_app/
├── flutter_app/
│   ├── lib/
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   ├── class.dart
│   │   │   ├── task.dart
│   │   │   └── submission.dart
│   │   ├── services/
│   │   │   ├── api_service.dart
│   │   │   └── auth_service.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── task_provider.dart
│   │   │   └── notification_provider.dart
│   │   ├── screens/
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── login_screen.dart
│   │   │   ├── teacher/
│   │   │   │   ├── home_screen.dart
│   │   │   │   ├── create_task_screen.dart
│   │   │   │   └── task_detail_screen.dart
│   │   │   └── student/
│   │   │       ├── home_screen.dart
│   │   │       ├── task_list_screen.dart
│   │   │       └── submission_screen.dart
│   │   └── widgets/
│   │       ├── role_selection.dart
│   │       ├── class_selector.dart
│   │       └── submission_table.dart
├── docs/
│   ├── setup.md
│   ├── session-1.md
│   ├── session-2.md
│   ├── session-3.md
│   └── session-4.md
└── README.md
```

## Database Schema (Outline)
```sql
-- Users table (Guru/Siswa)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    role VARCHAR(20) NOT NULL, -- 'teacher' or 'student'
    identification VARCHAR(50), -- NIP for teachers, NIK for students
    grade VARCHAR(10), -- X, XI, XII
    section VARCHAR(10), -- a, b, c, d
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Classes table (managed by teachers)
CREATE TABLE classes (
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES users(id),
    grade VARCHAR(10) NOT NULL, -- X, XI, XII
    section VARCHAR(10) NOT NULL, -- a, b, c, d
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tasks table (assigned by teachers)
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    teacher_id INTEGER REFERENCES users(id),
    class_id INTEGER REFERENCES classes(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    attachment_url TEXT,
    due_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Submissions table (by students)
CREATE TABLE submissions (
    id SERIAL PRIMARY KEY,
    task_id INTEGER REFERENCES tasks(id),
    student_id INTEGER REFERENCES users(id),
    attachment_url TEXT,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'submitted'
);
```

## API Endpoints (Outline)
```
# Authentication
POST    /api/auth/register     → Register Guru/Siswa
POST    /api/auth/login        → Login

# Users
GET     /api/users/profile     → Get user profile

# Classes
GET     /api/classes           → Get all classes (Guru only)
POST    /api/classes           → Create class (Guru only)
GET     /api/classes/:id       → Get class details

# Tasks
GET     /api/tasks             → Get tasks (filter by class/grade)
POST    /api/tasks             → Create task (Guru only)
PUT     /api/tasks/:id         → Update task (Guru only)
DELETE  /api/tasks/:id         → Delete task (Guru only)

# Submissions
POST    /api/tasks/:id/submit  → Submit assignment (Siswa)
GET     /api/tasks/:id/submissions → Get submission status
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

### 🛠️ **Verifikasi Setup**
```bash
# Setup Android SDK Command-line Tools melalui Android Studio
# Kemudian jalankan:
flutter doctor --android-licenses
flutter doctor -v
```

### 🗄️ **Setup Neon Database & Functions**
1. Buat akun di [neon.tech](https://neon.tech)
2. Buat project baru `task-collection-app`
3. Jalankan schema SQL di atas melalui Neon SQL Editor
4. Buat file konfig `config.json` untuk menyimpan URL Neon Function API

### 🚀 **Create & Run App**
# Create Flutter project
fvm flutter create task_collection_app
cd task_collection_app

# Install dependencies
fvm flutter pub add http provider flutter_dotenv shared_preferences intl

# Run the app (dengan config API URL)
fvm flutter run --dart-define-from-file=config.json
```

## Dokumentasi Lengkap
Lihat folder `docs/` untuk dokumentasi detail, atau kunjungi [dokumentasi online](https://next-training-flutter.readthedocs.io):

- `setup.md` - Setup lengkap dengan FVM untuk Windows/macOS
- `session-1.md` - Materi Session 1: Flutter Basics & Layouts untuk Aplikasi Pengumpulan Tugas
- `session-2.md` - Materi Session 2: HTTP Integration & Model dengan Role-based API
- `session-3.md` - Materi Session 3: Neon Database & API Functions dengan schema role-based
- `session-4.md` - Materi Session 4: State Management & Finalisasi dengan Provider untuk Guru/Siswa

## Struktur Training (4 Sesi x 4 Jam)
Training ini tetap menggunakan struktur 4 sesi dengan fokus aplikasi pengumpulan tugas:
1. **Session 1**: Flutter Basics → UI untuk Guru/Siswa
2. **Session 2**: HTTP Integration → API untuk auth dan tugas
3. **Session 3**: Neon Database → Schema role-based
4. **Session 4**: State Management → Provider untuk manajemen role

## Support & Resources
- **Dokumentasi Online**: https://next-training-flutter.readthedocs.io
- **GitHub Repository**: https://github.com/indraAsLesmana/next-training-flutter
- **Untuk SMK Labs**: Gunakan strategi offline kit dan scrcpy untuk testing di lab sekolah

## Troubleshooting
Common issues dan solusi ada di `docs/troubleshooting.md`

Untuk pertanyaan atau masalah selama training, hubungi instruktur atau lihat `docs/faq.md`

## License
Training materials ini tersedia untuk tujuan edukasi.