import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Badge selisih hitung vs sistem (pakai latar warna):
/// hijau "+8 sak" (bertambah), merah "-8 sak" (berkurang),
/// abu "Sesuai sistem" (sama), abu muda "Belum dihitung".
class DifferenceLabel extends StatelessWidget {
  final double? difference;
  final String unit;

  const DifferenceLabel({super.key, required this.difference, required this.unit});

  @override
  Widget build(BuildContext context) {
    final d = difference;
    final Color fg;
    final Color bg;
    final IconData icon;
    final String text;

    if (d == null) {
      fg = AppColors.textMuted;
      bg = AppColors.background;
      icon = Icons.hourglass_empty_rounded;
      text = 'Belum dihitung';
    } else if (d > 0) {
      fg = AppColors.success;
      bg = AppColors.successBg;
      icon = Icons.arrow_upward_rounded;
      text = '+${formatQty(d)} $unit';
    } else if (d < 0) {
      fg = AppColors.dangerText;
      bg = AppColors.dangerBg;
      icon = Icons.arrow_downward_rounded;
      text = '-${formatQty(-d)} $unit';
    } else {
      fg = AppColors.primary;
      bg = AppColors.primarySoft;
      icon = Icons.check_rounded;
      text = 'Sesuai sistem';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
          ),
        ],
      ),
    );
  }
}
