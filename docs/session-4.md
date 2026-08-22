# Session 4: Workshop — Fitur Baru: Hapus Tugas + Q&A

> **Hari 4 — Minggu, 23 Agustus** (09:30–12:00 pagi, 13:00–14:30 siang, break 12:00–13:00)

> **Branch workflow sesi ini:**
> - Lanjut dari hasil **homework Session 3** (branch `s3-finish` di kedua repo)
> - Hari ini kita pelajari **fitur baru nyata**: **hapus tugas (DELETE)** — dikembangkan setelah onsite teaching
> - Referensi kode: branch `build-project` (repo `next-training-flutter`), 2 commit terakhir

## Tujuan Sesi 4
1. **Mempelajari fitur nyata baru**: Delete Task — dari API `DELETE` sampai tombol hapus di UI
2. Memahami pola **end-to-end**: backend route → repository → provider → screen (confirm dialog)
3. Memahami pentingnya **konfirmasi destruktif** + handling cascade delete
4. Tanya-jawab terbuka & diskusi (berbasis project)

## Agenda (4 jam efektif)
1. Recap 3 sesi + peta lengkap project (30 menit)
2. **Belajar Fitur Baru: Hapus Tugas** (90 menit)
3. Q&A berbasis project (60 menit)
4. Penutupan (15 menit)

---

## 1. Recap 3 Sesi (09:30–09:50)

**Perjalanan yang sudah dilalui:**

| Sesi | Yang dibangun | Hasil |
|---|---|---|
| 1 | `fvm flutter create` → register page + data masuk Neon via `neon dev` | Register + DB |
| 2 | Re-arch berlapis: models, repositories, providers, screens + Dio | Arsitektur bersih |
| 3 | Homework: Task Management guru (buat, list, detail + status siswa) | Fitur tugas lengkap |

**Alur end-to-end yang sudah jadi:**
```text
Register → Login → Dashboard (role) → Buat tugas → List tugas → Detail + status → (HAPUS)
```

**Struktur akhir (Provider-based, bukan Riverpod/Bloc):**
```text
lib/
├── main.dart                    # DI + MultiProvider + role routing
├── core/network/                # DioClient, ApiResponse
├── models/                      # TaskModel, UserModel, ClassModel, SubmissionModel
├── providers/                   # AuthProvider, SchoolProvider, TaskProvider (ChangeNotifier)
├── repositories/                # AuthRepository, SchoolRepository, TaskRepository
└── screens/
    ├── auth/                    # login, register
    ├── guru/                    # teacher home, task detail
    └── siswa/                   # student home
```

> **State management yang dipakai project ini = `Provider`** (ChangeNotifier + MultiProvider). Bukan Riverpod, bukan Bloc.

---

## 2. Belajar Fitur Baru: Hapus Tugas (09:50–11:20)

Fitur **delete task** kita bangun bersama — persis seperti yang sudah ada di `build-project`. Ini alur lengkapnya:

### 2.1 API: `DELETE /api/tasks/:id`

Buka `flutter-task-api/src/index.ts` — tambahkan route hapus setelah route `POST /api/tasks`:

```ts
// -------------------------------------------------------------
// DELETE: Guru Hapus Tugas
// -------------------------------------------------------------
app.delete('/api/tasks/:id', async (c) => {
  const db = getDb();
  const taskId = c.req.param('id');

  try {
    const deleted = await db.delete(tasks).where(eq(tasks.id, taskId)).returning();
    if (deleted.length === 0) {
      return c.json({ success: false, message: 'Tugas tidak ditemukan' }, 404);
    }
    return c.json({ success: true, message: 'Tugas berhasil dihapus', data: deleted[0] }, 200);
  } catch (err: any) {
    return c.json({ success: false, message: err.message }, 500);
  }
});
```

**Poin penting:**
- `app.delete('/api/tasks/:id')` → method HTTP DELETE, id dari path param
- `db.delete(tasks).where(eq(tasks.id, taskId)).returning()` → hapus & return baris
- `.returning()` kosong (length 0) → tugas tidak ada → **404**
- **Cascade delete**: karena schema `submissions`/`submission_members` pakai `onDelete: "cascade"`, semua data pengumpulan siswa ikut terhapus otomatis — ini yang disebut di pesan konfirmasi.

**Test dengan `neon dev`:**

```bash
# Hapus tugas (ganti <uuid-task> dengan id tugas)
curl -X DELETE http://localhost:8787/api/tasks/<uuid-task>

# Jika id salah → 404 "Tugas tidak ditemukan"
curl -X DELETE http://localhost:8787/api/tasks/salah
```

