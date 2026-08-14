# Session 3: Backend Hono + Neon, Dio Integration & Login

> **Hari 3 — Sabtu, 22 Agustus** (09:30–12:00 pagi, 13:00–14:30 siang, break 12:00–13:00)

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-3-start`** (= hasil akhir `session-2-final`)
> - Hasil akhir sesi ini tersimpan di branch **`session-3-final`** (login screen + timeout handling)
> - Di akhir sesi bandingkan dengan `git diff` dan ambil referensi dengan `git merge session-3-final`

## Objectives
- Memahami arsitektur backend: **Hono + Drizzle + Neon PostgreSQL** (5 tabel)
- Membuat & menjalankan API lokal (register, login, tasks, submissions)
- Menghubungkan Flutter (Dio) ke API sungguhan
- **Login dengan NIP/NIK + password**, simpan sesi via `shared_preferences`
- Menangani error & timeout dengan pesan ramah (`DioClient.getErrorMessage`)

## Agenda (4 jam efektif)
1. Review Sesi 2 & demo akhir (15 menit)
2. Setup backend project (30 menit)
3. Database schema & migration (45 menit)
4. Hono routes: auth & classes (45 menit)
5. Hono routes: tasks & submissions (30 menit)
6. Dio integration: AuthRepository (40 menit)
7. Session persistence: shared_preferences (40 menit)
8. Login screen & timeout handling (20 menit)
9. Review, merge, preview Sesi 4 (15 menit)

---

## 1. Review Sesi 2 & Demo Akhir

Kemarin kita punya arsitektur berlapis + Dio, tapi masih dengan data mock/API lokal. Hari ini kita bangun **backend sungguhan** dan sambungkan:

```text
Flutter App (Dio)
    ↕ HTTP / JSON
Hono API (TypeScript)
    ↕ Drizzle ORM
