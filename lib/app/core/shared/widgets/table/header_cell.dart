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
          color: Colors.grey[800],
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
