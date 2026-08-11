# Session 1: Dasar Flutter & Membangun Dashboard Siswa

## Durasi: 4 jam

> **Branch workflow sesi ini:**
> - Mulai dari branch **`session-1-start`**
> - Hasil akhir sesi ini tersimpan di branch **`session-1-final`**
> - Di akhir sesi kita akan `git diff` dan `git merge session-1-final` untuk memverifikasi hasil.

## Objectives
- Memahami dasar bahasa Dart: tipe data, null-safety, class, dan `factory` constructor
- Memahami widget Flutter: `StatelessWidget` vs `StatefulWidget`, `BuildContext`, layout
- Membangun UI dashboard siswa secara bertahap mengikuti kode nyata di `flutter_training/`
- Mengenal arsitektur folder project Flutter: `lib/core`, `lib/models`, `lib/screens`, dll.

## Agenda
1. Pengenalan Flutter & struktur project (30 menit)
2. Dart Essentials: class, null-safety, factory (60 menit)
3. Widget & Layout Flutter (45 menit)
4. Hands-on: Membangun UI Dashboard Siswa (75 menit)
5. Review, `git diff`, dan merge `session-1-final` (30 menit)

---

## 1. Pengenalan Flutter & Struktur Project

### Apa itu Flutter?
- **Flutter SDK:** Framework UI open-source dari Google untuk membangun aplikasi mobile (Android/iOS), web, dan desktop dari satu codebase.
- **Dart Language:** Bahasa pemrograman yang digunakan Flutter, berbasis OOP, *strongly-typed*, dengan null-safety.
- **Hot Reload:** Perubahan kode langsung terlihat di emulator/perangkat tanpa rebuild penuh — mempercepat iterasi pengembangan.

### Struktur Folder Project (`flutter_training/`)

Project di repo ini sudah memiliki arsitektur berlapis (layered architecture) yang membagi tanggung jawab:

```text
flutter_training/
├── lib/
│   ├── main.dart                    # Entry point aplikasi (runApp + MultiProvider)
│   ├── core/                        # Utilitas lintas fitur
│   │   ├── network/                 #   - dio_client.dart, api_response.dart
│   │   └── utils/                   #   - url_launcher_utils.dart
│   ├── models/                      # Model data (TaskModel, UserModel, ClassModel, ...)
│   ├── providers/                   # State management (AuthProvider, TaskProvider, ...)
│   ├── repositories/                # Lapisan akses data ke API (AuthRepository, ...)
│   ├── screens/                     # Halaman UI
│   │   ├── auth/                    #   - login_screen.dart, register_screen.dart
│   │   ├── guru/                    #   - teacher_home_screen.dart, task_detail_screen.dart
│   │   └── siswa/                   #   - student_home_screen.dart
│   └── widgets/                     # Widget reusable (empty_state_widget.dart)
├── pubspec.yaml                     # Daftar dependency project
├── android/  ios/  web/             # Folder platform
```

> **Kenapa berlapis?** Memisahkan UI (screens), logika/state (providers), akses data (repositories), dan representasi data (models) membuat kode mudah dirawat, diuji, dan dipahami — ini pola yang dipakai di industri.

### Dependency di `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  provider: ^6.1.5+1      # State management
  dio: ^5.11.0            # HTTP client
  shared_preferences: ^2.5.5  # Simpan sesi login lokal
  url_launcher: ^6.3.2    # Membuka link eksternal
```

---

## 2. Dart Essentials: Class, Null-Safety, Factory

Dart adalah bahasa modern dengan **null-safety**: sebuah variabel secara default *tidak boleh* bernilai `null` kecuali dinyatakan dengan `?`.

### Variabel & Tipe Data

```dart
String nama = 'Budi';        // String
int tahun = 2026;            // Integer
double nilai = 87.5;         // Double (desimal)
bool aktif = true;           // Boolean

// Nullable: boleh bernilai null
String? email;               // default: null
int? umur;

