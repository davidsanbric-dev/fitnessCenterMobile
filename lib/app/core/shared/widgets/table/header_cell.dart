import 'package:flutter/material.dart';

class HeaderCell extends StatelessWidget {
  final String text;

  const HeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85),
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
