# Session 1: Perencanaan & Desain Aplikasi + Dasar Flutter

> **Hari 1 — Sabtu, 15 Agustus** (09:30–12:00 pagi, 13:00–14:30 siang, break 12:00–13:00)

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-1-start`** (scaffold `fvm flutter create` — kosong)
> - Hasil akhir sesi ini tersimpan di branch **`session-1-final`** (app tugas minimal)
> - Di akhir sesi kita bandingkan dengan `git diff` dan mengambil referensi dengan `git checkout session-1-final -- flutter_training/`

## Objectives
- Memahami **gambaran besar aplikasi**: alur pengguna, arsitektur, ERD 5 tabel, dan peta 4 sesi
- Membuat project Flutter dari nol dengan `fvm flutter create`
- Memahami dasar bahasa Dart: variabel, tipe data, class, constructor, `toJson`
- Memahami widget Flutter: `StatelessWidget` vs `StatefulWidget`, widget tree, layout, form
- Menjalankan **backend lokal** dengan `neon dev` (Hono API + Neon PostgreSQL)
- Membangun **register page**: form + validasi + `AuthProvider` (state) + HTTP POST
- **Melihat data register masuk ke database** via `drizzle-kit studio` (`npm run db:studio`)

## Agenda (4 jam efektif)
1. Pembukaan & ice-breaking (10 menit)
2. **Perencanaan & Desain Aplikasi** (40 menit)
3. `fvm flutter create` & struktur project (30 menit)
4. Dart Essentials (30 menit)
5. **Setup Backend: `neon dev` + `db:push` + `db:studio`** (30 menit)
6. Widget & Layout Flutter (25 menit)
7. **Membangun Register Page** (40 menit)
8. State: `setState` + Provider (35 menit)
9. HTTP ke backend (`AuthApiService`) (30 menit)
10. Review, diff, & catch-up (15 menit)

---

## 1. Pembukaan

- Tujuan 4 sesi & hasil akhir yang akan dicapai
- **Demo hasil akhir** — jalankan app dari branch `session-4-final` (aplikasi lengkap end-to-end)
- Cek kesiapan: Flutter SDK (FVM), VS Code, emulator/device
- Clone repo & checkout `session-1-start`

```bash
git clone https://github.com/indraAsLesmana/next-training-flutter.git
cd next-training-flutter
git checkout session-1-start
```

> **Apa yang ada di `session-1-start`?** Scaffold Flutter kosong hasil `fvm flutter create` — hanya `main.dart` counter bawaan. Kita akan membangun semuanya dari nol hari ini.

---

## 2. Perencanaan & Desain Aplikasi

> Bagian ini memberi **gambaran besar** sebelum mulai coding: apa yang kita bangun, siapa penggunanya, bagaimana data mengalir, dan bagaimana database dirancang.

### 2.1 Gambaran Proyek

**Aplikasi Pengumpulan Tugas** — aplikasi untuk sekolah dengan 2 peran pengguna:

| Peran | Identitas | Bisa Melakukan |
|---|---|---|
| **Guru** | NIP (Nomor Induk Pegawai) | membuat tugas (individu/kelompok), melihat pengumpulan |
| **Siswa** | NIK (Nomor Induk Kependudukan) | Melihat tugas kelas, mengumpulkan tugas (link URL), cek status |

#### 2.1.1 Hasil Akhir Aplikasi (Screenshot)

Ini **tampilan aplikasi yang akan kita bangun** selama 4 sesi:

| | |
|---|---|
| **1. Login** | **2. Register** |
| ![Login](project_ss/1.login.png) | ![Register](project_ss/2.register.png) |
| **3. Home Siswa** | **4. Submit Tugas (individu)** |
| ![Home Siswa](project_ss/3.home-siswa.png) | ![Submit Tugas](project_ss/4.submit-task-siswa.png) |
| **5. Submit Tugas (kelompok)** | **6. Progress Tugas Guru** |
| ![Submit Kelompok](project_ss/5.submit-task-siswa-group.png) | ![Progress Guru](project_ss/6.task-progress-guru.png) |
| **7. Pengumpulan Tugas Guru** | |
| ![Pengumpulan Guru](project_ss/7.task-submit-guru.png) | |

> **Catatan:** Screenshot di atas adalah hasil akhir dari seluruh training (branch `session-4-final`).

### 2.2 Alur Pengguna

```{mermaid}
flowchart TD
    A[Register: NIP/NIK + password] --> B[Login]
    B --> C{Role?}
    C -->|guru| D[Dashboard Guru<br>buat kelas & tugas]
    C -->|siswa| E[Dashboard Siswa<br>lihat tugas kelas]
    D --> F[Buat Tugas<br>individu / kelompok]
    E --> G[Kumpulkan Tugas<br>isi link URL]
    F --> H[Siswa kumpulkan]
    G --> I[Guru cek status<br>pengumpulan]
