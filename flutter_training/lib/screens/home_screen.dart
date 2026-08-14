// lib/screens/home_screen.dart
// Halaman beranda sederhana setelah register berhasil.
// (Session 2 akan mengganti ini dengan dashboard guru/siswa yang lengkap.)

import 'package:flutter/material.dart';
import 'register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aplikasi Pengumpulan Tugas')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade600),
            const SizedBox(height: 16),
            const Text(
              'Selamat datang!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registrasi berhasil. Cek database kamu di Drizzle Studio.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Daftar User Baru'),
            ),
          ],
        ),
      ),
    );
  }
}
