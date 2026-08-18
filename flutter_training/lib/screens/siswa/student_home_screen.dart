import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/submit_task_form.dart';
import '../../core/utils/url_launcher_utils.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    context.read<TaskProvider>().fetchTasks(
          classId: currentUser?.classId,
          siswaId: currentUser?.id,
        );
  }

  void _showSubmitTaskBottomSheet(BuildContext context, {TaskModel? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SubmitTaskForm(initialTask: task),
    );
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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.4),
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
                            authProvider.currentUser?.nama ?? 'Siswa',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: const Text('Siswa'),
                      avatar: const Icon(Icons.school, size: 16),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Daftar Tugas Kelas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Tasks List or Empty State
              Expanded(
                child: taskProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : taskProvider.tasks.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.assignment_outlined,
                        title: 'Belum Ada Tugas',
                        message:
                            'Belum ada tugas yang diberikan oleh guru untuk kelas Anda.',
                        onRefresh: _loadTasks,
                      )
                    : ListView.builder(
                        itemCount: taskProvider.tasks.length,
                        itemBuilder: (context, index) {
                          final task = taskProvider.tasks[index];
                          final isSubmitted = task.isSubmitted;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                      Expanded(
                                        child: Text(
                                          task.description,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      Chip(
                                        label: Text(
                                          'ID: ${task.id.substring(0, task.id.length > 8 ? 8 : task.id.length)}...',
                                        ),
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
                                      if (isSubmitted)
                                        Chip(
                                          label: Text(
                                            'Sudah Dikumpulkan',
                                            style: TextStyle(
                                              color: Colors.green[800],
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          avatar: const Icon(
                                            Icons.check_circle,
                                            size: 15,
                                            color: Colors.green,
                                          ),
                                          backgroundColor: Colors.green[50],
                                          side: BorderSide(color: Colors.green[300]!),
                                          visualDensity: VisualDensity.compact,
                                        )
                                      else
                                        Chip(
                                          label: Text(
                                            'Belum Dikumpulkan',
                                            style: TextStyle(
                                              color: Colors.orange[800],
                                              fontSize: 11,
                                            ),
                                          ),
                                          avatar: Icon(
                                            Icons.schedule,
                                            size: 15,
                                            color: Colors.orange[800],
                                          ),
                                          backgroundColor: Colors.orange[50],
                                          side: BorderSide(color: Colors.orange[300]!),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Mulai: ${task.startDate.split('T')[0]}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Icon(
                                        Icons.event,
                                        size: 14,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Tenggat: ${task.endDate.split('T')[0]}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (task.attachmentUrl != null &&
                                      task.attachmentUrl!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => openUrl(context, task.attachmentUrl!),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.link,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              task.attachmentUrl!,
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
                                  ],
                                  if (isSubmitted && task.submitUrl != null) ...[
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => openUrl(context, task.submitUrl!),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Hasil: ${task.submitUrl}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[700],
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
                                  if (isSubmitted && task.isTeamTask && task.teamMembers.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.groups, size: 14, color: Colors.blue),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Anggota (${task.teamMembers.length}): ${task.teamMembers.map((m) => m.nama).join(", ")}',
                                            style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showSubmitTaskBottomSheet(
                                            context,
                                            task: task,
                                          ),
                                      icon: Icon(
                                        isSubmitted ? Icons.edit : Icons.upload_file,
                                        size: 16,
                                      ),
                                      label: Text(isSubmitted ? 'Edit Pengumpulan' : 'Kumpulkan'),
                                      style: ElevatedButton.styleFrom(
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: isSubmitted ? Colors.grey[200] : null,
                                        foregroundColor: isSubmitted ? Colors.black87 : null,
                                      ),
                                    ),
                                  ),
                                ],
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
