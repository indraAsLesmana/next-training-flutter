import 'team_member_model.dart';

class TaskModel {
  final String id;
  final String guruId;
  final String classId;
  final String description;
  final String startDate;
  final String endDate;
  final String? attachmentUrl;
  final bool isTeamTask;
  final int maxTeamMembers;
  final bool isSubmitted;
  final String? submittedAt;
  final String? submitUrl;
  final String? submissionNotes;
  final List<TeamMemberInfo> teamMembers;

  TaskModel({
    required this.id,
    required this.guruId,
    required this.classId,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.attachmentUrl,
    this.isTeamTask = false,
    this.maxTeamMembers = 5,
    this.isSubmitted = false,
    this.submittedAt,
    this.submitUrl,
    this.submissionNotes,
    this.teamMembers = const [],
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['teamMembers'] ?? json['team_members'];
    List<TeamMemberInfo> membersList = [];
    if (rawMembers is List) {
      membersList = rawMembers.map((e) => TeamMemberInfo.fromJson(e as Map<String, dynamic>)).toList();
    }

    return TaskModel(
      id: json['id'],
      guruId: json['guruId'] ?? json['guru_id'],
      classId: json['classId'] ?? json['class_id'],
      description: json['description'],
      startDate: json['startDate'] ?? json['start_date'],
      endDate: json['endDate'] ?? json['end_date'],
      attachmentUrl: json['attachmentUrl'] ?? json['attachment_url'],
      isTeamTask: json['isTeamTask'] ?? json['is_team_task'] ?? false,
      maxTeamMembers: json['maxTeamMembers'] ?? json['max_team_members'] ?? 5,
      isSubmitted: json['isSubmitted'] ?? json['is_submitted'] ?? false,
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
      submitUrl: json['submitUrl'] ?? json['submit_url'],
      submissionNotes: json['submissionNotes'] ?? json['submission_notes'],
      teamMembers: membersList,
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
      'isTeamTask': isTeamTask,
      'maxTeamMembers': maxTeamMembers,
      'isSubmitted': isSubmitted,
      'submittedAt': submittedAt,
      'submitUrl': submitUrl,
      'submissionNotes': submissionNotes,
      'teamMembers': teamMembers.map((m) => m.toJson()).toList(),
    };
  }
}
