// lib/services/auth_api_service.dart
// Client HTTP sederhana untuk endpoint auth backend Hono.
// Backend dijalankan lokal dengan `neon dev` (port 8787).

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthApiService {
  // Base URL backend Hono lokal (dijalankan dengan `neon dev`).
  // Catatan: Android emulator memakai 10.0.2.2, bukan localhost.
  final String baseUrl = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8787',
  );

  /// Mengirim data register ke `POST /api/auth/register`.
  /// Mengembalikan User yang berhasil dibuat (dengan id dari database).
  Future<User> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 && body['success'] == true) {
      final data = body['data'] as Map<String, dynamic>;
      return User(
        id: data['id'],
        nama: data['nama'],
        role: data['role'],
        nipNik: data['nipNik'],
        email: data['email'],
        password: user.password,
      );
    }

    throw Exception(body['message'] ?? 'Gagal mendaftar (HTTP ${response.statusCode})');
  }
}
