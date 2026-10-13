import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/opname_record.dart';

/// Badge status opname: Draft (abu), Dikonfirmasi (hijau).
class OpnameStatusBadge extends StatelessWidget {
  final OpnameStatus status;

  const OpnameStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OpnameStatus.confirmed:
        return const StatusBadge.success('Dikonfirmasi');
      case OpnameStatus.draft:
        return const StatusBadge(
          label: 'Draft',
          background: AppColors.background,
          foreground: AppColors.textSecondary,
        );
      case OpnameStatus.other:
        return const StatusBadge(
          label: 'Lainnya',
          background: AppColors.background,
          foreground: AppColors.textMuted,
        );
    }
  }
}
