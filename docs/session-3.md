# Session 3: Homework 1 Minggu — Task Management (Guru)

> **Hari 3 — Sabtu, 15 Agustus → Sabtu, 22 Agustus** (homework 1 minggu, dikumpulkan 22 Agu)

> **Ini berbeda dari sesi sebelumnya!** Mulai sesi ini kita pindah ke **dua repository baru** — kode yang sama persis dengan yang dipakai saat teaching onsite. Repo ini sudah berisi login + session (hasil Sesi 2), dan tugas kalian adalah mengembangkan **fitur Task Management untuk guru** selama 1 minggu.

> **Repository:**
> - **Flutter**: [`flutter_application_training`](https://github.com/indraAsLesmana/flutter_application_training) (package name: `flutter_application_1`)
> - **Backend**: [`flutter-task-api-session1`](https://github.com/indraAsLesmana/flutter-task-api-session1)

> **Branch workflow:** setiap step punya branch sendiri (`s3-start` → `s3-01-*` → `s3-02-*` → `s3-03-*` → `s3-finish`). Di akhir tiap step, bandingkan dengan branch berikutnya untuk memastikan tidak tertinggal.

## Objectives
- Memahami **Task Management** di sisi guru: buat tugas → lihat daftar → detail + status siswa
- Menguasai pola **step-by-step pengembangan**: schema baru → `db:push` → `neon dev` test → `neon deploy`
- Membuat model Dart lengkap (`TaskModel`, `SubmissionModel`, `TeamMemberInfo`, `StudentSubmissionModel`)
- Membangun **TaskProvider + TaskRepository** (pola repository yang sudah dipelajari)
- Membangun **EmptyStateWidget**, **CreateTaskForm**, **list tugas**, dan **TaskDetailScreen**
- Menambahkan dependency baru dengan benar (`fvm flutter pub get`)
- Verifikasi API via **`neon dev`** (lokal) dan **`neon deploy`** (produksi)

## Agenda (1 minggu, 3 step)
1. **Setup** — clone 2 repo, branch `s3-start`, env, `neon dev` (1 hari)
2. **S3-01** — Schema Task + Model + Provider + Repository + EmptyState (2 hari)
3. **S3-02** — List Tugas Guru + API filter (2 hari)
4. **S3-03** — Task Detail + Status Siswa + url_launcher (2 hari)

---

## 1. Setup: Clone & Jalankan

### 1.1 Clone 2 repo + checkout `s3-start`

```bash
# Flutter app
git clone https://github.com/indraAsLesmana/flutter_application_training.git
cd flutter_application_training
git checkout s3-start

# Backend API
git clone https://github.com/indraAsLesmana/flutter-task-api-session1.git
cd flutter-task-api-session1
git checkout s3-start
```

> **Kenapa pindah repo?** Repo ini adalah **live code yang dipakai saat onsite teaching** — lebih relevan dan sudah mengandung login + session (materi Sesi 2). Kita lanjut kembangkan dari sini.

### 1.2 Setup Backend (API repo)

```bash
cd flutter-task-api-session1
npm install
neon login        # sekali saja
neon link         # hubungkan ke project Neon (buat .env.local)
npm run db:push   # terapkan schema (classes + users) ke database
npm run db:seed   # isi 12 kelas (X/a-d, XI/a-d, XII/a-d)
```

### 1.3 Jalankan Backend Lokal: `neon dev`

```bash
neon dev
```

`neon dev` menjalankan Hono API secara lokal (port `8787`) sambil terhubung ke **Neon cloud**. Test dengan curl:

```bash
curl http://localhost:8787/api/classes
# → {"success":true,"data":[{"id":"...","tingkat":"X","namaKelas":"a"},...]}
```

### 1.4 Jalankan Flutter App

```bash
cd flutter_application_training
fvm flutter pub get
fvm flutter run
```

Login dengan akun guru yang sudah didaftarkan di Sesi 2 (atau register baru). Setelah login, muncul **"Dashboard Guru"** dengan teks "Hello Dashboard" — belum ada fitur apa pun. Inilah titik awal S3-01.

---

## 2. S3-01: Schema Task + Model + Provider + Repository + EmptyState

> **Branch:** Flutter `s3-01-task-emptystate` · API `s3-01-taskapi-schema`
> **Fokus:** siapkan fondasi task management — dari database sampai UI kosong.

### 2.1 API: Tambah Schema `tasks` (WAJIB `db:push`!)

Buka `src/db/schema.ts` di API repo — tambahkan tabel `tasks`:

```ts
// src/db/schema.ts (tambahkan di bawah tabel users)
export const tasks = pgTable("tasks", {
  id: uuid("id").defaultRandom().primaryKey(),
  guruId: uuid("guru_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
  classId: uuid("class_id")
    .notNull()
    .references(() => classes.id, { onDelete: "cascade" }),
  description: text("description").notNull(),
  startDate: timestamp("start_date").notNull(),
  endDate: timestamp("end_date").notNull(),
  attachmentUrl: text("attachment_url"),
  isTeamTask: boolean("is_team_task").default(false).notNull(),
  maxTeamMembers: integer("max_team_members").default(5).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
```

> **Pola penting:** setiap kali schema berubah, **wajib `npm run db:push`** untuk menyinkronkan ke database Neon:
> ```bash
> npm run db:push
> ```

### 2.2 API: Routes `POST /api/tasks` + `GET /api/tasks`

Tambahkan di `src/index.ts`:

```ts
app.post("/api/tasks", async (c) => {
  const db = getDb();
  const {
    guruId, classId, description, startDate, endDate,
    attachmentUrl, isTeamTask, maxTeamMembers,
  } = await c.req.json();

  try {
    const newTask = await db
      .insert(tasks)
      .values({
        guruId, classId, description,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        attachmentUrl: attachmentUrl || null,
        isTeamTask: isTeamTask ?? false,
        maxTeamMembers: maxTeamMembers ? parseInt(maxTeamMembers.toString(), 10) : 5,
      })
      .returning();

    return c.json({ success: true, data: newTask[0] }, 201);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});

app.get("/api/tasks", async (c) => {
  const db = getDb();
  const classId = c.req.query("classId");
  const guruId = c.req.query("guruId");
  const siswaId = c.req.query("siswaId");

  try {
    const conditions = [];
    if (classId) conditions.push(eq(tasks.classId, classId));
    if (guruId) conditions.push(eq(tasks.guruId, guruId));

    const taskList =
      conditions.length > 0
        ? await db.select().from(tasks).where(and(...conditions))
        : await db.select().from(tasks);

    return c.json({ success: true, data: taskList });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});
```

**Test dengan `neon dev`** (backend harus jalan):

```bash
# Buat tugas (ganti guruId/classId dengan data dari Drizzle Studio)
curl -X POST http://localhost:8787/api/tasks \
  -H 'content-type: application/json' \
  -d '{"guruId":"<uuid-guru>","classId":"<uuid-kelas>","description":"Tugas 1","startDate":"2026-08-15T00:00:00Z","endDate":"2026-08-22T23:59:59Z"}'

# List tugas
curl http://localhost:8787/api/tasks
```

**Deploy ke Neon Functions:**

```bash
neon deploy
```

Setelah deploy, test URL produksi (ganti `<branch>` dan `<region>` dengan milikmu):

```bash
curl https://<branch>-ftonsite.compute.<region>.aws.neon.tech/api/tasks
```

> **Catatan:** nama function di `neon.ts` adalah `ftonsite` ("flutter training onsite") — lihat di `neon functions get` untuk URL invocation.

### 2.3 Flutter: Model Task

Buat `lib/models/task_model.dart`:

```dart
import 'team_member_model.dart';

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
  final String? submittedAt;
  final String? submitUrl;
  final String? submissionNotes;
  final List<TeamMemberInfo> teamMembers;

  TaskModel({
    required this.id,
    required this.guruId,
    required this.classId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentUrl,
    this.isTeamTask = false,
    this.maxTeamMembers = 5,
    this.isSubmitted = false,
    this.submittedAt,
    this.submitUrl,
    this.submissionNotes,
    this.teamMembers = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['teamMembers'] ?? json['team_members'];
    List<TeamMemberInfo> membersList = [];
    if (rawMembers is List) {
      membersList = rawMembers
          .map((e) => TeamMemberInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return TaskModel(
      id: json['id'],
      guruId: json['guruId'] ?? json['guru_id'],
      classId: json['classId'] ?? json['class_id'],
      description: json['description'],
      startDate: json['startDate'] ?? json['start_date'],
      endDate: json['endDate'] ?? json['end_date'],
      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
      isTeamTask: json['isTeamTask'] ?? json['is_team_task'] ?? false,
      maxTeamMembers: json['maxTeamMembers'] ?? json['max_team_members'] ?? 5,
      isSubmitted: json['isSubmitted'] ?? json['is_submitted'] ?? false,
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
      submitUrl: json['submitUrl'] ?? json['submit_url'],
      submissionNotes: json['submissionNotes'] ?? json['submission_notes'],
      teamMembers: membersList,
    );
  }

  Map<String, dynamic> toJson() { ... }
}
```

**Poin penting:**
- `TaskModel` = 1 baris tabel `tasks` + info submission (dari join API)
- `fromJson` dengan fallback `??` untuk format key camelCase/snake_case
- `isSubmitted`/`submitUrl`/`teamMembers` diisi oleh API saat query dengan `siswaId`

Buat juga model pendukung (`submission_model.dart`, `team_member_model.dart`, `student_submission_model.dart`) — mengikuti pola `fromJson` yang sama.

### 2.4 Flutter: TaskRepository

Buat `lib/repositories/task_repository.dart`:

```dart
class TaskRepository {
  final DioClient _client;

  TaskRepository(this._client);

  Future<ApiResponse<List<TaskModel>>> getTasks({
    String? classId,
    String? guruId,
    String? siswaId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (classId != null && classId.isNotEmpty) queryParams['classId'] = classId;
      if (guruId != null && guruId.isNotEmpty) queryParams['guruId'] = guruId;
      if (siswaId != null && siswaId.isNotEmpty) queryParams['siswaId'] = siswaId;

      final response = await _client.dio.get(
        '/api/tasks',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return ApiResponse<List<TaskModel>>.fromJson(response.data, (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } on DioException catch (e) {
      return ApiResponse<List<TaskModel>>(
        success: false,
        message: DioClient.getErrorMessage(e),
        error: e.response?.data?['error'],
      );
    }
  }

  Future<ApiResponse<TaskModel>> createTask({
    required String guruId,
    required String classId,
    required String description,
    required String startDate,
    required String endDate,
    String? attachmentUrl,
    bool isTeamTask = false,
    int maxTeamMembers = 5,
  }) async { ... }
}
```

**Poin penting:**
- `queryParameters` → filter opsional (classId/guruId/siswaId) — dikirim hanya jika ada
- `ApiResponse<T>.fromJson` → wrapper `{success, data, message}`
- `on DioException` → pesan error ramah (`DioClient.getErrorMessage`)

### 2.5 Flutter: TaskProvider

Buat `lib/providers/task_provider.dart`:

```dart
class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepo;

  List<TaskModel> _tasks = [];
  List<StudentSubmissionModel> _studentSubmissions = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider(this._taskRepo);

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks({String? classId, String? guruId, String? siswaId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _taskRepo.getTasks(
      classId: classId, guruId: guruId, siswaId: siswaId,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _tasks = response.data!;
    } else {
      _error = response.message ?? 'Gagal mengambil daftar tugas';
    }
    notifyListeners();
  }

  Future<bool> createNewTask({...}) async { ... }
}
```

### 2.6 Flutter: Daftarkan di `main.dart`

```dart
final taskRepo = TaskRepository(dioClient);
// ...
ChangeNotifierProvider(create: (_) => TaskProvider(taskRepo)),
```

### 2.7 Flutter: EmptyStateWidget + CreateTaskForm

**EmptyStateWidget** (`lib/widgets/empty_state_widget.dart`) — tampilan saat belum ada tugas:

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
```

**CreateTaskForm** (`lib/widgets/create_task_form.dart`) — bottom sheet form buat tugas baru (deskripsi, kelas tujuan, tanggal mulai/selesai, attachment URL, toggle tugas tim, max anggota).

**Update `teacher_home_screen.dart`** — ganti "Hello Dashboard" dengan header guru + FAB "Buat Tugas Baru" + EmptyStateWidget:

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => _showCreateTaskBottomSheet(context),
  icon: const Icon(Icons.add),
  label: const Text('Buat Tugas Baru'),
),
// body: taskProvider.isLoading
//   ? const Center(child: CircularProgressIndicator())
//   : taskProvider.tasks.isEmpty
//   ? EmptyStateWidget(...)
//   : ...  (S3-02)
```

> **Checkpoint S3-01:** setelah login sebagai guru, dashboard menampilkan header "Selamat Datang, [nama]" + tombol "Buat Tugas Baru" + EmptyState "Belum Ada Tugas". Klik FAB → form muncul → isi → submit → data masuk tabel `tasks` di Neon (cek Drizzle Studio).

---

## 3. S3-02: List Tugas Guru + API Filter

> **Branch:** Flutter `s3-02-listtask` · API `s3-02-listtask`
> **Fokus:** tampilkan daftar tugas yang dibuat guru (Card + nama kelas).

### 3.1 API: Filter + Submissions (schema `submissions` + `submission_members`)

Tambahkan di `src/db/schema.ts` — tabel `submissions` dan `submission_members` (lihat diff branch `s3-01-taskapi-schema` → `s3-02-listtask`):

```ts
// 4. Tabel Submissions
export const submissions = pgTable("submissions", {
  id: uuid("id").defaultRandom().primaryKey(),
  taskId: uuid("task_id").notNull().references(() => tasks.id, { onDelete: "cascade" }),
  siswaId: uuid("siswa_id").notNull().references(() => users.id, { onDelete: "cascade" }),
  submitUrl: text("submit_url").notNull(),
  notes: text("notes"),
  submittedAt: timestamp("submitted_at").defaultNow().notNull(),
});

// 5. Tabel Submission Members (Team Task Members)
export const submissionMembers = pgTable(
  "submission_members",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    submissionId: uuid("submission_id").notNull().references(() => submissions.id, { onDelete: "cascade" }),
    siswaId: uuid("siswa_id").notNull().references(() => users.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => [uniqueIndex("submission_siswa_idx").on(table.submissionId, table.siswaId)],
);
```

> **WAJIB `npm run db:push`** lagi (schema berubah).

Update `GET /api/tasks` di `src/index.ts` — tambahkan query `siswaId` yang mengembalikan `isSubmitted`, `submitUrl`, `teamMembers` per task (lihat diff branch). Ini yang membuat siswa bisa lihat status pengumpulannya.

**Test:**

```bash
# List tugas guru tertentu
curl "http://localhost:8787/api/tasks?guruId=<uuid-guru>"

# List tugas dengan status submission siswa
curl "http://localhost:8787/api/tasks?siswaId=<uuid-siswa>"
```

### 3.2 Flutter: List Tugas di TeacherHomeScreen

Update `teacher_home_screen.dart` — ganti EmptyState dengan `ListView.builder`:

```dart
: ListView.builder(
    itemCount: taskProvider.tasks.length,
    itemBuilder: (context, index) {
      final task = taskProvider.tasks[index];

      // Cari nama kelas dari schoolProvider
      final matchingClass = schoolProvider.classes.firstWhere(
        (c) => c.id == task.classId,
        orElse: () => schoolProvider.classes.isNotEmpty
            ? schoolProvider.classes.first
            : throw Exception(),
      );
      final className =
          schoolProvider.classes.any((c) => c.id == task.classId)
          ? 'Kelas ${matchingClass.tingkat} - ${matchingClass.namaKelas}'
          : 'Kelas ID: ${task.classId.substring(0, task.classId.length > 8 ? 8 : task.classId.length)}...';

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailScreen(task: task, className: className),
              ),
            );
          },
          child: /* isi card: deskripsi, kelas, tanggal, status */,
        ),
      );
    },
  ),
```

**Poin penting:**
- `schoolProvider.classes.firstWhere` → konversi `classId` (UUID) → nama kelas (Tingkat + Ruang)
- `Card` + `InkWell` → tiap tugas bisa diklik → S3-03
- `RefreshIndicator` (pull-to-refresh) + tombol refresh di AppBar

> **Checkpoint S3-02:** daftar tugas guru muncul sebagai Card (deskripsi + kelas + tanggal). Klik → (S3-03, belum ada → bisa placeholder dulu).

---

## 4. S3-03: Task Detail + Status Siswa + url_launcher

> **Branch:** Flutter `s3-03-taskdetailscreen` · API `s3-03-taskdetailapi`
> **Fokus:** detail tugas + daftar siswa + status pengumpulan + buka link.

### 4.1 API: `GET /api/tasks/:id/submissions`

Tambahkan di `src/index.ts`:

```ts
app.get("/api/tasks/:id/submissions", async (c) => {
  const db = getDb();
  const taskId = c.req.param("id");

  try {
    const taskData = await db.select().from(tasks).where(eq(tasks.id, taskId));
    if (taskData.length === 0) {
      return c.json({ success: false, message: "Tugas tidak ditemukan" }, 404);
    }
    const task = taskData[0];

    // Semua siswa di kelas tugas ini
    const studentsInClass = await db
      .select()
      .from(users)
      .where(and(eq(users.role, "siswa"), eq(users.classId, task.classId)));

    // Submission per task
    const taskSubmissions = await db
      .select()
      .from(submissions)
      .where(eq(submissions.taskId, taskId));

    // Map submission → members (untuk team task)
    // ... (lihat diff branch)

    return c.json({
      success: true,
      data: {
        task,
        students: studentList,   // [{siswaId, nama, nipNik, isSubmitted, submitUrl, notes, submittedAt, teamMembers}]
      },
    });
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});
```

**Test `neon dev`:**

```bash
curl http://localhost:8787/api/tasks/<uuid-task>/submissions
# → {"success":true,"data":{"task":{...},"students":[{"siswaId":"...","nama":"Budi","isSubmitted":false,...}]}}
```

**Deploy:**

```bash
neon deploy
```

### 4.2 Flutter: TaskDetailScreen + url_launcher

**pubspec berubah!** Tambah dependency:

```bash
fvm flutter pub add url_launcher
```

> **Pola penting:** setiap kali `pubspec.yaml` berubah, jalankan `fvm flutter pub get` (atau `fvm flutter pub add` yang otomatis melakukannya).

Buat `lib/core/utils/url_launcher_utils.dart`:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
```

Buat `lib/screens/guru/task_detail_screen.dart` — detail tugas + daftar siswa + filter status:

```dart
enum SubmissionFilter { all, submitted, pending }

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String? className;

  const TaskDetailScreen({super.key, required this.task, this.className});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  SubmissionFilter _filter = SubmissionFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<TaskProvider>().fetchTaskSubmissions(widget.task.id);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final students = taskProvider.studentSubmissions;

    final totalStudents = students.length;
    final submittedCount = students.where((s) => s.isSubmitted).length;
    final pendingCount = totalStudents - submittedCount;

    final filteredStudents = students.where((s) {
      if (_filter == SubmissionFilter.submitted) return s.isSubmitted;
      if (_filter == SubmissionFilter.pending) return !s.isSubmitted;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumpulan Tugas'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
      ),
      // ... ringkasan tugas + statistik (total/submitted/pending) + filter chips + ListView siswa
    );
  }
}
```

**Poin penting:**
- `enum SubmissionFilter` → filter All / Submitted / Pending
- `fetchTaskSubmissions(taskId)` → panggil API → `studentSubmissions`
- Tiap siswa: nama + status (chip "Sudah" / "Belum") + tombol buka `submitUrl` via `url_launcher`
- `RefreshIndicator` + tombol refresh

**Update `teacher_home_screen.dart`** — `onTap` Card → `TaskDetailScreen(task: task, className: className)`.

> **Checkpoint S3-03:** klik tugas → detail dengan daftar siswa (filter All/Submitted/Pending), status pengumpulan, dan link submit bisa dibuka.

---

## 5. Verifikasi Akhir & Pengumpulan

### 5.1 Bandingkan dengan referensi

```bash
# Flutter: diff seluruh homework
git diff s3-start..s3-finish --stat

