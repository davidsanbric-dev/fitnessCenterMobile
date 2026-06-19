import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/slide_page_switcher.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_capability_subpage.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_discipline_trainer_subpage.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/book_session_header_reporter.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/scheduling_mode_filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// The full "Book a Session" UI flow, from the initial scheduling-mode
/// selection through the field filters down to the available-slots table.
///
/// This widget is self-contained and layout-agnostic: it does not provide its
/// own [Scaffold] or bottom navigation reset wiring, so it can be hosted both
/// as a full page (the "Book" tab) and inside a dialog. The host is
/// responsible for giving it bounded constraints — the by-discipline/trainer
/// branch relies on a [Stack] with `StackFit.expand` while the other branches
/// are scroll-wrapped internally, mirroring the original page layout.
class BookSessionFlow extends StatefulWidget {
  const BookSessionFlow({
    super.key,
    this.scrollBottomPadding = 120,
    this.onHeaderStateChanged,
    this.onExit,
  });

  /// Bottom padding applied to the scroll-wrapped branches. Defaults to a value
  /// that clears the bottom navigation bar when hosted as a page; dialogs can
  /// pass a smaller value.
  final double scrollBottomPadding;

  /// When provided, the flow runs "chromeless": each stage suppresses its own
  /// [PageHeader] and instead reports its header state up so the host can render
  /// a single unified header. When null, the flow renders its own headers (the
  /// dialog and standalone-tab hosting).
  final BookSessionHeaderReporter? onHeaderStateChanged;

  /// Invoked when the user backs out of the initial scheduling-mode selection.
  /// Hosts that embed the flow (e.g. inline on the bookings page) use this to
  /// dismiss the flow and restore their previous content.
  final VoidCallback? onExit;

  @override
  State<BookSessionFlow> createState() => BookSessionFlowState();
}

class BookSessionFlowState extends State<BookSessionFlow> {
  static const String _byDisciplineTrainerHeaderSubtitle =
      'By Discipline/Trainer';
  static const String _byServiceHeaderSubtitle = 'By Class Type';

  bool _hasSelectedSchedulingMode = false;
  SchedulingMode _schedulingMode = SchedulingMode.byService;

  AvailableSlotsController? _findFiltersController() {
    if (!Get.isRegistered<AvailableSlotsController>()) {
      return null;
    }
    return Get.find<AvailableSlotsController>();
  }

  void _resetFiltersState() {
    final controller = _findFiltersController();
    if (controller == null) {
      return;
    }
    controller.resetAvailabilityView();
    controller.resetCapabilitySubgroup();
  }

  void _handleSchedulingModeChanged(SchedulingMode newMode) {
    if (_hasSelectedSchedulingMode && _schedulingMode == newMode) {
      return;
    }
    _resetFiltersState();
    setState(() {
      _schedulingMode = newMode;
      _hasSelectedSchedulingMode = true;
    });
  }

  void _backToSchedulingMode() {
    _resetFiltersState();
    setState(() {
      _hasSelectedSchedulingMode = false;
      _schedulingMode = SchedulingMode.byService;
    });
  }

  /// Resets the flow back to its initial scheduling-mode selection. Exposed for
  /// hosts (e.g. the navigation tab) that need to reset on visibility changes.
  void resetToInitial() {
    if (!mounted) {
      return;
    }
    _resetFiltersState();
    setState(() {
      _hasSelectedSchedulingMode = false;
      _schedulingMode = SchedulingMode.byService;
    });
  }

  double _horizontalPaddingForWidth(double width) => width > 600 ? 28.0 : 16.0;

  /// Reports header state to a chromeless host, deferred to after the current
  /// build so it can safely drive the host's `setState`.
  void _scheduleHeaderReport(
    String stageKey,
    String? secondarySubtitle,
    IconData? secondarySubtitleIcon,
    VoidCallback? backHandler,
  ) {
    final reporter = widget.onHeaderStateChanged;
    if (reporter == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      reporter(stageKey, secondarySubtitle, secondarySubtitleIcon, backHandler);
    });
  }

  @override
  Widget build(BuildContext context) {
    final chromeless = widget.onHeaderStateChanged != null;
    final showCapabilityFlow =
        _hasSelectedSchedulingMode &&
        _schedulingMode == SchedulingMode.byService;
    final showDisciplineFlow =
        _hasSelectedSchedulingMode &&
        _schedulingMode == SchedulingMode.byDisciplineTrainer;

    // The initial scheduling-mode stage has no second-level subtitle; backing
    // out of it exits the flow entirely.
    if (chromeless && !_hasSelectedSchedulingMode) {
      _scheduleHeaderReport('mode', null, null, widget.onExit);
    }

    // Each stage slides horizontally as the flow advances: the scheduling-mode
    // selection is the root (depth 0) and the chosen branch slides in one level
    // deeper (depth 1), matching the bookings card transition that hosts it.
    final String stageKey = showDisciplineFlow
        ? 'discipline'
        : (showCapabilityFlow ? 'capability' : 'mode');
    final int stageDepth = _hasSelectedSchedulingMode ? 1 : 0;

    final Widget stage = showDisciplineFlow
        ? AvailableSlotsByDisciplineTrainerPage(
            isEmbedded: true,
            onBack: _backToSchedulingMode,
            headerSubtitle: _byDisciplineTrainerHeaderSubtitle,
            headerSubtitleIcon: LucideIcons.dumbbell,
            onHeaderStateChanged: widget.onHeaderStateChanged,
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = _horizontalPaddingForWidth(
                constraints.maxWidth,
              );
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: widget.scrollBottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!showCapabilityFlow && !chromeless)
                      const PageHeader(title: 'Book a Session'),
                    if (showCapabilityFlow)
                      AvailableSlotsByCapabilityPage(
                        isEmbedded: true,
                        horizontalPadding: horizontalPadding,
                        onBack: _backToSchedulingMode,
                        headerSubtitle: _byServiceHeaderSubtitle,
                        headerSubtitleIcon: LucideIcons.trophy,
                        onHeaderStateChanged: widget.onHeaderStateChanged,
                      )
                    else
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          12,
                          horizontalPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            SchedulingModeFilterBox(
                              selectedMode: _hasSelectedSchedulingMode
                                  ? _schedulingMode
                                  : null,
                              onChanged: _handleSchedulingModeChanged,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );

    return SlidePageSwitcher(
      depth: stageDepth,
      stageKey: stageKey,
      child: stage,
    );
  }
}
