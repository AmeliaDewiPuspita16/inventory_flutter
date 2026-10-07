import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Hiasan barcode batang yang menggantung dari tepi atas. Murni dekorasi:
/// tidak menerima sentuhan dan tidak dibaca screen reader.
class BarcodeDecoration extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;

  const BarcodeDecoration({
    super.key,
    this.width = 150,
    this.height = 170,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          size: Size(width, height),
          painter: _BarcodePainter(
            color ?? AppColors.primary.withOpacity(0.10),
          ),
        ),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final Color color;

  const _BarcodePainter(this.color);

  // Lebar batang (satuan relatif) dan tinggi batang (pecahan dari tinggi
  // kanvas). Dibuat tidak beraturan supaya terlihat seperti barcode sungguhan.
  static const _widths = [3.0, 6.0, 2.0, 8.0, 4.0, 2.0, 6.0, 3.0, 5.0, 2.0];
  static const _heights = [.50, .78, .42, 1.0, .66, .36, .88, .56, .72, .46];
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final totalUnits = _widths.fold<double>(0, (a, b) => a + b) +
        _gap * (_widths.length - 1);
    final unit = size.width / totalUnits;
    final paint = Paint()..color = color;

    var x = 0.0;
    for (var i = 0; i < _widths.length; i++) {
      final w = _widths[i] * unit;
      final h = _heights[i] * size.height;
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, 0, w, h),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        paint,
      );
      x += w + _gap * unit;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.color != color;
}
