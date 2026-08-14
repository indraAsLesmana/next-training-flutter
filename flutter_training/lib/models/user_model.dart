class UserModel {
  final String id;
  final String nama;
  final String role;
  final String nipNik;
  final String? email;
  final String? classId;

  UserModel({
    required this.id,
    required this.nama,
    required this.role,
    required this.nipNik,
    this.email,
    this.classId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      role: json['role'],
      nipNik: json['nipNik'] ?? json['nip_nik'],
      email: json['email'],
      classId: json['classId'] ?? json['class_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'role': role,
      'nipNik': nipNik,
      'email': email,
      'classId': classId,
    };
  }
}
