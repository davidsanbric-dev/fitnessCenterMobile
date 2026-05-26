import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:get/get.dart';

class DisciplinesDirectoryController extends ControllerBase {
  DisciplinesDirectoryController({
    this.locationId,
    DisciplinesDirectoryRepository? repository,
  }) : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  final int? locationId;
  static const int _defaultPageSize = 6;
  final DisciplinesDirectoryRepository _repository;
  int _disciplineAvailabilitySequence = 0;

  final selectedLocationId = RxnInt();
  final selectedLocationLabel = RxnString();

  final disciplines = <DisciplineDto>[].obs;
  final _allDisciplines = <DisciplineDto>[];
  final pageNumber = 1.obs;
  final pageSize = _defaultPageSize.obs;
  final totalItems = RxnInt();
  final isServerPaginated = false.obs;
  final showDisciplinesResults = false.obs;
  final RxList<AvailableSlotDto> availableByDiscipline =
      <AvailableSlotDto>[].obs;
  final isDisciplineAvailabilityLoading = false.obs;
  final disciplineAvailabilityError = RxnString();
  final selectedDiscipline = Rxn<DisciplineDto>();
  final disciplineAvailabilityPageNumber = 1.obs;
  final disciplineAvailabilityPageSize = _defaultPageSize.obs;
  final disciplineAvailabilityTotalItems = 0.obs;

  List<Map<String, dynamic>> get disciplinesRows =>
      disciplines.map((item) => item.toTableRow()).toList(growable: false);

  List<Map<String, dynamic>> get disciplineAvailabilityRows => sliceTablePage(
    availableByDiscipline
        .map((slot) => slot.toDisciplineAvailabilityRow())
        .toList(growable: false),
    pageNumber: disciplineAvailabilityPageNumber.value,
    pageSize: disciplineAvailabilityPageSize.value,
    defaultPageSize: _defaultPageSize,
  );

