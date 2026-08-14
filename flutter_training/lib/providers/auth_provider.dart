// lib/providers/auth_provider.dart
// AuthProvider — state management untuk proses register.
// Menyimpan status loading, error, dan user yang berhasil terdaftar.

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();

  bool _isLoading = false;
  String? _error;
  User? _registeredUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get registeredUser => _registeredUser;

  /// Memanggil API register. Mengembalikan true jika sukses.
  Future<bool> register({
    required String nama,
    required String role,
    required String nipNik,
    String? email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = User(
        nama: nama,
        role: role,
        nipNik: nipNik,
        email: email,
        password: password,
      );
      _registeredUser = await _api.register(user);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