// List dan Map
List<String> peserta = ['Budi', 'Siti'];
Map<String, dynamic> user = {'nama': 'Budi', 'role': 'siswa'};
```

### Class & Constructor

Lihat `lib/models/user_model.dart` — ini contoh nyata dari project:

```dart
class UserModel {
  final String id;
  final String nama;
  final String role;        // 'guru' | 'siswa'
  final String nipNik;
  final String? email;      // nullable: siswa boleh tidak punya email
  final String? classId;    // nullable: guru tidak punya classId

  UserModel({
    required this.id,
    required this.nama,
    required this.role,
    required this.nipNik,
    this.email,
    this.classId,
  });
}
```

**Poin penting:**
- `final` → nilai tidak bisa diubah setelah di-set (immutable)
- `required` → parameter wajib diisi saat memanggil constructor
- Named parameters (`{...}`) → lebih jelas daripada positional

### Factory Constructor: JSON → Object

Data dari API berbentuk JSON (`Map<String, dynamic>`). Factory constructor mengubahnya menjadi object Dart:

```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    nama: json['nama'],
    role: json['role'],
    nipNik: json['nipNik'] ?? json['nip_nik'],
    email: json['email'],
    classId: json['classId'] ?? json['class_id'],
  );
}
```

**Poin penting:**
- `factory` → constructor yang *tidak selalu* membuat instance baru, bisa melakukan transformasi
- `json['nipNik'] ?? json['nip_nik']` → fallback jika key tidak ada (backend bisa kirim dua format berbeda)
- Kebalikannya, `toJson()` mengubah object kembali ke `Map<String, dynamic>` sebelum dikirim ke API

### Contoh Model Lain: `TaskModel`

`lib/models/task_model.dart` lebih kompleks karena punya data bertingkat (team members):

```dart
class TaskModel {
  final String id;
  final String guruId;
  final String classId;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentUrl;
  final bool isTeamTask;
  final int maxTeamMembers;
  final bool isSubmitted;
  final List<TeamMemberInfo> teamMembers;   // nested model
  // ... constructor, fromJson, toJson
}
```

**Latihan singkat:** Sebutkan perbedaan `fromJson` pada `TaskModel` vs `UserModel`. Kenapa `TaskModel.fromJson` perlu memproses `teamMembers` secara terpisah?

---

## 3. Widget & Layout Flutter

Di Flutter, **semuanya adalah widget**. UI dibangun dengan menyusun widget di dalam widget (composition).

### StatelessWidget vs StatefulWidget

```dart
// StatelessWidget: statis, tidak punya state yang berubah
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  const EmptyStateWidget({super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
```

```dart
// StatefulWidget: punya state yang bisa berubah + setState()
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipNikController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nipNikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  // ... build()
}
```

**Aturan emas:**
- Gunakan `StatelessWidget` jika UI tidak berubah setelah dibangun
- Gunakan `StatefulWidget` jika ada data yang berubah (input form, loading, hasil API)
- **Selalu `dispose()` controller** untuk mencegah memory leak

### BuildContext

`BuildContext` adalah "lokasi" widget di dalam tree. Digunakan untuk:
- Mengakses tema: `Theme.of(context)`
- Navigasi: `Navigator.push(context, ...)`
- Menampilkan SnackBar: `ScaffoldMessenger.of(context)`
- Mengakses Provider: `context.read<T>()`, `context.watch<T>()`

### Layout Dasar

| Widget | Fungsi |
|---|---|
| `Column` | Susun anak secara vertikal |
| `Row` | Susun anak secara horizontal |
| `Container` | Kotak dengan padding/margin/decoration |
| `ListView` | Daftar scrollable |
| `Card` | Kontainer bergaya kartu (Material) |
| `Scaffold` | Kerangka halaman (AppBar, body, FAB) |

Contoh nyata dari `student_home_screen.dart`:

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Dashboard Siswa'),
    actions: [
      IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTasks),
      IconButton(icon: const Icon(Icons.logout), onPressed: () => authProvider.logout()),
    ],
  ),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () => _showSubmitTaskBottomSheet(context),
    icon: const Icon(Icons.upload_file),
    label: const Text('Kumpulkan Tugas'),
  ),
  body: RefreshIndicator(
    onRefresh: () async => _loadTasks(),
    child: ...,
  ),
)
```

**Poin penting:**
- `AppBar` punya `actions` untuk tombol di kanan atas
- `FloatingActionButton.extended` → FAB dengan ikon + teks
- `RefreshIndicator` → pull-to-refresh bawaan Material

---

## 4. Hands-on: Membangun UI Dashboard Siswa

Kita akan membangun bagian-bagian utama aplikasi **dari nol**, mengikuti kode nyata di repo. Mulai dari `session-1-start`.

### 4.1 Entry Point: `main.dart`

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  final authRepo = AuthRepository(dioClient);
  final schoolRepo = SchoolRepository(dioClient);
  final taskRepo = TaskRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: schoolRepo),
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
- `WidgetsFlutterBinding.ensureInitialized()` → wajib sebelum pakai plugin native
- **Dependency Injection:** object (`DioClient`, repositories) dibuat sekali, lalu disuntikkan ke Provider
- `MultiProvider` → mendaftarkan beberapa provider sekaligus

