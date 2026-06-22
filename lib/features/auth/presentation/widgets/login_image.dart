import 'package:flutter/material.dart';
import 'package:fitnesscenter_mobile/app/core/constants/app_assets.dart';

class LoginImage extends StatelessWidget {
  /// Height fraction of the soft fade applied to the top edge of the image.
  /// 0 means the image is shown solid up to its top border (first stage); the
  /// fade grows in as the sheet reveals toward the second stage.
  final double topFadeFraction;

  const LoginImage({super.key, this.topFadeFraction = 0.08});

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      AppAssets.loginImage,
      fit: BoxFit.cover,
      alignment: Alignment.center,
    );

    if (topFadeFraction <= 0) {
      return ClipRect(child: image);
    }

    return ClipRect(
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.transparent, Colors.black, Colors.black],
            stops: [0.0, topFadeFraction, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: image,
      ),
    );
  }
}
