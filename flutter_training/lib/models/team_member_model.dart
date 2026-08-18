class TeamMemberInfo {
  final String siswaId;
  final String nama;
  final String nipNik;

  TeamMemberInfo({
    required this.siswaId,
    required this.nama,
    required this.nipNik,
  });

  factory TeamMemberInfo.fromJson(Map<String, dynamic> json) {
    return TeamMemberInfo(
      siswaId: json['siswaId'] ?? json['siswa_id'] ?? json['id'] ?? '',
      nama: json['nama'] ?? '',
      nipNik: json['nipNik'] ?? json['nip_nik'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siswaId': siswaId,
      'nama': nama,
      'nipNik': nipNik,
    };
  }
}
