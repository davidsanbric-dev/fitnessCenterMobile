import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_capability_subpage.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_discipline_trainer_subpage.dart';
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
  const BookSessionFlow({super.key, this.scrollBottomPadding = 120});

  /// Bottom padding applied to the scroll-wrapped branches. Defaults to a value
  /// that clears the bottom navigation bar when hosted as a page; dialogs can
  /// pass a smaller value.
  final double scrollBottomPadding;

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

  @override
  Widget build(BuildContext context) {
    final showCapabilityFlow =
        _hasSelectedSchedulingMode &&
        _schedulingMode == SchedulingMode.byService;
    final showDisciplineFlow =
        _hasSelectedSchedulingMode &&
        _schedulingMode == SchedulingMode.byDisciplineTrainer;

    return showDisciplineFlow
        ? AvailableSlotsByDisciplineTrainerPage(
            isEmbedded: true,
            onBack: _backToSchedulingMode,
            headerSubtitle: _byDisciplineTrainerHeaderSubtitle,
            headerSubtitleIcon: LucideIcons.dumbbell,
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
                    if (!showCapabilityFlow)
                      const PageHeader(title: 'Book a Session'),
                    if (showCapabilityFlow)
                      AvailableSlotsByCapabilityPage(
                        isEmbedded: true,
                        horizontalPadding: horizontalPadding,
                        onBack: _backToSchedulingMode,
                        headerSubtitle: _byServiceHeaderSubtitle,
                        headerSubtitleIcon: LucideIcons.trophy,
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
  }
}
