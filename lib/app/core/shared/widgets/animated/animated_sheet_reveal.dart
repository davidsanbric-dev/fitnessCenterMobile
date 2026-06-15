import 'dart:ui';

import 'package:flutter/material.dart';

/// Reveals a bottom-anchored sheet by growing its visible height from
/// [collapsedHeightFactor] up to its full height as [progress] runs 0 -> 1.
///
/// The content is produced by [builder], which receives the eased reveal
/// progress so callers can drive secondary animations (e.g. a sliding banner)
/// in sync with the reveal. The sheet is clipped with rounded top corners.
class AnimatedSheetReveal extends StatelessWidget {
  const AnimatedSheetReveal({
    super.key,
    required this.progress,
    required this.collapsedHeightFactor,
    required this.builder,
    this.revealInterval = const Interval(0.2, 1.0, curve: Curves.easeInOut),
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(66),
      topRight: Radius.circular(66),
    ),
  });

  final double progress;
  final double collapsedHeightFactor;
  final Interval revealInterval;
  final BorderRadius borderRadius;
  final Widget Function(BuildContext context, double revealProgress) builder;

  @override
  Widget build(BuildContext context) {
    final double revealProgress = revealInterval.transform(progress);
    final double heightFactor =
        lerpDouble(collapsedHeightFactor, 1.0, revealProgress) ?? 1.0;

    return ClipRRect(
      borderRadius: borderRadius,
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: heightFactor,
          child: builder(context, revealProgress),
        ),
      ),
    );
  }
}
