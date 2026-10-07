import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/hero_header.dart';
import '../../../../core/widgets/scan_badge.dart';
import '../../../auth/presentation/bloc/auth/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth/auth_event.dart';
import '../../data/dummy/opname_dummy.dart';
import '../widgets/home_guide_card.dart';
import '../widgets/home_header_content.dart';
import '../widgets/home_start_button.dart';
import 'opname_count_screen.dart';

/// Halaman pertama: header abu-hijau, tombol scan bulat di tengah,
/// lalu panduan 4 langkah. Satu ketukan membuka kamera.
/// Layar ini hanya menyusun widget; isi tiap bagian ada di widgets/home_*.dart.
class OpnameHomeScreen extends StatelessWidget {
  const OpnameHomeScreen({super.key});

  void _start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OpnameCountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = dummyOpnameItems.length;
    final rackCount = dummyOpnameItems.map((e) => e.location).toSet().length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: HeroHeader.overlayStyle,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header + tombol scan yang menumpuk di tepinya
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: HeroHeader(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 64),
                      child: HomeHeaderContent(
                        itemCount: itemCount,
                        rackCount: rackCount,
                        onLogoutConfirmed: () => context
                            .read<AuthBloc>()
                            .add(const AuthLogoutRequested()),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: ScanBadge(onTap: () => _start(context)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Ketuk untuk scan',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Bisa barcode batang atau QR code',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: HomeGuideCard(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: HomeStartButton(
          onPressed: () => _start(context),
        ),
      ),
    );
  }
}
