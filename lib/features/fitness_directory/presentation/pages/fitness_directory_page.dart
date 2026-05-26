import 'dart:async';

import 'package:portfolio_mobile_app/app/config/app_router.dart';
import 'package:portfolio_mobile_app/app/config/app_theme.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/location_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/pages/subpages.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/available_bookings_by_discipline_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class FitnessDirectoryPage extends StatefulWidget {
  const FitnessDirectoryPage({super.key});

  @override
  State<FitnessDirectoryPage> createState() => _FitnessDirectoryPageState();
}

class _FitnessDirectoryPageState extends State<FitnessDirectoryPage> {
  static const int _navIndex = 6;
  late final FitnessDirectoryController _controller;
  late final DisciplinesDirectoryController _disciplinesController;
  late final bool _ownsDisciplinesController;
  late final LocationController _locationController;
  late final bool _ownsLocationController;
  bool _ownsTrainersController = false;
  bool _ownsCapabilitiesController = false;
  AppRouter? _appRouter;
  Worker? _navWorker;

  @override
  void initState() {
    super.initState();
    _controller = FitnessDirectoryInjector.getFitnessDirectoryController();
    final hasDisciplinesController =
        Get.isRegistered<DisciplinesDirectoryController>();
    _disciplinesController =
        FitnessDirectoryInjector.getDisciplinesDirectoryController();
    _ownsDisciplinesController = !hasDisciplinesController;
    if (Get.isRegistered<LocationController>()) {
      _locationController = Get.find<LocationController>();
      _ownsLocationController = false;
    } else {
      _locationController = Get.put(LocationController());
      _ownsLocationController = true;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_loadLocations());
    });
    _attachNavListener();
  }

  @override
  void dispose() {
    _navWorker?.dispose();
    if (_ownsCapabilitiesController &&
        Get.isRegistered<CapabilitiesController>()) {
      Get.delete<CapabilitiesController>();
    }
    if (_ownsTrainersController && Get.isRegistered<TrainersController>()) {
      Get.delete<TrainersController>();
    }
    if (_ownsDisciplinesController) {
      Get.delete<DisciplinesDirectoryController>();
    }
    if (_ownsLocationController && Get.isRegistered<LocationController>()) {
      Get.delete<LocationController>();
    }
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      await _locationController.loadLocations();
    } catch (_) {
      // Location filtering can stay disabled if location loading fails.
    }
  }

  void _startTrainersFlow() {
    _ensureTrainersController();
    _controller.showTrainers();
  }

  void _startCapabilitiesFlow() {
    _ensureCapabilitiesController();
    _controller.showCapabilities();
  }

  void _handleBackFromDisciplineAvailability() {
    _disciplinesController.backToResults();
    _controller.showDisciplines();
  }

  void _handleBackFromCapabilities() {
    if (!Get.isRegistered<CapabilitiesController>()) {
      _showDirectoryOptions();
      return;
    }
    final controller = Get.find<CapabilitiesController>();
    switch (controller.stage.value) {
      case CapabilitiesViewStage.groupSelection:
        _showDirectoryOptions();
        return;
      case CapabilitiesViewStage.subgroupSelection:
        controller.backToGroups();
        return;
      case CapabilitiesViewStage.subgroupItemsSelection:
        controller.backToSubgroup();
        return;
      case CapabilitiesViewStage.capabilityAvailability:
        controller.backToSubgroupItems();
        return;
    }
  }

  void _handleBackFromTrainerAvailability() {
    if (!Get.isRegistered<TrainersController>()) {
      _showDirectoryOptions();
      return;
    }
    Get.find<TrainersController>().backToResults();
  }

  void _showDirectoryOptions() {
    _disciplinesController.error.value = null;
    _disciplinesController.clearLocationSelection();
    _disciplinesController.showDisciplinesResults.value = false;
    _disciplinesController.resetDisciplineAvailability();
    if (Get.isRegistered<TrainersController>()) {
      Get.find<TrainersController>().resetToInitialState();
    }
    if (Get.isRegistered<CapabilitiesController>()) {
      Get.find<CapabilitiesController>().backToGroups();
    }
    _controller.showDirectoryOptions();
  }

  void _ensureTrainersController() {
    if (Get.isRegistered<TrainersController>()) {
      return;
    }
    FitnessDirectoryInjector.getTrainersController();
    _ownsTrainersController = true;
  }

  void _ensureCapabilitiesController() {
    if (Get.isRegistered<CapabilitiesController>()) {
      return;
    }
    FitnessDirectoryInjector.getCapabilitiesController();
    _ownsCapabilitiesController = true;
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingFlow.bookStandard(
      context: context,
      controller: ClassBookingInjector.getSharedClassBookingController(),
      slot: slot,
      onBooked: () async {
        _disciplinesController.removeBookedAvailabilitySlot(slot);
      },
    );
  }

  List<TableFiltersSummaryItemData>? _buildDisciplineAvailabilitySummary(
    DisciplineDto? discipline,
  ) {
    if (discipline == null) {
      return null;
    }
    final items = <TableFiltersSummaryItemData>[];
    final disciplineName = discipline.disciplineName.trim();
    if (disciplineName.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Discipline',
          value: disciplineName,
          icon: LucideIcons.star,
        ),
      );
    }
    final locationLabel =
        _disciplinesController.selectedLocationLabel.value?.trim() ?? '';
    if (locationLabel.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Club',
          value: locationLabel,
          icon: LucideIcons.building2,
        ),
      );
    }
    if (items.isEmpty) {
      return null;
    }
    return items;
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
      _resetPageState();
    });
  }

  void _resetPageState() {
    if (!mounted) {
      return;
    }
    _controller.resetToInitialState();
    if (Get.isRegistered<TrainersController>()) {
      Get.find<TrainersController>().resetToInitialState();
    }
    if (Get.isRegistered<CapabilitiesController>()) {
      Get.find<CapabilitiesController>().backToGroups();
    }
    if (Get.isRegistered<DisciplinesDirectoryController>()) {
      _disciplinesController.resetToInitialState();
    }
  }

  PageHeader _buildHeader(FitnessDirectoryView view) {
    const headerTitle = 'Fitness Directory';
    if (view == FitnessDirectoryView.disciplines) {
      return PageHeader(
        title: headerTitle,
        subtitle: 'Disciplines',
        subtitleIcon: LucideIcons.dumbbell,
        onBackButtonPressed: _showDirectoryOptions,
      );
    }
    if (view == FitnessDirectoryView.disciplineAvailability) {
      return PageHeader(
        title: headerTitle,
        subtitle: 'Disciplines',
        subtitleIcon: LucideIcons.dumbbell,
        onBackButtonPressed: _handleBackFromDisciplineAvailability,
      );
    }
    if (view == FitnessDirectoryView.capabilities) {
      return PageHeader(
        title: headerTitle,
        subtitle: 'Class Types',
        subtitleIcon: LucideIcons.trophy,
        onBackButtonPressed: _handleBackFromCapabilities,
      );
    }
    if (view == FitnessDirectoryView.trainers) {
      final stage = Get.isRegistered<TrainersController>()
          ? Get.find<TrainersController>().stage.value
          : null;
      final isAvailability = stage == TrainersViewStage.availability;
      return PageHeader(
        title: headerTitle,
        subtitle: 'Trainers',
        subtitleIcon: LucideIcons.user,
        onBackButtonPressed: isAvailability
            ? _handleBackFromTrainerAvailability
            : _showDirectoryOptions,
      );
    }
    if (view == FitnessDirectoryView.memberships) {
      return PageHeader(
        title: headerTitle,
        subtitle: 'Membership Plans',
        subtitleIcon: LucideIcons.creditCard,
        onBackButtonPressed: _showDirectoryOptions,
      );
    }

    return const PageHeader(title: headerTitle);
  }

  List<BookingsLocationOption> _resolveLocationOptions() {
    final result = <BookingsLocationOption>[];
    final seenIds = <int>{};
    for (final location in _locationController.locations) {
      final name = location.name.trim();
      if (location.id <= 0 || name.isEmpty || !seenIds.add(location.id)) {
        continue;
      }
      result.add(BookingsLocationOption(id: location.id, name: name));
    }
    return result;
  }

  List<String> _locationLabelsFor(List<BookingsLocationOption> locations) =>
      locations.map((location) => location.name).toList(growable: false);

  Map<String, int> _locationLabelToIdFor(
    List<BookingsLocationOption> locations,
  ) {
    final map = <String, int>{};
    for (final location in locations) {
      map[location.name.trim().toLowerCase()] = location.id;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      DirectoryOption(
        title: 'Browse disciplines',
        onTap: () {
          _controller.showDisciplines();
          _disciplinesController.loadDisciplines();
        },
      ),
      DirectoryOption(
        title: 'Browse class types',
        onTap: _startCapabilitiesFlow,
      ),
      DirectoryOption(title: 'Browse trainers', onTap: _startTrainersFlow),
      DirectoryOption(
        title: 'Browse membership plans',
        onTap: () => _controller.loadMemberships(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => _buildHeader(_controller.view.value)),
            Expanded(
              child: Obx(() {
                final view = _controller.view.value;
                final locationOptionsData = _resolveLocationOptions();
                final locationLabels = _locationLabelsFor(locationOptionsData);
                final locationLabelToId = _locationLabelToIdFor(
                  locationOptionsData,
                );

                switch (view) {
                  case FitnessDirectoryView.capabilities:
                    return const CapabilitiesDirectoryPage();
                  case FitnessDirectoryView.disciplines:
                    return DisciplinesDirectoryPage(
                      controller: _disciplinesController,
                      onShowAvailability:
                          _controller.showDisciplineAvailabilityView,
                      locationOptions: locationLabels,
                      locationLabelToId: locationLabelToId,
                    );
                  case FitnessDirectoryView.disciplineAvailability:
                    final selectedDiscipline =
                        _disciplinesController.selectedDiscipline.value;
                    final summary = _buildDisciplineAvailabilitySummary(
                      selectedDiscipline,
                    );
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: AvailableBookingsByDisciplineTable(
                        bookings:
                            _disciplinesController.disciplineAvailabilityRows,
                        isLoading: _disciplinesController
                            .isDisciplineAvailabilityLoading
                            .value,
                        errorMessage: _disciplinesController
                            .disciplineAvailabilityError
                            .value,
                        filterSummary: summary,
                        onReserveBooking: _handleReserveBooking,
                        pageNumber: _disciplinesController
                            .disciplineAvailabilityPageNumber
                            .value,
                        pageSize: _disciplinesController
                            .disciplineAvailabilityPageSize
                            .value,
                        totalItems: _disciplinesController
                            .disciplineAvailabilityTotalItems
                            .value,
                        onPageChanged: _disciplinesController
                            .setDisciplineAvailabilityPageNumber,
                        showPagination: true,
                      ),
                    );
                  case FitnessDirectoryView.memberships:
                    return MembershipsDirectoryPage(
                      memberships: _controller.membershipsRows,
                      isLoading: _controller.isLoading.value,
                      errorMessage: _controller.error.value,
                      pageNumber: _controller.membershipsPageNumber.value,
                      pageSize: _controller.membershipsPageSize.value,
                      totalItems: _controller.membershipsTotalItems.value,
                      onPageChanged: _controller.setMembershipsPageNumber,
                      showPagination: true,
                    );
                  case FitnessDirectoryView.trainers:
                    return TrainersDirectoryPage(
                      locationOptions: locationLabels,
                      locationLabelToId: locationLabelToId,
                    );
                  case FitnessDirectoryView.options:
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 35,
                        vertical: 25,
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return ListTile(
                          title: Text(
                            option.title,
                            style: AppTheme.listTileTitle,
                          ),
                          onTap: option.onTap,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          minVerticalPadding: 10,
                        );
                      },
                      separatorBuilder: (context, _) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade300,
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
