// lib/models/user_model.dart
// Model User untuk halaman Register.
// Mewakili satu baris di tabel `users` (Neon PostgreSQL).

class User {
  final String? id;      // UUID dari database (null sebelum disimpan)
  final String nama;
  final String role;     // 'guru' | 'siswa'
  final String nipNik;   // NIP (guru) atau NIK (siswa)
  final String? email;
  final String password; // Plain text — versi training (tanpa bcrypt)

  User({
    this.id,
    required this.nama,
    required this.role,
    required this.nipNik,
    this.email,
    required this.password,
  });

  // Mengubah objek User menjadi Map untuk dikirim ke API (JSON body).
  Map<String, dynamic> toJson() => {
        'nama': nama,
        'role': role,
        'nipNik': nipNik,
        'email': email,
        'password': password,
        // classId dikirim null untuk guru; siswa akan diisi di Session 2
        'classId': null,
      };
}
