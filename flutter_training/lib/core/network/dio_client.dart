import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DioClient {
  late final Dio dio;

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
