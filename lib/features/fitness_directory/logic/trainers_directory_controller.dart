import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:get/get.dart';

class TrainersController extends ControllerBase {
  TrainersController({this.locationId, TrainersDirectoryRepository? repository})
    : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  final int? locationId;
  static const int _defaultPageSize = 6;
  final TrainersDirectoryRepository _repository;
  int _trainersLoadSequence = 0;
  int _trainerAvailabilitySequence = 0;
  String? _loadedTrainersFilter;
  int? _loadedTrainersLocationId;

  final stage = TrainersViewStage.filters.obs;
  final trainersMode = TrainersSearchMode.discipline.obs;
  final trainerFilterOptions = <String>[].obs;
  final selectedTrainersFilter = RxnString();
  final selectedLocationId = RxnInt();
  final selectedLocationLabel = RxnString();

  final disciplines = <DisciplineDto>[].obs;
  final memberships = <MembershipDto>[].obs;
  final trainers = <TrainerDirectoryDto>[].obs;
  final selectedTrainer = Rxn<TrainerDirectoryDto>();
  final RxList<AvailableSlotDto> availableByTrainer = <AvailableSlotDto>[].obs;
  final isTrainerAvailabilityLoading = false.obs;
  final trainerAvailabilityError = RxnString();
  final trainersPageNumber = 1.obs;
  final trainersPageSize = _defaultPageSize.obs;
  final trainersTotalItems = 0.obs;
  final trainerAvailabilityPageNumber = 1.obs;
  final trainerAvailabilityPageSize = _defaultPageSize.obs;
  final trainerAvailabilityTotalItems = 0.obs;

