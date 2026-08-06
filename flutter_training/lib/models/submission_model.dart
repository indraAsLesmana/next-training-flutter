class SubmissionModel {
  final String id;
  final String taskId;
  final String siswaId;
  final String submitUrl;
  final String? notes;
  final String? submittedAt;

  SubmissionModel({
    required this.id,
    required this.taskId,
    required this.siswaId,
    required this.submitUrl,
    this.notes,
    this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'],
      taskId: json['taskId'] ?? json['task_id'],
      siswaId: json['siswaId'] ?? json['siswa_id'],
      submitUrl: json['submitUrl'] ?? json['submit_url'],
      notes: json['notes'],
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'siswaId': siswaId,
      'submitUrl': submitUrl,
      'notes': notes,
      'submittedAt': submittedAt,
    };
  }
}
