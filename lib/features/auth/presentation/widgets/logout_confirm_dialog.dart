import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Dialog konfirmasi keluar akun.
/// Pakai [LogoutConfirmDialog.show]: hasilnya true kalau pengguna memilih
/// "Keluar", false kalau "Batal" atau dialog ditutup.
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmDialog(),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      clipBehavior: Clip.antiAlias, // supaya efek tekan ikut melengkung
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                Text(
                  'Keluar dari akun?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu perlu login lagi untuk memakai aplikasi.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          _LogoutDialogAction(
            label: 'Keluar',
            color: AppColors.dangerText,
            bold: true,
            onTap: () => Navigator.pop(context, true),
          ),
          const Divider(height: 1, color: AppColors.border),
          _LogoutDialogAction(
            label: 'Batal',
            color: AppColors.textPrimary,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

/// Satu baris aksi selebar dialog.
class _LogoutDialogAction extends StatelessWidget {
  final String label;
  final Color color;
  final bool bold;
  final VoidCallback onTap;

  const _LogoutDialogAction({
    required this.label,
    required this.color,
    required this.onTap,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
