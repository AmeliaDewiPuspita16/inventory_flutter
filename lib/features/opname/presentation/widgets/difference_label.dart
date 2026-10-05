import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

/// Teks kecil selisih hitung vs sistem:
/// hijau "+8 sak" (bertambah), merah "-8 sak" (berkurang), abu "Sesuai".
class DifferenceLabel extends StatelessWidget {
  final double? difference;
  final String unit;

  const DifferenceLabel({super.key, required this.difference, required this.unit});

  @override
  Widget build(BuildContext context) {
    final d = difference;
    final Color color;
    final IconData icon;
    final String text;

    if (d == null) {
      color = AppColors.textMuted;
      icon = Icons.remove;
      text = 'Belum dihitung';
    } else if (d > 0) {
      color = AppColors.success;
      icon = Icons.arrow_upward;
      text = '+${formatQty(d)} $unit';
    } else if (d < 0) {
      color = AppColors.dangerText;
      icon = Icons.arrow_downward;
      text = '-${formatQty(-d)} $unit';
    } else {
      color = AppColors.textSecondary;
      icon = Icons.check;
      text = 'Sesuai sistem';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
