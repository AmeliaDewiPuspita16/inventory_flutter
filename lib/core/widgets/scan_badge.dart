import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Lingkaran primary berisi ikon scan, dengan cincin putih di luarnya.
/// Dipakai sebagai tombol scan di halaman awal (isi [onTap]) dan sebagai
/// logo di halaman login (kosongkan [onTap]).
class ScanBadge extends StatelessWidget {
  final VoidCallback? onTap;

  /// Diameter lingkaran primary (tanpa cincin putih).
  final double size;

  const ScanBadge({super.key, this.onTap, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Ink(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.qr_code_scanner_rounded,
                size: size / 2,
                color: AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
