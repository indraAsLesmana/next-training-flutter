class TaskModel {
  final String id;
  final String guruId;
  final String classId;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentUrl;

  TaskModel({
    required this.id,
    required this.guruId,
    required this.classId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentUrl,
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
    };
  }
}
