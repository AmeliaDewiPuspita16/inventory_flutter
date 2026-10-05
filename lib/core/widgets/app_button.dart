import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    if (outlined) {
      return icon == null
          ? OutlinedButton(onPressed: onPressed, child: text)
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 20),
              label: text,
            );
    }
    return icon == null
        ? ElevatedButton(onPressed: onPressed, child: text)
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 20),
            label: text,
          );
  }
}
