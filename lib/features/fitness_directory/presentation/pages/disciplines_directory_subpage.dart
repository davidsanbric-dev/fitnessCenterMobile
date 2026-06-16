import 'dart:async';

import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/available_bookings_by_discipline_table.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/disciplines_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DisciplinesDirectoryPage extends StatefulWidget {
  const DisciplinesDirectoryPage({
    super.key,
    required this.controller,
    required this.onShowAvailability,
  });

  final DisciplinesDirectoryController controller;
  final VoidCallback onShowAvailability;

  @override
  State<DisciplinesDirectoryPage> createState() =>
      _DisciplinesDirectoryPageState();
}

class _DisciplinesDirectoryPageState extends State<DisciplinesDirectoryPage> {
  @override
  void initState() {
    super.initState();
    _ensureDisciplinesLoaded();
  }

  void _ensureDisciplinesLoaded() {
    if (widget.controller.disciplines.isEmpty &&
        !widget.controller.isLoading.value) {
      unawaited(
        widget.controller.loadDisciplines(
          forceRefresh: true,
          preserveResults: true,
        ),
      );
    }
  }

  void _handleDisciplineSelected(
    BuildContext context,
    Map<String, dynamic> row,
  ) {
    final discipline = row['discipline'] as DisciplineDto?;
    if (discipline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select the discipline.')),
      );
      return;
    }

    // The discipline carries its own club; a null id lists every club's slots.
    widget.controller.showDisciplineAvailability(
      discipline,
      locationId: discipline.locationId,
    );
    widget.onShowAvailability();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = widget.controller.isLoading.value;

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DisciplinesTable(
              disciplines: widget.controller.disciplinesRows,
              isLoading: isLoading,
              errorMessage: widget.controller.error.value,
              pageNumber: widget.controller.pageNumber.value,
              pageSize: widget.controller.pageSize.value,
              totalItems: widget.controller.totalItems.value,
              onPageChanged: widget.controller.setPageNumber,
              showPagination: true,
              onDisciplineSelected: (row) =>
                  _handleDisciplineSelected(context, row),
            ),
          ],
        ),
      );
    });
  }
}

class DisciplinesDirectoryStandalonePage extends StatefulWidget {
  const DisciplinesDirectoryStandalonePage({super.key});

  @override
  State<DisciplinesDirectoryStandalonePage> createState() =>
      _DisciplinesDirectoryStandalonePageState();
}

class _DisciplinesDirectoryStandalonePageState
    extends State<DisciplinesDirectoryStandalonePage> {
  late final DisciplinesDirectoryController _controller;
  late final bool _ownsController;
  late final LocationController _locationController;
  late final bool _ownsLocationController;
  bool _showAvailability = false;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<DisciplinesDirectoryController>()) {
      _controller = Get.find<DisciplinesDirectoryController>();
      _ownsController = false;
    } else {
      _controller =
          FitnessDirectoryInjector.getDisciplinesDirectoryController();
      _ownsController = true;
    }
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
  }

  @override
  void dispose() {
    if (_ownsController) {
      Get.delete<DisciplinesDirectoryController>();
    }
    if (_ownsLocationController && Get.isRegistered<LocationController>()) {
      Get.delete<LocationController>();
    }
    super.dispose();
  }

  Future<void> _loadLocations() async {
    // Locations are loaded so the LocationCodeRegistry can resolve each
    // discipline's club id to its `/statics` code when fetching availability.
    try {
      await _locationController.loadLocations();
    } catch (_) {
      // Keep the page usable when the locations request fails.
    }
  }

  void _handleShowAvailability() {
    if (_showAvailability) {
      return;
    }
    setState(() {
      _showAvailability = true;
    });
  }

  void _handleBack() {
    if (_showAvailability) {
      _controller.backToResults();
      setState(() {
        _showAvailability = false;
      });
      return;
    }
    Get.back();
  }

  Future<void> _handleReserveBooking(AvailableSlotDto slot) async {
    await ClassBookingFlow.bookStandard(
      context: context,
      controller: ClassBookingInjector.getSharedClassBookingController(),
      slot: slot,
      onBooked: () async {
        _controller.removeBookedAvailabilitySlot(slot);
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
    final locationLabel = discipline.locationName?.trim() ?? '';
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

  Widget _buildAvailabilityView() {
    return Obx(() {
      final selectedDiscipline = _controller.selectedDiscipline.value;
      final summary = _buildDisciplineAvailabilitySummary(selectedDiscipline);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: AvailableBookingsByDisciplineTable(
          bookings: _controller.disciplineAvailabilityRows,
          isLoading: _controller.isDisciplineAvailabilityLoading.value,
          errorMessage: _controller.disciplineAvailabilityError.value,
          filterSummary: summary,
          onReserveBooking: _handleReserveBooking,
          pageNumber: _controller.disciplineAvailabilityPageNumber.value,
          pageSize: _controller.disciplineAvailabilityPageSize.value,
          totalItems: _controller.disciplineAvailabilityTotalItems.value,
          onPageChanged: _controller.setDisciplineAvailabilityPageNumber,
          showPagination: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Fitness Directory',
              subtitle: 'Disciplines',
              subtitleIcon: LucideIcons.dumbbell,
              onBackButtonPressed: _handleBack,
            ),
            Expanded(
              child: _showAvailability
                  ? _buildAvailabilityView()
                  : DisciplinesDirectoryPage(
                      controller: _controller,
                      onShowAvailability: _handleShowAvailability,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
