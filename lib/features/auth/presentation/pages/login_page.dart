import 'dart:async';
import 'dart:ui';

import 'package:portfolio_mobile_app/features/auth/presentation/widgets/greeting_message.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_image.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_sheet.dart';
import 'package:flutter/material.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/brand/brand_slogan_bar.dart';
import 'package:portfolio_mobile_app/features/auth/presentation/widgets/login_form.dart';

const double _sloganHorizontalInset = 0.0;
const double _sloganWidthFactor = 0.8;
const double _loginImageAspectRatio = 323 / 248;
const double _sloganInitialDropFraction =
    0.2; // How far the slogan bar starts over the image
const double _collapsedSheetPeek =
    0.06; // Let the sheet overtake the image slightly when collapsed

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
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

    _animationStartTimer = Timer(_initialDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _animationStartTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget authForm = const LoginForm();

    return Scaffold(
      backgroundColor: AppTheme.brandBlue,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                final double t = _progress.value;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _AnimatedHeader(progress: t),
                        _AnimatedGreeting(progress: t),
                        _AnimatedSheets(progress: t, loginForm: authForm),
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

class _AnimatedHeader extends StatelessWidget {
  const _AnimatedHeader({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final double t = progress;
    final double headerScale = lerpDouble(
      1.08,
      0.76,
      const Interval(0, 0.7, curve: Curves.easeOut).transform(t),
    )!;
    final double headerOffset = lerpDouble(
      48,
      12,
      const Interval(0, 0.6, curve: Curves.easeOut).transform(t),
    )!;

    return Transform.translate(
      offset: Offset(0, headerOffset),
      child: Column(
        children: [
          Transform.scale(
            scale: headerScale,
            child: const BrandHeader(
              key: ValueKey('brand-extra'),
              variant: 'extralarge',
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGreeting extends StatelessWidget {
  const _AnimatedGreeting({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final double greetingCurve = const Interval(
      0,
      0.65,
      curve: Curves.easeInOut,
    ).transform(progress);
    final double greetingOpacity = (1 - greetingCurve).clamp(0.0, 1.0);
    final double greetingOffset = lerpDouble(0, -12, greetingCurve)!;

    return Opacity(
      opacity: greetingOpacity,
      child: Transform.translate(
        offset: Offset(0, greetingOffset),
        child: const GreetingMessage(),
      ),
    );
  }
}

class _AnimatedSheets extends StatelessWidget {
  const _AnimatedSheets({required this.progress, required this.loginForm});

  final double progress;
  final Widget loginForm;

  @override
  Widget build(BuildContext context) {
    final double revealProgress = const Interval(
      0.2,
      1.0,
      curve: Curves.easeInOut,
    ).transform(progress);

    return LayoutBuilder(
      builder: (context, constraints) {
        final Size viewport = MediaQuery.sizeOf(context);
        final double imageHeight =
            constraints.maxWidth / _loginImageAspectRatio;
        final double baseHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : viewport.height;
        final double fullHeight = imageHeight + baseHeight * 0.35;
        final double collapsedFactor = fullHeight > 0
            ? (imageHeight / fullHeight).clamp(0.0, 1.0)
            : 0.6;
        final double collapsedWithPeek = (collapsedFactor + _collapsedSheetPeek)
            .clamp(0.0, 1.0);
        final double heightFactor =
            lerpDouble(collapsedWithPeek, 1.0, revealProgress) ?? 1.0;
        final double sloganSlide = const Interval(
          0.0,
          0.9,
          curve: Curves.easeOut,
        ).transform(revealProgress);

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(66),
            topRight: Radius.circular(66),
          ),
          child: ClipRect(
            child: Align(
              alignment: Alignment.bottomCenter,
              heightFactor: heightFactor,
              child: LoginSheet(
                loginForm: loginForm,
                brandSloganBar: const BrandSloganBar(),
                loginImage: const LoginImage(),
                brandBarHorizontalInset: _sloganHorizontalInset,
                brandBarWidthFactor: _sloganWidthFactor,
                imageAspectRatio: _loginImageAspectRatio,
                brandSloganSlide: sloganSlide,
                brandSloganDropFraction: _sloganInitialDropFraction,
              ),
            ),
          ),
        );
      },
    );
  }
}
