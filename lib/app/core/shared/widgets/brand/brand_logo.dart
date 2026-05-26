import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:portfolio_mobile_app/app/core/constants/app_assets.dart';

class BrandLogo extends StatelessWidget {
  final double height;

  const BrandLogo({super.key, this.height = 50});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(AppAssets.logo),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Icon(LucideIcons.imageOff, size: height * 0.7);
        }

        if (!snapshot.hasData) {
          return SizedBox(
            height: height,
            width: height,
            child: Icon(LucideIcons.image, size: height * 0.7),
          );
        }

        return SvgPicture.string(
          snapshot.data!,
          height: height,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
