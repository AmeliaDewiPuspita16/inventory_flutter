import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'logout_confirm_dialog.dart';

/// Tombol ikon "Keluar". Menampilkan dialog konfirmasi dulu, dan hanya
/// memanggil [onConfirmed] kalau pengguna memilih "Keluar".
/// Widget ini tidak tahu soal Bloc: yang mengirim event logout adalah layar.
class LogoutButton extends StatelessWidget {
  final VoidCallback onConfirmed;

  const LogoutButton({super.key, required this.onConfirmed});

  Future<void> _onPressed(BuildContext context) async {
    final ok = await LogoutConfirmDialog.show(context);
    if (ok && context.mounted) onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      onPressed: () => _onPressed(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
    );
  }
}
