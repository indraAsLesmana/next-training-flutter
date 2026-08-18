import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/school_provider.dart';
import '../providers/task_provider.dart';

class CreateTaskForm extends StatefulWidget {
  const CreateTaskForm({super.key});

  @override
  State<CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<CreateTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _attachmentUrlController = TextEditingController();
  final _maxMembersController = TextEditingController(text: '5');
  String? _selectedClassId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isTeamTask = false;
  String? _formError;

  @override
  void dispose() {
    _descController.dispose();
    _attachmentUrlController.dispose();
    _maxMembersController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _formError = null;
    });

    final isFormValid = _formKey.currentState!.validate();

    if (!isFormValid || _selectedClassId == null || _endDate == null) {
      setState(() {
        if (_selectedClassId == null) {
          _formError = 'Mohon pilih Kelas Tujuan.';
        } else if (_descController.text.isEmpty) {
          _formError = 'Mohon isi Deskripsi Tugas.';
        } else if (_endDate == null) {
          _formError = 'Mohon pilih Tenggat Waktu.';
        } else {
          _formError = 'Mohon lengkapi semua bidang yang wajib diisi.';
        }
      });
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final authProvider = context.read<AuthProvider>();
    final startDateToUse = _startDate ?? DateTime.now();

    try {
      final success = await taskProvider.createNewTask(
        guruId: authProvider.currentUser!.id,
        classId: _selectedClassId!,
        description: _descController.text,
        startDate: startDateToUse.toIso8601String(),
        endDate: _endDate!.toIso8601String(),
        attachmentUrl: _attachmentUrlController.text.isEmpty ? null : _attachmentUrlController.text,
        isTeamTask: _isTeamTask,
        maxTeamMembers: int.tryParse(_maxMembersController.text) ?? 5,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _formError = taskProvider.error ?? 'Gagal membuat tugas';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _formError = 'Terjadi kesalahan: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Buat Tugas Baru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Inline Error Alert Box
              if (_formError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              DropdownButtonFormField<String>(
                initialValue: _selectedClassId,
                decoration: const InputDecoration(
                  labelText: 'Pilih Kelas Tujuan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.class_),
                ),
                items: schoolProvider.classes.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text('Kelas ${c.tingkat} - ${c.namaKelas}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedClassId = val;
                    _formError = null;
                  });
                },
                validator: (v) => v == null ? 'Pilih kelas tujuan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tugas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                onChanged: (_) {
                  if (_formError != null) setState(() => _formError = null);
                },
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(_startDate == null ? 'Pilih Tanggal Mulai (Opsional)' : 'Mulai: ${_startDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _startDate = date;
                        _formError = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: _endDate == null && _formError != null ? Colors.red : Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Text(_endDate == null ? 'Pilih Tenggat Waktu' : 'Tenggat: ${_endDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _endDate = date;
                        _formError = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _attachmentUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Lampiran / Link Referensi (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isTeamTask,
                title: const Text('Tugas Kelompok (Team Task)'),
                subtitle: const Text('Izinkan siswa menambahkan anggota kelompok saat mengumpulkan'),
                secondary: const Icon(Icons.groups),
                onChanged: (val) {
                  setState(() {
                    _isTeamTask = val;
                  });
                },
              ),
              if (_isTeamTask) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxMembersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Maksimal Anggota per Kelompok',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group_add),
                    hintText: '5',
                  ),
                  validator: (v) {
                    if (!_isTeamTask) return null;
                    final num = int.tryParse(v ?? '');
                    if (num == null || num < 2) {
                      return 'Minimal 2 anggota per kelompok';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: taskProvider.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: taskProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Tugas', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