### 4.2 Routing Berdasarkan Role

```dart
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
- `Consumer<AuthProvider>` → rebuild otomatis saat provider `notifyListeners()`
- Aplikasi memilih halaman awal berdasarkan **status login dan role** pengguna

### 4.3 Dashboard Siswa (`student_home_screen.dart`)

Struktur utama halaman:

```dart
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
    // ... Scaffold dengan AppBar, FAB, body
  }
}
```

**Poin penting:**
- `addPostFrameCallback` → panggil aksi setelah frame pertama selesai (mencegah `setState` saat build)
- `context.read<T>()` → baca provider sekali (untuk aksi)
- `context.watch<T>()` → subscribe dan rebuild saat provider berubah (untuk tampilan)

### 4.4 Empty State Widget (Reusable)

`lib/widgets/empty_state_widget.dart` adalah contoh widget reusable dengan properti yang bisa dikonfigurasi:

```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRefresh;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.assignment_outlined,
    required this.title,
    required this.message,
    this.onRefresh,
  });
  // ... build: ikon dalam lingkaran berwarna primary, teks, tombol "Muat Ulang"
}
```

**Kenapa reusable?** Karena dipakai di beberapa halaman (dashboard siswa & guru) dengan ikon/teks berbeda — satu widget, banyak pemakaian. Ini prinsip **DRY (Don't Repeat Yourself)**.

### Checklist Hasil Akhir Sesi 1
- [ ] Struktur folder `lib/` dipahami (core, models, providers, repositories, screens, widgets)
- [ ] `UserModel` dan `TaskModel` dengan `fromJson`/`toJson` dipahami
- [ ] `main.dart` dengan `MultiProvider` dan routing role dipahami
- [ ] `LoginScreen` dan `StudentHomeScreen` dibangun mengikuti kode nyata
- [ ] Aplikasi bisa dijalankan (statis, tanpa backend) di emulator/perangkat

---

## 5. Review, Diff, dan Merge `session-1-final`

Di akhir sesi, bandingkan hasil kerja dengan referensi:

```bash
# 1. Lihat semua file yang berubah vs branch start
git diff session-1-start..session-1-final --stat

# 2. Lihat detail perubahan per file
git diff session-1-start..session-1-final -- flutter_training/lib/screens/auth/login_screen.dart

# 3. Ambil hasil referensi (jika tertinggal / mau lanjut)
git merge session-1-final
```

**Kenapa branch `session-1-final`?** Jika ada peserta yang belum selesai, `git merge session-1-final` langsung membawa semua perubahan ke branch kerja peserta — tanpa harus mengetik ulang kode. Peserta bisa melanjutkan ke Session 2 dengan fondasi yang sama.

---

## Latihan / Tugas Rumah

1. Tambahkan halaman **profil** sederhana (`screens/siswa/profile_screen.dart`) yang menampilkan nama, NIP/NIK, dan kelas dari `AuthProvider.currentUser`.
2. Buat widget reusable `StatusChip` untuk menampilkan status tugas ("Belum Dikumpulkan" / "Sudah Dikumpulkan") dengan warna berbeda.
3. Jelaskan dengan kata-kata sendiri: apa bedanya `context.read`, `context.watch`, dan `Consumer`?

## Sumber Belajar
- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
