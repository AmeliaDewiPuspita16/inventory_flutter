import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/widgets/logout_button.dart';

/// isi header halaman awal: judul, subjudul, chip jumlah barang/rak,
/// dan tombol logout dikanan atas
class HomeHeaderContent extends StatelessWidget {
  final int itemCount;
  final int rackCount;
  final VoidCallback onLogoutConfirmed;

  const HomeHeaderContent({
    super.key,
    required this.itemCount,
    required this.rackCount,
    required this.onLogoutConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hitung Inventaris',
                style: AppTextStyles.title.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cek stok fisik dengan scan barcode.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.inventory_2_outlined,
                    label: '$itemCount barang',
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.place_outlined,
                    label: '$rackCount rak',
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: LogoutButton(onConfirmed: onLogoutConfirmed),
        ),
      ],
    );
  }
}

/// Chip kecil di header, misalnya "5 barang" atau "5 rak".
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
