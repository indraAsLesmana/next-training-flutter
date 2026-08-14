import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/task_model.dart';
import '../models/submission_model.dart';
import 'package:dio/dio.dart';

class TaskRepository {
  final DioClient _client;

  TaskRepository(this._client);

  Future<ApiResponse<TaskModel>> createTask({
    required String guruId,
    required String classId,
    required String description,
    required String startDate,
    required String endDate,
    String? attachmentUrl,
  }) async {
    try {
      final response = await _client.dio.post('/api/tasks', data: {
        'guruId': guruId,
        'classId': classId,
        'description': description,
        'startDate': startDate,
        'endDate': endDate,
        'attachmentUrl': attachmentUrl,
      });

      return ApiResponse<TaskModel>.fromJson(
        response.data,
        (json) => TaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<TaskModel>(
        success: false,
        message: DioClient.getErrorMessage(e),
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<TaskModel>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<SubmissionModel>> submitTask({
    required String taskId,
    required String siswaId,
    required String submitUrl,
    String? notes,
  }) async {
    try {
      final response = await _client.dio.post('/api/submissions', data: {
        'taskId': taskId,
        'siswaId': siswaId,
        'submitUrl': submitUrl,
        'notes': notes,
      });

      return ApiResponse<SubmissionModel>.fromJson(
        response.data,
        (json) => SubmissionModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<SubmissionModel>(
        success: false,
        message: DioClient.getErrorMessage(e),
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<SubmissionModel>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
