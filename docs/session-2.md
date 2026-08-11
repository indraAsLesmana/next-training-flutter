# Session 2: Backend API (Hono + Neon), Dio & State Management dengan Provider

## Durasi: 4 jam

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-2-start`** (= hasil `session-1-final`)
> - Hasil akhir sesi ini tersimpan di branch **`session-2-final`**
> - Di akhir sesi kita akan `git diff` dan `git merge session-2-final` untuk memverifikasi hasil.

## Objectives
- Memahami konsep REST API dan JSON
- Membangun backend API dengan **Hono + Drizzle + Neon** (PostgreSQL serverless)
- Mengenal arsitektur database: 5 tabel dengan relasi foreign key
- Menggunakan **Dio** untuk HTTP requests di Flutter (GET/POST)
- Menerapkan **Provider** untuk state management: auth, kelas, dan tugas
- Menghubungkan aplikasi Flutter ke backend secara end-to-end

## Agenda
1. Konsep REST API & Arsitektur Backend (30 menit)
2. Database Schema & Seed (30 menit)
3. Hono API: Routes & Endpoints (45 menit)
4. Dio Client & Repository Layer di Flutter (45 menit)
5. Provider: Auth, School, Task (45 menit)
6. End-to-End Testing & Review (45 menit)

---

## 1. Konsep REST API & Arsitektur Backend

### Client-Server & HTTP Methods

Aplikasi Flutter (client) berkomunikasi dengan backend melalui HTTP:

| Method | Fungsi | Contoh endpoint |
|---|---|---|
| `GET` | Mengambil data (Read) | `GET /api/classes` |
| `POST` | Membuat data baru (Create) | `POST /api/auth/register` |
| `PUT/PATCH` | Mengubah data (Update) | (pada project ini submit menggunakan POST) |
| `DELETE` | Menghapus data (Delete) | — |

Setiap response backend berbentuk JSON dengan struktur konsisten:

```text
{ "success": true, "data": { ... } }
```

atau saat error:

```text
{ "success": false, "message": "NIP/NIK atau password salah" }
```

### Stack Backend di `flutter-task-api/`

```text
flutter-task-api/
├── src/
│   ├── index.ts          # Hono app: semua routes API
│   └── db/
│       ├── schema.ts     # Definisi tabel (Drizzle ORM)
│       ├── seed.ts       # Seeder data kelas
│       ├── reset.ts      # Reset database
│       └── client.ts     # Koneksi Neon
├── drizzle/              # Hasil generate migration SQL
├── neon.ts               # Konfigurasi Neon Functions
└── package.json          # Dependency: hono, drizzle-orm, @neondatabase/serverless
```

| Komponen | Peran |
|---|---|
| **Hono** | Framework web ringan untuk API (mirip Express, tapi modern & cepat) |
| **Drizzle ORM** | Type-safe SQL builder untuk TypeScript |
| **Neon** | PostgreSQL serverless di cloud (auto-scaling, branch seperti git) |

---

## 2. Database Schema & Seed

### 5 Tabel dengan Relasi

`src/db/schema.ts` mendefinisikan 5 tabel:

```text
classes 1───* users 1───* tasks 1───* submissions 1───* submission_members
                       │                                  │
                       └────────── users (team members) ──┘
