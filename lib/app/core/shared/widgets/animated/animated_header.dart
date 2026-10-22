import 'dart:ui';

import 'package:flutter/material.dart';

/// Entrance animation for a page header: as [progress] goes 0 -> 1 the [child]
/// scales down slightly and slides into place. Driven by an external animation
/// value so the caller controls timing.
class AnimatedHeader extends StatelessWidget {
  const AnimatedHeader({
    super.key,
    required this.progress,
    required this.child,
  });

  final double progress;
  final Widget child;

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
      40,
      const Interval(0, 0.6, curve: Curves.easeOut).transform(t),
    )!;

    return Transform.translate(
      offset: Offset(0, headerOffset),
      child: Transform.scale(scale: headerScale, child: child),
    );
  }
}
