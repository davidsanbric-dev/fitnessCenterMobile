import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';

class TrainersViewModel extends ViewModelBase {
  TrainersViewModel({required TrainersDirectoryRepository repository})
    : _repository = repository;

  static const int _defaultPageSize = 6;
  // Sentinel "filter" key for the no-discipline listing, so the load-cache
  // guard in [loadAllTrainers] can tell an all-trainers result apart from a
  // discipline/membership filtered one.
  static const String _allTrainersFilterKey = '__all_trainers__';
  final TrainersDirectoryRepository _repository;
  int _trainersLoadSequence = 0;
  int _trainerAvailabilitySequence = 0;
  String? _loadedTrainersFilter;

  bool isLoading = false;
  String? error;
  TrainersViewStage stage = TrainersViewStage.filters;
  TrainersSearchMode trainersMode = TrainersSearchMode.discipline;
  final List<String> trainerFilterOptions = <String>[];
  String? selectedTrainersFilter;

  final List<DisciplineDto> disciplines = <DisciplineDto>[];
  final List<MembershipDto> memberships = <MembershipDto>[];
  final List<TrainerDirectoryDto> trainers = <TrainerDirectoryDto>[];
  TrainerDirectoryDto? selectedTrainer;
  final List<AvailableSlotDto> availableByTrainer = <AvailableSlotDto>[];
  bool isTrainerAvailabilityLoading = false;
  String? trainerAvailabilityError;
  int trainersPageNumber = 1;
  int trainersPageSize = _defaultPageSize;
  int trainersTotalItems = 0;
  int trainerAvailabilityPageNumber = 1;
  int trainerAvailabilityPageSize = _defaultPageSize;
  int trainerAvailabilityTotalItems = 0;

