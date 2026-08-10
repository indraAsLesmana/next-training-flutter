import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/student_submission_model.dart';
import '../../providers/task_provider.dart';
import '../../core/utils/url_launcher_utils.dart';

enum SubmissionFilter { all, submitted, pending }

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String? className;

  const TaskDetailScreen({
    super.key,
    required this.task,
    this.className,
  });

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Task Detail Header Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(widget.className ?? 'Kelas ID: ${widget.task.classId.substring(0, widget.task.classId.length > 8 ? 8 : widget.task.classId.length)}...'),
                            visualDensity: VisualDensity.compact,
                          ),
                          SelectableText(
                            'ID: ${widget.task.id.substring(0, widget.task.id.length > 8 ? 8 : widget.task.id.length)}...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.task.description,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Mulai: ${widget.task.startDate.split('T')[0]}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.event, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            'Tenggat: ${widget.task.endDate.split('T')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (widget.task.attachmentUrl != null &&
                          widget.task.attachmentUrl!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => openUrl(context, widget.task.attachmentUrl!),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.task.attachmentUrl!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.open_in_new, size: 12, color: Colors.blue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Summary Metric Stat Cards
              Row(
                children: [
                  _StatCard(
                    title: 'Total Siswa',
                    value: '$totalStudents',
                    color: Colors.blue,
                    icon: Icons.people,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    title: 'Sudah',
                    value: '$submittedCount',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    title: 'Belum',
                    value: '$pendingCount',
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Filter Segmented Buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: Text('Semua ($totalStudents)'),
                      selected: _filter == SubmissionFilter.all,
                      onSelected: (_) => setState(() => _filter = SubmissionFilter.all),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text('Sudah Dikumpulkan ($submittedCount)'),
                      selected: _filter == SubmissionFilter.submitted,
                      selectedColor: Colors.green[100],
                      onSelected: (_) => setState(() => _filter = SubmissionFilter.submitted),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text('Belum Dikumpulkan ($pendingCount)'),
                      selected: _filter == SubmissionFilter.pending,
                      selectedColor: Colors.orange[100],
                      onSelected: (_) => setState(() => _filter = SubmissionFilter.pending),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Student Submissions List
              Expanded(
                child: taskProvider.isDetailLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredStudents.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada data siswa untuk kategori ini.',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return _StudentSubmissionCard(student: student);
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSubmissionCard extends StatelessWidget {
  final StudentSubmissionModel student;

  const _StudentSubmissionCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: student.isSubmitted ? Colors.green[100] : Colors.grey[200],
                  child: Icon(
                    student.isSubmitted ? Icons.check : Icons.person_outline,
                    size: 20,
                    color: student.isSubmitted ? Colors.green[800] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'NIS/NIK: ${student.nipNik}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    student.isSubmitted ? 'Sudah' : 'Belum',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: student.isSubmitted ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                  avatar: Icon(
                    student.isSubmitted ? Icons.check_circle : Icons.schedule,
                    size: 14,
                    color: student.isSubmitted ? Colors.green[800] : Colors.orange[800],
                  ),
                  backgroundColor: student.isSubmitted ? Colors.green[50] : Colors.orange[50],
                  side: BorderSide(
                    color: student.isSubmitted ? Colors.green[300]! : Colors.orange[300]!,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (student.isSubmitted) ...[
              const Divider(height: 20),
              if (student.submitUrl != null && student.submitUrl!.isNotEmpty) ...[
                InkWell(
                  onTap: () => openUrl(context, student.submitUrl!),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 14, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            student.submitUrl!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 12, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
              if (student.notes != null && student.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.note_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Catatan: ${student.notes}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
              if (student.submittedAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Dikumpulkan: ${student.submittedAt!.replaceAll('T', ' ').split('.')[0]}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
