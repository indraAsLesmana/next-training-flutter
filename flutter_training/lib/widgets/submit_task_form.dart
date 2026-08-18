import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../models/team_member_model.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../repositories/school_repository.dart';

class SubmitTaskForm extends StatefulWidget {
  final TaskModel? initialTask;

  const SubmitTaskForm({super.key, this.initialTask});

  @override
  State<SubmitTaskForm> createState() => _SubmitTaskFormState();
}

class _SubmitTaskFormState extends State<SubmitTaskForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taskIdController;
  late final TextEditingController _submitUrlController;
  late final TextEditingController _notesController;
  final TextEditingController _searchStudentController = TextEditingController();

  List<TeamMemberInfo> _selectedTeamMembers = [];
  List<TeamMemberInfo> _searchResults = [];
  bool _isSearching = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _taskIdController = TextEditingController(
      text: widget.initialTask?.id ?? '',
    );
    _submitUrlController = TextEditingController(
      text: widget.initialTask?.submitUrl ?? '',
    );
    _notesController = TextEditingController(
      text: widget.initialTask?.submissionNotes ?? '',
    );

    final currentUser = context.read<AuthProvider>().currentUser;
    if (widget.initialTask?.teamMembers != null && widget.initialTask!.teamMembers.isNotEmpty) {
      _selectedTeamMembers = List.from(widget.initialTask!.teamMembers);
    } else if (currentUser != null) {
      _selectedTeamMembers = [
        TeamMemberInfo(
          siswaId: currentUser.id,
          nama: currentUser.nama,
          nipNik: currentUser.nipNik,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _taskIdController.dispose();
    _submitUrlController.dispose();
    _notesController.dispose();
    _searchStudentController.dispose();
    super.dispose();
  }

  void _searchStudents(String query) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser?.classId == null || query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final schoolRepo = context.read<SchoolRepository>();
      final response = await schoolRepo.searchStudents(
        classId: currentUser!.classId!,
        query: query.trim(),
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            final selectedIds = _selectedTeamMembers.map((m) => m.siswaId).toSet();
            _searchResults = response.data!.where((s) => !selectedIds.contains(s.siswaId)).toList();
          } else {
            _searchResults = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _addTeamMember(TeamMemberInfo student) {
    final maxMembers = widget.initialTask?.maxTeamMembers ?? 5;
    if (_selectedTeamMembers.length >= maxMembers) {
      setState(() {
        _formError = 'Maksimal $maxMembers anggota per kelompok untuk tugas ini.';
      });
      return;
    }

    setState(() {
      _selectedTeamMembers.add(student);
      _searchResults.removeWhere((s) => s.siswaId == student.siswaId);
      _searchStudentController.clear();
      _formError = null;
    });
  }

  void _removeTeamMember(String siswaId) {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (siswaId == currentUser?.id) return;

    setState(() {
      _selectedTeamMembers.removeWhere((m) => m.siswaId == siswaId);
      _formError = null;
    });
  }

  void _submit() async {
    setState(() {
      _formError = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _formError = 'Mohon isi semua bidang yang wajib diisi.';
      });
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final authProvider = context.read<AuthProvider>();

    try {
      final success = await taskProvider.submitStudentTask(
        taskId: _taskIdController.text,
        siswaId: authProvider.currentUser!.id,
        submitUrl: _submitUrlController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        teamMemberIds: _selectedTeamMembers
            .map((m) => m.siswaId)
            .where((id) => id.trim().isNotEmpty)
            .toList(),
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.initialTask?.isSubmitted == true
                  ? 'Pengumpulan tugas berhasil diperbarui!'
                  : 'Tugas berhasil dikumpulkan!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _formError = taskProvider.error ?? 'Gagal mengumpulkan tugas';
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
    final taskProvider = context.watch<TaskProvider>();
    final isEditing = widget.initialTask?.isSubmitted == true;

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
                    isEditing ? 'Edit Pengumpulan Tugas' : 'Kumpulkan Tugas',
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
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _formError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              TextFormField(
                controller: _taskIdController,
                readOnly: true,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Task ID',
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _submitUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Hasil Tugas (Google Drive/GitHub/dll)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (_) {
                  if (_formError != null) setState(() => _formError = null);
                },
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan Tambahan (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              if (widget.initialTask?.isTeamTask == true) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.groups, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Tugas Kelompok (Maks ${_selectedTeamMembers.length}/${widget.initialTask?.maxTeamMembers} Anggota)',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _selectedTeamMembers.map((member) {
                          final isSelf = member.siswaId == context.read<AuthProvider>().currentUser?.id;
                          return Chip(
                            avatar: Icon(
                              isSelf ? Icons.star : Icons.person,
                              size: 16,
                              color: isSelf ? Colors.amber[800] : Colors.blue[800],
                            ),
                            label: Text(
                              '${member.nama} ${isSelf ? "(Ketua)" : "(${member.nipNik})"}'
                            ),
                            deleteIcon: isSelf ? null : const Icon(Icons.close, size: 16),
                            onDeleted: isSelf ? null : () => _removeTeamMember(member.siswaId),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchStudentController,
                        decoration: InputDecoration(
                          hintText: 'Cari Anggota (Ketik Nama atau NIK)...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : null,
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: _searchStudents,
                      ),
                      if (_searchResults.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final student = _searchResults[index];
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  dense: true,
                                  title: Text(student.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('NIS/NIK: ${student.nipNik}'),
                                  trailing: const Icon(Icons.add_circle_outline, color: Colors.blue),
                                  onTap: () => _addTeamMember(student),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
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
                    : Text(
                        isEditing ? 'Simpan Perubahan' : 'Kumpulkan Tugas',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
