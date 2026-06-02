import 'package:portfolio_mobile_app/app/config/app_router.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_capability_subpage.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/pages/subpages/available_slots_by_discipline_trainer_subpage.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/scheduling_mode_filter_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class AvailableSlotsPage extends StatefulWidget {
  const AvailableSlotsPage({super.key});

  @override
  State<AvailableSlotsPage> createState() => _AvailableSlotsPageState();
}

class _AvailableSlotsPageState extends State<AvailableSlotsPage> {
  static const int _navIndex = 4;
  static const String _byDisciplineTrainerHeaderSubtitle =
      'By Discipline/Trainer';
  static const String _byServiceHeaderSubtitle = 'By Class Type';

  AppRouter? _appRouter;
  Worker? _navWorker;
  bool _hasSelectedSchedulingMode = false;
  SchedulingMode _schedulingMode = SchedulingMode.byService;

  @override
  void initState() {
    super.initState();
    _attachNavListener();
  }

  @override
  void dispose() {
    _navWorker?.dispose();
    super.dispose();
  }

  void _attachNavListener() {
    if (!Get.isRegistered<AppRouter>()) {
      return;
    }
    _appRouter = Get.find<AppRouter>();
    _navWorker = ever<int>(_appRouter!.currentIndex, (index) {
      if (index == _navIndex) {
        return;
      }
      _resetToInitialState();
    });
  }

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

  void _resetToInitialState() {
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

    return Scaffold(
      body: SafeArea(
        top: false,
        child: showDisciplineFlow
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
                    padding: const EdgeInsets.only(bottom: 120),
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
              ),
      ),
    );
  }
}
