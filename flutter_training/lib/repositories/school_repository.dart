import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/class_model.dart';
import '../models/team_member_model.dart';
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
        message: DioClient.getErrorMessage(e),
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<List<ClassModel>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<List<TeamMemberInfo>>> searchStudents({required String classId, required String query}) async {
    try {
      final response = await _client.dio.get('/api/students/search', queryParameters: {
        'classId': classId,
        'query': query,
      });

      return ApiResponse<List<TeamMemberInfo>>.fromJson(
        response.data,
        (json) {
          final list = json as List<dynamic>;
          return list.map((e) => TeamMemberInfo.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse<List<TeamMemberInfo>>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<List<TeamMemberInfo>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
