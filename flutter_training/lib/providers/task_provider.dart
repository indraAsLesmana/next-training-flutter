import 'package:flutter/material.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepo;
  
  bool _isLoading = false;
  String? _error;

  TaskProvider(this._taskRepo);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createNewTask({
    required String guruId,
    required String classId,
    required String description,
    required String startDate,
    required String endDate,
    String? attachmentUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _taskRepo.createTask(
      guruId: guruId,
      classId: classId,
      description: description,
      startDate: startDate,
      endDate: endDate,
      attachmentUrl: attachmentUrl,
    );

    _isLoading = false;

    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitStudentTask({
    required String taskId,
    required String siswaId,
    required String submitUrl,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _taskRepo.submitTask(
      taskId: taskId,
      siswaId: siswaId,
      submitUrl: submitUrl,
      notes: notes,
    );

    _isLoading = false;

    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      notifyListeners();
      return false;
    }
  }
}
