import 'package:fitnesscenter_mobile/app/core/api/shared/types.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';

class DisciplinesDirectoryViewModel extends ViewModelBase {
  DisciplinesDirectoryViewModel({
    required DisciplinesDirectoryRepository repository,
  }) : _repository = repository;

  static const int _defaultPageSize = 6;
  final DisciplinesDirectoryRepository _repository;
  int _disciplineAvailabilitySequence = 0;

  final List<DisciplineDto> disciplines = <DisciplineDto>[];
  final List<DisciplineDto> _allDisciplines = <DisciplineDto>[];
  bool isLoading = false;
  String? error;
  int pageNumber = 1;
  int pageSize = _defaultPageSize;
  int? totalItems;
  bool isServerPaginated = false;
  bool showDisciplinesResults = false;
  final List<AvailableSlotDto> availableByDiscipline = <AvailableSlotDto>[];
  bool isDisciplineAvailabilityLoading = false;
  String? disciplineAvailabilityError;
  DisciplineDto? selectedDiscipline;
  int disciplineAvailabilityPageNumber = 1;
  int disciplineAvailabilityPageSize = _defaultPageSize;
  int disciplineAvailabilityTotalItems = 0;

  List<Map<String, dynamic>> get disciplinesRows =>
      disciplines.map((item) => item.toTableRow()).toList(growable: false);

  List<Map<String, dynamic>> get disciplineAvailabilityRows => sliceTablePage(
    availableByDiscipline
        .map((slot) => slot.toDisciplineAvailabilityRow())
        .toList(growable: false),
    pageNumber: disciplineAvailabilityPageNumber,
    pageSize: disciplineAvailabilityPageSize,
    defaultPageSize: _defaultPageSize,
  );

