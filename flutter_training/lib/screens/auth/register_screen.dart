import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/school_provider.dart';

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

  String _role = 'siswa';
  String? _selectedTingkat;
  String? _selectedNamaKelas;
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchoolProvider>().fetchClasses();
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nipNikController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'siswa' && _selectedClassId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih Tingkat dan Kelas terlebih dahulu')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.register(
      nama: _namaController.text,
      role: _role,
      nipNik: _nipNikController.text,
      password: _passwordController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
      classId: _role == 'siswa' ? _selectedClassId : null,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Gagal mendaftar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schoolProvider = context.watch<SchoolProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Extract unique Tingkat list (e.g. ['X', 'XI', 'XII'])
    final uniqueTingkatList = schoolProvider.classes.map((c) => c.tingkat).toSet().toList();

    // Filter available Nama Kelas list based on selected Tingkat (e.g. ['a', 'b', 'c', 'd'])
    final availableNamaKelasList = _selectedTingkat == null
        ? <String>[]
        : schoolProvider.classes
            .where((c) => c.tingkat == _selectedTingkat)
            .map((c) => c.namaKelas)
            .toSet()
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Kelas',
            onPressed: () => context.read<SchoolProvider>().fetchClasses(),
          )
        ],
      ),
      body: schoolProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<SchoolProvider>().fetchClasses(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (schoolProvider.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Gagal memuat kelas: ${schoolProvider.error}',
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _namaController,
                        decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Peran'),
                        items: const [
                          DropdownMenuItem(value: 'siswa', child: Text('Siswa')),
                          DropdownMenuItem(value: 'guru', child: Text('Guru')),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _role = val!;
                            if (_role == 'guru') {
                              _selectedTingkat = null;
                              _selectedNamaKelas = null;
                              _selectedClassId = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nipNikController,
                        decoration: InputDecoration(
                          labelText: _role == 'guru' ? 'NIP' : 'NIS/NIK',
                        ),
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email (Opsional)'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                      ),
                      if (_role == 'siswa') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // Tingkat Dropdown (X, XI, XII)
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedTingkat,
                                decoration: const InputDecoration(labelText: 'Tingkat'),
                                hint: const Text('Pilih Tingkat'),
                                items: uniqueTingkatList.map((t) {
                                  return DropdownMenuItem(
                                    value: t,
                                    child: Text('Kelas $t'),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedTingkat = val;
                                    _selectedNamaKelas = null;
                                    _selectedClassId = null;
                                  });
                                },
                                validator: (v) => v == null ? 'Pilih tingkat' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Nama Kelas Dropdown (a, b, c, d)
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedNamaKelas,
                                decoration: const InputDecoration(labelText: 'Ruang Kelas'),
                                hint: const Text('Pilih Kelas'),
                                items: availableNamaKelasList.map((k) {
                                  return DropdownMenuItem(
                                    value: k,
                                    child: Text('Kelas ${k.toUpperCase()}'),
                                  );
                                }).toList(),
                                onChanged: _selectedTingkat == null
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _selectedNamaKelas = val;
                                          final match = schoolProvider.classes.firstWhere(
                                            (c) =>
                                                c.tingkat == _selectedTingkat &&
                                                c.namaKelas == _selectedNamaKelas,
                                          );
                                          _selectedClassId = match.id;
                                        });
                                      },
                                validator: (v) => v == null ? 'Pilih kelas' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _submit,
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Daftar'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Sudah punya akun?'),
                          TextButton(
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('Masuk di sini'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
