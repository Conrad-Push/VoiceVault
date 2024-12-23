import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;

  const AppHeader({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true, // Domyślnie strzałka jest widoczna
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFFFA726),
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: const Color(0xFF5A7D9A),
      automaticallyImplyLeading: automaticallyImplyLeading, // Kontrola strzałki
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
