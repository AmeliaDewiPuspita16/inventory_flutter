import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class FieldLabelRow extends StatelessWidget {
  final String label;
  final bool required;

  const FieldLabelRow({super.key, required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.label),
          if (required)
            Text(
              'Wajib diisi',
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
        ],
      ),
    );
  }
}