  List<Map<String, dynamic>> get trainersTableRows {
    final rows = trainers
        .map((trainer) => trainer.toTableRow())
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: trainersPageNumber.value,
      pageSize: trainersPageSize.value,
      defaultPageSize: _defaultPageSize,
    );
  }

  List<Map<String, dynamic>> get trainerAvailabilityRows {
    final rows = availableByTrainer
        .map((slot) => slot.toTrainerAvailabilityRow())
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: trainerAvailabilityPageNumber.value,
      pageSize: trainerAvailabilityPageSize.value,
      defaultPageSize: _defaultPageSize,
    );
  }

  Future<void> ensureFiltersLoaded() async {
    if (trainerFilterOptions.isNotEmpty || isLoading.value) return;

    await loadTrainersFilters(mode: trainersMode.value);
  }

  Future<void> loadTrainersFilters({
    TrainersSearchMode? mode,
    bool forceRefresh = false,
  }) async {
    final targetMode = mode ?? trainersMode.value;
    final modeChanged = targetMode != trainersMode.value;
    final selectionSnapshot = selectedTrainersFilter.value;
    trainersMode.value = targetMode;
    stage.value = TrainersViewStage.filters;
    resetTrainerAvailability();
    if (modeChanged) {
      trainerFilterOptions.clear();
      selectedTrainersFilter.value = null;
    }
    if (!forceRefresh &&
        !modeChanged &&
        trainerFilterOptions.isNotEmpty &&
        error.value == null) {
      _syncTrainersPagination();
      return;
    }

    isLoading.value = true;
    error.value = null;
    trainers.clear();
    _syncTrainersPagination();
    _loadedTrainersFilter = null;
    _loadedTrainersLocationId = null;

    try {
      final filters = await _repository.fetchTrainersFilterData(
        mode: targetMode,
      );
      disciplines.assignAll(filters.disciplines);
      memberships.assignAll(filters.memberships);
      trainerFilterOptions.assignAll(filters.options);
    } on ApiException catch (apiError) {
      error.value = apiError.message;
      trainerFilterOptions.clear();
      selectedTrainersFilter.value = null;
    } catch (err) {
      error.value = 'Unexpected error while loading filters: $err';
      trainerFilterOptions.clear();
      selectedTrainersFilter.value = null;
    } finally {
      isLoading.value = false;
    }

    if (error.value == null &&
        !modeChanged &&
        selectionSnapshot == selectedTrainersFilter.value) {
      _syncSelectedFilterWithOptions(selectionSnapshot);
    }
  }

  Future<void> loadTrainers({
    required TrainersSearchMode mode,
    required String filterLabel,
    bool forceRefresh = false,
  }) async {
    final normalized = filterLabel.trim();
    final resolvedLocationId = selectedLocationId.value ?? locationId;
    if (resolvedLocationId == null || resolvedLocationId <= 0) {
      error.value = 'Select a valid club.';
      trainers.clear();
      _syncTrainersPagination();
      _loadedTrainersFilter = null;
      _loadedTrainersLocationId = null;
      stage.value = TrainersViewStage.filters;
      return;
    }
    final activeLocationId = resolvedLocationId;
    if (normalized.isEmpty) {
      error.value = 'Select a valid filter.';
      trainers.clear();
      _syncTrainersPagination();
      _loadedTrainersFilter = null;
      _loadedTrainersLocationId = null;
      stage.value = TrainersViewStage.filters;
      return;
    }

    final isSameFilter =
        !forceRefresh &&
        trainers.isNotEmpty &&
        _loadedTrainersFilter == normalized &&
        _loadedTrainersLocationId == activeLocationId &&
        trainersMode.value == mode &&
        error.value == null;
    if (isSameFilter) {
      stage.value = TrainersViewStage.results;
      return;
    }

    resetTrainerAvailability();
    trainersPageNumber.value = 1;
    isLoading.value = true;
    error.value = null;
    trainersMode.value = mode;
    final currentSelection = selectedTrainersFilter.value?.trim();
    if (currentSelection == null ||
        currentSelection.isEmpty ||
        currentSelection.toLowerCase() == normalized.toLowerCase()) {
      selectedTrainersFilter.value = normalized;
    }

    await runLatestLoadOperation<List<TrainerDirectoryDto>>(
      isLoading: isLoading,
      error: error,
      loader: () async {
        if (mode == TrainersSearchMode.discipline) {
          return _repository.fetchTrainersByDiscipline(
            filterLabel: filterLabel,
            locationId: activeLocationId,
            disciplines: disciplines,
          );
        }
        return _repository.fetchTrainersByMembership(
          filterLabel: filterLabel,
          locationId: activeLocationId,
          memberships: memberships,
        );
      },
      onSuccess: (mapped) {
        trainers.assignAll(mapped);
        _syncTrainersPagination();
        _loadedTrainersFilter = normalized;
        _loadedTrainersLocationId = activeLocationId;
        stage.value = TrainersViewStage.results;
      },
      onError: () {
        trainers.clear();
        _syncTrainersPagination();
        _loadedTrainersFilter = null;
        _loadedTrainersLocationId = null;
        stage.value = TrainersViewStage.results;
      },
      unexpectedErrorMessage: 'Unexpected error while loading trainers',
      startSequence: () => ++_trainersLoadSequence,
      shouldApplyResult: (sequence) => sequence == _trainersLoadSequence,
    );
  }

  Future<void> refreshTrainers() async {
    final filter = selectedTrainersFilter.value;
    if (filter == null || filter.isEmpty) {
      await loadTrainersFilters(mode: trainersMode.value, forceRefresh: true);
      return;
    }
    await loadTrainers(
      mode: trainersMode.value,
      filterLabel: filter,
      forceRefresh: true,
    );
  }

  void backToFilters() {
    error.value = null;
    trainers.clear();
    _syncTrainersPagination();
    _loadedTrainersFilter = null;
    _loadedTrainersLocationId = null;
    selectedTrainersFilter.value = null;
    clearLocationSelection();
    resetTrainerAvailability();
    stage.value = TrainersViewStage.filters;
  }

  Future<void> showTrainerAvailability(
    TrainerDirectoryDto trainer, {
    int? locationId,
  }) async {
    selectedTrainer.value = trainer;
    trainerAvailabilityError.value = null;
    isTrainerAvailabilityLoading.value = false;
    availableByTrainer.clear();
    trainerAvailabilityPageNumber.value = 1;
    _syncTrainerAvailabilityPagination();
    stage.value = TrainersViewStage.availability;

    final trainerId = trainer.trainerId.trim();
    if (trainerId.isEmpty) {
      _trainerAvailabilitySequence++;
      trainerAvailabilityError.value = 'Could not determine the trainer.';
      return;
    }

    final disciplineId = trainer.disciplineId;
    if (disciplineId == 0) {
      _trainerAvailabilitySequence++;
      trainerAvailabilityError.value =
          'Could not determine the trainer discipline.';
      return;
    }

    final resolvedLocationId = locationId ?? this.locationId;
    if (resolvedLocationId == null || resolvedLocationId <= 0) {
      _trainerAvailabilitySequence++;
      trainerAvailabilityError.value = 'Could not determine the club.';
      return;
    }
    final activeLocationId = resolvedLocationId;

    await runLatestLoadOperation<List<AvailableSlotDto>>(
      isLoading: isTrainerAvailabilityLoading,
      error: trainerAvailabilityError,
      loader: () => _repository.fetchTrainerAvailability(
        trainerId: trainerId,
        disciplineId: disciplineId,
        locationId: activeLocationId,
      ),
      onSuccess: (items) {
        availableByTrainer.assignAll(items);
        _syncTrainerAvailabilityPagination();
      },
      onError: () {
        availableByTrainer.clear();
        _syncTrainerAvailabilityPagination();
      },
      unexpectedErrorMessage: 'Could not load trainer time slots',
      startSequence: () => ++_trainerAvailabilitySequence,
      shouldApplyResult: (sequence) => sequence == _trainerAvailabilitySequence,
    );
  }

  void backToResults() {
    resetTrainerAvailability();
    stage.value = TrainersViewStage.results;
  }

  void resetTrainerAvailability() {
    _trainerAvailabilitySequence++;
    trainerAvailabilityError.value = null;
    isTrainerAvailabilityLoading.value = false;
    availableByTrainer.clear();
    selectedTrainer.value = null;
    trainerAvailabilityPageNumber.value = 1;
    trainerAvailabilityPageSize.value = _defaultPageSize;
    _syncTrainerAvailabilityPagination();
  }

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableByTrainer.remove(slot);
    _syncTrainerAvailabilityPagination();
  }

  void clearLocationSelection() {
    selectedLocationId.value = null;
    selectedLocationLabel.value = null;
  }

  void setTrainersPageNumber(int value) => setTablePageNumber(
    pageNumber: trainersPageNumber,
    value: value,
    syncPagination: _syncTrainersPagination,
  );

  void setTrainersPageSize(int value) => setTablePageSize(
    pageNumber: trainersPageNumber,
    pageSize: trainersPageSize,
    value: value,
    syncPagination: _syncTrainersPagination,
  );

  void setTrainerAvailabilityPageNumber(int value) => setTablePageNumber(
    pageNumber: trainerAvailabilityPageNumber,
    value: value,
    syncPagination: _syncTrainerAvailabilityPagination,
  );

  void setTrainerAvailabilityPageSize(int value) => setTablePageSize(
    pageNumber: trainerAvailabilityPageNumber,
    pageSize: trainerAvailabilityPageSize,
    value: value,
    syncPagination: _syncTrainerAvailabilityPagination,
  );

  void resetToInitialState() {
    isLoading.value = false;
    error.value = null;
    stage.value = TrainersViewStage.filters;
    trainersMode.value = TrainersSearchMode.discipline;
    trainerFilterOptions.clear();
    _loadedTrainersFilter = null;
    _loadedTrainersLocationId = null;
    selectedTrainersFilter.value = null;
    clearLocationSelection();
    disciplines.clear();
    memberships.clear();
    trainers.clear();
    trainersPageNumber.value = 1;
    trainersPageSize.value = _defaultPageSize;
    _syncTrainersPagination();
    resetTrainerAvailability();
  }

  void _syncSelectedFilterWithOptions(String? selection) {
    final trimmed = selection?.trim() ?? '';
    if (trimmed.isEmpty) {
      selectedTrainersFilter.value = null;
      return;
    }
    final normalized = trimmed.toLowerCase();
    final hasMatch = trainerFilterOptions.any(
      (option) => option.trim().toLowerCase() == normalized,
    );
    selectedTrainersFilter.value = hasMatch ? trimmed : null;
  }

  void _syncTrainersPagination() {
    syncTablePaginationState(
      totalItems: trainers.length,
      pageNumber: trainersPageNumber,
      pageSize: trainersPageSize,
      defaultPageSize: _defaultPageSize,
      onTotalItemsResolved: (value) => trainersTotalItems.value = value,
    );
  }

  void _syncTrainerAvailabilityPagination() {
    syncTablePaginationState(
      totalItems: availableByTrainer.length,
      pageNumber: trainerAvailabilityPageNumber,
      pageSize: trainerAvailabilityPageSize,
      defaultPageSize: _defaultPageSize,
      onTotalItemsResolved: (value) =>
          trainerAvailabilityTotalItems.value = value,
    );
  }
}