```

1. **`classes`** — data kelas: `tingkat` (X/XI/XII), `nama_kelas` (a/b/c/d), unique index `(tingkat, nama_kelas)`
2. **`users`** — guru & siswa: `nama`, `role`, `nip_nik` (unique), `email`, `password_hash`, `class_id` (FK → classes, `onDelete: set null`)
3. **`tasks`** — tugas: `guru_id` (FK → users), `class_id` (FK → classes), `description`, `start_date`, `end_date`, `attachment_url`, `is_team_task`, `max_team_members`
4. **`submissions`** — pengumpulan tugas: `task_id` (FK → tasks), `siswa_id` (FK → users), `submit_url`, `notes`, `submitted_at`
5. **`submission_members`** — anggota tim pada tugas kelompok: `submission_id` (FK → submissions), `siswa_id` (FK → users), unique `(submission_id, siswa_id)`

Contoh definisi Drizzle:

```typescript
export const classes = pgTable('classes', {
  id: uuid('id').defaultRandom().primaryKey(),
  tingkat: varchar('tingkat', { length: 5 }).notNull(),   // 'X', 'XI', 'XII'
  namaKelas: varchar('nama_kelas', { length: 5 }).notNull(), // 'a', 'b', 'c', 'd'
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => [
  uniqueIndex('tingkat_nama_kelas_idx').on(table.tingkat, table.namaKelas),
]);
```

**Poin penting:**
- `defaultRandom()` → UUID otomatis
- `references(() => users.id, { onDelete: 'cascade' })` → jika guru dihapus, tugasnya ikut terhapus
- `onDelete: 'set null'` untuk `users.class_id` → jika kelas dihapus, siswa tetap ada tapi `class_id` menjadi null

### Seed Data

`src/db/seed.ts` mengisi 12 kelas (X a-d, XI a-d, XII a-d) secara **idempotent**:

```typescript
const dataClasses = [
  { tingkat: 'X', namaKelas: 'a' },
  { tingkat: 'X', namaKelas: 'b' },
  // ...
];

await db.insert(classes).values(dataClasses).onConflictDoNothing();
```

`onConflictDoNothing()` → aman dijalankan berkali-kali tanpa duplikasi.

---

## 3. Hono API: Routes & Endpoints

`src/index.ts` mendefinisikan semua endpoint. Pola umumnya:

```typescript
const app = new Hono();
app.use('*', cors());  // Izinkan request dari aplikasi Flutter

function getDb() {
  const sql = neon(process.env.DATABASE_URL!);
  return drizzle(sql);
}

app.get('/api/classes', async (c) => {
  const db = getDb();
  try {
    const data = await db.select().from(classes);
    return c.json({ success: true, data });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});
```

### Endpoint Lengkap

| Method | Endpoint | Fungsi |
|---|---|---|
| `GET` | `/api/classes` | Ambil semua kelas |
| `GET` | `/api/students/search?classId=..&query=..` | Cari siswa dalam kelas (nama/NIK, max 20) |
| `POST` | `/api/auth/register` | Daftar (guru/siswa) |
| `POST` | `/api/auth/login` | Login dengan NIP/NIK + password |
| `GET` | `/api/tasks?classId=&guruId=&siswaId=` | List tugas dengan filter; jika `siswaId` diberikan, sertakan status `isSubmitted`, `submitUrl`, `teamMembers` |
| `POST` | `/api/tasks` | Guru membuat tugas baru |
| `POST` | `/api/submissions` | Siswa mengumpulkan/update tugas (support tugas kelompok) |
| `GET` | `/api/tasks/:id/submissions` | Guru melihat detail pengumpulan per siswa |

### Contoh: Login

```typescript
app.post('/api/auth/login', async (c) => {
  const db = getDb();
  const { nipNik, password } = await c.req.json();

  const foundUsers = await db
    .select()
    .from(users)
    .where(and(eq(users.nipNik, nipNik), eq(users.passwordHash, password)));

  if (foundUsers.length === 0) {
    return c.json({ success: false, message: 'NIP/NIK atau password salah' }, 401);
  }
  return c.json({ success: true, data: foundUsers[0] }, 200);
});
```

### Contoh: Submit Tugas (dengan Team Task)

```typescript
app.post('/api/submissions', async (c) => {
  const db = getDb();
  const { taskId, siswaId, submitUrl, notes, teamMemberIds } = await c.req.json();

  // 1. Cek apakah siswa sudah pernah submit
  const existingDirect = await db.select().from(submissions)
    .where(and(eq(submissions.taskId, taskId), eq(submissions.siswaId, siswaId)));

  // 2. Update jika sudah ada, insert jika belum
  // 3. Simpan anggota tim di submission_members (hapus dulu, lalu insert ulang)
});
```

**Poin penting:** endpoint submit menggunakan pola *upsert* — jika siswa sudah mengumpulkan, request berikutnya akan *memperbarui* alih-alih membuat duplikat.

---

## 4. Dio Client & Repository Layer di Flutter

### Kenapa Dio?

Project menggunakan **Dio** (`dio: ^5.11.0`) — HTTP client populer untuk Dart/Flutter yang menawarkan:
- Interceptors (log request/response otomatis)
- Timeout configurable
- Error handling terstruktur (`DioException`)
- Mudah membaca response JSON

### `DioClient` (`lib/core/network/dio_client.dart`)

```dart
class DioClient {
  late final Dio dio;

  DioClient() {
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8787',
    );

    // Android Emulator: localhost host tidak bisa diakses langsung
    if (!kIsWeb && Platform.isAndroid && baseUrl.contains('localhost')) {
      baseUrl = baseUrl.replaceAll('localhost', '10.0.2.2');
    }

    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(request: true, responseBody: true));
  }

  static String getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi ke server timeout. Periksa koneksi internet atau server backend.';
      case DioExceptionType.connectionError:
        return 'Gagal terhubung ke server backend. Pastikan server aktif.';
      case DioExceptionType.badResponse:
        return e.response?.data?['message'] ?? 'Terjadi kesalahan pada server (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return e.message ?? 'Terjadi kesalahan jaringan tidak terduga.';
    }
  }
}
```

**Poin penting:**
- `String.fromEnvironment('API_BASE_URL')` → konfigurasi lewat `--dart-define-from-file` (lihat `config_dev.json`/`config_prod.json`), bukan hardcode
- **Android emulator memakai `10.0.2.2`** untuk mengakses localhost host machine
- `getErrorMessage` → pesan error ramah pengguna dalam Bahasa Indonesia

### Repository Pattern

Repository membungkus pemanggilan API dan mengembalikan `ApiResponse<T>`:

```dart
class AuthRepository {
  final DioClient _client;
  AuthRepository(this._client);

