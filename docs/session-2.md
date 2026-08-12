# Session 2: Arsitektur Berlapis, Model, Repository & Dio

> **Hari 2 — Minggu, 16 Agustus** (09:00–12:00 pagi, 13:00–15:00 siang, break 12:00–13:00)

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-2-start`** (= hasil akhir `session-1-final`)
> - Hasil akhir sesi ini tersimpan di branch **`session-2-final`** (re-arch lengkap dengan Dio)
> - Di akhir sesi bandingkan dengan `git diff` dan ambil referensi dengan `git merge session-2-final`

## Objectives
- Memahami **arsitektur berlapis**: `models/` → `repositories/` → `providers/` → `screens/`
- Membuat model Dart lengkap dengan `fromJson`/`toJson` (serialization manual)
- Memahami **repository pattern** sebagai abstraksi sumber data
- Mengganti `http` → **Dio** (interceptor, error handling, `ApiResponse` wrapper)
- Membuat **halaman role-based** (siswa & guru) dengan routing otomatis

## Agenda (4 jam efektif)
1. Review Sesi 1 & preview target (15 menit)
2. Arsitektur berlapis (30 menit)
3. Model lengkap: `fromJson`/`toJson` (45 menit)
4. Repository pattern (30 menit)
5. Dio client & error handling (45 menit)
6. Home screen siswa (40 menit)
7. Home screen guru + role-based routing (40 menit)
8. Integrasi & polish (20 menit)
9. Review, merge, preview Sesi 3 (15 menit)

---

## 1. Review Sesi 1 & Preview Target

Kemarin kita membangun app tugas minimal dengan `http` + `Provider`. Hari ini kita **re-architect** menjadi struktur berlapis yang dipakai di industri:

```text
lib/
├── main.dart                    # Entry point + DI (dependency injection)
├── core/network/                # DioClient, ApiResponse
├── models/                      # TaskModel, UserModel, ClassModel, SubmissionModel
├── repositories/                # AuthRepository, SchoolRepository, TaskRepository
├── providers/                   # AuthProvider, SchoolProvider, TaskProvider
└── screens/
    ├── auth/                    # register_screen.dart
    ├── guru/                    # teacher_home_screen.dart
    └── siswa/                   # student_home_screen.dart
```

> **Kenapa berlapis?** Memisahkan UI (screens), state (providers), akses data (repositories), dan representasi data (models) → mudah diuji, dirawat, dan dipahami.

---

## 2. Arsitektur Berlapis

```text
Screen (UI)
   ↓  context.watch<T>()
Provider (state)
   ↓  panggil method
Repository (akses data)
   ↓  Dio HTTP
API (backend Hono)
```

| Layer | Tanggung jawab | Contoh |
|---|---|---|
| `screens/` | Tampilan UI, menangani interaksi pengguna | `StudentHomeScreen` |
| `providers/` | State management, memanggil repository | `TaskProvider` |
| `repositories/` | Abstraksi sumber data (API), parsing response | `TaskRepository` |
| `models/` | Representasi data (JSON ↔ object) | `TaskModel` |
| `core/network/` | Infrastruktur HTTP (Dio, ApiResponse) | `DioClient` |

**Aliran data (satu arah):** Screen → Provider → Repository → API → Database.

---

## 3. Model Lengkap: `fromJson`/`toJson`

Model di project nyata lebih kompleks dari `Task` kemarin. Lihat `lib/models/task_model.dart`:

```dart
class TaskModel {
  final String id;
  final String guruId;
  final String classId;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentUrl;

