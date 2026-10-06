import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/opname_item.dart';
import 'difference_label.dart';

/// Kartu barang di daftar rak.
///   Border: abu = belum dihitung, primary = sudah dihitung.
///   atas : ikon, kode, nama, tombol edit
///   bawah: Total (jumlah aktual), badge selisih +/-, dan stok sistem
class OpnameLineTile extends StatelessWidget {
  final OpnameItem item;
  final VoidCallback onEdit;

  const OpnameLineTile({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final counted = item.isCounted;

    return AppCard(
      onTap: onEdit,
      padding: EdgeInsets.zero,
      borderColor: counted ? AppColors.primary : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 22,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.code,
                          style: AppTextStyles.caption
                              .copyWith(letterSpacing: 0.6)),
                      const SizedBox(height: 2),
                      Text(item.name, style: AppTextStyles.bodyBold),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit jumlah',
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primarySoft,
                  ),
                  icon: const Icon(Icons.edit_outlined,
                      color: AppColors.primary, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            counted ? formatQty(item.countedQty!) : '-',
                            style: AppTextStyles.quantity.copyWith(
                              fontSize: 28,
                              color: counted
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(item.unit, style: AppTextStyles.label),
                        ],
                      ),
                      const SizedBox(height: 6),
                      DifferenceLabel(
                          difference: item.difference, unit: item.unit),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Stok sistem', style: AppTextStyles.caption),
                    const SizedBox(height: 2),
                    Text('${formatQty(item.systemQty)} ${item.unit}',
                        style: AppTextStyles.label),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
