import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DioClient {
  late final Dio dio;

  // Token JWT yang dikirim pada header `Authorization: Bearer <token>`.
  // Di-set oleh AuthProvider setelah login/register / saat restore sesi.
  String? authToken;

  DioClient() {
    // Determine base URL dynamically
    // Use 10.0.2.2 for Android Emulator, otherwise localhost
    String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8787');

    if (!kIsWeb && Platform.isAndroid && baseUrl.contains('localhost')) {
      baseUrl = baseUrl.replaceAll('localhost', '10.0.2.2');
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Tambahkan Authorization header ke setiap request jika token tersedia.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = authToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
}
