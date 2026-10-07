import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hero_header.dart';
import '../../data/auth_repository.dart';
import '../../domain/login_credentials.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import '../widgets/barcode_decoration.dart';
import '../widgets/login_form_card.dart';
import '../widgets/login_header.dart';

/// Halaman login. Bagian luar ini hanya menyediakan [LoginBloc]; isi layar
/// ada di [_LoginView].
///
/// LoginBloc berumur pendek (hidup selama layar ini saja). Status sesi yang
/// jangka panjang dipegang AuthBloc, yang sudah dibuat di main.dart.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        // AuthRepository diambil dari RepositoryProvider di main.dart.
        repository: context.read<AuthRepository>(),
      ),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  static const String _appVersion = '1.0.0';

  /// Tinggi gradasi abu-hijau di bagian atas (belum termasuk status bar).
  static const double _glowHeight = 340;

  static const LinearGradient _glow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroTop, AppColors.heroBottom, AppColors.background],
    stops: [0, 0.6, 1],
  );

  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  /// Pesan dari validasi lokal (email kosong, format salah, dst).
  /// Pesan dari server TIDAK disimpan di sini, tapi di LoginState.
  String? _validationError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Dipanggil setiap user mengetik: hilangkan pesan error yang lama.
  void _clearError() {
    if (_validationError != null) setState(() => _validationError = null);

    final bloc = context.read<LoginBloc>();
    if (bloc.state.status == LoginStatus.failure) {
      bloc.add(const LoginReset());
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    // 1. Validasi lokal dulu, supaya tidak ada request yang sia-sia.
    final credentials = LoginCredentials(
      email: _email.text.trim(),
      password: _password.text,
    );
    final error = credentials.emailError ?? credentials.passwordError;
    if (error != null) {
      setState(() => _validationError = error);
      return;
    }

    // 2. Lolos validasi: serahkan ke LoginBloc, yang memanggil API.
    context.read<LoginBloc>().add(
          LoginSubmitted(
            email: credentials.email,
            password: credentials.password,
          ),
        );
  }

  /// Navigasi TIDAK dilakukan di sini. Cukup kabari AuthBloc bahwa sesi
  /// sudah sah; AuthGate yang akan mengganti layar ke halaman utama.
  void _onLoginState(BuildContext context, LoginState state) {
    final session = state.session;
    if (state.status == LoginStatus.success && session != null) {
      context.read<AuthBloc>().add(AuthSessionGranted(session));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return BlocConsumer<LoginBloc, LoginState>(
      listener: _onLoginState,
      builder: (context, state) {
        // Error lokal didahulukan; kalau tidak ada, pakai pesan dari server.
        final errorText = _validationError ??
            (state.status == LoginStatus.failure ? state.errorMessage : null);

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: HeroHeader.overlayStyle,
          child: Scaffold(
            body: CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Stack(
                    children: [
                      // Gradasi abu-hijau yang memudar ke krem.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _glowHeight + topInset,
                        child: const DecoratedBox(
                          decoration: BoxDecoration(gradient: _glow),
                        ),
                      ),
                      // Hiasan barcode: menggantung dari tepi atas.
                      const Positioned(
                        top: 0,
                        right: 24,
                        child: BarcodeDecoration(),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              const LoginHeader(),
                              const SizedBox(height: 32),
                              LoginFormCard(
                                emailController: _email,
                                passwordController: _password,
                                obscurePassword: _obscure,
                                onToggleObscure: () =>
                                    setState(() => _obscure = !_obscure),
                                onSubmit: _submit,
                                onChanged: _clearError,
                                errorText: errorText,
                                isLoading: state.isLoading,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Forgotten your password? Contact the admin',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.label,
                              ),
                              const SizedBox(height: 28),
                              const Spacer(),
                              Text(
                                'Versi $_appVersion',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
