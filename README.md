# Flutter Basic + Neon Database Training

## Overview
Training program untuk guru SMK tentang Flutter basic dan koneksi ke database menggunakan Neon PostgreSQL. Program ini dirancang untuk memberikan pengalaman langsung membangun aplikasi mobile dengan database cloud.

## Target Audience
- Guru SMK jurusan RPL/TKJ
- Peserta: 3-4 orang per sesi
- Platform: Windows
- Level: Beginner to Intermediate

## Aplikasi Contoh
**To-Do App dengan Neon Database** - Aplikasi manajemen tugas yang terhubung ke database cloud PostgreSQL di Neon.

## Fitur Utama
- ✅ CRUD operations (Create, Read, Update, Delete)
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
- **Backend:** Node.js/Express atau Python/FastAPI
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
todo_app_flutter/
├── lib/
│   ├── main.dart
│   ├── models/task.dart
│   ├── services/api_service.dart
│   ├── providers/task_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── add_task_screen.dart
│   └── widgets/
│       └── task_list.dart
├── backend/
│   └── server.js
├── docs/
│   ├── setup.md
│   ├── session-1.md
│   └── session-2.md
└── README.md
```

## Database Schema
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## API Endpoints
```
GET    /tasks      → Get all tasks
POST   /tasks      → Create new task
PUT    /tasks/:id  → Update task
DELETE /tasks/:id  → Delete task
```

## Quick Start

### 1. Setup Flutter
```bash
flutter create todo_app_flutter
cd todo_app_flutter
flutter pub add http provider flutter_dotenv
```

### 2. Setup Neon Database
1. Buat akun di [neon.tech](https://neon.tech)
2. Buat project baru
3. Buat database `todo_app`
4. Jalankan schema SQL di atas

### 3. Setup Backend API
```bash
cd backend
npm init -y
npm install express pg dotenv cors
node server.js
```

### 4. Run Flutter App
```bash
flutter run
```

## Dokumentasi Lengkap
Lihat folder `docs/` untuk dokumentasi detail:
- `setup.md` - Setup lengkap untuk peserta
- `session-1.md` - Materi Session 1: Flutter Basics & Layouts
- `session-2.md` - Materi Session 2: HTTP Integration & Model
- `session-3.md` - Materi Session 3: Neon Database & Backend
- `session-4.md` - Materi Session 4: State Management & Finalisasi

## Troubleshooting
Common issues dan solusi ada di `docs/troubleshooting.md`

## Kontak & Support
Untuk pertanyaan atau masalah selama training, hubungi instruktur atau lihat FAQ di `docs/faq.md`

## License
Training materials ini tersedia untuk tujuan edukasi.