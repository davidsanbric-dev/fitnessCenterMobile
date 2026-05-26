import 'dart:async';
import 'dart:math' as math;

import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/forms/inline_options_dropdown.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/layout/page_header.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_filters_summary.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/feature.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/available_bookings_by_trainer_table.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/presentation/widgets/trainers_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TrainersDirectoryPage extends StatefulWidget {
  const TrainersDirectoryPage({
    super.key,
    required this.locationOptions,
    required this.locationLabelToId,
  });

  final List<String> locationOptions;
  final Map<String, int> locationLabelToId;

  @override
  State<TrainersDirectoryPage> createState() => _TrainersDirectoryPageState();
}

class _TrainersDirectoryPageState extends State<TrainersDirectoryPage> {
  static const int _defaultDisciplineId = 25;
  static const int _defaultDirectoryLocationId = 3;

  late final TrainersController _controller;
  late final bool _ownsController;
  bool _pendingAutoConsult = false;
  bool _isDisciplineSheetVisible = false;
  late final TextEditingController _disciplineSearchController;
  late final FocusNode _disciplineFocusNode;
  final GlobalKey _disciplineFieldKey = GlobalKey();
  Worker? _selectedFilterWorker;

  @override
  void initState() {
    super.initState();
    _disciplineSearchController = TextEditingController();
    _disciplineFocusNode = FocusNode();
    _disciplineSearchController.addListener(_handleDisciplineSearchChanged);
    _disciplineFocusNode.addListener(_handleDisciplineFocusChanged);
    if (Get.isRegistered<TrainersController>()) {
      _controller = Get.find<TrainersController>();
      _ownsController = false;
    } else {
      _controller = FitnessDirectoryInjector.getTrainersController();
      _ownsController = true;
    }
    _selectedFilterWorker = ever<String?>(
      _controller.selectedTrainersFilter,
      _syncDisciplineInputFromSelection,
    );
    _syncDisciplineInputFromSelection(_controller.selectedTrainersFilter.value);
    _applyDefaultLocationSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.ensureFiltersLoaded();
      if (!mounted) {
        return;
      }
      final hasSelection =
          _controller.selectedTrainersFilter.value?.trim().isNotEmpty ?? false;
      if (hasSelection) {
        _requestAutoConsult();
        return;
      }
      final appliedDefault = _applyDefaultDisciplineSelection();
      if (appliedDefault) {
        _requestAutoConsult();
      }
    });
  }

  @override
  void dispose() {
    _disciplineSearchController.removeListener(_handleDisciplineSearchChanged);
    _disciplineFocusNode.removeListener(_handleDisciplineFocusChanged);
    _selectedFilterWorker?.dispose();
    _disciplineSearchController.dispose();
    _disciplineFocusNode.dispose();
    if (_ownsController) {
      Get.delete<TrainersController>();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TrainersDirectoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final appliedDefault = _applyDefaultLocationSelection();
    if (appliedDefault) {
      _requestAutoConsult();
    }
  }

  void _handleFilterSelected(String? value) {
    final trimmed = value?.trim() ?? '';
    _controller.selectedTrainersFilter.value = trimmed.isEmpty ? null : trimmed;
    if (_disciplineSearchController.text.trim() != trimmed) {
      _disciplineSearchController.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
    }
    _hideDisciplineDropdown();
    _requestAutoConsult();
  }

  void _handleLocationSelected(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      _controller.clearLocationSelection();
      _requestAutoConsult();
      return;
    }
    final locationId = _resolveLocationId(trimmed);
    if (locationId == null) {
      _controller.clearLocationSelection();
      _requestAutoConsult();
      return;
    }
    _controller.selectedLocationId.value = locationId;
    _controller.selectedLocationLabel.value = trimmed;
    _requestAutoConsult();
  }

  void _requestAutoConsult() {
    if (_controller.isLoading.value) {
      _pendingAutoConsult = true;
      return;
    }
    _pendingAutoConsult = false;
    _handleConsultTrainers();
  }

  void _showDisciplineDropdown() {
    if (_isDisciplineSheetVisible) {
      return;
    }
    setState(() {
      _isDisciplineSheetVisible = true;
    });
  }

  void _hideDisciplineDropdown({bool unfocus = true}) {
    if (_isDisciplineSheetVisible) {
      setState(() {
        _isDisciplineSheetVisible = false;
      });
    }
    if (unfocus) {
      FocusScope.of(context).unfocus();
    }
  }

  void _handleConsultTrainers({bool showFeedback = false}) {
    final filterLabel = _controller.selectedTrainersFilter.value?.trim() ?? '';
    if (filterLabel.isEmpty) {
      if (showFeedback) {
        _showSnackBar('Select a valid option before searching.');
      }
      return;
    }

    final locationLabel = _controller.selectedLocationLabel.value?.trim() ?? '';
    if (locationLabel.isEmpty) {
      if (showFeedback) {
        _showSnackBar('Select a club before searching.');
      }
      return;
    }

    final locationId = _resolveLocationId(locationLabel);
    if (locationId == null) {
      if (showFeedback) {
        _showSnackBar('Select a club from the list.');
      }
      return;
    }

    final isValidFilter = _controller.trainerFilterOptions.any(
      (option) => option.toLowerCase() == filterLabel.toLowerCase(),
    );
    if (!isValidFilter) {
      if (showFeedback) {
        _showSnackBar('Select a filter from the list.');
      }
      return;
    }

    if (_controller.selectedLocationId.value != locationId) {
      _controller.selectedLocationId.value = locationId;
    }
    if (_controller.selectedLocationLabel.value != locationLabel) {
      _controller.selectedLocationLabel.value = locationLabel;
    }
    _controller.loadTrainers(
      mode: _controller.trainersMode.value,
      filterLabel: filterLabel,
    );
  }

  void _handleTrainerSelected(Map<String, dynamic> row) {
    _hideDisciplineDropdown();
    final trainer = row['trainer'] as TrainerDirectoryDto?;
    if (trainer == null) {
      _showSnackBar('Could not select the trainer.');
      return;
    }
    final locationId = _controller.selectedLocationId.value;
    if (locationId == null) {
      _showSnackBar('Select a club before continuing.');
      return;
    }
    unawaited(
      _controller.showTrainerAvailability(trainer, locationId: locationId),
    );
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

  void _showSnackBar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  int? _resolveLocationId(String label) {
    final normalized = label.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }
    return widget.locationLabelToId[normalized];
  }

  void _handleDisciplineSearchChanged() {
    if (!mounted) {
      return;
    }
    if (_disciplineFocusNode.hasFocus && !_isDisciplineSheetVisible) {
      _showDisciplineDropdown();
    }
    if (_isDisciplineSheetVisible) {
      setState(() {});
    }

    final typedValue = _disciplineSearchController.text.trim();
    final selectedValue = _controller.selectedTrainersFilter.value?.trim();
    if (typedValue.isEmpty) {
      if (selectedValue?.isNotEmpty ?? false) {
        _controller.selectedTrainersFilter.value = null;
      }
      return;
    }

    if (selectedValue == null || selectedValue.isEmpty) {
      return;
    }

    if (selectedValue.toLowerCase() != typedValue.toLowerCase()) {
      _controller.selectedTrainersFilter.value = null;
    }
  }

  void _handleDisciplineFocusChanged() {
    if (!mounted) {
      return;
    }
    if (_disciplineFocusNode.hasFocus) {
      _showDisciplineDropdown();
      return;
    }
    _hideDisciplineDropdown(unfocus: false);
  }

  void _syncDisciplineInputFromSelection(String? value) {
    if (!mounted || _disciplineFocusNode.hasFocus) {
      return;
    }

    final normalizedValue = value?.trim() ?? '';
    if (_disciplineSearchController.text.trim() == normalizedValue) {
      return;
    }

    _disciplineSearchController.value = TextEditingValue(
      text: normalizedValue,
      selection: TextSelection.collapsed(offset: normalizedValue.length),
    );
  }

  bool _applyDefaultLocationSelection() {
    final existing = _controller.selectedLocationLabel.value?.trim();
    if (existing != null && existing.isNotEmpty) {
      final existingId = _resolveLocationId(existing);
      if (existingId != null && existingId > 0) {
        if (_controller.selectedLocationId.value != existingId) {
          _controller.selectedLocationId.value = existingId;
          return true;
        }
        return false;
      }
    }
    final label = _resolveDefaultLocationLabel();
    if (label == null) {
      return false;
    }

    final locationId = _resolveLocationId(label);
    if (locationId != null) {
      _controller.selectedLocationId.value = locationId;
      _controller.selectedLocationLabel.value = label;
      return true;
    }
    return false;
  }

  bool _applyDefaultDisciplineSelection() {
    final existing = _controller.selectedTrainersFilter.value?.trim() ?? '';
    if (existing.isNotEmpty) {
      return false;
    }
    if (_controller.trainerFilterOptions.isEmpty ||
        _controller.disciplines.isEmpty) {
      return false;
    }
    final label = _resolveDefaultDisciplineLabel();
    if (label == null) {
      return false;
    }
    _controller.selectedTrainersFilter.value = label;
    return true;
  }

  String? _resolveDefaultLocationLabel() {
    final preferredLocationId =
        _controller.locationId ?? _defaultDirectoryLocationId;
    for (final option in widget.locationOptions) {
      if (_resolveLocationId(option) == preferredLocationId) {
        final label = option.trim();
        if (label.isNotEmpty) {
          return label;
        }
      }
    }
    for (final option in widget.locationOptions) {
      final label = option.trim();
      if (label.isNotEmpty) {
        return label;
      }
    }
    return null;
  }

  String? _resolveDefaultDisciplineLabel() {
    for (final discipline in _controller.disciplines) {
      if (discipline.disciplineId == _defaultDisciplineId) {
        final label = discipline.disciplineName.trim();
        if (label.isNotEmpty) {
          return label;
        }
      }
    }
    return null;
  }

  List<TableFiltersSummaryItemData>? _buildTrainerAvailabilitySummary(
    TrainerDirectoryDto? trainer,
  ) {
    if (trainer == null) {
      return null;
    }
    final items = <TableFiltersSummaryItemData>[];
    final trainerName = trainer.trainerName.trim();
    if (trainerName.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Trainer',
          value: trainerName,
          icon: LucideIcons.user,
        ),
      );
    }
    final discipline = trainer.disciplineName.trim();
    if (discipline.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Discipline',
          value: discipline,
          icon: LucideIcons.star,
        ),
      );
    }
    final membership = trainer.membershipName.trim();
    if (membership.isNotEmpty) {
      items.add(
        TableFiltersSummaryItemData(
          label: 'Membership plan',
          value: membership,
          icon: LucideIcons.creditCard,
        ),
      );
    }
    final locationLabel = _controller.selectedLocationLabel.value?.trim() ?? '';
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stage = _controller.stage.value;
      final isLoading = _controller.isLoading.value;
      final errorMessage = _controller.error.value;
      final trainers = _controller.trainersTableRows;
      final mode = _controller.trainersMode.value;
      final disciplineOptions = _controller.trainerFilterOptions.toList(
        growable: false,
      );
      final selectedFilterLabel = _controller.selectedTrainersFilter.value;
      final selectedLocationLabel = _controller.selectedLocationLabel.value;
      final availabilityRows = _controller.trainerAvailabilityRows;
      final availabilityLoading =
          _controller.isTrainerAvailabilityLoading.value;
      final availabilityError = _controller.trainerAvailabilityError.value;
      final selectedTrainer = _controller.selectedTrainer.value;

      if (stage == TrainersViewStage.availability) {
        return _buildAvailabilityView(
          bookings: availabilityRows,
          isLoading: availabilityLoading,
          errorMessage: availabilityError,
          selectedTrainer: selectedTrainer,
        );
      }
      if (_pendingAutoConsult && !isLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _controller.isLoading.value) {
            return;
          }
          if (_pendingAutoConsult) {
            _pendingAutoConsult = false;
            _handleConsultTrainers();
          }
        });
      }
      return _buildTrainersView(
        stage: stage,
        trainers: trainers,
        mode: mode,
        isLoading: isLoading,
        errorMessage: errorMessage,
        disciplineOptions: disciplineOptions,
        selectedFilterLabel: selectedFilterLabel,
        selectedLocationLabel: selectedLocationLabel,
      );
    });
  }

  Widget _buildTrainersView({
    required TrainersViewStage stage,
    required List<Map<String, dynamic>> trainers,
    required TrainersSearchMode mode,
    required bool isLoading,
    required String? errorMessage,
    required List<String> disciplineOptions,
    required String? selectedFilterLabel,
    required String? selectedLocationLabel,
  }) {
    final locationOptions = widget.locationOptions.toList(growable: false);
    final emptyLabel = stage == TrainersViewStage.filters
        ? 'Select filters to search.'
        : 'No trainers available.';
    final showDisciplineSheet = _isDisciplineSheetVisible;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dropdownLayout = _resolveDisciplineDropdownLayout(
          context,
          constraints,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            TrainersTable(
              trainers: trainers,
              mode: mode,
              isLoading: isLoading,
              errorMessage: errorMessage,
              onTrainerSelected: _handleTrainerSelected,
              pageNumber: _controller.trainersPageNumber.value,
              pageSize: _controller.trainersPageSize.value,
              totalItems: _controller.trainersTotalItems.value,
              onPageChanged: _controller.setTrainersPageNumber,
              showPagination: stage == TrainersViewStage.results,
              disciplineOptions: disciplineOptions,
              selectedDisciplineLabel: selectedFilterLabel,
              onDisciplineSelected: _handleFilterSelected,
              onDisciplineTap: _showDisciplineDropdown,
              disciplineSearchController: _disciplineSearchController,
              disciplineFocusNode: _disciplineFocusNode,
              disciplineFieldKey: _disciplineFieldKey,
              locationOptions: locationOptions,
              selectedLocationLabel: selectedLocationLabel,
              onLocationSelected: _handleLocationSelected,
              emptyLabel: emptyLabel,
            ),
            if (showDisciplineSheet)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _hideDisciplineDropdown,
                ),
              ),
            Positioned(
              left: dropdownLayout.offset.dx,
              top: dropdownLayout.offset.dy,
              width: dropdownLayout.width,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                reverseDuration: const Duration(milliseconds: 180),
                child: showDisciplineSheet
                    ? InlineOptionsDropdown(
                        key: const ValueKey('discipline_inline_dropdown'),
                        title: 'Discipline',
                        options: disciplineOptions,
                        onOptionSelected: _handleFilterSelected,
                        filterText: _disciplineSearchController.text,
                        maxHeight: dropdownLayout.maxHeight,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }

  _DisciplineDropdownLayout _resolveDisciplineDropdownLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final stackBox = context.findRenderObject();
    final fieldBox = _renderBoxForKey(_disciplineFieldKey);

    Offset dropdownOffset = const Offset(16, 0);
    double dropdownWidth = constraints.maxWidth - 32;
    double maxDropdownHeight = 280;

    if (stackBox is RenderBox && fieldBox != null) {
      final fieldTopLeft = fieldBox.localToGlobal(
        Offset.zero,
        ancestor: stackBox,
      );
      final dropdownTop = fieldTopLeft.dy + fieldBox.size.height + 8;
      dropdownOffset = Offset(fieldTopLeft.dx, dropdownTop);
      dropdownWidth = fieldBox.size.width;
      final availableHeight = constraints.maxHeight - dropdownTop;
      maxDropdownHeight = math.min(
        280,
        MediaQuery.of(context).size.height * 0.35,
      );
      if (availableHeight > 0) {
        maxDropdownHeight = math.min(maxDropdownHeight, availableHeight);
      }
    }

    return _DisciplineDropdownLayout(
      offset: dropdownOffset,
      width: dropdownWidth,
      maxHeight: maxDropdownHeight,
    );
  }

  RenderBox? _renderBoxForKey(GlobalKey key) {
    final context = key.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      return renderObject;
    }
    return null;
  }

  Widget _buildAvailabilityView({
    required List<Map<String, dynamic>> bookings,
    required bool isLoading,
    required String? errorMessage,
    required TrainerDirectoryDto? selectedTrainer,
  }) {
    final summary = _buildTrainerAvailabilitySummary(selectedTrainer);

    return AvailableBookingsByTrainerTable(
      bookings: bookings,
      isLoading: isLoading,
      errorMessage: errorMessage,
      filterSummary: summary,
      onReserveBooking: _handleReserveBooking,
      pageNumber: _controller.trainerAvailabilityPageNumber.value,
      pageSize: _controller.trainerAvailabilityPageSize.value,
      totalItems: _controller.trainerAvailabilityTotalItems.value,
      onPageChanged: _controller.setTrainerAvailabilityPageNumber,
      showPagination: true,
    );
  }
}

class _DisciplineDropdownLayout {
  const _DisciplineDropdownLayout({
    required this.offset,
    required this.width,
    required this.maxHeight,
  });

  final Offset offset;
  final double width;
  final double maxHeight;
}

class TrainersDirectoryStandalonePage extends StatefulWidget {
  const TrainersDirectoryStandalonePage({super.key});

  @override
  State<TrainersDirectoryStandalonePage> createState() =>
      _TrainersDirectoryStandalonePageState();
}

class _TrainersDirectoryStandalonePageState
    extends State<TrainersDirectoryStandalonePage> {
  late final LocationController _locationController;
  late final bool _ownsLocationController;

  @override
  void initState() {
    super.initState();
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

  void _handleBack() {
    if (Get.isRegistered<TrainersController>()) {
      final controller = Get.find<TrainersController>();
      if (controller.stage.value == TrainersViewStage.availability) {
        controller.backToResults();
        return;
      }
    }
    Get.back();
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
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              title: 'Fitness Directory',
              subtitle: 'Trainers',
              subtitleIcon: LucideIcons.user,
              onBackButtonPressed: _handleBack,
            ),
            Expanded(
              child: Obx(() {
                final locationData = _resolveLocationOptions();
                return TrainersDirectoryPage(
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
