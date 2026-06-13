import 'package:flutter/material.dart';

class LoginSheet extends StatelessWidget {
  final Widget loginForm;
  final Widget brandSloganBar;
  final Widget loginImage;
  final double brandBarHorizontalInset;
  final double brandBarWidthFactor;
  final double imageHeight;
  final double brandSloganSlide;
  final double brandSloganDropFraction;

  const LoginSheet({
    super.key,
    required this.loginForm,
    required this.brandSloganBar,
    required this.loginImage,
    required this.imageHeight,
    this.brandBarHorizontalInset = 16,
    this.brandBarWidthFactor = 0.7,
    this.brandSloganSlide = 1.0,
    this.brandSloganDropFraction = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    // imageHeight is supplied by the caller (derived once from the stable
    // layout width), so this widget no longer needs its own LayoutBuilder.
    final double sloganDrop = imageHeight * brandSloganDropFraction;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(66),
          topRight: Radius.circular(66),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: imageHeight,
            // Isolate the image so it doesn't repaint the form/slogan (and vice
            // versa) as the sheet reveals.
            child: RepaintBoundary(child: loginImage),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: imageHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RepaintBoundary(child: loginForm),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    brandBarHorizontalInset,
                    8,
                    brandBarHorizontalInset,
                    0,
                  ),
                  child: Transform.translate(
                    offset: Offset(0, (1 - brandSloganSlide) * sloganDrop),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: brandBarWidthFactor,
                      child: brandSloganBar,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
