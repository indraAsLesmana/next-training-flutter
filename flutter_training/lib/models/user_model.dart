class UserModel {
  final String id;
  final String nama;
  final String role;
  final String nipNik;
  final String? email;
  final String? classId;
  final String? token;

  UserModel({
    required this.id,
    required this.nama,
    required this.role,
    required this.nipNik,
    this.email,
    this.classId,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      role: json['role'],
      nipNik: json['nipNik'] ?? json['nip_nik'],
      email: json['email'],
      classId: json['classId'] ?? json['class_id'],
      token: json['token'],
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
      'token': token,
    };
  }

  UserModel copyWith({
    String? id,
    String? nama,
    String? role,
    String? nipNik,
    String? email,
    String? classId,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      nipNik: nipNik ?? this.nipNik,
      email: email ?? this.email,
      classId: classId ?? this.classId,
      token: token ?? this.token,
    );
  }
}
