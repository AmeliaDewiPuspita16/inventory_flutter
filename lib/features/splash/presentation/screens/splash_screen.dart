import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hero_header.dart';
import '../../../../core/widgets/scan_badge.dart';
import '../../../auth/presentation/widgets/barcode_decoration.dart';

/// Layar pembuka selama aplikasi memeriksa sesi tersimpan.
///
/// Tampilannya sengaja mengikuti halaman login (gradasi abu-hijau yang
/// memudar ke krem, hiasan barcode di kanan atas, logo [ScanBadge]) supaya
/// perpindahan splash -> login terasa menyambung, bukan ganti halaman.
///
/// Tidak punya logika apa pun: [AuthGate] yang menentukan kapan layar ini
/// diganti.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Lama minimal layar ini tampil. Dipakai [AuthGate] kalau ingin splash
  /// tidak berkedip saat sesi ternyata sudah diketahui lebih cepat.
  static const Duration displayDuration = Duration(milliseconds: 2000);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _appVersion = '1.0.0';

  static const LinearGradient _background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroTop, AppColors.heroBottom, AppColors.background],
    stops: [0, 0.55, 1],
  );

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    // Satu gerakan saja: logo dan judul muncul pelan, sekali, lalu diam.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _scale = Tween<double>(begin: 0.92, end: 1).animate(curve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: HeroHeader.overlayStyle,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: _background),
          child: Stack(
            children: [
              // Hiasan barcode, posisinya sama persis dengan di halaman login.
              Positioned(
                top: 0,
                right: 24,
                child: FadeTransition(
                  opacity: _fade,
                  child: const BarcodeDecoration(),
                ),
              ),

              // Logo + nama aplikasi di tengah layar.
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ScanBadge(size: 96),
                          const SizedBox(height: 20),
                          Text(
                            'Inventory Count',
                            style: AppTextStyles.title.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cek stok fisik dengan scan barcode.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.label.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Indikator muat + versi di dasar layar.
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Versi $_appVersion', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
