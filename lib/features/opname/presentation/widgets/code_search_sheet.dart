import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/opname_item.dart';

/// Hasil dari [showCodeSearchSheet]. Hanya salah satu field yang terisi:
/// - [rack]    : user memilih sebuah rak dari daftar
/// - [item]    : user memilih sebuah barang (sudah spesifik: kode + lokasi)
/// - [rawCode] : user menekan Enter di keyboard dengan teks ketikannya
///               (diproses seperti hasil scan)
class CodeSearchResult {
  final String? rack;
  final OpnameItem? item;
  final String? rawCode;

  const CodeSearchResult.rack(String this.rack)
      : item = null,
        rawCode = null;

  const CodeSearchResult.item(OpnameItem this.item)
      : rack = null,
        rawCode = null;

  const CodeSearchResult.code(String this.rawCode)
      : rack = null,
        item = null;
}

/// Membuka sheet pencarian rak/barang. Mengembalikan null kalau ditutup
/// tanpa memilih apa pun.
Future<CodeSearchResult?> showCodeSearchSheet(
  BuildContext context, {
  required List<OpnameItem> items,
}) {
  return showModalBottomSheet<CodeSearchResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CodeSearchSheet(items: items),
  );
}

class _CodeSearchSheet extends StatefulWidget {
  final List<OpnameItem> items;

  const _CodeSearchSheet({required this.items});

  @override
  State<_CodeSearchSheet> createState() => _CodeSearchSheetState();
}

class _CodeSearchSheetState extends State<_CodeSearchSheet> {
  /// Batas jumlah hasil per kelompok, supaya daftar tidak terlalu panjang.
  static const int _maxRacks = 8;
  static const int _maxItems = 20;

  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Enter di keyboard: proses teksnya persis seperti hasil scan.
  void _submit(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return;
    Navigator.pop(context, CodeSearchResult.code(raw));
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();

    // Rak: lokasi unik yang mengandung teks pencarian, plus jumlah barangnya.
    final rackCounts = <String, int>{};
    if (q.isNotEmpty) {
      for (final e in widget.items) {
        if (e.location.toLowerCase().contains(q)) {
          rackCounts[e.location] = (rackCounts[e.location] ?? 0) + 1;
        }
      }
    }
    final racks = rackCounts.entries.take(_maxRacks).toList();

    // Barang: cocok di kode ATAU nama.
    final items = q.isEmpty
        ? <OpnameItem>[]
        : widget.items
            .where((e) =>
                e.code.toLowerCase().contains(q) ||
                e.name.toLowerCase().contains(q))
            .take(_maxItems)
            .toList();

    final noResult = q.isNotEmpty && racks.isEmpty && items.isEmpty;

    return Padding(
      // Naikkan sheet setinggi keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('Cari rak atau barang', style: AppTextStyles.bodyBold),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: 'Kode / nama barang, atau kode rak',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                if (q.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Ketik sebagian saja, misalnya "004/03", "semen", '
                      'atau "MLKPL".',
                      style: AppTextStyles.caption,
                    ),
                  ),
                if (noResult)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Text(
                      'Tidak ada rak atau barang yang cocok dengan "$_query".',
                      style: AppTextStyles.caption,
                    ),
                  ),
                if (racks.isNotEmpty) ...[
                  const _SectionLabel('Rak'),
                  for (final r in racks)
                    ListTile(
                      leading: const Icon(Icons.place_outlined,
                          color: AppColors.primary),
                      title: Text(r.key, style: AppTextStyles.body),
                      subtitle:
                          Text('${r.value} barang', style: AppTextStyles.caption),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pop(context, CodeSearchResult.rack(r.key)),
                    ),
                ],
                if (items.isNotEmpty) ...[
                  const _SectionLabel('Barang'),
                  for (final e in items)
                    ListTile(
                      leading: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.primary),
                      title: Text(e.name, style: AppTextStyles.body),
                      subtitle: Text('${e.code}  ·  ${e.location}',
                          style: AppTextStyles.caption),
                      trailing: e.isCounted
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20)
                          : const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pop(context, CodeSearchResult.item(e)),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
