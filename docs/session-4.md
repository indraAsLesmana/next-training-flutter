# Session 4: State Management & Finalisasi

## Durasi: 4 jam

## Objectives
- Memahami konsep State Management di Flutter
- Mengimplementasikan `Provider` untuk manajemen data (State)
- Menghubungkan UI penuh ke Backend (Neon Database)
- Menambahkan UX/UI Polish (Loading state, Error Handling)

## Agenda
1. Pengenalan State Management & Provider (45 menit)
2. Setup & Pembuatan Provider Class (60 menit)
3. Integrasi Provider dengan UI (75 menit)
4. UI Polish, Error Handling & Review (60 menit)

## 1. Pengenalan State Management & Provider

### Mengapa butuh State Management?
- Di Session 1, kita menggunakan `setState()` (Local State).
- Saat aplikasi besar, mengirim data/state antar screen menjadi sulit (Prop drilling).
- State Management memisahkan Logic dan UI.

### Package `Provider`
- Provider adalah state management yang paling direkomendasikan Google untuk pemula.
- Menggunakan konsep Dependency Injection dan Observer Pattern (`ChangeNotifier`).

### Instalasi
Tambahkan di project Flutter (`flutter_training`):
```bash
flutter pub add provider
```

## 2. Setup & Pembuatan Provider Class

Kita akan memindahkan logika dari `ApiService` ke dalam class Provider agar UI bisa "mendengarkan" perubahannya.

### Buat file `providers/task_provider.dart`

```dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 1. Fetch Tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Memberitahu UI untuk rebuild loading state

    try {
      _tasks = await _apiService.getTasks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Memberitahu UI data sudah siap
    }
  }

  // 2. Add Task
  Future<void> addTask(String title, String description) async {
    try {
      final newTask = await _apiService.createTask(title, description);
      _tasks.insert(0, newTask); // Masukkan di urutan teratas
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow; // Lempar error ke UI agar bisa menampilkan Snackbar
    }
  }

  // 3. Toggle Completion (Update)
  Future<void> toggleTaskCompletion(int taskId, bool currentStatus) async {
    try {
      // Optimistic UI Update (Update UI dulu biar cepat)
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = Task(
          id: _tasks[index].id,
          title: _tasks[index].title,
          description: _tasks[index].description,
          completed: !currentStatus,
        );
        notifyListeners();
      }

      // Update ke Backend/Database
      await _apiService.updateTask(taskId, !currentStatus);
    } catch (e) {
      // Revert if error
      fetchTasks();
    }
  }

  // 4. Delete Task
  Future<void> deleteTask(int taskId) async {
    try {
      await _apiService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
```

## 3. Integrasi Provider dengan UI

### Setup MultiProvider di `main.dart`
Bungkus `MaterialApp` dengan Provider.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pengumpulan Tugas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
```

### Menggunakan Data Provider di `home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat pertama kali screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Tasks')),
      
      // Consumer akan otomatis rebuild widget saat notifyListeners() dipanggil
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }

          if (provider.tasks.isEmpty) {
            return Center(child: Text('Belum ada task. Tambahkan sekarang!'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTasks(),
            child: ListView.builder(
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                final task = provider.tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed 
                        ? TextDecoration.lineThrough 
                        : null,
                    ),
                  ),
                  subtitle: Text(task.description),
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (value) {
                      provider.toggleTaskCompletion(task.id, task.completed);
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.deleteTask(task.id);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  // Modal Dialog untuk nambah Task
  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Task Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Judul Task'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Deskripsi'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  // Gunakan context.read untuk memanggil fungsi Provider di luar builder
                  await context.read<TaskProvider>().addTask(
                    titleController.text, 
                    descController.text
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
```

## 4. UI Polish & Error Handling (Finishing)

### Snackbar Error Handling
Jika operasi tambah/hapus gagal, kita perlu memberitahu pengguna.
Contoh pada fungsi tombol Hapus:
```dart
onPressed: () async {
  try {
    await provider.deleteTask(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task dihapus'))
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menghapus task'), backgroundColor: Colors.red)
    );
  }
}
```

## Tugas Akhir / Final Review
1. Pastikan URL endpoint Neon Function Anda sudah dimasukkan ke dalam `config.json`.
2. Jalankan aplikasi Flutter: `flutter run --dart-define-from-file=config.json`
3. Test alur lengkap: Create Task -> Muncul di UI -> Centang/Uncentang -> Hapus.
4. Cek Neon Dashboard -> SQL Editor -> `SELECT * FROM tasks;` untuk memastikan sinkronisasi data Flutter ke Cloud berhasil!