import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// kartu panduan "Cara Pakai" di halaman awal.
/// untuk mengubah isi langkahnya, edit daftar [_steps] di bawah
class HomeGuideCard extends StatelessWidget {
  const HomeGuideCard({super.key});

  static const _steps = <_GuideStep>[
    _GuideStep(
      icon: Icons.warehouse_outlined,
      title: 'Scan rak',
      desc: 'Daftar barang di rak itu langsung muncul.',
    ),
    _GuideStep(
      icon: Icons.sell_outlined,
      title: 'Scan barang',
      desc: 'Langsung buka detail barang, tanpa lewat daftar.',
    ),
    _GuideStep(
      icon: Icons.edit_outlined,
      title: 'Isi jumlah',
      desc: 'Ketuk kartu barang untuk mengisi jumlah hitung.',
    ),
    _GuideStep(
      icon: Icons.check_circle_outline,
      title: 'Konfirmasi',
      desc: 'Tekan Konfirmasi setelah semua selesai dihitung.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CARA PAKAI', style: AppTextStyles.sectionLabel),
          const SizedBox(height: 14),
          for (var i = 0; i < _steps.length; i++)
            _GuideStepRow(
              number: i + 1,
              step: _steps[i],
              isLast: i == _steps.length - 1,
            ),
        ],
      ),
    );
  }
}

/// data satu langkah.
class _GuideStep {
  final IconData icon;
  final String title;
  final String desc;

  const _GuideStep({
    required this.icon,
    required this.title,
    required this.desc,
  });
}

/// satu baris langkah: ikon bulat + garis penghubung di kiri,
/// nomor + judul + penjelasan dikanan.
class _GuideStepRow extends StatelessWidget {
  final int number;
  final _GuideStep step;
  final bool isLast;

  const _GuideStepRow({
    required this.number,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle
                  ),
                  child: Icon(step.icon, size: 18, color: AppColors.primary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    )
                  )
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 12 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$number. ${step.title}', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(step.desc, style: AppTextStyles.label),
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
