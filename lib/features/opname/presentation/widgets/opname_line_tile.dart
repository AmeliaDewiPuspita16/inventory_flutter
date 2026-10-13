import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/opname_item.dart';
import 'difference_label.dart';

/// Kartu barang di daftar hitung. Kalau [onEdit] null, kartu hanya untuk
/// dibaca (tanpa tombol dan tidak bisa diketuk), mis. di detail riwayat.
///
/// Dua tampilan:
///  - SUDAH dihitung: border hijau, angka Total besar, badge selisih +/-,
///    dan stok sistem di kanan. Tombol pensil untuk mengubah.
///  - BELUM dihitung: border abu, stok sistem jadi angka utama (diberi
///    label jelas supaya tidak dikira hasil hitung), dan tombol "Hitung"
///    yang menunjukkan langkah berikutnya.
class OpnameLineTile extends StatelessWidget {
  final OpnameItem item;
  final VoidCallback? onEdit;

  const OpnameLineTile({super.key, required this.item, this.onEdit});

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
                if (onEdit != null) ...[
                  const SizedBox(width: 8),
                  counted ? _EditButton(onEdit: onEdit!) : _CountButton(onTap: onEdit!),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: counted ? _CountedBottom(item: item) : _UncountedBottom(item: item),
          ),
        ],
      ),
    );
  }
}

/// Bawah kartu SUDAH dihitung (desain awal): Total besar + selisih, dan
/// stok sistem di kanan.
class _CountedBottom extends StatelessWidget {
  final OpnameItem item;

  const _CountedBottom({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    formatQty(item.countedQty!),
                    style: AppTextStyles.quantity.copyWith(
                      fontSize: 28,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item.unit, style: AppTextStyles.label),
                ],
              ),
              const SizedBox(height: 6),
              DifferenceLabel(difference: item.difference, unit: item.unit),
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
    );
  }
}

/// Bawah kartu BELUM dihitung: stok sistem sebagai informasi utama,
/// dengan keterangan bahwa jumlah fisik belum diisi.
class _UncountedBottom extends StatelessWidget {
  final OpnameItem item;

  const _UncountedBottom({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stok menurut sistem', style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatQty(item.systemQty),
                    style: AppTextStyles.quantity.copyWith(
                      fontSize: 24,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(item.unit, style: AppTextStyles.label),
                ],
              ),
            ],
          ),
        ),
        const _UncountedBadge(),
      ],
    );
  }
}

/// Tombol pensil untuk barang yang sudah dihitung (mengubah jumlah).
class _EditButton extends StatelessWidget {
  final VoidCallback onEdit;

  const _EditButton({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Edit jumlah',
      onPressed: onEdit,
      style: IconButton.styleFrom(backgroundColor: AppColors.primarySoft),
      icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
    );
  }
}

/// Tombol "Hitung" untuk barang yang belum dihitung. Memakai teks, bukan
/// hanya ikon, supaya pengguna baru langsung tahu langkah berikutnya.
class _CountButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CountButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primarySoft,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
      ),
      icon: const Icon(Icons.edit_note_rounded, size: 18),
      label: const Text(
        'Hitung',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Penanda status "Belum dihitung": pil abu, hanya teks (tanpa ikon).
class _UncountedBadge extends StatelessWidget {
  const _UncountedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Belum dihitung',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