  Future<ApiResponse<UserModel>> loginUser({
    required String nipNik,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post('/api/auth/login', data: {
        'nipNik': nipNik,
        'password': password,
      });
      return ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    }
  }
}
```

**Poin penting:**
- Repository = satu-satunya tempat yang tahu "cara bicara ke API" (endpoint, method, JSON)
- UI tidak pernah memanggil Dio langsung — selalu lewat repository
- Semua error ditangkap dan diubah jadi `ApiResponse` dengan pesan yang bisa ditampilkan

### `ApiResponse<T>` (Generic)

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  // ... constructor + fromJson
}
```

`T` adalah tipe data generik — `ApiResponse<UserModel>`, `ApiResponse<List<TaskModel>>`, dll. Satu class untuk semua response.

---

## 5. Provider: Auth, School, Task

### Apa itu Provider?

**Provider** adalah state management resmi yang direkomendasikan untuk pemula. Konsep inti:

- `ChangeNotifier` → class yang bisa "memberitahu" UI bahwa ada perubahan (`notifyListeners()`)
- `ChangeNotifierProvider` → mendaftarkan notifier ke widget tree
- `Consumer` / `context.watch` → widget yang *mendengarkan* dan rebuild saat ada perubahan

### `AuthProvider` (Login + Session)

```dart
class AuthProvider with ChangeNotifier {
  static const String _userSessionKey = 'user_session';

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login({required String nipNik, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authRepo.loginUser(nipNik: nipNik, password: password);
    _isLoading = false;

    if (response.success && response.data != null) {
      _currentUser = response.data;
      await _saveSession(_currentUser!);
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'NIP/NIK atau password salah';
      notifyListeners();
      return false;
    }
  }
}
```

**Poin penting:**
- `_saveSession` menyimpan user ke **`SharedPreferences`** (JSON) — jadi login tetap tersimpan walau app ditutup
- `loadSession()` dipanggil di `main.dart` saat startup (`AuthProvider(authRepo)..loadSession()`)
- `_isInitializing` → menampilkan loading spinner di `main.dart` selama session dimuat

