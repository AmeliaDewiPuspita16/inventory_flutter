import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/back_header.dart';
import '../../data/dummy/opname_dummy.dart';
import '../../domain/entities/opname_item.dart';
import '../widgets/opname_line_tile.dart';
import '../widgets/scanner_panel.dart';
import 'opname_detail_screen.dart';

/// Layar kamera + daftar barang.
///
/// - Scan RAK (lokasi)  -> daftar menampilkan barang di rak itu saja.
/// - Scan BARANG        -> langsung buka detail barang (tanpa lewat daftar).
/// - Tombol edit di daftar -> buka detail barang.
class OpnameCountScreen extends StatefulWidget {
  const OpnameCountScreen({super.key});

  @override
  State<OpnameCountScreen> createState() => _OpnameCountScreenState();
}

class _OpnameCountScreenState extends State<OpnameCountScreen>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 1000,
    facing: CameraFacing.back,
  );

  List<OpnameItem> _items = List.of(dummyOpnameItems);
  String? _location; // rak yang sedang aktif (hasil scan rak)
  bool _cameraOn = true;
  bool _busy = false; // true selama kode sedang diproses / detail terbuka

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraOn || _busy) return;
    if (state == AppLifecycleState.resumed) {
      _startCamera();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // Error kamera ditampilkan oleh errorBuilder di ScannerPanel.
    }
  }

  Future<void> _stopCamera() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  void _toggleCamera() {
    setState(() => _cameraOn = !_cameraOn);
    _cameraOn ? _startCamera() : _stopCamera();
  }

  // ---------------------------------------------------------------- scan

  Future<void> _onCode(String raw) async {
    if (_busy) return;
    _busy = true;
    HapticFeedback.mediumImpact();
    try {
      await _handleCode(raw);
    } finally {
      _busy = false;
    }
  }

  Future<void> _handleCode(String raw) async {
    final code = raw.trim().toLowerCase();

    // 1) Kode rak/lokasi -> filter daftar ke rak itu.
    final rack = _items
        .where((e) => e.location.toLowerCase() == code)
        .map((e) => e.location)
        .firstOrNull;
    if (rack != null) {
      setState(() => _location = rack);
      return;
    }

    // 2) Kode barang -> langsung ke detail.
    var matches = _items.where((e) => e.code.toLowerCase() == code).toList();
    if (_location != null) {
      final inRack = matches.where((e) => e.location == _location).toList();
      if (inRack.isNotEmpty) {
        matches = inRack;
      } else if (matches.isNotEmpty) {
        // barang ada, tapi di rak lain: tanya dulu sebelum pindah.
        final go = await _confirmOtherRack(matches);
        if (go != true || !mounted) return;
        setState(() => _location = null); // lepas filter rak, biar bisa buka detail barang di rak lain
      }
    }

    if (matches.isEmpty) {
      _showMessage(
        _location == null
            ? 'Kode "$raw" tidak ada di daftar.'
            : 'Kode "$raw" tidak ada di rak $_location.',
      );
      return;
    }

    final item = matches.length == 1
        ? matches.first
        : await _pickLocation(matches);
    if (item == null || !mounted) return;
    await _openDetail(item);
  }

  Future<bool?> _confirmOtherRack(List<OpnameItem> matches) {
    final racks = matches.map((e) => e.location).join('\n');
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Barang ada di rak lain'),
        content: Text(
          '${matches.first.code} tidak ada di rak $_location. \n\n'
          'Ada di:\n$racks\n\nTetep buka?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Tetep buka'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDetail(OpnameItem item) async {
    final wasBusy = _busy;
    _busy = true; // cegah scan baru saat detail terbuka
    if (_cameraOn) await _stopCamera();

    if (!mounted) return;
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => OpnameDetailScreen(item: item)),
    );

    if (!mounted) return;
    if (result != null) {
      setState(() {
        _items = _items
            .map((e) => e.id == item.id ? e.withCount(result) : e)
            .toList();
      });
    }
    if (_cameraOn) await _startCamera();
    _busy = wasBusy;
  }

  Future<OpnameItem?> _pickLocation(List<OpnameItem> options) {
    return showModalBottomSheet<OpnameItem>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text('Pilih lokasi', style: AppTextStyles.bodyBold),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${options.first.code} ada di beberapa rak. Scan rak dulu '
                'kalau mau langsung ke barang yang tepat.',
                style: AppTextStyles.caption,
              ),
            ),
            for (final o in options)
              ListTile(
                leading: const Icon(
                  Icons.place_outlined,
                  color: AppColors.primary,
                ),
                title: Text(o.location, style: AppTextStyles.body),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, o),
              ),
          ],
        ),
      ),
    );
  }

  /// Tombol "Tambah Barang": ketik kode barang/rak secara manual,
  /// diproses sama persis seperti hasil scan.
  Future<void> _manualInput() async {
    final text = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input kode manual'),
        content: TextField(
          controller: text,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(hintText: 'Contoh: MLKPL009'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, text.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    text.dispose();
    if (code != null && code.isNotEmpty && mounted) _onCode(code);
  }

  // ------------------------------------------------------------- confirm

  int get _countedTotal => _items.where((e) => e.isCounted).length;

  void _confirm() {
    final done = _countedTotal;
    if (done == 0) return;
    setState(() {
      _items = List.of(dummyOpnameItems);
      _location = null;
    });
    _showMessage('$done item dikonfirmasi. Data contoh.');
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final visible = _location == null
        ? _items
        : _items.where((e) => e.location == _location).toList();

    // Kelompokkan per lokasi (urutan kemunculan dipertahankan).
    final groups = <String, List<OpnameItem>>{};
    for (final e in visible) {
      groups.putIfAbsent(e.location, () => []).add(e);
    }

    return Scaffold(
      appBar: BackHeader(
        title: 'Hitung Inventaris',
        actions: [
          IconButton(
            tooltip: _cameraOn ? 'Tutup kamera' : 'Buka kamera',
            onPressed: _toggleCamera,
            style: IconButton.styleFrom(
              backgroundColor: _cameraOn
                  ? AppColors.primary
                  : AppColors.primarySoft,
            ),
            icon: Icon(
              Icons.qr_code_scanner,
              color: _cameraOn ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_cameraOn)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: ScannerPanel(controller: _controller, onCode: _onCode),
                ),
              ),
            ),
          _ScanStepBanner(
            location: _location,
            onClearLocation: () => setState(() => _location = null),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                for (final entry in groups.entries) ...[
                  _LocationHeader(name: entry.key, count: entry.value.length),
                  for (final item in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: OpnameLineTile(
                        item: item,
                        onEdit: () => _openDetail(item),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _manualInput,
                    icon: const Icon(Icons.keyboard_outlined, size: 20),
                    label: const Text('Input kode'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _countedTotal == 0 ? null : _confirm,
                    child: Text('Konfirmasi ($_countedTotal)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Penunjuk langkah: "Scan rak" dulu (opsional), lalu "Scan barang".
class _ScanStepBanner extends StatelessWidget {
  final String? location;
  final VoidCallback onClearLocation;

  const _ScanStepBanner({
    required this.location,
    required this.onClearLocation,
  });

  @override
  Widget build(BuildContext context) {
    final hasRack = location != null;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            hasRack ? Icons.sell_outlined : Icons.warehouse_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasRack ? 'Scan barang di rak ini' : 'Scan rak atau barang',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  hasRack ? location! : 'Scan rak untuk lihat isinya, scan barang untuk langsung hitung',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (hasRack)
            TextButton(
              onPressed: onClearLocation,
              child: const Text('Ganti rak'),
            ),
        ],
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  final String name;
  final int count;

  const _LocationHeader({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.place, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(name, style: AppTextStyles.bodyBold)),
          Text('$count barang', style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
