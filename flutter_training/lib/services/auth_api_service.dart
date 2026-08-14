// lib/services/auth_api_service.dart
// Layanan API untuk autentikasi & master data kelas.
// Memakai Dio (via DioClient) untuk HTTP — bukan package http.
//
// Di Session 2, service ini akan di-refactor menjadi
// AuthRepository + SchoolRepository (pola repository).

import 'package:dio/dio.dart';
import '../core/network/api_response.dart';
import '../core/network/dio_client.dart';
import '../models/class_model.dart';
import '../models/user_model.dart';

class AuthApiService {
  final DioClient _client = DioClient();

  // POST /api/auth/register — daftarkan user baru
  Future<ApiResponse<UserModel>> register({
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
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<UserModel>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  // GET /api/classes — ambil daftar kelas (untuk dropdown Tingkat & Ruang Kelas)
  Future<ApiResponse<List<ClassModel>>> fetchClasses() async {
    try {
      final response = await _client.dio.get('/api/classes');

      return ApiResponse<List<ClassModel>>.fromJson(
        response.data,
        (json) {
          final list = json as List<dynamic>;
          return list
              .map((e) => ClassModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } on DioException catch (e) {
      return ApiResponse<List<ClassModel>>(
        success: false,
        message: DioClient.getErrorMessage(e),
      );
    } catch (e) {
      return ApiResponse<List<ClassModel>>(
        success: false,
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }
}