  Future<void> loadDisciplines({
    bool forceRefresh = false,
    bool preserveResults = false,
  }) async {
    if (!preserveResults) {
      showDisciplinesResults.value = false;
    }
    if (!forceRefresh && disciplines.isNotEmpty && error.value == null) {
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final response = await _repository.fetchDisciplines(
        pageNumber: pageNumber.value,
        pageSize: pageSize.value,
      );
      _applyDisciplinesResponse(response);
    } on ApiException catch (apiError) {
      error.value = apiError.message;
      disciplines.clear();
      _allDisciplines.clear();
      totalItems.value = null;
      isServerPaginated.value = false;
    } catch (err) {
      error.value = 'Unexpected error while loading disciplines: $err';
      disciplines.clear();
      _allDisciplines.clear();
      totalItems.value = null;
      isServerPaginated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showDisciplineAvailability(
    DisciplineDto discipline, {
    int? locationId,
  }) async {
    showDisciplinesResults.value = true;
    selectedDiscipline.value = discipline;
    disciplineAvailabilityError.value = null;
    isDisciplineAvailabilityLoading.value = false;
    availableByDiscipline.clear();
    disciplineAvailabilityPageNumber.value = 1;
    _syncDisciplineAvailabilityPagination();

    final disciplineId = discipline.disciplineId;
    if (disciplineId == 0) {
      _disciplineAvailabilitySequence++;
      disciplineAvailabilityError.value = 'Could not determine the discipline.';
      return;
    }

    final resolvedLocationId = locationId ?? this.locationId;
    if (resolvedLocationId == null || resolvedLocationId <= 0) {
      _disciplineAvailabilitySequence++;
      disciplineAvailabilityError.value = 'Could not determine the club.';
      return;
    }
    final activeLocationId = resolvedLocationId;

    await runLatestLoadOperation<List<AvailableSlotDto>>(
      isLoading: isDisciplineAvailabilityLoading,
      error: disciplineAvailabilityError,
      loader: () => _repository.fetchAvailableBookingsByDiscipline(
        disciplineId: disciplineId,
        locationId: activeLocationId,
      ),
      onSuccess: (items) {
        availableByDiscipline.assignAll(items);
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
    showDisciplinesResults.value = true;
  }

  void resetDisciplineAvailability() {
    _disciplineAvailabilitySequence++;
    disciplineAvailabilityError.value = null;
    isDisciplineAvailabilityLoading.value = false;
    availableByDiscipline.clear();
    selectedDiscipline.value = null;
    disciplineAvailabilityPageNumber.value = 1;
    disciplineAvailabilityPageSize.value = _defaultPageSize;
    _syncDisciplineAvailabilityPagination();
  }

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) {
    availableByDiscipline.remove(slot);
    _syncDisciplineAvailabilityPagination();
  }

  void clearLocationSelection() {
    selectedLocationId.value = null;
    selectedLocationLabel.value = null;
  }

  void setPageNumber(int value) => setTablePageNumber(
    pageNumber: pageNumber,
    value: value,
    syncPagination: _refreshPagination,
  );

  void setPageSize(int value) => setTablePageSize(
    pageNumber: pageNumber,
    pageSize: pageSize,
    value: value,
    syncPagination: _refreshPagination,
  );

  void resetToInitialState() {
    isLoading.value = false;
    error.value = null;
    clearLocationSelection();
    disciplines.clear();
    _allDisciplines.clear();
    pageNumber.value = 1;
    pageSize.value = _defaultPageSize;
    totalItems.value = null;
    isServerPaginated.value = false;
    showDisciplinesResults.value = false;
    resetDisciplineAvailability();
  }

  void _applyDisciplinesResponse(PaginatedResult<DisciplineDto> response) {
    final items = response.items;
    final serverPaginationByCount =
        response.totalItems != null && response.totalItems! > items.length;
    final expectedPageSize =
        response.pageSize ?? (pageSize.value > 0 ? pageSize.value : null);
    final serverPaginationInEffect = expectedPageSize != null
        ? items.length <= expectedPageSize
        : true;
    final hasServerPagination =
        (response.pageNumber != null || response.pageSize != null) &&
        serverPaginationInEffect;
    totalItems.value = response.totalItems ?? items.length;
    isServerPaginated.value = hasServerPagination || serverPaginationByCount;

    if (hasServerPagination || serverPaginationByCount) {
      disciplines.assignAll(items);
      _allDisciplines.clear();
      return;
    }

    _allDisciplines
      ..clear()
      ..addAll(items);
    _applyClientPagination();
  }

  void _refreshPagination() {
    if (isServerPaginated.value) {
      loadDisciplines(forceRefresh: true, preserveResults: true);
    } else {
      _applyClientPagination();
    }
  }

  void _applyClientPagination() {
    final pagination = syncTablePaginationState(
      totalItems: _allDisciplines.length,
      pageNumber: pageNumber,
      pageSize: pageSize,
      defaultPageSize: _defaultPageSize,
    );
    totalItems.value = pagination.totalItems;

    disciplines.assignAll(
      sliceTablePage(
        _allDisciplines,
        pageNumber: pagination.pageNumber,
        pageSize: pagination.pageSize,
        defaultPageSize: _defaultPageSize,
      ),
    );
  }

  void setDisciplineAvailabilityPageNumber(int value) => setTablePageNumber(
    pageNumber: disciplineAvailabilityPageNumber,
    value: value,
    syncPagination: _syncDisciplineAvailabilityPagination,
  );

  void setDisciplineAvailabilityPageSize(int value) => setTablePageSize(
    pageNumber: disciplineAvailabilityPageNumber,
    pageSize: disciplineAvailabilityPageSize,
    value: value,
    syncPagination: _syncDisciplineAvailabilityPagination,
  );

  void _syncDisciplineAvailabilityPagination() {
    syncTablePaginationState(
      totalItems: availableByDiscipline.length,
      pageNumber: disciplineAvailabilityPageNumber,
      pageSize: disciplineAvailabilityPageSize,
      defaultPageSize: _defaultPageSize,
      onTotalItemsResolved: (value) =>
          disciplineAvailabilityTotalItems.value = value,
    );
  }
}