```

### 2.3 Arsitektur Aplikasi

```{mermaid}
flowchart LR
    F["Flutter App<br>flutter_training/"] -->|"HTTP / JSON"| A["Hono API<br>flutter-task-api/"]
    A --> D[("Neon PostgreSQL<br>5 tabel")]
```

| Layer | Teknologi | Peran |
|---|---|---|
| **Client** | Flutter (Dart) | UI, state management (Provider), HTTP client (Dio) |
| **Backend** | Hono (TypeScript) | REST API, validasi, logika bisnis |
| **Database** | Neon PostgreSQL | Penyimpanan data (serverless) |

### 2.4 ERD Database (5 Tabel)

```{mermaid}
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

| Tabel | Isi | Relasi penting |
|---|---|---|
| `classes` | Kelas (nama, tingkatan) | 1 kelas → banyak users/tasks |
| `users` | Guru & siswa (NIP/NIK, role, classId) | role: `guru`/`siswa` |
| `tasks` | Tugas (guruId, classId, tanggal, link, isTeamTask) | dibuat guru untuk kelas |
| `submissions` | Pengumpulan (taskId, siswaId, link) | 1 tugas ← banyak pengumpulan |
| `submission_members` | Anggota tugas kelompok | 1 pengumpulan → banyak anggota |

### 2.5 Ringkasan API

| Method | Endpoint | Fungsi |
|---|---|---|
| `POST` | `/api/auth/register` | Daftar (NIP/NIK + password) |
| `POST` | `/api/auth/login` | Masuk |
| `GET` | `/api/classes` | Daftar kelas |
| `GET` | `/api/students/search?classId=&query=` | Cari siswa per kelas |
| `POST` | `/api/tasks` | Guru membuat tugas |
| `GET` | `/api/tasks?classId=&siswaId=` | Siswa melihat tugas |
| `POST` | `/api/submissions` | Siswa mengumpulkan |
| `GET` | `/api/tasks/:id/submissions` | Status pengumpulan |

> **Detail backend dibahas di Session 3.** Untuk sekarang, cukup pahami *bentuk* API-nya.

- **File:** [`docs/apidog/next-training-api.yaml`](apidog/next-training-api.yaml)
  - *GitHub raw:* <https://raw.githubusercontent.com/indraAsLesmana/next-training-flutter/build-project/docs/apidog/next-training-api.yaml>

### 2.6 Peta 4 Sesi

| Sesi | Hari | Fokus | Hasil Akhir | Branch |
|---|---|---|---|---|
| 1 | 15 Agu | Perencanaan + Dasar Flutter + `neon dev` | **Register page + data masuk Neon DB** | `session-1-start` → `session-1-final` |
| 2 | 16 Agu | State mgmt, HTTP, re-arch | Arsitektur berlapis + Dio | `session-2-start` → `session-2-final` |
| 3 | 22 Agu | Backend Hono+Neon, login | App lengkap end-to-end | `session-3-start` → `session-3-final` |
| 4 | 23 Agu | Workshop: replikasi, improvement, Q&A | Tidak ada target kode | `session-4-start` → `session-4-final` |

> **Checkpoint**

---

