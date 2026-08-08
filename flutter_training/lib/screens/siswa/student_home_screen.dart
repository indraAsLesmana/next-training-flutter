import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskIdController = TextEditingController();
  final _submitUrlController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _taskIdController.dispose();
    _submitUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();

    final success = await taskProvider.submitStudentTask(
      taskId: _taskIdController.text,
      submitUrl: _submitUrlController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dikumpulkan!')),
      );
      _taskIdController.clear();
      _submitUrlController.clear();
      _notesController.clear();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.error ?? 'Gagal mengumpulkan tugas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Siswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Selamat datang, ${authProvider.currentUser?.nama ?? ""}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              const Text('Kumpulkan Tugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _taskIdController,
                decoration: const InputDecoration(labelText: 'Task ID (UUID dari Guru)'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _submitUrlController,
                decoration: const InputDecoration(labelText: 'URL Hasil Tugas (Google Drive/GitHub/dll)'),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Catatan Tambahan (Opsional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: taskProvider.isLoading ? null : _submit,
                child: taskProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Kumpulkan Tugas'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
