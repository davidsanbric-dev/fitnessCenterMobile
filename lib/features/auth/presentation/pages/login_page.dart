import 'dart:async';

import 'package:portfolio_mobile_app/features/auth/presentation/widgets/greeting_message.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_image.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_sheet.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/animated/animated_greeting.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/animated/animated_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/animated/animated_sheet_reveal.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_slogan_bar.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_form.dart';

const double _sloganHorizontalInset = 0.0;
const double _sloganWidthFactor = 0.8;
const double _loginImageAspectRatio = 323 / 248;
const double _sloganInitialDropFraction =
    0.4; // How far the slogan bar starts over the image (first stage),
// enough to clear the sheet's top edge so the bar is fully visible there too
const double _collapsedSheetPeek =
    0.0; // Sheet reveal stops at the image top when collapsed (no surface peek)
const double _imageTopFade =
    0.08; // Static soft fade on the image top edge (kept constant so the image
// widget stays const and its ShaderMask rasterizes once instead of per frame).

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;
  late final CurvedAnimation _greeting;
  Timer? _animationStartTimer;

  static const _transitionDuration = Duration(milliseconds: 900);
  static const _initialDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _transitionDuration,
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    // Greeting fade/slide runs on its own curve so it can repaint
    // independently of the header/sheet transforms.
    _greeting = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.65, curve: Curves.easeInOut),
    );

    _animationStartTimer = Timer(_initialDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _animationStartTimer?.cancel();
    _greeting.dispose();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Static subtrees built once; they are not rebuilt while the animation runs.
    const Widget authForm = LoginForm();
    const Widget loginImage = LoginImage(topFadeFraction: _imageTopFade);
    const Widget sloganBar = BrandSloganBar();
    final Widget greeting = AnimatedGreeting(
      animation: _greeting,
      child: const GreetingMessage(),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Layout-derived values depend only on the (stable) constraints,
            // so compute them once here instead of inside the per-frame builder.
            final double imageHeight =
                constraints.maxWidth / _loginImageAspectRatio;
            final double baseHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height;
            final double fullHeight = imageHeight + baseHeight * 0.55;
            final double collapsedFactor = fullHeight > 0
                ? (imageHeight / fullHeight).clamp(0.0, 1.0)
                : 0.6;
            final double collapsedWithPeek =
                (collapsedFactor + _collapsedSheetPeek).clamp(0.0, 1.0);

            return AnimatedBuilder(
              animation: _progress,
              child: greeting,
              builder: (context, greetingChild) {
                final double t = _progress.value;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedHeader(
                          progress: t,
                          // RepaintBoundary isolates the brand logo so the
                          // per-frame scale/translate is applied to a cached
                          // raster layer.
                          child: const RepaintBoundary(
                            child: BrandHeader(
                              key: ValueKey('brand-extra'),
                              variant: 'extralarge',
                            ),
                          ),
                        ),
                        greetingChild!,
                        AnimatedSheetReveal(
                          progress: t,
                          collapsedHeightFactor: collapsedWithPeek,
                          builder: (context, revealProgress) {
                            final double sloganSlide = const Interval(
                              0.0,
                              0.9,
                              curve: Curves.easeOut,
                            ).transform(revealProgress);

                            return LoginSheet(
                              loginForm: authForm,
                              brandSloganBar: sloganBar,
                              loginImage: loginImage,
                              imageHeight: imageHeight,
                              brandBarHorizontalInset: _sloganHorizontalInset,
                              brandBarWidthFactor: _sloganWidthFactor,
                              brandSloganSlide: sloganSlide,
                              brandSloganDropFraction: _sloganInitialDropFraction,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
