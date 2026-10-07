import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_label_row.dart';

/// Form login tanpa kartu: langsung duduk di atas latar krem halaman.
/// Tidak menyimpan state: semua nilai dan aksi dikirim dari [LoginScreen].
class LoginFormCard extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;
  final String? errorText;

  const LoginFormCard({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabelRow(label: 'Username'),
        AppTextField(
          controller: usernameController,
          hint: 'Enter your username',
          prefixIcon: Icons.person_outline,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username],
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        const FieldLabelRow(label: 'Password'),
        AppTextField(
          controller: passwordController,
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          onChanged: (_) => onChanged(),
          onSubmitted: (_) => onSubmit(),
          suffixIcon: IconButton(
            tooltip: obscurePassword
                ? 'Show password'
                : 'Hide password',
            onPressed: onToggleObscure,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              color: AppColors.dangerText,
            ),
          ),
        ],
        const SizedBox(height: 24),
        AppButton(label: 'Sign in', onPressed: onSubmit),
      ],
    );
  }
}