  List<Map<String, dynamic>> get trainersTableRows {
    final rows = trainers
        .map((trainer) => trainer.toTableRow())
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: trainersPageNumber,
      pageSize: trainersPageSize,
      defaultPageSize: _defaultPageSize,
    );
  }

  List<Map<String, dynamic>> get trainerAvailabilityRows {
    final rows = availableByTrainer
        .map((slot) => slot.toTrainerAvailabilityRow())
        .toList(growable: false);
    return sliceTablePage(
      rows,
      pageNumber: trainerAvailabilityPageNumber,
      pageSize: trainerAvailabilityPageSize,
      defaultPageSize: _defaultPageSize,
    );
  }

  Future<void> ensureFiltersLoaded() async {
    if (trainerFilterOptions.isNotEmpty || isLoading) return;

    await loadTrainersFilters(mode: trainersMode);
  }

  Future<void> loadTrainersFilters({
    TrainersSearchMode? mode,
    bool forceRefresh = false,
  }) async {
    final targetMode = mode ?? trainersMode;
    final modeChanged = targetMode != trainersMode;
    final selectionSnapshot = selectedTrainersFilter;
    trainersMode = targetMode;
    stage = TrainersViewStage.filters;
    resetTrainerAvailability();
    if (modeChanged) {
      trainerFilterOptions.clear();
      selectedTrainersFilter = null;
    }
    if (!forceRefresh &&
        !modeChanged &&
        trainerFilterOptions.isNotEmpty &&
        error == null) {
      _syncTrainersPagination();
      return;
    }

    isLoading = true;
    error = null;
    trainers.clear();
    _syncTrainersPagination();
    _loadedTrainersFilter = null;

    try {
      final filters = await _repository.fetchTrainersFilterData(
        mode: targetMode,
      );
      disciplines
        ..clear()
        ..addAll(filters.disciplines);
      memberships
        ..clear()
        ..addAll(filters.memberships);
      trainerFilterOptions
        ..clear()
        ..addAll(filters.options);
    } on ApiException catch (apiError) {
      error = apiError.message;
      trainerFilterOptions.clear();
      selectedTrainersFilter = null;
    } catch (err) {
      error = 'Unexpected error while loading filters: $err';
      trainerFilterOptions.clear();
      selectedTrainersFilter = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }

    if (error == null &&
        !modeChanged &&
        selectionSnapshot == selectedTrainersFilter) {
      _syncSelectedFilterWithOptions(selectionSnapshot);
    }
  }

  Future<void> loadTrainers({
    required TrainersSearchMode mode,
    required String filterLabel,
    bool forceRefresh = false,
  }) async {
    final normalized = filterLabel.trim();
    if (normalized.isEmpty) {
      error = 'Select a valid filter.';
      trainers.clear();
      _syncTrainersPagination();
      _loadedTrainersFilter = null;
      stage = TrainersViewStage.filters;
      notifyListeners();
      return;
    }

    final isSameFilter =
        !forceRefresh &&
        trainers.isNotEmpty &&
        _loadedTrainersFilter == normalized &&
        trainersMode == mode &&
        error == null;
    if (isSameFilter) {
      stage = TrainersViewStage.results;
      notifyListeners();
      return;
    }

    resetTrainerAvailability();
    trainersPageNumber = 1;
    isLoading = true;
    error = null;
    trainersMode = mode;
    final currentSelection = selectedTrainersFilter?.trim();
    if (currentSelection == null ||
        currentSelection.isEmpty ||
        currentSelection.toLowerCase() == normalized.toLowerCase()) {
      selectedTrainersFilter = normalized;
    }
    notifyListeners();

    await runLatestLoadOperation<List<TrainerDirectoryDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () async {
        if (mode == TrainersSearchMode.discipline) {
          return _repository.fetchTrainersByDiscipline(
            filterLabel: filterLabel,
            disciplines: disciplines,
          );
        }
        return _repository.fetchTrainersByMembership(
          filterLabel: filterLabel,
          memberships: memberships,
        );
      },
      onSuccess: (mapped) {
        trainers
          ..clear()
          ..addAll(mapped);
        _syncTrainersPagination();
        _loadedTrainersFilter = normalized;
        stage = TrainersViewStage.results;
      },
      onError: () {
        trainers.clear();
        _syncTrainersPagination();
        _loadedTrainersFilter = null;
        stage = TrainersViewStage.results;
      },
      unexpectedErrorMessage: 'Unexpected error while loading trainers',
      startSequence: () => ++_trainersLoadSequence,
      shouldApplyResult: (sequence) => sequence == _trainersLoadSequence,
    );
  }

  // Loads every active trainer across all clubs, with no discipline or club
  // filter. The discipline and club shown per row come from the API response.
  Future<void> loadAllTrainers({bool forceRefresh = false}) async {
    final isSameFilter =
        !forceRefresh &&
        trainers.isNotEmpty &&
        _loadedTrainersFilter == _allTrainersFilterKey &&
        error == null;
    if (isSameFilter) {
      stage = TrainersViewStage.results;
      notifyListeners();
      return;
    }

    resetTrainerAvailability();
    trainersPageNumber = 1;
    isLoading = true;
    error = null;
    notifyListeners();

    await runLatestLoadOperation<List<TrainerDirectoryDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () => _repository.fetchAllTrainers(),
      onSuccess: (mapped) {
        trainers
          ..clear()
          ..addAll(mapped);
        _syncTrainersPagination();
        _loadedTrainersFilter = _allTrainersFilterKey;
        stage = TrainersViewStage.results;
      },
      onError: () {
        trainers.clear();
        _syncTrainersPagination();
        _loadedTrainersFilter = null;
        stage = TrainersViewStage.results;
      },
      unexpectedErrorMessage: 'Unexpected error while loading trainers',
      startSequence: () => ++_trainersLoadSequence,
      shouldApplyResult: (sequence) => sequence == _trainersLoadSequence,
    );
  }

  Future<void> refreshTrainers() async {
    await loadAllTrainers(forceRefresh: true);
  }

  void backToFilters() {
    error = null;
    trainers.clear();
    _syncTrainersPagination();
    _loadedTrainersFilter = null;
    selectedTrainersFilter = null;
    resetTrainerAvailability();
    stage = TrainersViewStage.filters;
    notifyListeners();
  }

  Future<void> showTrainerAvailability(TrainerDirectoryDto trainer) async {
    selectedTrainer = trainer;
    trainerAvailabilityError = null;
    isTrainerAvailabilityLoading = false;
    availableByTrainer.clear();
    trainerAvailabilityPageNumber = 1;
    _syncTrainerAvailabilityPagination();
    stage = TrainersViewStage.availability;
    notifyListeners();

    final trainerId = trainer.trainerId.trim();
    if (trainerId.isEmpty) {
      _trainerAvailabilitySequence++;
      trainerAvailabilityError = 'Could not determine the trainer.';
      notifyListeners();
      return;
    }

    final disciplineId = trainer.disciplineId;
    if (disciplineId == 0) {
      _trainerAvailabilitySequence++;
      trainerAvailabilityError = 'Could not determine the trainer discipline.';
      notifyListeners();
      return;
    }

    await runLatestLoadOperation<List<AvailableSlotDto>>(
      setLoading: (value) => isTrainerAvailabilityLoading = value,
      setError: (message) => trainerAvailabilityError = message,
      loader: () => _repository.fetchTrainerAvailability(
        trainerId: trainerId,
        disciplineId: disciplineId,
      ),
      onSuccess: (items) {
        availableByTrainer
          ..clear()
          ..addAll(items);
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
    stage = TrainersViewStage.results;
    notifyListeners();
  }

  void resetTrainerAvailability() {
    _trainerAvailabilitySequence++;
    trainerAvailabilityError = null;
    isTrainerAvailabilityLoading = false;
    availableByTrainer.clear();
    selectedTrainer = null;
    trainerAvailabilityPageNumber = 1;
    trainerAvailabilityPageSize = _defaultPageSize;
    _syncTrainerAvailabilityPagination();
  }

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableByTrainer.remove(slot);
    _syncTrainerAvailabilityPagination();
  }

  void setTrainersPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: trainersPageNumber,
    value: value,
    setPageNumber: (v) => trainersPageNumber = v,
    syncPagination: _syncTrainersPagination,
  );

  void setTrainersPageSize(int value) => applyTablePageSize(
    currentPageSize: trainersPageSize,
    value: value,
    setPageNumber: (v) => trainersPageNumber = v,
    setPageSize: (v) => trainersPageSize = v,
    syncPagination: _syncTrainersPagination,
  );

  void setTrainerAvailabilityPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: trainerAvailabilityPageNumber,
    value: value,
    setPageNumber: (v) => trainerAvailabilityPageNumber = v,
    syncPagination: _syncTrainerAvailabilityPagination,
  );

  void setTrainerAvailabilityPageSize(int value) => applyTablePageSize(
    currentPageSize: trainerAvailabilityPageSize,
    value: value,
    setPageNumber: (v) => trainerAvailabilityPageNumber = v,
    setPageSize: (v) => trainerAvailabilityPageSize = v,
    syncPagination: _syncTrainerAvailabilityPagination,
  );

  void resetToInitialState() {
    isLoading = false;
    error = null;
    stage = TrainersViewStage.filters;
    trainersMode = TrainersSearchMode.discipline;
    trainerFilterOptions.clear();
    _loadedTrainersFilter = null;
    selectedTrainersFilter = null;
    disciplines.clear();
    memberships.clear();
    trainers.clear();
    trainersPageNumber = 1;
    trainersPageSize = _defaultPageSize;
    _syncTrainersPagination();
    resetTrainerAvailability();
    notifyListeners();
  }

  void _syncSelectedFilterWithOptions(String? selection) {
    final trimmed = selection?.trim() ?? '';
    if (trimmed.isEmpty) {
      selectedTrainersFilter = null;
      return;
    }
    final normalized = trimmed.toLowerCase();
    final hasMatch = trainerFilterOptions.any(
      (option) => option.trim().toLowerCase() == normalized,
    );
    selectedTrainersFilter = hasMatch ? trimmed : null;
  }

  void _syncTrainersPagination() {
    syncTablePaginationValues(
      totalItems: trainers.length,
      pageNumber: trainersPageNumber,
      pageSize: trainersPageSize,
      defaultPageSize: _defaultPageSize,
      setPageNumber: (v) => trainersPageNumber = v,
      setPageSize: (v) => trainersPageSize = v,
      onTotalItemsResolved: (value) => trainersTotalItems = value,
    );
    notifyListeners();
  }

  void _syncTrainerAvailabilityPagination() {
    syncTablePaginationValues(
      totalItems: availableByTrainer.length,
      pageNumber: trainerAvailabilityPageNumber,
      pageSize: trainerAvailabilityPageSize,
      defaultPageSize: _defaultPageSize,
      setPageNumber: (v) => trainerAvailabilityPageNumber = v,
      setPageSize: (v) => trainerAvailabilityPageSize = v,
      onTotalItemsResolved: (value) => trainerAvailabilityTotalItems = value,
    );
    notifyListeners();
  }
}
