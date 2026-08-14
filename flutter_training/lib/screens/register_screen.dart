// lib/screens/register_screen.dart
// Halaman Register — form pendaftaran guru/siswa.
// Mengirim data ke backend Hono (neon dev) lalu user bisa cek
// barisnya muncul di Drizzle Studio (npm run db:studio).

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _nipNikController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _role = 'siswa'; // toggle: 'siswa' | 'guru'

  @override
  void dispose() {
    _namaController.dispose();
    _nipNikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      nama: _namaController.text.trim(),
      role: _role,
      nipNik: _nipNikController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Registrasi berhasil! Cek tabel users di Drizzle Studio.',
          ),
        ),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal: ${authProvider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // -- Pilihan peran: Siswa / Guru ----------------------------
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'siswa',
                      label: Text('Siswa'),
                      icon: Icon(Icons.school),
                    ),
                    ButtonSegment(
                      value: 'guru',
                      label: Text('Guru'),
                      icon: Icon(Icons.teacher),
                    ),
                  ],
                  selected: {_role},
                  onSelectionChanged: (selection) {
                    setState(() => _role = selection.first);
                  },
                ),
                const SizedBox(height: 16),

                // -- Nama lengkap ------------------------------------------
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                // -- NIP / NIK ----------------------------------------------
                TextFormField(
                  controller: _nipNikController,
                  decoration: InputDecoration(
                    labelText: _role == 'guru' ? 'NIP' : 'NIK',
                    hintText: _role == 'guru'
                        ? 'Nomor Induk Pegawai'
                        : 'Nomor Induk Kependudukan',
                    prefixIcon: const Icon(Icons.badge),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'NIP/NIK wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),

                // -- Email (opsional) ---------------------------------------
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (opsional)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // -- Password -----------------------------------------------
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password minimal 6 karakter'
                      : null,
                ),
                const SizedBox(height: 24),

                // -- Tombol submit ------------------------------------------
                FilledButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Daftar'),
                ),

                // -- Pesan sukses -------------------------------------------
                if (authProvider.registeredUser != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Terdaftar: ${authProvider.registeredUser!.nama} '
                        '(${authProvider.registeredUser!.role}) — '
                        'id: ${authProvider.registeredUser!.id}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
