import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/scan_badge.dart';

/// Bagian atas halaman login: logo, judul, dan subjudul. Tidak punya latar
/// sendiri karena latar gradasinya dipasang oleh [LoginScreen].
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ScanBadge(),
        const SizedBox(height: 16),
        Text(
          'Inventory Count',
          style: AppTextStyles.title.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Log in to start counting stock',
          textAlign: TextAlign.center,
          style: AppTextStyles.label.copyWith(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
