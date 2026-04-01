import 'package:flutter/material.dart';

class BrandIconNameWhiteBackground extends StatelessWidget {
  const BrandIconNameWhiteBackground({
    super.key,
    this.topSpacing = 8,
    this.iconHeight = 60,
  });

  final double topSpacing;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topSpacing),
        Image.asset(
          'assets/icons/icon_brand_white_background.png',
          height: iconHeight,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
