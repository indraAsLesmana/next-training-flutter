# flutter_training

Aplikasi Mobile Pengumpulan Tugas (Flutter).

## Environment Configurations

Proyek ini mendukung pergantian konfigurasi API Base URL antara **Development** (server Hono lokal) dan **Production** (Neon Cloud API).

### 🛠️ 1. Development Mode (Server Lokal)
Gunakan konfigurasi `config_dev.json` untuk menghubungkan aplikasi ke server `neon dev` lokal (`http://localhost:8787` / `http://10.0.2.2:8787` di Android Emulator):

```bash
fvm flutter run --dart-define-from-file=config_dev.json
```

### 🌐 2. Production Mode (Neon Cloud API)
Gunakan konfigurasi `config_prod.json` untuk menghubungkan aplikasi langsung ke database / API cloud Neon:

```bash
fvm flutter run --dart-define-from-file=config_prod.json
```
