import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../opname/presentation/screens/opname_home_screen.dart';
import '../../../splash/presentation/screens/splash_screen.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../screens/login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({
    super.key,
    this.minimumSplashDuration = SplashScreen.displayDuration,
  });

  /// Splash tetap tampil selama ini walaupun status sesi sudah diketahui
  /// lebih cepat.
  final Duration minimumSplashDuration;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Timer? _splashTimer;
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();
    _splashTimer = Timer(widget.minimumSplashDuration, () {
      if (mounted) setState(() => _splashFinished = true);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Splash tampil selama timer belum habis ATAU sesi belum selesai
        // diperiksa. Dua-duanya harus beres baru lanjut.
        if (!_splashFinished || state.status == AuthStatus.unknown) {
          return const SplashScreen();
        }

        return switch (state.status) {
          AuthStatus.authenticated => const OpnameHomeScreen(),
          _ => const LoginScreen(),
        };
      },
    );
  }
}