Neon PostgreSQL (5 tabel)
```

**Demo akhir:** register → login → dashboard (role) → buat tugas → kumpulkan → cek status — **end-to-end**.

---

## 2. Setup Backend Project

Struktur `flutter-task-api/`:

```text
flutter-task-api/
├── src/
│   ├── index.ts              # Hono app + semua routes
│   └── db/
│       ├── schema.ts         # Definisi 5 tabel (Drizzle)
│       ├── seed.ts           # Data awal (kelas, contoh user)
│       └── reset.ts          # Hapus semua data
├── drizzle/                  # Hasil generate migration
├── drizzle.config.ts
├── neon.ts                   # Neon Functions entry
├── package.json
└── .env.example              # Template environment
```

```bash
cd flutter-task-api
npm install
npm run dev
```

> **Prasyarat:** Neon CLI sudah terpasang & terautentikasi dari Setup — cek dengan `neon me`.

> **Checkpoint:** server jalan di `localhost:3000`, `GET /api/classes` merespons.

---

## 3. Database Schema & Migration

### 3.1 Lima Tabel di `src/db/schema.ts`

```ts
// 1. Tabel Classes
export const classes = pgTable('classes', {
  id: uuid('id').defaultRandom().primaryKey(),
  tingkat: varchar('tingkat', { length: 5 }).notNull(),      // 'X', 'XI', 'XII'
  namaKelas: varchar('nama_kelas', { length: 5 }).notNull(), // 'a', 'b', 'c', 'd'
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => [
  uniqueIndex('tingkat_nama_kelas_idx').on(table.tingkat, table.namaKelas),
]);

// 2. Tabel Users
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  nama: varchar('nama', { length: 100 }).notNull(),
  role: varchar('role', { length: 10 }).notNull(),           // 'guru' | 'siswa'
  nipNik: varchar('nip_nik', { length: 50 }).notNull().unique(),
  email: varchar('email', { length: 100 }),
  passwordHash: text('password_hash').notNull(),
  classId: uuid('class_id').references(() => classes.id, { onDelete: 'set null' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// 3. Tabel Tasks
export const tasks = pgTable('tasks', {
  id: uuid('id').defaultRandom().primaryKey(),
  guruId: uuid('guru_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  classId: uuid('class_id').notNull().references(() => classes.id, { onDelete: 'cascade' }),
  description: text('description').notNull(),
  startDate: timestamp('start_date').notNull(),
  endDate: timestamp('end_date').notNull(),
  attachmentUrl: text('attachment_url'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

// 4. Tabel Submissions
export const submissions = pgTable('submissions', {
  id: uuid('id').defaultRandom().primaryKey(),
  taskId: uuid('task_id').notNull().references(() => tasks.id, { onDelete: 'cascade' }),
  siswaId: uuid('siswa_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  submitUrl: text('submit_url').notNull(),
  notes: text('notes'),
  submittedAt: timestamp('submitted_at').defaultNow().notNull(),
});
```

**Poin penting (relasi & onDelete):**
- `users.classId → classes.id` dengan `onDelete: 'set null'` — jika kelas dihapus, user tetap ada (classId jadi null)
- `tasks.guruId → users.id` dengan `onDelete: 'cascade'` — jika guru dihapus, tugasnya ikut terhapus
- `submissions.taskId → tasks.id` dengan `onDelete: 'cascade'` — jika tugas dihapus, pengumpulannya ikut terhapus
- `nip_nik` unik — satu NIP/NIK hanya bisa daftar sekali

### 3.2 Migration ke Neon

```bash
# Buat migration dari schema
npm run db:generate

# Terapkan ke database Neon
npm run db:push
```

> **Checkpoint:** 5 tabel terbuat di Neon (cek via `neon` CLI / dashboard).

---

## 4. Hono Routes: Auth & Classes

### 4.1 Register (`POST /api/auth/register`)

```ts
app.post('/api/auth/register', async (c) => {
  const { nama, role, nipNik, password, email, classId } = await c.req.json();

  // Validasi role
  if (!['guru', 'siswa'].includes(role)) {
    return c.json({ success: false, message: 'Role tidak valid' }, 400);
  }

  // Hash password
  const passwordHash = await Bun.password.hash(password);

  // Cek duplikat NIP/NIK
  const existing = await db.select().from(users).where(eq(users.nipNik, nipNik));
  if (existing.length > 0) {
    return c.json({ success: false, message: 'NIP/NIK sudah terdaftar' }, 409);
  }

  const [user] = await db.insert(users).values({ ... }).returning();
  return c.json({ success: true, data: user });
});
```

### 4.2 Login (`POST /api/auth/login`)

```ts
app.post('/api/auth/login', async (c) => {
  const { nipNik, password } = await c.req.json();

  const [user] = await db.select().from(users).where(eq(users.nipNik, nipNik));
  if (!user) {
    return c.json({ success: false, message: 'NIP/NIK tidak ditemukan' }, 404);
  }

  const valid = await Bun.password.verify(password, user.passwordHash);
  if (!valid) {
    return c.json({ success: false, message: 'Password salah' }, 401);
  }

  return c.json({ success: true, data: user });
});
```

### 4.3 Classes (`GET /api/classes`)

```ts
app.get('/api/classes', async (c) => {
  const allClasses = await db.select().from(classes);
  return c.json({ success: true, data: allClasses });
});
```

**Latihan:** implement register & login mengikuti kode di atas, test dengan curl/Postman.

> **Checkpoint:** `POST /api/auth/register` + `POST /api/auth/login` sukses via curl.

---

## 5. Hono Routes: Tasks & Submissions

```ts
// Guru membuat tugas
app.post('/api/tasks', async (c) => {
  const { guruId, classId, description, startDate, endDate, attachmentUrl } = await c.req.json();
  const [task] = await db.insert(tasks).values({ ... }).returning();
  return c.json({ success: true, data: task }, 201);
});

// Siswa melihat tugas kelas
app.get('/api/tasks', async (c) => {
  const { classId, siswaId } = c.req.query();
  // ... filter berdasarkan classId, cek status pengumpulan siswa
});

// Siswa mengumpulkan tugas
app.post('/api/submissions', async (c) => {
  const { taskId, siswaId, submitUrl, notes } = await c.req.json();
  const [submission] = await db.insert(submissions).values({ ... }).returning();
  return c.json({ success: true, data: submission }, 201);
});

// Guru cek status pengumpulan
app.get('/api/tasks/:id/submissions', async (c) => {
  const taskId = c.req.param('id');
  // ... list submissions dengan data siswa
});
```

**Latihan:** implement minimal task CRUD + submissions.

> **Checkpoint:** bisa buat tugas via API (`POST /api/tasks`).

---

## 6. Dio Integration: AuthRepository

```dart
// lib/repositories/auth_repository.dart
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
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<UserModel>> registerUser({
    required String nama,
    required String role,
    required String nipNik,
    required String password,
    String? email,
    String? classId,
  }) async {
    // ... POST /api/auth/register
  }
}
```

**Latihan:** implement `loginUser` + `registerUser` di `AuthRepository`, lalu `login()` di `AuthProvider`.

> **Checkpoint:** login berhasil dari Flutter (user tersimpan di provider).

---

## 7. Session Persistence: shared_preferences

```bash
fvm flutter pub add shared_preferences
```

### AuthProvider dengan Persistensi

```dart
// lib/providers/auth_provider.dart (ringkas)
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> login({required String nipNik, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authRepository.loginUser(nipNik: nipNik, password: password);
    if (response.success) {
      _currentUser = response.data;
      await _saveSession(response.data!);   // simpan ke shared_preferences
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
    return response.success;
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_nama', user.nama);
    await prefs.setString('user_role', user.role);
    // ...
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }
}
```

**Poin penting:**
- `SharedPreferences` → simpan data kecil (session) secara lokal & persisten
- Auto-login: saat app dibuka, baca `prefs`, restore `_currentUser`
- `logout()` → clear prefs + null-kan user

**Latihan:** implement `_restoreSession()` di `initState`/`main()` — tutup & buka app → tetap login.

> **Checkpoint:** tutup & buka app → tetap login (session persist).

---

## 8. Login Screen & Timeout Handling

### 8.1 LoginScreen

```dart
// lib/screens/auth/login_screen.dart
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipNikController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      nipNik: _nipNikController.text,
      password: _passwordController.text,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Gagal masuk. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // build(): Form dengan TextFormField NIP/NIK + Password, tombol Masuk
}
```

### 8.2 Timeout Handling (`DioClient.getErrorMessage`)

```dart
static String getErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi ke server timeout (waktu habis). Silakan periksa koneksi internet atau server backend.';
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
```

**Poin penting:**
- Setiap tipe `DioException` punya pesan ramah untuk user (bukan stack trace)
- `connectionTimeout` → pesan khusus "timeout"
- `badResponse` → ambil pesan dari backend jika ada

**Latihan:** implement `LoginScreen` + hubungkan ke `AuthProvider.login()`. Matikan server → login → lihat pesan timeout yang rapi.

> **Checkpoint:** app menampilkan pesan timeout/error yang ramah jika server mati.

---

## 9. Review, Merge & Preview Sesi 4

```bash
# 1. Bandingkan dengan referensi
git diff session-3-start..session-3-final --stat

# 2. Ambil hasil referensi (jika tertinggal)
git merge session-3-final
```

**Preview Sesi 4 (besok):** **workshop** — replikasi project dari nol, improvement (fitur baru), dan Q&A. Aplikasi sudah **end-to-end lengkap** — besok saatnya berkreasi!

### Checklist Hasil Akhir Sesi 3
- [ ] Backend Hono jalan dengan 5 tabel di Neon
- [ ] Register & login berfungsi via API (curl/Postman)
- [ ] Flutter terhubung ke backend sungguhan via Dio
- [ ] Login screen berfungsi (NIP/NIK + password, error state)
- [ ] Session persisten (tutup & buka app → tetap login)
- [ ] Pesan timeout/error ramah untuk user

---

## Latihan / Tugas Rumah
1. Tambahkan validasi di register: tolak NIP/NIK duplikat dengan pesan ramah (cek status 409).
2. Implement `SchoolRepository.fetchClasses()` + tampilkan dropdown kelas di halaman register.
3. Coba deploy backend ke **Neon Functions** (lihat `neon.ts`) — atau setidaknya pahami konsepnya.

## Sumber Belajar
- [Hono Documentation](https://hono.dev/)
- [Drizzle ORM](https://orm.drizzle.team/)
- [Neon Functions](https://neon.com/docs/functions/overview)
- [shared_preferences Package](https://pub.dev/packages/shared_preferences)
