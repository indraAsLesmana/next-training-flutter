import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/empty_state_widget.dart';
import 'task_detail_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      context.read<TaskProvider>().fetchTasks(guruId: authProvider.currentUser!.id);
    }
  }

  void _showCreateTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _CreateTaskForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final schoolProvider = context.watch<SchoolProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Tugas Baru'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadTasks(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      radius: 24,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            authProvider.currentUser?.nama ?? 'Guru',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: const Text('Guru'),
                      avatar: const Icon(Icons.school, size: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Daftar Tugas Dibuat',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Content Area
              Expanded(
                child: taskProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : taskProvider.tasks.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.assignment_outlined,
                            title: 'Belum Ada Tugas',
                            message: 'Tugas yang Anda buat akan muncul di sini. Klik "Buat Tugas Baru" untuk menambahkan.',
                            onRefresh: _loadTasks,
                          )
                        : ListView.builder(
                            itemCount: taskProvider.tasks.length,
                            itemBuilder: (context, index) {
                              final task = taskProvider.tasks[index];
                              
                              // Find class name if available
                              final matchingClass = schoolProvider.classes.firstWhere(
                                (c) => c.id == task.classId,
                                orElse: () => schoolProvider.classes.isNotEmpty 
                                    ? schoolProvider.classes.first 
                                    : throw Exception(),
                              );
                              final className = schoolProvider.classes.any((c) => c.id == task.classId)
                                  ? 'Kelas ${matchingClass.tingkat} - ${matchingClass.namaKelas}'
                                  : 'Kelas ID: ${task.classId.substring(0, task.classId.length > 8 ? 8 : task.classId.length)}...';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                clipBehavior: Clip.antiAlias,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailScreen(
                                          task: task,
                                          className: className,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: Wrap(
                                                spacing: 6,
                                                runSpacing: 4,
                                                children: [
                                                  Chip(
                                                    label: Text(className),
                                                    visualDensity: VisualDensity.compact,
                                                  ),
                                                  if (task.isTeamTask)
                                                    Chip(
                                                      label: Text('Kelompok (Maks ${task.maxTeamMembers})'),
                                                      avatar: const Icon(Icons.groups, size: 14, color: Colors.blue),
                                                      backgroundColor: Colors.blue[50],
                                                      side: BorderSide(color: Colors.blue[300]!),
                                                      visualDensity: VisualDensity.compact,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SelectableText(
                                              'ID: ${task.id.substring(0, task.id.length > 8 ? 8 : task.id.length)}...',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          task.description,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Mulai: ${task.startDate.split('T')[0]}',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.event, size: 14, color: Colors.redAccent),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Tenggat: ${task.endDate.split('T')[0]}',
                                              style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        if (task.attachmentUrl != null && task.attachmentUrl!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.link, size: 14, color: Colors.blue),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  task.attachmentUrl!,
                                                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Ketuk untuk lihat detail pengumpulan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context).colorScheme.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              size: 18,
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTaskForm extends StatefulWidget {
  const _CreateTaskForm();

  @override
  State<_CreateTaskForm> createState() => _CreateTaskFormState();
}

class _CreateTaskFormState extends State<_CreateTaskForm> {
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
