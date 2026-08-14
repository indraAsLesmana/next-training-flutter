import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/class_model.dart';
import 'package:dio/dio.dart';

class SchoolRepository {
  final DioClient _client;

  SchoolRepository(this._client);

  Future<ApiResponse<List<ClassModel>>> getClasses() async {
    try {
      final response = await _client.dio.get('/api/classes');

      return ApiResponse<List<ClassModel>>.fromJson(
        response.data,
        (json) {
          final list = json as List<dynamic>;
          return list.map((e) => ClassModel.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse<List<ClassModel>>(
        success: false,
        message: e.response?.data?['message'] ?? e.message,
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<List<ClassModel>>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
