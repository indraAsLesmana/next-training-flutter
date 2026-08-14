// lib/providers/auth_provider.dart
// AuthProvider — state untuk proses register.
// (Login & session akan dibahas di Session 3.)

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();

  bool _isLoading = false;
  String? _error;
  UserModel? _registeredUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get registeredUser => _registeredUser;

  Future<bool> register({
    required String nama,
    required String role,
    required String nipNik,
    required String password,
    String? email,
    String? classId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.register(
      nama: nama,
      role: role,
      nipNik: nipNik,
      password: password,
      email: email,
      classId: classId,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _registeredUser = response.data;
      notifyListeners();
      return true;
    }

    _error = response.message ?? 'Gagal mendaftar';
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
