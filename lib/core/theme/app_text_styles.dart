import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headerTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textMuted,
  );

  static const TextStyle sectionLabel = TextStyle(
    fontSize: 12,
    letterSpacing: 0.5,
    color: AppColors.textMuted,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle quantity = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}
