import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/create_task_form.dart';
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
    context.read<TaskProvider>().fetchTasks(guruId: authProvider.currentUser?.id);
  }

  void _showCreateTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreateTaskForm(),
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
