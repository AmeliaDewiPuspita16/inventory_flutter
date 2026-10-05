import 'package:equatable/equatable.dart';

class OpnameItem extends Equatable {
  final String id;
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
    required this.code,
    required this.name,
    required this.unit,
    required this.location,
    required this.systemQty,
    this.countedQty,
  });

  bool get isCounted => countedQty != null;

  /// Selisih fisik - sistem. Positif = bertambah, negatif = berkurang.
  /// Null kalau belum dihitung.
  double? get difference => countedQty == null ? null : countedQty! - systemQty;

  OpnameItem withCount(double qty) => OpnameItem(
        id: id,
        code: code,
        name: name,
        unit: unit,
        location: location,
        systemQty: systemQty,
        countedQty: qty,
      );

  @override
  List<Object?> get props =>
      [id, code, name, unit, location, systemQty, countedQty];
}
