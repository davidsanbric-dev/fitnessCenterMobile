import 'package:flutter/material.dart';

/// Cross-fades + horizontally slides between the stages of a multi-stage page
/// flow (the ones whose page-header subtitle depends on navigation).
///
/// Going deeper into a flow (a larger [depth]) slides the outgoing card out to
/// the left while the incoming card slides in from the right; backing out
/// reverses the motion. The direction is inferred from how [depth] changes
/// between builds, so hosts only need to map each stage to an increasing depth
/// and give each stage child a stable [Key].
class SlidePageSwitcher extends StatefulWidget {
  const SlidePageSwitcher({
    super.key,
    required this.depth,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Monotonic navigation depth of the currently shown stage. Increasing it
  /// animates forward (new card from the right); decreasing it animates back.
  final int depth;

  /// The current stage. Must carry a [Key] that is unique per stage so the
  /// switcher can tell the incoming card apart from the outgoing one.
  final Widget child;

  final Duration duration;

  @override
  State<SlidePageSwitcher> createState() => _SlidePageSwitcherState();
}

class _SlidePageSwitcherState extends State<SlidePageSwitcher> {
  late int _currentDepth = widget.depth;
  bool _forward = true;

  @override
  void didUpdateWidget(covariant SlidePageSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.depth != _currentDepth) {
      _forward = widget.depth > _currentDepth;
      _currentDepth = widget.depth;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Clip at the viewport so the cards sliding past each other are hidden once
    // they leave the bounds instead of overflowing onto neighbouring chrome.
    return ClipRect(
      child: AnimatedSwitcher(
        duration: widget.duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: _buildTransition,
        layoutBuilder: _buildLayout,
        child: widget.child,
      ),
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    final isIncoming = child.key == widget.child.key;
    // Incoming card enters from the side we're navigating toward; the outgoing
    // card (whose animation runs in reverse) departs to the opposite side.
    final Offset begin;
    if (isIncoming) {
      begin = _forward ? const Offset(1, 0) : const Offset(-1, 0);
    } else {
      begin = _forward ? const Offset(-1, 0) : const Offset(1, 0);
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  Widget _buildLayout(Widget? currentChild, List<Widget> previousChildren) {
    // Force every card to fill the switcher's box so flows that rely on bounded
    // constraints (ListView, Expanded columns) lay out correctly while sliding.
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        ...previousChildren.map((child) => Positioned.fill(child: child)),
        if (currentChild != null) Positioned.fill(child: currentChild),
      ],
    );
  }
}