## 3. Membuat Project: `fvm flutter create`

```bash
fvm flutter create --org com.flutter_training --platforms android,ios,web flutter_training
cd flutter_training
fvm flutter run
```

### Struktur Folder yang Dihasilkan

```text
flutter_training/
├── lib/
│   └── main.dart              # Entry point (counter app bawaan)
├── pubspec.yaml               # Daftar dependency
└── android/  ios/  web/       # Folder platform
```

| Folder/File | Fungsi |
|---|---|
| `lib/` | Semua kode Dart aplikasi |
| `pubspec.yaml` | Dependency + metadata project |
| `android/`, `ios/`, `web/` | Kode native per platform (jarang disentuh) |

> **Checkpoint:** semua berhasil menjalankan counter app di emulator.

### Eksplorasi `main.dart` Bawaan

```dart
void main() {
  runApp(const MyApp());        // entry point
}

class MyApp extends StatelessWidget { ... }        // akar widget tree
class MyHomePage extends StatefulWidget { ... }    // halaman dengan state
class _MyHomePageState extends State<MyHomePage> { // state + setState()
  int _counter = 0;
  void _incrementCounter() {
    setState(() { _counter++; });  // ubah state → rebuild UI
  }
}
```

---
---

## 4. Dart Essentials

Dart adalah bahasa **strongly-typed** dengan **null-safety** (nilai default tidak boleh `null` kecuali dinyatakan dengan `?`).

### Variabel & Tipe Data

```dart
String nama = 'Budi';        // String
int tahun = 2026;            // Integer
double nilai = 87.5;         // Double
bool aktif = true;           // Boolean

String? email;               // Nullable — boleh null
final int id = 1;            // final: tidak bisa diubah setelah di-set
const pi = 3.14;             // const: konstanta compile-time

List<String> peserta = ['Budi', 'Siti'];
Map<String, dynamic> user = {'nama': 'Budi', 'role': 'siswa'};
```

### Class & Constructor

Kita akan membuat model `User` di `lib/models/user_model.dart` — mewakili **satu baris di tabel `users`** database:

```dart
class User {
  final String? id;      // UUID dari database (null sebelum disimpan)
  final String nama;
  final String role;     // 'guru' | 'siswa'
  final String nipNik;   // NIP (guru) atau NIK (siswa)
  final String? email;
  final String password;

  User({
    this.id,
    required this.nama,
    required this.role,
    required this.nipNik,
    this.email,
    required this.password,
  });
}
```

**Poin penting:**
- `final` → immutable (nilai tidak bisa diubah setelah di-set)
- `required` → parameter wajib
- Named parameters `{...}` → lebih jelas daripada positional
- `String?` → nullable (boleh null) — `id` & `email` belum tentu ada

### Method `toJson`: Object → JSON

```dart
Map<String, dynamic> toJson() => {
      'nama': nama,
      'role': role,
      'nipNik': nipNik,
      'email': email,
      'password': password,
      'classId': null,   // siswa diisi di Session 2
    };
```

**Poin penting:**
- `toJson()` → mengubah objek Dart menjadi `Map` yang bisa di-encode ke JSON (`jsonEncode`)
- API backend menerima JSON body — inilah "bahasa" komunikasi Flutter ↔ Hono
- Nama key (`nama`, `role`, `nipNik`) **harus cocok** dengan yang backend baca di `c.req.json()`

---

## 5. Setup Backend Lokal: `neon dev`

Sebelum membangun register page, kita aktifkan **backend lokal** — supaya nanti saat form di-submit, datanya benar-benar tersimpan ke database.

### 5.1 Prasyarat

- Sudah install **Neon CLI**: `npm install -g neon` (lihat Setup)
- Sudah punya akun Neon + project (lihat Setup)

### 5.2 Jalankan Backend dengan `neon dev`

```bash
cd flutter-task-api
npm install          # install dependencies (hono, drizzle, dll)
neon dev             # jalankan Hono API secara lokal
```