  TaskModel({
    required this.id,
    required this.guruId,
    required this.classId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentUrl,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      guruId: json['guruId'] ?? json['guru_id'],
      classId: json['classId'] ?? json['class_id'],
      description: json['description'],
      startDate: json['startDate'] ?? json['start_date'],
      endDate: json['endDate'] ?? json['end_date'],
      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guruId': guruId,
      'classId': classId,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'attachmentUrl': attachmentUrl,
    };
  }
}
```

**Poin penting:**
- `json['guruId'] ?? json['guru_id']` → **fallback key** — backend bisa kirim camelCase atau snake_case
- `String? attachmentUrl` → nullable (tugas tidak wajib punya lampiran)
- `toJson()` → kebalikan dari `fromJson`, untuk kirim data ke API

**Latihan:** buat `UserModel` (id, nama, role, nipNik, email?, classId?) dengan `fromJson`/`toJson`.

---

## 4. Repository Pattern

Repository = **abstraksi sumber data**. Screen tidak perlu tahu apakah data datang dari API, cache, atau database lokal — cukup panggil method repository.

```dart
// lib/repositories/task_repository.dart
class TaskRepository {
  final DioClient _client;

  TaskRepository(this._client);

  Future<ApiResponse<TaskModel>> createTask({
    required String guruId,
    required String classId,
    required String description,
    required String startDate,
    required String endDate,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _client.dio.post('/api/tasks', data: {
        'guruId': guruId,
        'classId': classId,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'attachmentUrl': attachmentUrl,
      });

      return ApiResponse<TaskModel>.fromJson(
        response.data,
        (json) => TaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<TaskModel>(
        success: false,
        message: e.response?.data?['message'] ?? e.message,
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<TaskModel>(success: false, message: e.toString());
    }
  }
  // ... submitTask(), fetchTasks(), dll.
}
```

**Poin penting:**
- Repository menerima `DioClient` via **constructor** (dependency injection)
- `DioException` → tangkap error jaringan/HTTP, parse pesan dari response
- Selalu mengembalikan `ApiResponse` (bukan raw exception) → UI mudah menangani

---

## 5. Dio Client & Error Handling

### 5.1 `DioClient` — Konfigurasi HTTP

```dart
// lib/core/network/dio_client.dart
class DioClient {
  late final Dio dio;

  DioClient() {
    String baseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8787',
    );

    // Android emulator: localhost -> 10.0.2.2
    if (!kIsWeb && Platform.isAndroid && baseUrl.contains('localhost')) {
      baseUrl = baseUrl.replaceAll('localhost', '10.0.2.2');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
}
```

**Poin penting:**
- `10.0.2.2` → alamat host dari Android Emulator (bukan `localhost`)
- `connectTimeout`/`receiveTimeout` → 10 detik, cegah hang selamanya
- `LogInterceptor` → debug request/response di console
- `--dart-define=API_BASE_URL=...` → override base URL saat build

### 5.2 `ApiResponse<T>` — Wrapper Response

```dart
// lib/core/network/api_response.dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
    );
  }
}
```

**Poin penting:**
- Generic `<T>` → bisa dipakai untuk response apa pun (TaskModel, UserModel, dll.)
- `success` → cepat cek apakah request berhasil
- `message`/`error` → pesan untuk ditampilkan ke user

---

## 6. Home Screen Siswa

```dart
// lib/screens/siswa/student_home_screen.dart
class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    context.read<TaskProvider>().fetchTasks(
          classId: currentUser?.classId,
          siswaId: currentUser?.id,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSubmitTaskBottomSheet(context),
        icon: const Icon(Icons.upload_file),
        label: const Text('Kumpulkan Tugas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTasks(),
        child: /* ListView tugas atau EmptyStateWidget */,
      ),
    );
  }
}
```

**Poin penting:**
- `addPostFrameCallback` → panggil aksi setelah frame pertama (cegah error saat build)
- `context.read<T>()` → baca provider sekali (untuk aksi)
- `context.watch<T>()` → subscribe & rebuild saat provider berubah (untuk tampilan)
- `FloatingActionButton.extended` → FAB dengan ikon + teks

---

## 7. Home Screen Guru & Role-Based Routing

### 7.1 Routing Berdasarkan Role

```dart
// lib/main.dart
home: Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    if (!authProvider.isAuthenticated) {
      return const RegisterScreen();
    }
    if (authProvider.currentUser?.role == 'guru') {
      return const TeacherHomeScreen();
    } else {
      return const StudentHomeScreen();
    }
  },
),
```

**Poin penting:**
- Aplikasi memilih halaman awal berdasarkan **status login + role** pengguna
- `Consumer<AuthProvider>` → rebuild otomatis saat `notifyListeners()`

### 7.2 Dependency Injection di `main.dart`

```dart
void main() {
  final dioClient = DioClient();
  final authRepo = AuthRepository(dioClient);
  final schoolRepo = SchoolRepository(dioClient);
  final taskRepo = TaskRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
        ChangeNotifierProvider(create: (_) => SchoolProvider(schoolRepo)..fetchClasses()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepo)),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Poin penting:**
