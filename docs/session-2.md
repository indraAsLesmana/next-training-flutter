# Session 2: HTTP Integration & Model

## Durasi: 4 jam

## Objectives
- Memahami konsep REST API
- Menggunakan package `http` di Flutter
- Melakukan request GET, POST, PUT, DELETE
- Handle JSON serialization/deserialization
- Error handling untuk network requests

## Agenda
1. Pengenalan REST API (30 menit)
2. Setup Package dan Model (30 menit)
3. Implementasi HTTP Requests (60 menit)
4. Error Handling & Loading State (45 menit)

## 1. Pengenalan REST API

### Apa itu REST API?
REST (Representational State Transfer) API adalah cara aplikasi berkomunikasi.
- **Client (Flutter):** Meminta data
- **Server (Backend/Neon):** Menyediakan data

### HTTP Methods
- `GET`: Mengambil data (Read)
- `POST`: Membuat data baru (Create)
- `PUT/PATCH`: Mengubah data (Update)
- `DELETE`: Menghapus data (Delete)

### JSON Format
Data dikirim dalam format JSON (JavaScript Object Notation):
```json
{
  "id": 1,
  "title": "Belajar HTTP",
  "completed": false
}
```

## 2. Setup Package dan Model

### Install Package `http`
Tambahkan di `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```
Atau jalankan: `flutter pub add http`

### Membuat Data Model (task.dart)
```dart
class Task {
  final int id;
  final String title;
  final String description;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
  });

  // Convert JSON to Task Object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      completed: json['completed'] ?? false,
    );
  }

  // Convert Task Object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
    };
  }
}
```

## 3. Implementasi HTTP Requests

### Membuat ApiService (api_service.dart)
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  // Ganti dengan URL backend Anda (contoh: http://10.0.2.2:3000 untuk Android Emulator)
  final String baseUrl = 'http://localhost:3000';

  // 1. GET Request (Read)
  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 2. POST Request (Create)
  Future<Task> createTask(String title, String description) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task');
    }
  }

  // 3. PUT Request (Update)
  Future<void> updateTask(int id, bool completed) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'completed': completed}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  // 4. DELETE Request (Delete)
  Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
```

## 4. Integrasi dengan UI (StatefulWidget)

```dart
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Fetch data
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tasks = await _apiService.getTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Integration'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTasks,
          )
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add task dialog
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadTasks,
              child: Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(child: Text('No tasks found'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Checkbox(
            value: task.completed,
            onChanged: (value) {
              // TODO: Implement update task
            },
          ),
        );
      },
    );
  }
}
```

## Tugas/Latihan
1. Modifikasi UI untuk menambahkan Snackbar jika terjadi error
2. Implementasikan fungsi `_addTask()` yang memanggil `_apiService.createTask()`
3. Buat file konstan untuk menyimpan Base URL
4. Tambahkan validasi form sebelum mengirim data POST