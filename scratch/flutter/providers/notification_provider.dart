import 'dart:async';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  String? _activeUserId;

  NotificationProvider(this._repository);

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize notifications and start periodic 30s background timer
  void init(String userId) {
    if (_activeUserId == userId && _pollingTimer != null && _pollingTimer!.isActive) {
      return;
    }

    _activeUserId = userId;
    fetchNotifications(userId);

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_activeUserId != null) {
        checkUnreadCount(_activeUserId!);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _repository.getNotifications(userId);

    _isLoading = false;

    if (response.success && response.data != null) {
      _notifications = response.data!;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } else {
      _error = response.message ?? 'Gagal mengambil notifikasi';
    }
    notifyListeners();
  }

  Future<void> checkUnreadCount(String userId) async {
    final response = await _repository.getUnreadCount(userId);
    if (response.success && response.data != null) {
      if (_unreadCount != response.data!) {
        _unreadCount = response.data!;
        // Re-fetch full list if new notifications arrived
        fetchNotifications(userId);
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, 999);
      notifyListeners();

      await _repository.markAsRead(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    if (_activeUserId == null) return;

    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    await _repository.markAllAsRead(_activeUserId!);
  }
}
