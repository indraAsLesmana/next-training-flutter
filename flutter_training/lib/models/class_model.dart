class ClassModel {
  final String id;
  final String tingkat;
  final String namaKelas;

  ClassModel({
    required this.id,
    required this.tingkat,
    required this.namaKelas,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      tingkat: json['tingkat'],
      namaKelas: json['namaKelas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tingkat': tingkat,
      'namaKelas': namaKelas,
    };
  }
}