### `TaskProvider` (Fetch + Submit)

```dart
class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  Future<void> fetchTasks({String? classId, String? guruId, String? siswaId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _taskRepo.getTasks(classId: classId, guruId: guruId, siswaId: siswaId);
    _isLoading = false;

    if (response.success && response.data != null) {
      _tasks = response.data!;
    } else {
      _error = response.message ?? 'Gagal mengambil daftar tugas';
    }
    notifyListeners();
  }
}
```

### Menggunakan Provider di UI

```dart
// Aksi (baca sekali)
context.read<TaskProvider>().fetchTasks(classId: currentUser?.classId);

// Tampilan (subscribe — rebuild saat berubah)
final taskProvider = context.watch<TaskProvider>();

// Atau dengan Consumer untuk rebuild bagian tertentu saja
Consumer<TaskProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.tasks.isEmpty) return const EmptyStateWidget(...);
    return ListView.builder(...);
  },
)
```

**Poin penting:**
- `read` → jangan pernah pakai untuk tampilan (tidak rebuild)
- `watch`/`Consumer` → jangan pernah pakai di dalam callback (mis. `onPressed`)
- Prinsip: **UI membaca state, provider mengubah state, repository memanggil API**

---

## 6. End-to-End Testing & Review

### Alur Lengkap Aplikasi

1. **Daftar** sebagai guru (NIP) atau siswa (NIK + pilih kelas) → `POST /api/auth/register`
2. **Login** → `POST /api/auth/login` → user disimpan di `SharedPreferences`
3. **Guru:** buat tugas baru (pilih kelas, tanggal mulai/selesai, opsi tugas kelompok) → `POST /api/tasks`
4. **Siswa:** lihat daftar tugas (filter `classId` + `siswaId`) → `GET /api/tasks`
5. **Siswa:** kumpulkan tugas (submit URL + catatan + anggota tim) → `POST /api/submissions`
6. **Guru:** lihat detail pengumpulan per siswa → `GET /api/tasks/:id/submissions`

### Checklist Hasil Akhir Sesi 2
- [ ] Database Neon dibuat di region `aws-us-east-2`, schema ter-push (5 tabel), seed 12 kelas berhasil
- [ ] API Hono berjalan lokal (`localhost:8787`), semua endpoint bisa diuji dengan Postman/REST Client
- [ ] `DioClient` memahami base URL switching (emulator `10.0.2.2`)
- [ ] `AuthProvider.login` menyimpan session dan `loadSession()` bekerja setelah app restart
- [ ] Guru bisa membuat tugas; siswa bisa melihat & mengumpulkan tugas; status berubah di UI
- [ ] Alur end-to-end lengkap berjalan tanpa error

### Diff & Merge `session-2-final`

```bash
git diff session-2-start..session-2-final --stat
git diff session-2-start..session-2-final -- flutter_training/lib/providers/task_provider.dart
git merge session-2-final
```

---

## Latihan / Tugas Akhir

1. Tambahkan endpoint baru di backend: `DELETE /api/tasks/:id` (hapus tugas) dan implementasikan di `TaskRepository` + `TaskProvider`.
2. Tambahkan validasi di backend: `POST /api/auth/register` harus menolak jika `nipNik` sudah terdaftar (saat ini error datang dari constraint unique — coba tangani lebih baik).
3. Buat halaman "Riwayat Pengumpulan" di aplikasi siswa yang menampilkan tugas yang sudah dikumpulkan beserta tanggalnya.

## Sumber Belajar
- [Hono Documentation](https://hono.dev)
- [Drizzle ORM](https://orm.drizzle.team)
- [Neon Docs — Functions](https://neon.com/docs/compute/functions/overview)
- [Dio Package](https://pub.dev/packages/dio)
- [Provider Package](https://pub.dev/packages/provider)
