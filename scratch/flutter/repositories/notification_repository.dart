import 'package:dio/dio.dart';
import '../../../flutter_training/lib/core/network/dio_client.dart';
import '../../../flutter_training/lib/core/network/api_response.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final DioClient _client;

  NotificationRepository(this._client);

  Future<ApiResponse<List<NotificationModel>>> getNotifications(String userId) async {
    try {
      final response = await _client.dio.get(
        '/api/notifications',
        queryParameters: {'userId': userId},
      );

      return ApiResponse<List<NotificationModel>>.fromJson(
        response.data,
        (json) {
          final list = json as List<dynamic>;
          return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse<List<NotificationModel>>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<List<NotificationModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<int>> getUnreadCount(String userId) async {
    try {
      final response = await _client.dio.get(
        '/api/notifications/unread-count',
        queryParameters: {'userId': userId},
      );

      final unreadCount = response.data['data']?['unreadCount'] ?? 0;
      return ApiResponse<int>(success: true, data: unreadCount);
    } on DioException catch (e) {
      return ApiResponse<int>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<int>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      await _client.dio.patch('/api/notifications/$notificationId/read');
      return ApiResponse<void>(success: true);
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> markAllAsRead(String userId) async {
    try {
      await _client.dio.patch(
        '/api/notifications/read-all',
        queryParameters: {'userId': userId},
      );
      return ApiResponse<void>(success: true);
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<void>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
