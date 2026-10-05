import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Preview kamera + bingkai scan. Mendukung barcode batang maupun QR (kotak).
/// Lifecycle controller (start/stop) diatur oleh layar yang memakainya.
class ScannerPanel extends StatelessWidget {
  final MobileScannerController controller;
  final ValueChanged<String> onCode;

  const ScannerPanel({
    super.key,
    required this.controller,
    required this.onCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textPrimary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final value = capture.barcodes.firstOrNull?.rawValue?.trim();
              if (value != null && value.isNotEmpty) onCode(value);
            },
            errorBuilder: (context, error) => _CameraError(error: error),
          ),
          const Center(child: _ScanFrame()),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                ValueListenableBuilder<MobileScannerState>(
                  valueListenable: controller,
                  builder: (context, state, _) => IconButton(
                    tooltip: 'Senter',
                    color: Colors.white,
                    icon: Icon(
                      state.torchState == TorchState.on
                          ? Icons.flash_on
                          : Icons.flash_off,
                    ),
                    onPressed: controller.toggleTorch,
                  ),
                ),
                IconButton(
                  tooltip: 'Ganti kamera',
                  color: Colors.white,
                  icon: const Icon(Icons.cameraswitch_outlined),
                  onPressed: controller.switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white70, width: 2),
            ),
          ),
          Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  final MobileScannerException error;

  const _CameraError({required this.error});

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white70, size: 40),
            const SizedBox(height: 10),
            Text(
              denied
                  ? 'Izin kamera ditolak. Aktifkan izin kamera di pengaturan HP.'
                  : 'Kamera tidak bisa dibuka.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
