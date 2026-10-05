import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/opname/presentation/screens/opname_home_screen.dart';

void main() {
  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const OpnameHomeScreen(),
    );
  }
}
