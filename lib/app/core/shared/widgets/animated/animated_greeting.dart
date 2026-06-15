import 'package:flutter/material.dart';

/// Fades and slides [child] upward out of view as [animation] runs 0 -> 1.
///
/// Wrapped in a [RepaintBoundary] and an [AnimatedBuilder] so it repaints
/// independently of the rest of the page while the animation plays.
class AnimatedGreeting extends StatelessWidget {
  const AnimatedGreeting({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final double v = animation.value;
          return Opacity(
            opacity: (1 - v).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, -12 * v),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
