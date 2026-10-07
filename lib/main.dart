import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/session_storage.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth/auth_event.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'features/auth/presentation/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Satu ApiClient dipakai bersama oleh semua repository, supaya token yang
  // dipasang AuthRepository setelah login otomatis ikut terpakai saat
  // DepartmentRepository (dan repository lain nanti) memanggil endpoint
  // yang perlu Authorization header.
  final apiClient = ApiClient();

  runApp(
    MyApp(
      authRepository: AuthRepository(
        apiClient: apiClient,
        storage: SecureSessionStorage(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    // Repository disediakan ke seluruh pohon widget supaya LoginScreen bisa
    // membuat LoginBloc-nya sendiri saat layar itu dibuka
    return RepositoryProvider.value(
      value: authRepository,
      child: BlocProvider(
        create: (_) => AuthBloc(repository: authRepository)..add(const AuthStarted()),
        child: MaterialApp(
          title: 'Inventory',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const AuthGate(),
        ),
      ),
    );
  }
}
