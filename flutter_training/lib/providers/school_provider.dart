// lib/providers/school_provider.dart
// SchoolProvider — state untuk data master kelas (dropdown Tingkat & Ruang Kelas).

import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/auth_api_service.dart';

class SchoolProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();

  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _api.fetchClasses();

    _isLoading = false;

    if (response.success && response.data != null) {
      _classes = response.data!;
    } else {
      _error = response.message ?? 'Gagal memuat kelas';
    }
    notifyListeners();
  }
}
