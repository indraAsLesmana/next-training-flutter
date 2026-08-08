import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  // Parsing response { success, data: user, token } -> UserModel dengan token.
  ApiResponse<UserModel> _parseAuthResponse(Map<String, dynamic> map) {
    final baseUser = UserModel.fromJson(map['data'] as Map<String, dynamic>);
    final user = baseUser.copyWith(token: map['token'] as String?);
    return ApiResponse<UserModel>(success: true, data: user);
  }

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

      return _parseAuthResponse(response.data as Map<String, dynamic>);
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

      return _parseAuthResponse(response.data as Map<String, dynamic>);
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
