import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/task_provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _attachmentUrlController = TextEditingController();
  String? _selectedClassId;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _descController.dispose();
    _attachmentUrlController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClassId == null || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data (Kelas, Tanggal Mulai, Tanggal Berakhir)')),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final authProvider = context.read<AuthProvider>();

    final success = await taskProvider.createNewTask(
      guruId: authProvider.currentUser!.id,
      classId: _selectedClassId!,
      description: _descController.text,
      startDate: _startDate!.toIso8601String(),
      endDate: _endDate!.toIso8601String(),
      attachmentUrl: _attachmentUrlController.text.isEmpty ? null : _attachmentUrlController.text,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tugas berhasil dibuat!')),
      );
      _descController.clear();
      _attachmentUrlController.clear();
      setState(() {
        _selectedClassId = null;
        _startDate = null;
        _endDate = null;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.error ?? 'Gagal membuat tugas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          )
        ],
      ),
      body: schoolProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                    const Text('Buat Tugas Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedClassId,
                      decoration: const InputDecoration(labelText: 'Pilih Kelas Tujuan'),
                      items: schoolProvider.classes.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('Kelas ${c.tingkat} - ${c.namaKelas}'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedClassId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Deskripsi Tugas'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_startDate == null ? 'Pilih Tanggal Mulai' : 'Mulai: ${_startDate.toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _startDate = date);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_endDate == null ? 'Pilih Tenggat Waktu' : 'Tenggat: ${_endDate.toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) setState(() => _endDate = date);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _attachmentUrlController,
                      decoration: const InputDecoration(labelText: 'URL Lampiran (Opsional)'),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: taskProvider.isLoading ? null : _submit,
                      child: taskProvider.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Simpan Tugas'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
