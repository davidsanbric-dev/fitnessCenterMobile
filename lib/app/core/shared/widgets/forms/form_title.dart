import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/config/app_theme.dart'; // ajusta la ruta según tu estructura

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 28),
      child: Text(
        text,
        style: AppTheme.cardHeading.copyWith(
          color: AppTheme.primaryTextColor(context),
        ),
      ),
    );
  }
}
