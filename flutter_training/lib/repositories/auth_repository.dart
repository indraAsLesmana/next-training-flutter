import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  Future<ApiResponse<UserModel>> registerUser({
    required String nama,
    required String role,
    required String nipNik,
    required String password,
    String? email,
    String? classId,
  }) async {
    try {
      final response = await _client.dio.post('/api/auth/register', data: {
        'nama': nama,
        'role': role,
        'nipNik': nipNik,
        'password': password,
        'email': email,
        'classId': classId,
      });

      return ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data?['message'] ?? e.message,
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<UserModel>> loginUser({
    required String nipNik,
    required String password,
  }) async {
    try {
      final response = await _client.dio.post('/api/auth/login', data: {
        'nipNik': nipNik,
        'password': password,
      });

      return ApiResponse<UserModel>.fromJson(
        response.data,
        (json) => UserModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.response?.data?['message'] ?? e.message,
        error: e.response?.data?['error'],
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