- **Dependency Injection**: `DioClient` dibuat sekali, disuntikkan ke semua repository
- `..fetchClasses()` → cascade operator, panggil method setelah create

### 7.3 Teacher Home Screen

```dart
// lib/screens/guru/teacher_home_screen.dart
// Konten berbeda dari siswa: daftar kelas, buat tugas, lihat pengumpulan
Scaffold(
  appBar: AppBar(
    title: const Text('Dashboard Guru'),
    actions: [/* logout */],
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => _showCreateTaskDialog(context),
    icon: const Icon(Icons.add_task),
    label: const Text('Buat Tugas'),
  ),
  body: /* daftar kelas + tugas yang dibuat guru */,
)
```

**Latihan:** implement `TeacherHomeScreen` — tampilkan daftar tugas milik guru (filter `guruId`), tombol buat tugas.

> **Checkpoint:** bisa navigasi siswa ↔ guru berdasarkan role.

---

## 8. Integrasi & Polish

- Pastikan `main.dart` memakai `MultiProvider` (Auth, School, Task)
- Semua screen membaca state dari provider (bukan `setState` lokal)
- `RefreshIndicator` untuk pull-to-refresh di kedua home screen
- Error state & empty state ditampilkan rapi

> **Checkpoint:** app jalan end-to-end dengan struktur bersih.

---

## 9. Review, Merge & Preview Sesi 3

```bash
# 1. Bandingkan dengan referensi
git diff session-2-start..session-2-final --stat

# 2. Ambil hasil referensi (jika tertinggal)
git merge session-2-final
```

> **Kenapa `git merge` di sesi ini?** Karena `session-2-start` dan `session-2-final` berbagi struktur yang sama (peserta melanjutkan dari `session-1-final`) — merge akan berjalan mulus tanpa konflik besar.

**Preview Sesi 3 (Sabtu depan):** backend Hono + Neon PostgreSQL, Dio integration sungguhan, login dengan NIP/NIK, sesi persisten via `shared_preferences`.

### Checklist Hasil Akhir Sesi 2
- [ ] Struktur folder berlapis dipahami (core, models, repositories, providers, screens)
- [ ] Model lengkap dengan `fromJson`/`toJson` (fallback key camelCase/snake_case)
- [ ] Repository pattern dengan `ApiResponse<T>` dipahami
- [ ] `DioClient` dengan interceptor & timeout berfungsi
- [ ] Role-based routing (guru/siswa) berjalan
- [ ] App jalan end-to-end (data dari API lokal)

---

## Latihan / Tugas Rumah
1. Buat `ClassModel` (id, nama, tingkatan) dengan `fromJson`/`toJson`.
2. Implement `AuthRepository.register()` — POST `/api/auth/register` dengan `ApiResponse<UserModel>`.
3. Jelaskan aliran data: dari tombol "Kumpulkan Tugas" di UI sampai tersimpan di database — sebutkan layer yang terlibat.

## Sumber Belajar
- [Dio Package](https://pub.dev/packages/dio)
- [Provider Package](https://pub.dev/packages/provider)
- [JSON Serialization in Flutter](https://docs.flutter.dev/data-and-backend/json)
