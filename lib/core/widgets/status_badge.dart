import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  const StatusBadge.success(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: AppColors.successBg,
          foreground: AppColors.success,
        );

  const StatusBadge.warning(String label, {Key? key})
      : this(
          key: key,
          label: label,
          background: AppColors.dangerBg,
          foreground: AppColors.dangerText,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
