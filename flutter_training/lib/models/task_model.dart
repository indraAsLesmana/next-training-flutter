class TaskModel {
  final String id;
  final String guruId;
  final String classId;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentUrl;
  final bool isSubmitted;
  final String? submittedAt;
  final String? submitUrl;
  final String? submissionNotes;

  TaskModel({
    required this.id,
    required this.guruId,
    required this.classId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentUrl,
    this.isSubmitted = false,
    this.submittedAt,
    this.submitUrl,
    this.submissionNotes,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      guruId: json['guruId'] ?? json['guru_id'],
      classId: json['classId'] ?? json['class_id'],
      description: json['description'],
      startDate: json['startDate'] ?? json['start_date'],
      endDate: json['endDate'] ?? json['end_date'],
      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
      isSubmitted: json['isSubmitted'] ?? json['is_submitted'] ?? false,
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
      submitUrl: json['submitUrl'] ?? json['submit_url'],
      submissionNotes: json['submissionNotes'] ?? json['submission_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guruId': guruId,
      'classId': classId,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'attachmentUrl': attachmentUrl,
      'isSubmitted': isSubmitted,
      'submittedAt': submittedAt,
      'submitUrl': submitUrl,
      'submissionNotes': submissionNotes,
    };
  }
}
