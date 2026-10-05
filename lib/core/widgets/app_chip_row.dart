import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool soft;

  const AppChipRow({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: labels[i],
                selected: i == selectedIndex,
                soft: soft,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool soft;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.soft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (soft ? AppColors.primarySoft : AppColors.primary)
        : AppColors.surface;
    final fg = selected
        ? (soft ? AppColors.primary : AppColors.textOnPrimary)
        : AppColors.textSecondary;

    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.inputBorder,
          width: selected && soft ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