`neon dev` akan:
1. Membaca konfigurasi `neon.ts` (function `todos` → `src/index.ts`)
2. Menjalankan **Hono API di `http://localhost:8787`**
3. Mengisi `.env` dengan `DATABASE_URL` yang menunjuk ke **Neon cloud** (branch yang di-link)

> **Kenapa `neon dev`?** Ini adalah cara resmi Neon untuk develop backend secara lokal — API jalan di mesinmu, tapi database tetap di Neon cloud (serverless PostgreSQL). Perubahan schema langsung bisa di-push.

> **Penting:** Biarkan terminal `neon dev` berjalan — jangan ditutup selama sesi.

### 5.3 Push Schema ke Database

Di terminal kedua:

```bash
cd flutter-task-api
npm run db:push     # push schema Drizzle (tabel users, classes, dll) ke Neon
```

Ini membuat 5 tabel (`classes`, `users`, `tasks`, `submissions`, `submission_members`) di database Neon kamu.

### 5.4 Buka Drizzle Studio (Database Visualizer)

```bash
npm run db:studio   # = drizzle-kit studio
```

Drizzle Studio terbuka di browser (biasanya `https://local.drizzle.studio` atau `http://127.0.0.1:4983`).

**Yang perlu kamu lihat:**
- Tabel **`users`** — masih **kosong** (belum ada data)
- Kolom-kolomnya: `id`, `nama`, `role`, `nip_nik`, `email`, `password_hash`, `class_id`, `created_at`

> **Checkpoint:** Drizzle Studio terbuka, tabel `users` kosong. Ini "kanvas" kita — setiap register yang berhasil akan muncul di sini.

### 5.5 Test API dengan `curl`

Sebelum bikin Flutter, test dulu endpoint register:

```bash
curl -X POST http://localhost:8787/api/auth/register \
  -H 'content-type: application/json' \
  -d '{"nama":"Test User","role":"siswa","nipNik":"1234567890","password":"rahasia123"}'
```

**Respons sukses (201):**
```json
{ "success": true, "data": { "id": "uuid-...", "nama": "Test User", "role": "siswa" } }
```

Sekarang **refresh Drizzle Studio** → tabel `users` berisi **1 baris**! 🎉

> **Ini momen penting:** data yang kamu kirim dari API → tersimpan di database → terlihat di studio. Alur inilah yang akan kita bangun dari Flutter.

---

## 6. Widget & Layout Flutter

Di Flutter, **semuanya adalah widget** — UI dibangun dengan menyusun widget di dalam widget (composition).

### Widget Tree

```text
MaterialApp
└── Scaffold
    ├── AppBar (judul "Register")
    └── body: Center
        └── SingleChildScrollView
            └── Form
                └── Column
                    ├── SegmentedButton (role)
                    ├── TextFormField (nama)
                    ├── TextFormField (NIP/NIK)
                    ├── TextFormField (email)
                    ├── TextFormField (password)
                    └── FilledButton (Daftar)
```

### StatelessWidget vs StatefulWidget

```dart
// StatelessWidget: statis, tidak punya state yang berubah
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pengumpulan Tugas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
```

```dart
// StatefulWidget: punya state yang bisa berubah + setState()
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
```

**Aturan emas:**
- `StatelessWidget` → UI tidak berubah setelah dibangun
- `StatefulWidget` → ada data yang berubah (input form, loading, hasil API)

### Layout Dasar

| Widget | Fungsi |
|---|---|
| `Column` | Susun anak vertikal |
| `Row` | Susun anak horizontal |
| `Container` | Kotak dengan padding/margin/decoration |
| `SingleChildScrollView` | Konten scrollable (form panjang) |
| `Card` | Kontainer bergaya kartu (Material) |
| `Scaffold` | Kerangka halaman (AppBar, body, FAB) |

---

## 7. Membangun Register Page

Sekarang kita bangun halaman register — **goal utama sesi ini**.

### 7.1 Form dengan `TextFormField`

`TextFormField` adalah input teks dengan **validasi bawaan** (`validator`):

