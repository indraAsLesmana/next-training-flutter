import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepo;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authRepo);

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

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
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Unknown error';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
