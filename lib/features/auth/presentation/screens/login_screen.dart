import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hero_header.dart';
import '../../../opname/presentation/screens/opname_home_screen.dart';
import '../widgets/barcode_decoration.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_card.dart';

/// halaman login. Menyimpan state input (controller, tampil/sembunyi
/// password, pesan error) dan memutuskan apa yang terjadi saat "masuk"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _appVersion = '1.0.0';

  /// Tinggi gradasi abu-hijau di bagian atas (belum termasuk status bar).
  /// Gradasi memudar ke warna latar krem, jadi tidak ada tepi yang keras.
  static const double _glowHeight = 340;

  static const LinearGradient _glow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroTop, AppColors.heroBottom, AppColors.background],
    stops: [0, 0.6, 1],
  );

  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (_username.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'You must enter your username and password');
      return;
    }

    // Belum terhubung ke API: untuk sekarang langsung lanjut ke halaman utama
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OpnameHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: HeroHeader.overlayStyle,
      child: Scaffold(
        body: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            usernameController: _username,
                            passwordController: _password,
                            obscurePassword: _obscure,
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            onSubmit: _submit,
                            onChanged: _clearError,
                            errorText: _error,
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
  }
}