```dart
// lib/screens/register_screen.dart
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nipNikController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'siswa'; // toggle: 'siswa' | 'guru'

  @override
  void dispose() {
    _namaController.dispose();
    _nipNikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**Poin penting:**
- `TextEditingController` → "jembatan" antara widget dan teks yang diketik
- `GlobalKey<FormState>` → untuk memicu validasi (`_formKey.currentState!.validate()`)
- `dispose()` → selalu bersihkan controller (hindari memory leak)
- `setState` → untuk toggle role (`SegmentedButton`)

### 7.2 Pilihan Peran dengan `SegmentedButton`

```dart
SegmentedButton<String>(
  segments: const [
    ButtonSegment(value: 'siswa', label: Text('Siswa'), icon: Icon(Icons.school)),
    ButtonSegment(value: 'guru', label: Text('Guru'), icon: Icon(Icons.teacher)),
  ],
  selected: {_role},
  onSelectionChanged: (selection) {
    setState(() => _role = selection.first);
  },
)
```

**Latihan:** ubah label NIP/NIK dinamis — jika `_role == 'guru'` tampilkan "NIP", jika siswa tampilkan "NIK".

### 7.3 Field dengan Validasi

```dart
TextFormField(
  controller: _namaController,
  decoration: const InputDecoration(
    labelText: 'Nama Lengkap',
    prefixIcon: Icon(Icons.person),
    border: OutlineInputBorder(),
  ),
  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
),
```

```dart
TextFormField(
  controller: _passwordController,
  decoration: const InputDecoration(
    labelText: 'Password',
    prefixIcon: Icon(Icons.lock),
    border: OutlineInputBorder(),
  ),
  obscureText: true,   // tampil sebagai bullet
  validator: (v) => (v == null || v.length < 6) ? 'Password minimal 6 karakter' : null,
),
```

**Poin penting:**
- `validator` mengembalikan `String?` — `null` = valid, selain itu = pesan error
- `obscureText: true` → menyembunyikan teks password
- `trim()` → hapus spasi di awal/akhir

> **Checkpoint:** form tampil dengan 4 field + toggle role, validasi bekerja (klik Daftar dengan form kosong → muncul error).

---

## 8. State: `setState` → Provider

### 8.1 `setState` untuk Loading

```dart
FilledButton(
  onPressed: authProvider.isLoading ? null : _submit,
  child: authProvider.isLoading
      ? const SizedBox(
          height: 20, width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('Daftar'),
)
```

**Latihan:** klik Daftar → tombol berubah jadi spinner (loading state). Ini `setState`/`notifyListeners` bekerja.

### 8.2 Kenapa `setState` Tidak Cukup?

Ketika state harus **dibagi antar screen** (misal: status register dilihat dari halaman lain), `setState` di satu screen tidak akan memperbarui screen lain. Solusinya: **`ChangeNotifier` + `Provider`**.

### 8.3 Provider: `AuthProvider`

```dart
// lib/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();

  bool _isLoading = false;
  String? _error;
  User? _registeredUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get registeredUser => _registeredUser;

  Future<bool> register({
    required String nama,
    required String role,
    required String nipNik,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = User(
        nama: nama, role: role, nipNik: nipNik,
        email: email, password: password,
      );
      _registeredUser = await _api.register(user);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

**Poin penting:**
- `ChangeNotifier` → memberi tahu listener saat state berubah (`notifyListeners()`)
- `register()` mengembalikan `bool` — screen tinggal cek sukses/gagal
- Error disimpan di `_error` agar UI bisa menampilkan pesan

### 8.4 Daftarkan di `main.dart`

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

### 8.5 Konsumsi dengan `context.watch` / `context.read`

```dart
// Di dalam build():
final authProvider = context.watch<AuthProvider>();   // rebuild saat berubah

// Di dalam handler:
final authProvider = context.read<AuthProvider>();     // sekali pakai, tanpa rebuild
```

**Aturan:**
- `watch` → di dalam `build()` (ikuti perubahan)
- `read` → di dalam event handler (panggil method)

---

## 9. HTTP ke Backend: `AuthApiService`

Tambah dependency:

```bash
fvm flutter pub add http
```

### `AuthApiService` — Kirim Register ke Hono

```dart
// lib/services/auth_api_service.dart
class AuthApiService {
  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',   // port dari `neon dev`
  );

  Future<User> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 && body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      return User(
        id: data['id'],
        nama: data['nama'],
        role: data['role'],
        nipNik: data['nipNik'],
        email: data['email'],
        password: user.password,
      );
    }

    throw Exception(body['message'] ?? 'Gagal mendaftar (HTTP ${response.statusCode})');
  }
}
```

**Poin penting:**
- `http.post(Uri, headers:, body:)` → kirim HTTP POST dengan JSON body
- `jsonEncode(user.toJson())` → objek `User` → JSON string
- `statusCode == 201` → Created (backend mengembalikan 201 untuk register sukses)
- `String.fromEnvironment` → base URL bisa di-override saat build:
  ```bash
  fvm flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787   # Android emulator
  ```

> **Penting — Android emulator:** `localhost` di emulator menunjuk ke emulator itu sendiri. Untuk mencapai backend di mesin host, pakai `10.0.2.2`:
> `fvm flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8787`

**Latihan:** jalankan app, isi form register, klik **Daftar** → setelah sukses, buka **Drizzle Studio** dan refresh tabel `users` → **baris baru muncul!** 🎉

> **Checkpoint:** register dari Flutter → data tersimpan di Neon → terlihat di Drizzle Studio.

---

## 10. Review, Diff, dan Catch-up

Di akhir sesi, bandingkan hasil kerja dengan referensi:

```bash
# 1. Lihat semua file yang berubah
git diff session-1-start..session-1-final --stat

# 2. Lihat detail perubahan per file
git diff session-1-start..session-1-final -- flutter_training/lib/main.dart

# 3. Ambil hasil referensi (jika tertinggal / mau lanjut)
git checkout session-1-final -- flutter_training/
```

> **Kenapa `git checkout <branch> -- <folder>` dan bukan `git merge`?** Karena di Session 1 peserta mulai dari scaffold kosong (`session-1-start`) yang *berbeda struktur* dari `session-1-final` — `git merge` akan bentrok. Dengan checkout file, kita menimpa folder `flutter_training/` dengan versi referensi, lalu tinggal `fvm flutter pub get` dan lanjut ke Session 2 dengan fondasi yang sama.

### Checklist Hasil Akhir Sesi 1
- [ ] `fvm flutter create` berhasil & struktur folder dipahami
- [ ] Backend lokal jalan: `neon dev` → Hono API di `localhost:8787`
- [ ] Schema di-push: `npm run db:push` → 5 tabel di Neon
- [ ] Drizzle Studio terbuka (`npm run db:studio`) & tabel `users` kosong
- [ ] Test API `curl` register → 1 baris muncul di studio
- [ ] Class `User` + `toJson` dipahami
- [ ] UI form register (TextFormField + SegmentedButton + validasi) dibangun
- [ ] State dipindah ke `AuthProvider` (ChangeNotifier + Provider)
- [ ] HTTP POST register (`AuthApiService`) dipahami
- [ ] **Register dari Flutter → data masuk ke Neon → terlihat di Drizzle Studio**

---

## Latihan / Tugas Rumah
1. Tambahkan **validasi NIP/NIK** — minimal 10 karakter (NIK Indonesia 16 digit).
2. Tampilkan **snackbar sukses** berisi id user yang baru dibuat (dari `registeredUser.id`).
3. Coba register **guru** (toggle role) → di Drizzle Studio, kolom `role` = `guru` dan `class_id` = `null`.
4. Jelaskan dengan kata-kata sendiri: apa bedanya `setState`, `ChangeNotifier`, dan `Consumer`?

## Sumber Belajar
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Neon CLI — `neon dev`](https://neon.tech/docs/cli/dev)
- [Drizzle Kit Studio](https://orm.drizzle.team/drizzle-studio/overview/)
