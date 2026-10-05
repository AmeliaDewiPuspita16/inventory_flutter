import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffixText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final TextAlign textAlign;
  final TextStyle? style;

  const AppTextField({
    super.key,
    this.controller,
    this.hint,
    this.prefixIcon,
    this.suffixText,
    this.errorText,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textAlign: textAlign,
      style: style ?? AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        suffixText: suffixText,
        suffixStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: AppColors.textMuted),
      ),
    );
  }
}
