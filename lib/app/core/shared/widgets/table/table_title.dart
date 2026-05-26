import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TableTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final EdgeInsetsGeometry padding;

  const TableTitle({
    super.key,
    required this.text,
    this.icon = LucideIcons.shield,
    this.padding = const EdgeInsets.only(bottom: 8, left: 4, top: 4),
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