# API: diff seluruh homework
git diff s3-start..s3-finish --stat

# Detail per file (contoh)
git diff s3-start..s3-finish -- lib/screens/guru/teacher_home_screen.dart
```

> **Kenapa `git diff s3-start..s3-finish` dan bukan merge?** Karena homework ini berbasis branch per step — diff menunjukkan progres kalian dari titik awal sampai akhir, dan bisa dibandingkan dengan branch referensi `s3-01-*`/`s3-02-*`/`s3-03-*` per step.

### 5.2 Screenshot hasil

- [ ] Dashboard guru menampilkan daftar tugas (Card + nama kelas + tanggal)
- [ ] Detail tugas menampilkan daftar siswa + status pengumpulan (All/Submitted/Pending)
- [ ] Tombol "Buat Tugas Baru" membuka form dan berhasil membuat tugas (cek Drizzle Studio)

### 5.3 Checklist Hasil Akhir Sesi 3

- [ ] Kedua repo di-clone + branch `s3-start` checkout
- [ ] `neon link` + `db:push` + `db:seed` berhasil (tabel classes/users)
- [ ] `neon dev` jalan di `localhost:8787` + curl `/api/classes` sukses
- [ ] Schema `tasks` ditambahkan + `db:push` + curl `POST /api/tasks` sukses
- [ ] `neon deploy` berhasil + curl URL produksi sukses
- [ ] `TaskModel` + model pendukung (Submission/TeamMember/StudentSubmission) dibuat
- [ ] `TaskRepository` + `TaskProvider` dibuat & didaftarkan di `main.dart`
- [ ] `EmptyStateWidget` + `CreateTaskForm` dibuat
- [ ] List tugas guru muncul (Card + class lookup)
- [ ] Schema `submissions` + `submission_members` ditambahkan + `db:push`
- [ ] `GET /api/tasks?guruId=...` & `?siswaId=...` bekerja
- [ ] `url_launcher` ditambahkan (`fvm flutter pub add url_launcher`)
- [ ] `TaskDetailScreen` + filter status (All/Submitted/Pending) berfungsi
- [ ] `GET /api/tasks/:id/submissions` berfungsi
- [ ] `git diff s3-start..s3-finish` bersih (tidak ada file hilang)

---

## Latihan / Pengayaan (Opsional)

1. Tambahkan **validasi tanggal** — `endDate` harus setelah `startDate` (di CreateTaskForm dan API).
2. Tambahkan **halaman siswa**: siswa login → lihat tugas kelasnya + tombol "Kumpulkan" (pakai `GET /api/tasks?siswaId=...` + `POST /api/submissions` yang sudah ada di API).
3. Tambahkan **konfirmasi hapus tugas** (guru) — dengan `DELETE /api/tasks/:id` (buat sendiri di API).
4. Jelaskan dengan kata-kata sendiri: kenapa kita perlu `db:push` setiap schema berubah, dan apa bedanya `neon dev` vs `neon deploy`?

## Sumber Belajar
- [Neon CLI — `neon dev`](https://neon.tech/docs/cli/dev)
- [Neon CLI — `neon deploy`](https://neon.tech/docs/cli/deploy)
- [Drizzle ORM — Schema & Migrations](https://orm.drizzle.team/docs/migrations)
- [Provider Package](https://pub.dev/packages/provider)
- [url_launcher](https://pub.dev/packages/url_launcher)
- [Flutter — ListView & Cards](https://docs.flutter.dev/ui/widgets/layout)
