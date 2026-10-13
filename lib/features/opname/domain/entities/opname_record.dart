import 'opname_item.dart';

/// Status satu dokumen opname di server.
enum OpnameStatus {
  /// Tersimpan, stok BELUM berubah. Menunggu konfirmasi di portal.
  draft,

  /// Sudah dikonfirmasi: stok sudah disesuaikan dengan hitungan.
  confirmed,

  /// Status yang belum dikenal app (server menambah status baru).
  other;

  static OpnameStatus parse(dynamic v) => switch (v?.toString()) {
        'draft' => OpnameStatus.draft,
        'confirmed' => OpnameStatus.confirmed,
        _ => OpnameStatus.other,
      };
}

/// Satu baris di daftar riwayat (`GET .../stock-opname`).
class OpnameSummary {
  final int id;
  final String code;
  final DateTime? date;
  final OpnameStatus status;
  final String countedBy;
  final String locationLabel;
  final int itemsCount;

  /// Jumlah baris yang stoknya benar-benar disesuaikan. Null selama draft.
  final int? adjustedCount;

  const OpnameSummary({
    required this.id,
    required this.code,
    required this.date,
    required this.status,
    required this.countedBy,
    required this.locationLabel,
    required this.itemsCount,
    this.adjustedCount,
  });

  factory OpnameSummary.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    if (id == null) throw const FormatException('id opname tidak ada');
    return OpnameSummary(
      id: id,
      code: json['code']?.toString() ?? '',
      date: _asDate(json['opname_date']),
      status: OpnameStatus.parse(json['status']),
      countedBy: json['counted_by']?.toString() ?? '-',
      locationLabel: json['location_label']?.toString() ?? '',
      itemsCount: _asInt(json['items_count']) ?? 0,
      adjustedCount: _asInt(json['adjusted_count']),
    );
  }
}

/// Satu halaman hasil `GET .../stock-opname`.
class OpnamePage {
  final List<OpnameSummary> items;
  final int currentPage;
  final int lastPage;

  const OpnamePage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}

/// Isi lengkap satu opname (`GET .../stock-opname/{id}`).
class OpnameDetail {
  final int id;
  final String code;
  final DateTime? date;
  final OpnameStatus status;
  final String countedBy;
  final String? notes;
  final String? createdBy;
  final DateTime? createdAt;
  final String? confirmedBy;
  final DateTime? confirmedAt;
  final List<OpnameItem> items;

  const OpnameDetail({
    required this.id,
    required this.code,
    required this.date,
    required this.status,
    required this.countedBy,
    required this.items,
    this.notes,
    this.createdBy,
    this.createdAt,
    this.confirmedBy,
    this.confirmedAt,
  });

  factory OpnameDetail.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final rawItems = json['items'];
    if (id == null || rawItems is! List) {
      throw const FormatException('Detail opname tidak lengkap');
    }
    final notes = json['notes']?.toString();
    return OpnameDetail(
      id: id,
      code: json['code']?.toString() ?? '',
      date: _asDate(json['opname_date']),
      status: OpnameStatus.parse(json['status']),
      countedBy: json['counted_by']?.toString() ?? '-',
      notes: (notes == null || notes.trim().isEmpty) ? null : notes,
      createdBy: json['created_by']?.toString(),
      createdAt: _asDate(json['created_at']),
      confirmedBy: json['confirmed_by']?.toString(),
      confirmedAt: _asDate(json['confirmed_at']),
      // Baris detail punya bentuk yang sama dengan countable-items
      // (key, item, location_label, system_qty, counted_qty).
      items: [
        for (final row in rawItems)
          OpnameItem.fromJson(Map<String, dynamic>.from(row as Map)),
      ],
    );
  }
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Server mengirim `2026-10-13` atau `2026-10-13T13:10:15+07:00`.
/// Hasilnya diubah ke waktu lokal perangkat.
DateTime? _asDate(dynamic v) {
  if (v is! String || v.isEmpty) return null;
  return DateTime.tryParse(v)?.toLocal();
}
