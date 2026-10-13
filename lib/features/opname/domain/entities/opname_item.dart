import 'package:equatable/equatable.dart';

/// Satu baris hitung: satu barang di satu lokasi.
///
/// Identitas baris di server adalah kombinasi barang + gudang + rak (field
/// `key` di API, mis. `138|0:0`). Barang yang sama di dua rak adalah dua
/// baris berbeda, jadi [id] di sini memakai `key` itu, bukan id barang.
class OpnameItem extends Equatable {
  /// `key` dari server. Unik per baris, dipakai sebagai id di UI.
  final String id;

  /// Id barang di server, dikirim kembali saat menyimpan hitungan.
  final int itemId;

  /// Null = barang belum ditempatkan di gudang manapun ("Unassigned").
  final int? storeLocationId;

  /// Null = barang ada di gudang tapi tidak di rak tertentu.
  final int? putawayId;

  final String code;
  final String name;
  final String unit;
  final String location;

  /// Stok menurut sistem (pembanding).
  final double systemQty;

  /// Jumlah hasil hitung fisik; null kalau belum dihitung.
  final double? countedQty;

  const OpnameItem({
    required this.id,
    required this.itemId,
    required this.code,
    required this.name,
    required this.unit,
    required this.location,
    required this.systemQty,
    this.storeLocationId,
    this.putawayId,
    this.countedQty,
  });

  bool get isCounted => countedQty != null;

  /// Selisih fisik - sistem. Positif = bertambah, negatif = berkurang.
  /// Null kalau belum dihitung.
  double? get difference => countedQty == null ? null : countedQty! - systemQty;

  OpnameItem withCount(double qty) => OpnameItem(
    id: id,
    itemId: itemId,
    storeLocationId: storeLocationId,
    putawayId: putawayId,
    code: code,
    name: name,
    unit: unit,
    location: location,
    systemQty: systemQty,
    countedQty: qty,
  );

  /// Dari satu elemen `data` di `GET .../stock-opname/countable-items`.
  ///
  /// Melempar [FormatException] kalau bentuknya tidak dikenali, supaya
  /// repository bisa mengubahnya jadi pesan galat yang jelas.
  factory OpnameItem.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    final key = json['key'];
    if (item is! Map || key is! String) {
      throw const FormatException('Baris countable-items tidak lengkap');
    }
    final itemId = _asInt(item['id']);
    if (itemId == null) {
      throw const FormatException('item.id tidak ada');
    }
    return OpnameItem(
      id: key,
      itemId: itemId,
      storeLocationId: _asInt(json['store_location_id']),
      putawayId: _asInt(json['putaway_id']),
      code: item['code']?.toString() ?? '',
      name: item['name']?.toString() ?? '',
      unit: item['unit']?.toString() ?? '',
      location: json['location_label']?.toString() ?? 'Unassigned',
      systemQty: _asDouble(json['system_qty']) ?? 0,
      countedQty: _asDouble(json['counted_qty']),
    );
  }

  /// Bentuk yang diminta `POST .../stock-opname` untuk satu baris.
  Map<String, dynamic> toSubmitJson() => {
    'item_id': itemId,
    'store_location_id': storeLocationId,
    'putaway_id': putawayId,
    'counted_qty': countedQty,
  };

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static double? _asDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        storeLocationId,
        putawayId,
        code,
        name,
        unit,
        location,
        systemQty,
        countedQty,
      ];
}

/// Rak dari `GET .../stock-opname/options`. [text] berbentuk
/// `PUT00003 - Test Rak`; [code] adalah bagian sebelum " - ".
class OpnameRack extends Equatable {
  final int id;
  final int storeId;
  final String text;

  const OpnameRack({
    required this.id,
    required this.storeId,
    required this.text,
  });

  String get code {
    final i = text.indexOf(' - ');
    return (i < 0 ? text : text.substring(0, i)).trim();
  }

  @override
  List<Object?> get props => [id, storeId, text];
}
