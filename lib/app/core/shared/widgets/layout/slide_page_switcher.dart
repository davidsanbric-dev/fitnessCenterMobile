import 'package:flutter/material.dart';

/// Cross-slides between the stages of a multi-stage page flow (the ones whose
/// page-header subtitle depends on navigation).
///
/// Hosts describe each stage with two values:
///   * [stageKey] — the stage's identity. A change here is what triggers a
///     slide; rebuilding with the same key just refreshes the stage in place.
///   * [depth] — its position in the flow. A deeper stage slides the outgoing
///     card out to the left while the incoming card slides in from the right;
///     backing out to a shallower depth reverses the motion.
///
/// The two cards move as one rigid strip — always exactly one viewport width
/// apart — so they never overlap or leave a gap. Identity and depth are kept
/// separate because parallel stages can share a depth (e.g. sibling sections
/// one level into a directory), so depth alone can't tell them apart.
class SlidePageSwitcher extends StatefulWidget {
  const SlidePageSwitcher({
    super.key,
    required this.depth,
    required this.stageKey,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Monotonic navigation depth of the currently shown stage. A larger value
  /// than the previous stage animates forward (new card from the right); a
  /// smaller one animates back.
  final int depth;

  /// Identity of the current stage. When it differs from the previous build the
  /// switcher slides to [child]; otherwise [child] replaces the current stage
  /// in place without animating.
  final Object stageKey;

  /// The current stage's content.
  final Widget child;

  final Duration duration;

  @override
  State<SlidePageSwitcher> createState() => _SlidePageSwitcherState();
}

class _SlidePageSwitcherState extends State<SlidePageSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    // Start settled so the first card is on-screen instead of waiting off to
    // the side for an animation that never ran.
    value: 1,
  )..addStatusListener(_onStatus);

  late final CurvedAnimation _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  late Object _currentKey = widget.stageKey;
  late Widget _currentChild = _keyed(widget);
  Widget? _outgoingChild;
  late int _currentDepth = widget.depth;
  bool _forward = true;

  // Key each card by its stage so the Stack keeps the incoming and outgoing
  // cards distinct (and preserves each stage's state) while they slide.
  Widget _keyed(SlidePageSwitcher w) =>
      KeyedSubtree(key: ValueKey(w.stageKey), child: w.child);

  @override
  void didUpdateWidget(covariant SlidePageSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.stageKey == _currentKey) {
      // Same stage rebuilt with fresh content; keep it on-screen as-is.
      _currentChild = _keyed(widget);
      _currentDepth = widget.depth;
      return;
    }
    // New stage: a deeper (or equal) depth reads as forward. Slide the old card
    // out while the new one slides in.
    _forward = widget.depth >= _currentDepth;
    _outgoingChild = _currentChild;
    _currentChild = _keyed(widget);
    _currentKey = widget.stageKey;
    _currentDepth = widget.depth;
    _controller
      ..reset()
      ..forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _outgoingChild != null) {
      setState(() => _outgoingChild = null);
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Incoming enters from the side we're heading toward; the outgoing card
    // departs to the opposite side, one width behind it.
    final side = _forward ? 1.0 : -1.0;
    // Clip at the viewport so the cards sliding past each other are hidden once
    // they leave the bounds instead of overflowing onto neighbouring chrome.
    return ClipRect(
      child: Stack(
        // Force every card to fill the box so flows that rely on bounded
        // constraints (ListView, Expanded columns) lay out while sliding.
        alignment: Alignment.topCenter,
        children: <Widget>[
          if (_outgoingChild != null)
            Positioned.fill(
              child: SlideTransition(
                position: Tween(
                  begin: Offset.zero,
                  end: Offset(-side, 0),
                ).animate(_progress),
                child: _outgoingChild,
              ),
            ),
          Positioned.fill(
            child: SlideTransition(
              position: Tween(
                begin: Offset(side, 0),
                end: Offset.zero,
              ).animate(_progress),
              child: _currentChild,
            ),
          ),
        ],
      ),
    );
  }
}
