import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';

class BrandLogo extends StatelessWidget {
  final double height;

  const BrandLogo({super.key, this.height = 50});

  @override
  Widget build(BuildContext context) {
    // The logo is a pre-rasterized WebP (was a 144 KB / 316-path SVG): it
    // decodes once into the image cache and composites for free, so animated
    // Transform.scale wrappers never re-rasterize vector paths per frame.
    // RepaintBoundary keeps it on its own cached layer during those animations.
    return RepaintBoundary(
      child: Image.asset(
        AppAssets.logo,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) =>
            Icon(LucideIcons.imageOff, size: height * 0.7),
      ),
    );
  }
}
