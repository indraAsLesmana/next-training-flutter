import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../repositories/task_repository.dart';

class TaskProvider with ChangeNotifier {
  final TaskRepository _taskRepo;
  
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskProvider(this._taskRepo);

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTasks({String? classId, String? guruId, String? siswaId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _taskRepo.getTasks(classId: classId, guruId: guruId, siswaId: siswaId);

    _isLoading = false;

    if (response.success && response.data != null) {
      _tasks = response.data!;
    } else {
      _error = response.message ?? 'Gagal mengambil daftar tugas';
    }
    notifyListeners();
  }

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

    if (response.success && response.data != null) {
      _tasks.insert(0, response.data!);
      notifyListeners();
      return true;
    } else if (response.success) {
      await fetchTasks(guruId: guruId, classId: classId);
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
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final old = _tasks[index];
        _tasks[index] = TaskModel(
          id: old.id,
          guruId: old.guruId,
          classId: old.classId,
          description: old.description,
          startDate: old.startDate,
          endDate: old.endDate,
          attachmentUrl: old.attachmentUrl,
          isSubmitted: true,
          submittedAt: response.data?.submittedAt ?? DateTime.now().toIso8601String(),
          submitUrl: submitUrl,
          submissionNotes: notes,
        );
      }
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      notifyListeners();
      return false;
    }
  }
}
