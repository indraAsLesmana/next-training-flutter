import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepo;

  static const String _userSessionKey = 'user_session';

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  AuthProvider(this._authRepo);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> loadSession() async {
    _isInitializing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userSessionKey);

      if (userJsonString != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonString);
        _currentUser = UserModel.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Failed to load user session: $e');
      _currentUser = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Failed to save user session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
    } catch (e) {
      debugPrint('Failed to clear user session: $e');
    }
  }

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

    final response = await _authRepo.registerUser(
      nama: nama,
      role: role,
      nipNik: nipNik,
      password: password,
      email: email,
      classId: classId,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _currentUser = response.data;
      await _saveSession(_currentUser!);
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Gagal mendaftar';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String nipNik,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _authRepo.loginUser(
      nipNik: nipNik,
      password: password,
    );

    _isLoading = false;

    if (response.success && response.data != null) {
      _currentUser = response.data;
      await _saveSession(_currentUser!);
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'NIP/NIK atau password salah';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await _clearSession();
    notifyListeners();
  }
}