**Deploy:**

```bash
neon deploy
```

### 2.2 Repository: `deleteTask(taskId)`

Buka `lib/repositories/task_repository.dart`:

```dart
Future<ApiResponse<void>> deleteTask(String taskId) async {
  try {
    final response = await _client.dio.delete('/api/tasks/$taskId');
    return ApiResponse<void>(
      success: response.data['success'] ?? true,
      message: response.data['message'],
    );
  } on DioException catch (e) {
    return ApiResponse<void>(
      success: false,
      message: DioClient.getErrorMessage(e),
      error: e.response?.data?['error'],
    );
  } catch (e) {
    return ApiResponse<void>(
      success: false,
      message: 'Terjadi kesalahan: ${e.toString()}',
    );
  }
}
```

**Poin penting:**
- `_client.dio.delete('/api/tasks/$taskId')` → URL pakai path param
- Return `ApiResponse<void>` — tidak ada data yang di-parse, cukup `success` + `message`
- Tetap tangkap `DioException` + error umum (pola konsisten)

### 2.3 Provider: `deleteTask(taskId)`

Buka `lib/providers/task_provider.dart`:

```dart
Future<bool> deleteTask(String taskId) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  final response = await _taskRepo.deleteTask(taskId);

  _isLoading = false;

  if (response.success) {
    _tasks.removeWhere((t) => t.id == taskId);   // hapus dari state lokal
    _studentSubmissions = [];
    notifyListeners();
    return true;
  } else {
    _error = response.message;
    notifyListeners();
    return false;
  }
}
```

**Poin penting:**
- `_tasks.removeWhere((t) => t.id == taskId)` → hapus dari daftar tanpa perlu fetch ulang
- `_studentSubmissions = []` → reset detail (tugas yang ditampilkan sudah dihapus)
- Return `bool` → screen tahu sukses/gagal

### 2.4 Screen: Tombol Hapus + Confirm Dialog

Buka `lib/screens/guru/task_detail_screen.dart`:

**a. State `_isDeleting`:**

```dart
class _TaskDetailScreenState extends State<TaskDetailScreen> {
  SubmissionFilter _filter = SubmissionFilter.all;
  bool _isDeleting = false;   // loading state tombol hapus
  ...
}
```

**b. Method `_confirmDeleteTask`:**

```dart
Future<void> _confirmDeleteTask() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Hapus Tugas'),
        ],
      ),
      content: const Text(
        'Apakah Anda yakin ingin menghapus tugas ini?\n\n'
        'Perhatian: Seluruh data pengumpulan siswa yang terkait dengan tugas ini juga akan dihapus secara permanen.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  setState(() => _isDeleting = true);

  final taskProvider = context.read<TaskProvider>();
  final success = await taskProvider.deleteTask(widget.task.id);

  if (!mounted) return;
  setState(() => _isDeleting = false);

  if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil dihapus'), backgroundColor: Colors.green),
    );
    Navigator.of(context).pop(true);   // kembali ke list
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(taskProvider.error ?? 'Gagal menghapus tugas'), backgroundColor: Colors.red),
    );
  }
}
```

**c. Tombol hapus di AppBar/detail:**

```dart
IconButton(
  icon: _isDeleting
      ? const SizedBox(
          width: 18, height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
        )
      : const Icon(Icons.delete_outline, color: Colors.red),
  tooltip: 'Hapus Tugas',
  onPressed: _isDeleting ? null : _confirmDeleteTask,
  visualDensity: VisualDensity.compact,
),
```

**Poin penting:**
- `AlertDialog` → **konfirmasi sebelum aksi destruktif** (praktik baik UX)
- Pesan menegaskan **cascade delete** (data pengumpulan ikut hilang)
- `_isDeleting` → spinner di tombol, cegah klik ganda
- `Navigator.pop(true)` → kembalikan ke list setelah sukses
- Snackbar hijau (sukses) / merah (gagal)

> **Checkpoint:** klik ikon hapus di detail tugas → dialog konfirmasi → Hapus → tugas hilang dari list, data pengumpulan siswa ikut terhapus (cek Drizzle Studio `/api/tasks`).

### 2.5 Alur lengkap delete task

