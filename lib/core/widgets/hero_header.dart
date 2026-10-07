import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Header berwarna gradasi abu-hijau untuk halaman awal. Gradasi dan gaya
/// status bar-nya juga dipakai halaman login (lihat [gradient] dan
/// [overlayStyle]) supaya kedua halaman terasa seragam. Tanpa sudut melengkung.
///
/// Header menjorok ke bawah status bar, jadi tinggi status bar otomatis
/// ditambahkan ke padding atas.
class HeroHeader extends StatelessWidget {
  /// Isi header.
  final Widget child;

  /// Tinggi total header (sudah termasuk status bar). Kalau null, tinggi
  /// mengikuti isi.
  final double? height;

  /// Padding isi, belum termasuk tinggi status bar.
  final EdgeInsets padding;

  const HeroHeader({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 64),
  });

  /// Gradasi abu-hijau (atas ke bawah).
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.heroTop, AppColors.heroBottom],
  );

  /// Gaya status bar untuk halaman berlatar gradasi ini
  /// (ikon gelap karena latarnya terang).
  static const SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      height: height,
      padding: padding.copyWith(top: padding.top + topInset),
      decoration: const BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
