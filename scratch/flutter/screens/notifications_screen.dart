import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../../../flutter_training/lib/widgets/empty_state_widget.dart';

enum NotificationFilter { all, unread }

class NotificationsScreen extends StatefulWidget {
  final String userId;

  const NotificationsScreen({super.key, required this.userId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationFilter _filter = NotificationFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    final filteredList = notifications.where((n) {
      if (_filter == NotificationFilter.unread) return !n.isRead;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemberitahuan'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => provider.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Tandai Dibaca'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => provider.fetchNotifications(widget.userId),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Chips
              Row(
                children: [
                  FilterChip(
                    label: Text('Semua (${notifications.length})'),
                    selected: _filter == NotificationFilter.all,
                    onSelected: (_) => setState(() => _filter = NotificationFilter.all),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Belum Dibaca (${provider.unreadCount})'),
                    selected: _filter == NotificationFilter.unread,
                    selectedColor: Colors.blue[100],
                    onSelected: (_) => setState(() => _filter = NotificationFilter.unread),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notification List
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredList.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.notifications_off_outlined,
                            title: 'Tidak Ada Notifikasi',
                            message: 'Notifikasi tugas baru akan muncul di sini.',
                            onRefresh: () => provider.fetchNotifications(widget.userId),
                          )
                        : ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                color: item.isRead ? Colors.white : Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: item.isRead ? Colors.grey[300]! : Colors.blue[300]!,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  leading: CircleAvatar(
                                    backgroundColor: item.isRead ? Colors.grey[300] : Colors.blue,
                                    child: Icon(
                                      Icons.assignment_ind,
                                      color: item.isRead ? Colors.grey[700] : Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(item.message),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.createdAt.replaceAll('T', ' ').split('.')[0],
                                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                  trailing: !item.isRead
                                      ? Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                  onTap: () {
                                    if (!item.isRead) {
                                      provider.markAsRead(item.id);
                                    }
                                  },
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
