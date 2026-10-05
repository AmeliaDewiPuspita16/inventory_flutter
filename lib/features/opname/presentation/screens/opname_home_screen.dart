import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/dummy/opname_dummy.dart';
import 'opname_count_screen.dart';

/// Halaman pertama (versi 2): header hijau besar, tombol scan bulat di tengah,
/// lalu panduan 4 langkah. Satu ketukan membuka kamera.
class OpnameHomeScreen extends StatelessWidget {
  const OpnameHomeScreen({super.key});

  static const _steps = <_Step>[
    _Step(
      icon: Icons.warehouse_outlined,
      title: 'Scan rak',
      desc: 'Daftar barang di rak itu langsung muncul.',
    ),
    _Step(
      icon: Icons.sell_outlined,
      title: 'Scan barang',
      desc: 'Langsung buka detail barang, tanpa lewat daftar.',
    ),
    _Step(
      icon: Icons.edit_outlined,
      title: 'Isi jumlah',
      desc: 'Ketuk kartu barang untuk mengisi jumlah hitung.',
    ),
    _Step(
      icon: Icons.check_circle_outline,
      title: 'Konfirmasi',
      desc: 'Tekan Konfirmasi setelah semua selesai dihitung.',
    ),
  ];

  void _start(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OpnameCountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = dummyOpnameItems.length;
    final rackCount = dummyOpnameItems.map((e) => e.location).toSet().length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ---------- Header + tombol scan yang menumpuk di tepinya
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      MediaQuery.of(context).padding.top + 28,
                      24,
                      76,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hitung Inventaris',
                          style: AppTextStyles.headerTitle
                              .copyWith(fontSize: 26, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cek stok fisik dengan scan barcode.',
                          style: AppTextStyles.body
                              .copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _StatChip(
                                icon: Icons.inventory_2_outlined,
                                label: '$itemCount barang'),
                            const SizedBox(width: 8),
                            _StatChip(
                                icon: Icons.place_outlined,
                                label: '$rackCount rak'),
                          ],
                        ),
                      ],
                    ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: _ScanButton(onTap: () => _start(context)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Ketuk untuk scan',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: 2),
              Text('Bisa barcode batang atau QR code',
                  style: AppTextStyles.caption),
              const SizedBox(height: 24),

              // ---------- Panduan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CARA PAKAI', style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 14),
                      for (var i = 0; i < _steps.length; i++)
                        _StepRow(
                          number: i + 1,
                          step: _steps[i],
                          isLast: i == _steps.length - 1,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: ElevatedButton.icon(
              onPressed: () => _start(context),
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text('Mulai Hitung'),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: Colors.black38,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.qr_code_scanner_rounded,
                size: 40, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final String title;
  final String desc;

  const _Step({required this.icon, required this.title, required this.desc});
}

class _StepRow extends StatelessWidget {
  final int number;
  final _Step step;
  final bool isLast;

  const _StepRow({
    required this.number,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(step.icon, size: 18, color: AppColors.primary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 12 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$number. ${step.title}', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(step.desc, style: AppTextStyles.label),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
