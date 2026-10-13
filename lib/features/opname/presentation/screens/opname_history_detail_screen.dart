import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/back_header.dart';
import '../../data/opname_repository.dart';
import '../../domain/entities/opname_item.dart';
import '../../domain/entities/opname_record.dart';
import '../widgets/opname_line_tile.dart';
import '../widgets/opname_status_badge.dart';

/// Detail satu opname (hanya baca): info dokumen, keterangan status,
/// lalu barang yang dihitung dikelompokkan per lokasi.
class OpnameHistoryDetailScreen extends StatefulWidget {
  final int id;

  /// Kode (mis. SOP00003) untuk judul selagi isinya dimuat.
  final String code;

  const OpnameHistoryDetailScreen({
    super.key,
    required this.id,
    required this.code,
  });

  @override
  State<OpnameHistoryDetailScreen> createState() =>
      _OpnameHistoryDetailScreenState();
}

class _OpnameHistoryDetailScreenState extends State<OpnameHistoryDetailScreen> {
  OpnameDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await context.read<OpnameRepository>().fetchDetail(widget.id);
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackHeader(title: widget.code.isEmpty ? 'Detail Opname' : widget.code),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined,
                            size: 40, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _load,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : _content(_detail!),
    );
  }

  Widget _content(OpnameDetail d) {
    // Kelompokkan per lokasi, urutan kemunculan dipertahankan.
    final groups = <String, List<OpnameItem>>{};
    for (final e in d.items) {
      groups.putIfAbsent(e.location, () => []).add(e);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _InfoCard(detail: d),
          const SizedBox(height: 10),
          _StatusNote(detail: d),
          for (final entry in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.place, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppTextStyles.bodyBold,
                    ),
                  ),
                  Text('${entry.value.length} item',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            for (final item in entry.value)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpnameLineTile(item: item), // tanpa onEdit = hanya baca
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final OpnameDetail detail;

  const _InfoCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  d.date == null ? '-' : formatShortDate(d.date!),
                  style: AppTextStyles.bodyBold,
                ),
              ),
              OpnameStatusBadge(status: d.status),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          _row('Dihitung oleh', d.countedBy),
          if (d.createdAt != null)
            _row('Disimpan', formatShortDateTime(d.createdAt!)),
          if (d.status == OpnameStatus.confirmed && d.confirmedBy != null)
            _row(
              'Dikonfirmasi',
              d.confirmedAt == null
                  ? d.confirmedBy!
                  : '${d.confirmedBy} · ${formatShortDateTime(d.confirmedAt!)}',
            ),
          if (d.notes != null) _row('Catatan', d.notes!),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

/// Keterangan singkat arti status, supaya petugas tahu stok sudah berubah
/// atau belum.
class _StatusNote extends StatelessWidget {
  final OpnameDetail detail;

  const _StatusNote({required this.detail});

  @override
  Widget build(BuildContext context) {
    final confirmed = detail.status == OpnameStatus.confirmed;
    final text = switch (detail.status) {
      OpnameStatus.draft =>
        'Draft: menunggu konfirmasi admin di website. Stok belum berubah.',
      OpnameStatus.confirmed =>
        'Sudah dikonfirmasi. Stok sudah disesuaikan dengan hitungan ini.',
      OpnameStatus.other => 'Status opname ini belum dikenali aplikasi.',
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.successBg : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            confirmed ? Icons.check_circle_outline : Icons.info_outline,
            size: 20,
            color: confirmed ? AppColors.success : AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.label.copyWith(
                color: confirmed ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
