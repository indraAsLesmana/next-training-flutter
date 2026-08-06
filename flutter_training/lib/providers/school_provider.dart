import 'package:flutter/material.dart';
import '../repositories/school_repository.dart';
import '../models/class_model.dart';

class SchoolProvider with ChangeNotifier {
  final SchoolRepository _schoolRepo;
  
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _error;

  SchoolProvider(this._schoolRepo);

  List<ClassModel> get classes => _classes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchClasses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _schoolRepo.getClasses();

    _isLoading = false;

    if (response.success && response.data != null) {
      _classes = response.data!;
    } else {
      _error = response.message ?? 'Failed to load classes';
    }
    notifyListeners();
  }
}
