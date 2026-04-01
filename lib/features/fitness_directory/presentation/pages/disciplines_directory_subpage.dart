import 'dart:async';

import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/format/date_time.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/location_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/logic/disciplines_directory_controller.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/available_bookings_by_discipline_table.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/disciplines_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisciplinesDirectoryPage extends StatefulWidget {
  const DisciplinesDirectoryPage({
    super.key,
    required this.controller,
    required this.onShowAvailability,
    required this.locationOptions,
    required this.locationLabelToId,
  });

  final DisciplinesDirectoryController controller;
  final VoidCallback onShowAvailability;
  final List<String> locationOptions;
  final Map<String, int> locationLabelToId;

  @override
  State<DisciplinesDirectoryPage> createState() =>
      _DisciplinesDirectoryPageState();
}

class _DisciplinesDirectoryPageState extends State<DisciplinesDirectoryPage> {
  static const int _defaultDirectoryLocationId = 3;

  @override
  void initState() {
    super.initState();
    _ensureDefaultLocationSelection();
  }

  @override
  void didUpdateWidget(covariant DisciplinesDirectoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureDefaultLocationSelection();
  }

  void _ensureDefaultLocationSelection() {
    final options = widget.locationOptions;
    if (options.isEmpty) {
      return;
    }

    final currentLocationId = widget.controller.selectedLocationId.value;
    if (currentLocationId != null) {
      final hasCurrent = options.any(
        (option) => _resolveLocationId(option) == currentLocationId,
      );
      if (hasCurrent) {
        return;
      }
    }

    final defaultLabel = _resolveDefaultLocationLabel(options);
    final label = defaultLabel ?? options.first;
    final locationId = _resolveLocationId(label);
    if (locationId == null) {
      return;
    }

    widget.controller.selectedLocationId.value = locationId;
    widget.controller.selectedLocationLabel.value = label.trim();
    final shouldLoadDisciplines =
        widget.controller.disciplines.isEmpty &&
        !widget.controller.isLoading.value;
    if (shouldLoadDisciplines) {
      unawaited(
        widget.controller.loadDisciplines(
          forceRefresh: true,
          preserveResults: true,
        ),
      );
    }
  }

  String? _resolveDefaultLocationLabel(List<String> options) {
    for (final option in options) {
      if (_resolveLocationId(option) == _defaultDirectoryLocationId) {
        final label = option.trim();
        if (label.isNotEmpty) {
          return label;
        }
      }
    }
    return null;
  }

  void _handleLocationSelected(String? value) {
    final label = value?.trim() ?? '';
    if (label.isEmpty) {
      widget.controller.clearLocationSelection();
      return;
    }
    final locationId = _resolveLocationId(label);
    if (locationId == null) {
      widget.controller.clearLocationSelection();
      return;
    }
    widget.controller.selectedLocationId.value = locationId;
    widget.controller.selectedLocationLabel.value = label;
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

    final locationId = widget.controller.selectedLocationId.value;
    if (locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a club before continuing.')),
      );
      return;
    }

    widget.controller.showDisciplineAvailability(
      discipline,
      locationId: locationId,
    );
    widget.onShowAvailability();
  }

  int? _resolveLocationId(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return widget.locationLabelToId[normalized];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locationOptions = widget.locationOptions.toList(growable: false);
      final isLoading = widget.controller.isLoading.value;
      final selectedLocationLabel =
          widget.controller.selectedLocationLabel.value ?? '';

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
              locationOptions: locationOptions,
              selectedLocationLabel: selectedLocationLabel,
              onLocationSelected: _handleLocationSelected,
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
      _controller = Get.put(DisciplinesDirectoryController());
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
    try {
      await _locationController.loadLocations();
    } catch (_) {
      // Keep page usable without location options when API fails.
    }
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

  void _handleReserveBooking(AvailableSlotDto slot) {
    final trainer = slot.trainerName.trim().isEmpty
        ? 'Trainer pending confirmation'
        : slot.trainerName.trim();
    final location = slot.locationName.trim().isEmpty
        ? 'Club pending confirmation'
        : slot.locationName.trim();
    final dateLabel = formatDateTimeLabel(slot.schedulingDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Book a session on $dateLabel with $trainer at $location.',
        ),
        duration: const Duration(seconds: 3),
      ),
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
          icon: Icons.stars_outlined,
        ),
      );
    }
    final locationLabel = _controller.selectedLocationLabel.value?.trim() ?? '';
    if (locationLabel.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Club',
          value: locationLabel,
          icon: Icons.apartment,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Fitness Directory',
              subtitle: 'Disciplines',
              subtitleIcon: Icons.fitness_center,
              onBackButtonPressed: _handleBack,
            ),
            Expanded(
              child: _showAvailability
                  ? _buildAvailabilityView()
                  : Obx(() {
                      final locationData = _resolveLocationOptions();
                      return DisciplinesDirectoryPage(
                        controller: _controller,
                        onShowAvailability: _handleShowAvailability,
                        locationOptions: _locationLabelsFor(locationData),
                        locationLabelToId: _locationLabelToIdFor(locationData),
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }
}
