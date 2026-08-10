import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/dio_client.dart';
import 'repositories/auth_repository.dart';
import 'repositories/school_repository.dart';
import 'repositories/task_repository.dart';

import 'providers/auth_provider.dart';
import 'providers/school_provider.dart';
import 'providers/task_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/guru/teacher_home_screen.dart';
import 'screens/siswa/student_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  final authRepo = AuthRepository(dioClient);
  final schoolRepo = SchoolRepository(dioClient);
  final taskRepo = TaskRepository(dioClient);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: schoolRepo),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)..loadSession()),
        ChangeNotifierProvider(create: (_) => SchoolProvider(schoolRepo)..fetchClasses()),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pengumpulan Tugas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isInitializing) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }

          if (authProvider.currentUser?.role == 'guru') {
            return const TeacherHomeScreen();
          } else {
            return const StudentHomeScreen();
          }
        },
      ),
    );
  }
}
