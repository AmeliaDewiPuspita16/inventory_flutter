import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../domain/entities/opname_item.dart';
import '../widgets/difference_label.dart';

/// Detail satu barang: isi jumlah hitung lalu Simpan (return double)
/// atau Batal (return null).
class OpnameDetailScreen extends StatefulWidget {
  final OpnameItem item;

  const OpnameDetailScreen({super.key, required this.item});

  @override
  State<OpnameDetailScreen> createState() => _OpnameDetailScreenState();
}

class _OpnameDetailScreenState extends State<OpnameDetailScreen> {
  late final TextEditingController _qty;
  String? _error;

  @override
  void initState() {
    super.initState();
    _qty = TextEditingController(
      text: formatQty(widget.item.countedQty ?? widget.item.systemQty),
    );
  }

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  double? _parse() => double.tryParse(_qty.text.trim().replaceAll(',', '.'));

  void _set(double value) {
    setState(() {
      _qty.text = formatQty(value);
      _error = null;
    });
  }

  void _adjust(double delta) {
    final next = ((_parse() ?? 0) + delta).clamp(0, double.infinity).toDouble();
    _set(next);
  }

  void _save() {
    final v = _parse();
    if (v == null) {
      setState(() => _error = 'Masukkan jumlah dulu. Isi 0 kalau barang tidak ada.');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final live = _parse();

    return Scaffold(
      appBar: const BackHeader(title: 'Detail Barang'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.inventory_2_outlined,
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.code, style: AppTextStyles.caption),
                            Text(item.name, style: AppTextStyles.bodyBold),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28, color: AppColors.border),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(item.location, style: AppTextStyles.body)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.storage_outlined,
                          size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text(
                        'Stok sistem: ${formatQty(item.systemQty)} ${item.unit}',
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jumlah hitung (aktual)', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qty,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.quantity.copyWith(fontSize: 34),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                          ],
                          onChanged: (_) => setState(() => _error = null),
                          decoration: InputDecoration(errorText: _error),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(item.unit,
                            style: AppTextStyles.quantity.copyWith(fontSize: 24)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QuickButton(label: '0', onTap: () => _set(0)),
                      const SizedBox(width: 8),
                      _QuickButton(label: '-1', onTap: () => _adjust(-1)),
                      const SizedBox(width: 8),
                      _QuickButton(label: '+1', onTap: () => _adjust(1)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('Selisih: ', style: AppTextStyles.caption),
                      DifferenceLabel(
                        difference:
                            live == null ? null : live - item.systemQty,
                        unit: item.unit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Batal',
                  outlined: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: AppButton(label: 'Simpan', onPressed: _save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.background,
        ),
        child: Text(label),
      ),
    );
  }
}
