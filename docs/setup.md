# Setup untuk Peserta Training Flutter + Neon

## Prerequisites

### 1. System Requirements
- **OS:** Windows 10/11 (64-bit)
- **RAM:** Minimum 8GB (16GB recommended)
- **Storage:** Minimum 20GB free space
- **Processor:** Intel i5 atau setara

### 2. Software yang perlu diinstall

#### Flutter SDK
1. Download Flutter SDK dari [flutter.dev](https://flutter.dev)
2. Extract ke folder, contoh: `C:\flutter`
3. Tambahkan ke PATH environment variable:
   ```
   C:\flutter\bin
   ```
4. Verifikasi installasi:
   ```bash
   flutter doctor
   ```

#### Visual Studio Code
1. Download VS Code dari [code.visualstudio.com](https://code.visualstudio.com)
2. Install extensions:
   - Flutter
   - Dart
   - REST Client (opsional)

#### Git
1. Download Git dari [git-scm.com](https://git-scm.com)
2. Install dengan default options
3. Konfigurasi:
   ```bash
   git config --global user.name "Nama Anda"
   git config --global user.email "email@example.com"
   ```

### 3. Akun Cloud Services

#### Neon PostgreSQL
1. Buka [neon.tech](https://neon.tech)
2. Buat akun gratis dengan GitHub/Google
3. Buat project baru:
   - **Project Name:** `flutter-training`
   - **Region:** Singapore (pilih terdekat)
   - **PostgreSQL Version:** 15 atau terbaru
4. Catat database connection string

#### GitHub (Opsional)
1. Buat akun di [github.com](https://github.com)
2. Buat repository baru untuk project

### 4. Environment Setup

#### Clone Project Template
```bash
git clone <template-repo-url>
cd todo_app_flutter
```

#### Install Dependencies Flutter
```bash
flutter pub get
```

#### Setup Environment Variables
Buat file `.env` di root project:
```env
# Backend API URL
API_BASE_URL=http://localhost:3000

# Neon Database URL (untuk backend)
DATABASE_URL=postgresql://username:password@host.neon.tech/database

# App Settings
APP_NAME=To-Do App
APP_VERSION=1.0.0
```

### 5. Backend API Setup

#### Install Node.js
1. Download Node.js LTS dari [nodejs.org](https://nodejs.org)
2. Install dengan default options
3. Verifikasi:
   ```bash
   node --version
   npm --version
   ```

#### Setup Backend Project
```bash
# Navigasi ke folder backend
cd backend

# Install dependencies
npm init -y
npm install express pg dotenv cors

# Jalankan server
node server.js
```

### 6. Database Setup

#### Buat Database di Neon
1. Login ke Neon dashboard
2. Pilih project `flutter-training`
3. Klik "SQL Editor"
4. Jalankan script berikut:

```sql
-- Buat table tasks
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO tasks (title, description) VALUES
('Belajar Flutter', 'Membuat aplikasi To-Do dengan database'),
('Setup Neon', 'Konfigurasi PostgreSQL di cloud'),
('Buat REST API', 'Backend dengan Node.js');

-- Verifikasi data
SELECT * FROM tasks;
```

### 7. Testing Setup

#### Test Flutter App
```bash
# Build untuk testing
flutter build apk --debug

# Run di emulator/device
flutter run

# Run tests
flutter test
```

#### Test Backend API
Gunakan Postman atau curl untuk test endpoints:
```bash
# Test GET /tasks
curl http://localhost:3000/tasks

# Test POST /tasks
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task","description":"Testing API"}'
```

### 8. Troubleshooting Common Issues

#### Flutter doctor errors
- **Android SDK not found:** Install Android Studio dan setup SDK
- **No devices available:** Enable USB debugging di Android device
- **Firewall issues:** Allow Flutter dan Dart di Windows Firewall

#### Database connection errors
- **Connection refused:** Pastikan backend server running
- **SSL connection error:** Tambahkan `?sslmode=require` di connection string
- **Authentication failed:** Periksa username dan password

#### API errors
- **CORS issues:** Pastikan backend mengizinkan CORS
- **404 Not Found:** Periksa route di backend
- **500 Internal Error:** Check server logs

### 9. Verifikasi Setup Lengkap

#### Checklist Setup
- [ ] Flutter SDK terinstall (`flutter doctor`)
- [ ] VS Code dengan extensions Flutter
- [ ] Git terinstall (`git --version`)
- [ ] Akun Neon dibuat
- [ ] Database schema dijalankan
- [ ] Backend API running
- [ ] Flutter app bisa di-run
- [ ] API endpoints respond

#### Quick Test
```bash
# Test komponen utama
cd todo_app_flutter
flutter doctor
flutter run --verbose
curl http://localhost:3000/tasks
```

### 10. Resources

#### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Neon Documentation](https://neon.tech/docs)
- [Node.js Documentation](https://nodejs.org/docs)

#### Learning Resources
- [Flutter Codelabs](https://codelabs.developers.google.com/codelabs/flutter)
- [PostgreSQL Tutorial](https://www.postgresqltutorial.com)
- [REST API Best Practices](https://restfulapi.net)

#### Support
- [Flutter Community](https://flutter.dev/community)
- [Neon Discord](https://discord.gg/neon)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

### 11. Backup & Recovery

#### Export Database
```sql
-- Backup data tasks
COPY tasks TO '/path/to/backup.csv' WITH CSV HEADER;
```

#### Backup Code
```bash
# Commit ke Git
git add .
git commit -m "Backup sebelum training"
git push origin main

# Buat zip backup
tar -czf backup-$(date +%Y%m%d).tar.gz todo_app_flutter/
```

### 12. Ready for Training
Setup selesai! Anda sekarang siap untuk mengikuti training Flutter + Neon.

Jika ada masalah selama setup, konsultasikan dengan instruktur atau lihat bagian troubleshooting.