  Future<void> loadDisciplines({
    bool forceRefresh = false,
    bool preserveResults = false,
  }) async {
    if (!preserveResults) {
      showDisciplinesResults = false;
    }
    if (!forceRefresh && disciplines.isNotEmpty && error == null) {
      return;
    }

    await runLoad<PaginatedResult<DisciplineDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      // Unscoped: list every club's disciplines, each carrying its own club.
      loader: () => _repository.fetchDisciplines(
        pageNumber: pageNumber,
        pageSize: pageSize,
      ),
      onSuccess: _applyDisciplinesResponse,
      onError: () {
        disciplines.clear();
        _allDisciplines.clear();
        totalItems = null;
        isServerPaginated = false;
      },
      unexpectedErrorMessage: 'Unexpected error while loading disciplines',
    );
  }

  Future<void> showDisciplineAvailability(DisciplineDto discipline) async {
    showDisciplinesResults = true;
    selectedDiscipline = discipline;
    disciplineAvailabilityError = null;
    isDisciplineAvailabilityLoading = false;
    availableByDiscipline.clear();
    disciplineAvailabilityPageNumber = 1;
    _syncDisciplineAvailabilityPagination();

    final disciplineId = discipline.disciplineId;
    if (disciplineId == 0) {
      _disciplineAvailabilitySequence++;
      disciplineAvailabilityError = 'Could not determine the discipline.';
      notifyListeners();
      return;
    }

    await runLatestLoadOperation<List<AvailableSlotDto>>(
      setLoading: (value) => isDisciplineAvailabilityLoading = value,
      setError: (message) => disciplineAvailabilityError = message,
      loader: () => _repository.fetchAvailableBookingsByDiscipline(
        disciplineId: disciplineId,
      ),
      onSuccess: (items) {
        availableByDiscipline
          ..clear()
          ..addAll(items);
        _syncDisciplineAvailabilityPagination();
      },
      onError: () {
        availableByDiscipline.clear();
        _syncDisciplineAvailabilityPagination();
      },
      unexpectedErrorMessage: 'Could not load time slots for this discipline',
      startSequence: () => ++_disciplineAvailabilitySequence,
      shouldApplyResult: (sequence) =>
          sequence == _disciplineAvailabilitySequence,
    );
  }

  void backToResults() {
    resetDisciplineAvailability();
    showDisciplinesResults = true;
    notifyListeners();
  }

  void resetDisciplineAvailability() {
    _disciplineAvailabilitySequence++;
    disciplineAvailabilityError = null;
    isDisciplineAvailabilityLoading = false;
    availableByDiscipline.clear();
    selectedDiscipline = null;
    disciplineAvailabilityPageNumber = 1;
    disciplineAvailabilityPageSize = _defaultPageSize;
    _syncDisciplineAvailabilityPagination();
  }

  /// Returns to the directory options entry point while keeping the loaded
  /// disciplines list: clears any error, hides the results view, and resets the
  /// availability sub-state.
  void prepareDirectoryOptions() {
    error = null;
    showDisciplinesResults = false;
    resetDisciplineAvailability();
    notifyListeners();
  }

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableByDiscipline.remove(slot);
    _syncDisciplineAvailabilityPagination();
  }

  void setPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: pageNumber,
    value: value,
    setPageNumber: (v) => pageNumber = v,
    syncPagination: _refreshPagination,
  );

  void setPageSize(int value) => applyTablePageSize(
    currentPageSize: pageSize,
    value: value,
    setPageNumber: (v) => pageNumber = v,
    setPageSize: (v) => pageSize = v,
    syncPagination: _refreshPagination,
  );

  void resetToInitialState() {
    isLoading = false;
    error = null;
    disciplines.clear();
    _allDisciplines.clear();
    pageNumber = 1;
    pageSize = _defaultPageSize;
    totalItems = null;
    isServerPaginated = false;
    showDisciplinesResults = false;
    resetDisciplineAvailability();
    notifyListeners();
  }

  void _applyDisciplinesResponse(PaginatedResult<DisciplineDto> response) {
    final items = response.items;
    final serverPaginationByCount =
        response.totalItems != null && response.totalItems! > items.length;
    final expectedPageSize =
        response.pageSize ?? (pageSize > 0 ? pageSize : null);
    final serverPaginationInEffect = expectedPageSize != null
        ? items.length <= expectedPageSize
        : true;
    final hasServerPagination =
        (response.pageNumber != null || response.pageSize != null) &&
        serverPaginationInEffect;
    totalItems = response.totalItems ?? items.length;
    isServerPaginated = hasServerPagination || serverPaginationByCount;

    if (hasServerPagination || serverPaginationByCount) {
      disciplines
        ..clear()
        ..addAll(items);
      _allDisciplines.clear();
      return;
    }

    _allDisciplines
      ..clear()
      ..addAll(items);
    _applyClientPagination();
  }

  void _refreshPagination() {
    if (isServerPaginated) {
      loadDisciplines(forceRefresh: true, preserveResults: true);
    } else {
      _applyClientPagination();
    }
  }

  void _applyClientPagination() {
    final pagination = syncTablePaginationValues(
      totalItems: _allDisciplines.length,
      pageNumber: pageNumber,
      pageSize: pageSize,
      defaultPageSize: _defaultPageSize,
      setPageNumber: (v) => pageNumber = v,
      setPageSize: (v) => pageSize = v,
    );
    totalItems = pagination.totalItems;

    disciplines
      ..clear()
      ..addAll(
        sliceTablePage(
          _allDisciplines,
          pageNumber: pagination.pageNumber,
          pageSize: pagination.pageSize,
          defaultPageSize: _defaultPageSize,
        ),
      );
    notifyListeners();
  }

  void setDisciplineAvailabilityPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: disciplineAvailabilityPageNumber,
    value: value,
    setPageNumber: (v) => disciplineAvailabilityPageNumber = v,
    syncPagination: _syncDisciplineAvailabilityPagination,
  );

  void setDisciplineAvailabilityPageSize(int value) => applyTablePageSize(
    currentPageSize: disciplineAvailabilityPageSize,
    value: value,
    setPageNumber: (v) => disciplineAvailabilityPageNumber = v,
    setPageSize: (v) => disciplineAvailabilityPageSize = v,
    syncPagination: _syncDisciplineAvailabilityPagination,
  );

  void _syncDisciplineAvailabilityPagination() {
    syncTablePaginationValues(
      totalItems: availableByDiscipline.length,
      pageNumber: disciplineAvailabilityPageNumber,
      pageSize: disciplineAvailabilityPageSize,
      defaultPageSize: _defaultPageSize,
      setPageNumber: (v) => disciplineAvailabilityPageNumber = v,
      setPageSize: (v) => disciplineAvailabilityPageSize = v,
      onTotalItemsResolved: (value) => disciplineAvailabilityTotalItems = value,
    );
    notifyListeners();
  }
}
