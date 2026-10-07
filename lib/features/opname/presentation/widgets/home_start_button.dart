import 'package:flutter/material.dart';

/// Tombol "Mulai Hitung" di bawah halaman awal.
/// Dipasang sebagai bottomNavigatorBar, jadi sudah pakai SafeArea.
class HomeStartButton extends StatelessWidget {
  final VoidCallback onPressed;

  const HomeStartButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow_rounded, size: 22),
          label: const Text('Mulai Hitung'),
        ),
      ),
    );
  }
}
