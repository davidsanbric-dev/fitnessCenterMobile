import 'package:flutter/material.dart';

class LoginSheet extends StatelessWidget {
  final Widget loginForm;
  final Widget brandSloganBar;
  final Widget loginImage;
  final double brandBarHorizontalInset;
  final double brandBarWidthFactor;
  final double imageAspectRatio;
  final double brandSloganSlide;
  final double brandSloganDropFraction;

  const LoginSheet({
    super.key,
    required this.loginForm,
    required this.brandSloganBar,
    required this.loginImage,
    this.brandBarHorizontalInset = 16,
    this.brandBarWidthFactor = 0.7,
    this.imageAspectRatio = 3 / 2,
    this.brandSloganSlide = 1.0,
    this.brandSloganDropFraction = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double imageHeight = constraints.maxWidth > 0
            ? constraints.maxWidth / imageAspectRatio
            : 0;
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
                child: loginImage,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: imageHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    loginForm,
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
      },
    );
  }
}
