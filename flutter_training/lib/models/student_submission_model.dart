import 'team_member_model.dart';

class StudentSubmissionModel {
  final String siswaId;
  final String nama;
  final String nipNik;
  final String? email;
  final bool isSubmitted;
  final String? submitUrl;
  final String? notes;
  final String? submittedAt;
  final List<TeamMemberInfo> teamMembers;

  StudentSubmissionModel({
    required this.siswaId,
    required this.nama,
    required this.nipNik,
    this.email,
    required this.isSubmitted,
    this.submitUrl,
    this.notes,
    this.submittedAt,
    this.teamMembers = const [],
  });

  factory StudentSubmissionModel.fromJson(Map<String, dynamic> json) {
    final rawMembers = json['teamMembers'] ?? json['team_members'];
    List<TeamMemberInfo> membersList = [];
    if (rawMembers is List) {
      membersList = rawMembers.map((e) => TeamMemberInfo.fromJson(e as Map<String, dynamic>)).toList();
    }

    return StudentSubmissionModel(
      siswaId: json['siswaId'] ?? json['siswa_id'] ?? '',
      nama: json['nama'] ?? '',
      nipNik: json['nipNik'] ?? json['nip_nik'] ?? '',
      email: json['email'],
      isSubmitted: json['isSubmitted'] ?? json['is_submitted'] ?? false,
      submitUrl: json['submitUrl'] ?? json['submit_url'],
      notes: json['notes'],
      submittedAt: json['submittedAt'] ?? json['submitted_at'],
      teamMembers: membersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswaId': siswaId,
      'nama': nama,
      'nipNik': nipNik,
      'email': email,
      'isSubmitted': isSubmitted,
      'submitUrl': submitUrl,
      'notes': notes,
      'submittedAt': submittedAt,
      'teamMembers': teamMembers.map((m) => m.toJson()).toList(),
    };
  }
}
