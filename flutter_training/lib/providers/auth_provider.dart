import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepo;
  final DioClient _dioClient;

  static const String _userSessionKey = 'user_session';
  static const String _tokenKey = 'auth_token';

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  AuthProvider(this._authRepo, this._dioClient);

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
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
      final savedToken = prefs.getString(_tokenKey);

      if (userJsonString != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonString);
        _currentUser = UserModel.fromJson(userMap);
      }

      _token = savedToken;
      _dioClient.setToken(_token);
    } catch (e) {
      debugPrint('Failed to load user session: $e');
      _currentUser = null;
      _token = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession(UserModel user, String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userSessionKey, jsonEncode(user.toJson()));
      if (token != null) {
        await prefs.setString(_tokenKey, token);
      }
    } catch (e) {
      debugPrint('Failed to save user session: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
      await prefs.remove(_tokenKey);
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
      _token = response.token;
      _dioClient.setToken(_token);
      await _saveSession(_currentUser!, _token);
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
      _token = response.token;
      _dioClient.setToken(_token);
      await _saveSession(_currentUser!, _token);
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
    _token = null;
    _dioClient.setToken(null);
    await _clearSession();
    notifyListeners();
  }
}