```text
[daftar tugas] --tap--> [detail] --klik ikon hapus--> [AlertDialog]
                                                          │
                                                    konfirmasi "Hapus"
                                                          ▼
[TaskDetailScreen._confirmDeleteTask]
    → TaskProvider.deleteTask(taskId)
    → TaskRepository.deleteTask(taskId)
    → Dio DELETE /api/tasks/:id
    → Hono: db.delete(tasks).where(id).returning()
    → Neon DB (cascade hapus submissions)
    → success → notifyListeners → _tasks.removeWhere → Navigator.pop → snackbar hijau
```

---

## 3. Q&A Terbuka Berbasis Project (13:00–13:45)

> **Catatan:** project ini memakai **`Provider`** sebagai state management (ChangeNotifier + `MultiProvider`) dan **Dio** untuk HTTP. Q&A berikut berdasarkan kode nyata project — bukan teori umum.

### Tabel Topik (berbasis project)

| Topik | Isi |
|---|---|
| **State management: Provider** | Kenapa project pakai `Provider` (bukan Riverpod/Bloc) — lihat `main.dart` `MultiProvider` + `ChangeNotifier` + `context.watch`/`context.read`. Kapan `watch` vs `read`? |
| **Cascade delete** | Kenapa hapus tugas menghapus pengumpulan siswa? Lihat schema `onDelete: "cascade"` + respons API. |
| **`neon dev` vs `neon deploy`** | Bedanya? `dev` = lokal (port 8787), `deploy` = produksi (Neon Functions). Kapan pakai masing-masing. |
| **Repository pattern** | Kenapa pisah `repository` dari `provider`? Lihat `TaskRepository` vs `TaskProvider`. Manfaat untuk testing. |
| **ApiResponse wrapper** | Kenapa semua response dibungkus `{success, data, message}`? Konsistensi error handling. |
| **Error handling Dio** | `getErrorMessage` — bagaimana `DioException` diubah jadi pesan ramah untuk user. |
| **Git workflow** | Branch per sesi (`session-1-start`..`s3-finish`), `git diff` utk bandingkan, `git checkout <branch> -- folder`. |
| **Neon Functions deploy** | `neon.ts` + `ftonsite` function — bagaimana Hono API di-deploy & invocation URL-nya. |

### Pertanyaan Pemicu (mulai diskusi)

1. **Provider vs setState:** di `TaskProvider`, kenapa kita butuh `ChangeNotifier` + `notifyListeners`? Apa bedanya dengan `setState` di widget?
2. **`watch` vs `read`:** di `task_detail_screen.dart`, kenapa `context.watch` di `build()` tapi `context.read` di handler? Bisa salah pakai?
3. **Cascade delete:** jika kita ganti `onDelete: "cascade"` jadi `"set null"`, apa akibatnya saat hapus guru/tugas?
4. **Repository purpose:** kenapa `TaskProvider` tidak langsung panggil Dio? Apa untungnya API dipisah di `TaskRepository`?
5. **Error handling:** jalankan `neon dev` dalam keadaan mati → apa pesan yang muncul di app? Dari `DioClient.getErrorMessage` bagian mana?
6. **Delete flow:** apa yang terjadi di UI jika `DELETE` mengembalikan 404 (tugas sudah dihapus orang lain)? Apakah pesan error-nya sudah ramah?

### Demo Deploy (opsional, 13:45–14:05)
Demo: `neon deploy` + panggil `/api/tasks` dari URL Neon Functions produksi, lalu hapus via Flutter web.

---

## 4. Penutupan (14:05–14:30)

- Recap perjalanan 4 sesi
- Bagikan link materi: repo, docs online (ReadTheDocs), rundown
- Feedback form / evaluasi
- Sertifikat / penutup

---

## Checklist Kesiapan Instruktur
- [ ] Kode delete task sudah di-commit & build (2 commit terakhir `build-project`)
- [ ] `neon dev` siap demo (API jalan di `localhost:8787`)
- [ ] Jawaban Q&A siap (lihat tabel + pertanyaan pemicu)
- [ ] (Opsional) Demo deploy siap dijalankan
- [ ] Feedback form siap

## Tips Mengajar
- Mulai dari **alur end-to-end** dulu (2.5), baru breakdown per layer — peserta lihat "mau ke mana"
- Tekankan **konfirmasi destruktif** & **cascade delete** — ini pelajaran penting produksi
- Peserta cepat: minta buat **hapus kelas** atau **ganti `cascade` → `set null`** dan jelaskan dampaknya
- Peserta lambat: sudah punya kode referensi di `build-project`, fokus pahami alur + 1 layer