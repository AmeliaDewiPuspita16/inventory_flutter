import '../../../core/network/api_client.dart';
import '../../../core/network/api_config.dart';
import '../../../core/network/api_exception.dart';
import '../domain/entities/opname_item.dart';
import '../domain/entities/opname_record.dart';

/// Pintu masuk fitur stock opname: tahu endpoint dan bentuk datanya,
/// tidak tahu soal tampilan.
class OpnameRepository {
  OpnameRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// Daftar baris yang bisa dihitung (barang + lokasi + stok sistem).
  Future<List<OpnameItem>> fetchCountableItems() async {
    final list = await _apiClient.getList(ApiConfig.opnameCountableItems);
    try {
      return [
        for (final row in list)
          OpnameItem.fromJson(Map<String, dynamic>.from(row as Map)),
      ];
    } on FormatException catch (_) {
      throw const ApiException.server(
        'Data barang dari server tidak dikenali. Hubungi tim IT.',
      );
    } on TypeError catch (_) {
      throw const ApiException.server(
        'Data barang dari server tidak dikenali. Hubungi tim IT.',
      );
    }
  }

  /// Semua rak dari semua gudang. Dipakai untuk mengenali kode rak yang
  /// di-scan (mis. `PUT00003`).
  Future<List<OpnameRack>> fetchRacks() async {
    final data = await _apiClient.get(ApiConfig.opnameOptions);
    final stores = data['stores'];
    if (stores is! List) return const [];

    final racks = <OpnameRack>[];
    for (final store in stores.whereType<Map>()) {
      final storeId = _asInt(store['id']);
      final putaways = store['putaways'];
      if (storeId == null || putaways is! List) continue;
      for (final p in putaways.whereType<Map>()) {
        final id = _asInt(p['id']);
        final text = p['text']?.toString();
        if (id != null && text != null) {
          racks.add(OpnameRack(id: id, storeId: storeId, text: text));
        }
      }
    }
    return racks;
  }

  /// Satu halaman riwayat opname. [status] null = semua status.
  Future<OpnamePage> fetchHistory({
    OpnameStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final query = <String, String>{
      if (status == OpnameStatus.draft) 'status': 'draft',
      if (status == OpnameStatus.confirmed) 'status': 'confirmed',
      'page': '$page',
      'per_page': '$perPage',
    };
    // Dipakai getEnvelope karena info halaman (`meta`) ada di samping `data`.
    final envelope = await _apiClient.getEnvelope(
      '${ApiConfig.opnameBase}?${Uri(queryParameters: query).query}',
    );
    try {
      final data = envelope['data'] as List;
      final meta = envelope['meta'];
      return OpnamePage(
        items: [
          for (final row in data)
            OpnameSummary.fromJson(Map<String, dynamic>.from(row as Map)),
        ],
        currentPage: meta is Map ? (_asInt(meta['current_page']) ?? page) : page,
        lastPage: meta is Map ? (_asInt(meta['last_page']) ?? page) : page,
      );
    } on FormatException catch (_) {
      throw _unreadable;
    } on TypeError catch (_) {
      throw _unreadable;
    }
  }

  /// Isi lengkap satu opname beserta baris-barisnya.
  Future<OpnameDetail> fetchDetail(int id) async {
    final data = await _apiClient.get('${ApiConfig.opnameBase}/$id');
    try {
      return OpnameDetail.fromJson(data);
    } on FormatException catch (_) {
      throw _unreadable;
    } on TypeError catch (_) {
      throw _unreadable;
    }
  }

  static const _unreadable = ApiException.server(
    'Data opname dari server tidak dikenali. Hubungi tim IT.',
  );

  /// Mengirim hasil hitungan ke server dan mengembalikan id opname-nya.
  ///
  /// [confirm] = false  -> disimpan sebagai draft, stok BELUM berubah.
  /// [confirm] = true   -> langsung dikonfirmasi: stok tiap lokasi di-set
  ///                       sama dengan jumlah hitung, tidak bisa dibatalkan.
  Future<int?> submit({
    required List<OpnameItem> counted,
    required String countedBy,
    required bool confirm,
    String? notes,
  }) async {
    final now = DateTime.now();
    final date = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final data = await _apiClient.post(
      ApiConfig.opnameBase,
      body: {
        'opname_date': date,
        'counted_by': countedBy,
        if (notes != null) 'notes': notes,
        'confirm': confirm,
        'items': [
          for (final e in counted)
            if (e.isCounted) e.toSubmitJson(),
        ],
      },
    );
    return _asInt(data['id']);
  }

  static int? _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}
