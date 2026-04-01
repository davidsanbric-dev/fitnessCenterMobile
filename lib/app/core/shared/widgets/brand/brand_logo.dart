import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';
import 'package:portfolio_mobile_app/app/core/diagnostics/runtime_diagnostics.dart';

class BrandLogo extends StatelessWidget {
  final double height;

  const BrandLogo({super.key, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logo,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        RuntimeDiagnostics.missingAsset(
          AppAssets.logo,
          scope: 'BrandLogo',
          error: error,
        );
        return Icon(Icons.image_not_supported_outlined, size: height * 0.7);
      },
    );
  }
}
