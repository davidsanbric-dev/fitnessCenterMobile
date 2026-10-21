import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';

class CapabilitiesViewModel extends ViewModelBase {
  static const int _defaultSubgroupItemsPageSize = 6;
  static const int _defaultCapabilityAvailabilityPageSize = 6;

  CapabilitiesViewModel({required CapabilitiesDirectoryRepository repository})
    : _repository = repository;

  final CapabilitiesDirectoryRepository _repository;

  bool isLoading = false;
  String? error;
  CapabilitiesViewStage stage = CapabilitiesViewStage.groupSelection;
  final List<CapabilityDto> groups = <CapabilityDto>[];
  final List<CapabilityDto> subgroup = <CapabilityDto>[];
  final List<CapabilityDto> subgroupItems = <CapabilityDto>[];
  CapabilityDto? selectedGroup;
  CapabilityDto? selectedSubgroup;
  CapabilityDto? selectedCapability;
  final List<AvailableSlotByCapabilityDto> availableByCapability =
      <AvailableSlotByCapabilityDto>[];
  bool isSubgroupItemsLoading = false;
  String? subgroupItemsError;
  int subgroupItemsPageNumber = 1;
  int subgroupItemsPageSize = _defaultSubgroupItemsPageSize;
  int subgroupItemsTotalItems = 0;
  bool isCapabilityAvailabilityLoading = false;
  String? capabilityAvailabilityError;
  int capabilityAvailabilityPageNumber = 1;
  int capabilityAvailabilityPageSize = _defaultCapabilityAvailabilityPageSize;
  int capabilityAvailabilityTotalItems = 0;

  Future<void> ensureGroupsLoaded() async {
    if (groups.isNotEmpty || isLoading) return;

    await loadGroups();
  }

  Future<void> loadGroups({bool forceRefresh = false}) async {
    if (!forceRefresh && groups.isNotEmpty && error == null) {
      stage = CapabilitiesViewStage.groupSelection;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Unscoped so every club's groups show, like the booking flow.
      final items = await _repository.fetchGroups();
      groups
        ..clear()
        ..addAll(items);
      _resetSubgroupState();
      stage = CapabilitiesViewStage.groupSelection;
    } catch (err) {
      groups.clear();
      _resetSubgroupState();
      stage = CapabilitiesViewStage.groupSelection;
      error = err.userErrorMessageWith('Could not load class options');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubgroupFor(CapabilityDto group) async {
    if (group.id == 0) {
      error = 'Select a valid group.';
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final items = await _repository.fetchSubgroup(groupId: group.id);
      selectedGroup = group;
      subgroup
        ..clear()
        ..addAll(items);
      _resetSubgroupItemsState();
      stage = CapabilitiesViewStage.subgroupSelection;
    } catch (err) {
      subgroup.clear();
      selectedGroup = group;
      _resetSubgroupItemsState();
      stage = CapabilitiesViewStage.subgroupSelection;
      error = err.userErrorMessageWith('Could not load subgroup options');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSubgroupItemsFor(CapabilityDto subgroup) async {
    if (subgroup.id == 0) {
      subgroupItemsError = 'Select a valid subgroup.';
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      return;
    }

    final groupId = selectedGroup?.id;
    if (groupId == null || groupId <= 0) {
      subgroupItemsError = 'Select a valid group.';
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      return;
    }

    error = null;
    selectedSubgroup = subgroup;
    selectedCapability = null;
    _resetAvailabilityState();
    isSubgroupItemsLoading = true;
    subgroupItemsError = null;
    subgroupItemsPageNumber = 1;
    subgroupItems.clear();
    _syncSubgroupItemsPagination();
    stage = CapabilitiesViewStage.subgroupItemsSelection;
    notifyListeners();

    try {
      final items = await _repository.fetchSubgroupItems(
        groupId: groupId,
        subgroupId: subgroup.id,
      );
      subgroupItems
        ..clear()
        ..addAll(items);
      _syncSubgroupItemsPagination();
    } catch (err) {
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      subgroupItemsError = err.userErrorMessageWith(
        'Could not load class options for this subgroup',
      );
    } finally {
      isSubgroupItemsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookingsForCapability(CapabilityDto capability) async {
    if (capability.id == 0) {
      capabilityAvailabilityError = 'Select a valid class option.';
      notifyListeners();
      return;
    }

    error = null;
    isCapabilityAvailabilityLoading = true;
    capabilityAvailabilityError = null;
    capabilityAvailabilityPageNumber = 1;
    stage = CapabilitiesViewStage.capabilityAvailability;
    selectedCapability = capability;
    availableByCapability.clear();
    _syncCapabilityAvailabilityPagination();

    try {
      final items = await _repository.fetchAvailableBookingsByCapability(
        capability: capability,
      );
      availableByCapability
        ..clear()
        ..addAll(items);
      _syncCapabilityAvailabilityPagination();
      stage = CapabilitiesViewStage.capabilityAvailability;
    } catch (err) {
      availableByCapability.clear();
      _syncCapabilityAvailabilityPagination();
      stage = CapabilitiesViewStage.capabilityAvailability;
      capabilityAvailabilityError = err.userErrorMessageWith(
        'Could not load availability for this class option',
      );
    } finally {
      isCapabilityAvailabilityLoading = false;
      notifyListeners();
    }
  }

  void backToGroups() {
    error = null;
    _resetSubgroupState();
    stage = CapabilitiesViewStage.groupSelection;
    notifyListeners();
  }

  void backToSubgroup() {
    error = null;
    _resetSubgroupItemsState();
    stage = CapabilitiesViewStage.subgroupSelection;
    notifyListeners();
  }

  void backToSubgroupItems() {
    error = null;
    isCapabilityAvailabilityLoading = false;
    capabilityAvailabilityError = null;
    selectedCapability = null;
    availableByCapability.clear();
    stage = CapabilitiesViewStage.subgroupItemsSelection;
    notifyListeners();
  }

  void removeBookedAvailabilitySlot(AvailableSlotByCapabilityDto slot) {
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  List<Map<String, dynamic>> get capabilityBookingsTableRows => sliceTablePage(
    availableByCapability
        .map((item) => item.toTableRow())
        .toList(growable: false),
    pageNumber: capabilityAvailabilityPageNumber,
    pageSize: capabilityAvailabilityPageSize,
    defaultPageSize: _defaultCapabilityAvailabilityPageSize,
  );

  List<CapabilityDto> get subgroupItemsPageRows => sliceTablePage(
    subgroupItems.toList(growable: false),
    pageNumber: subgroupItemsPageNumber,
    pageSize: subgroupItemsPageSize,
    defaultPageSize: _defaultSubgroupItemsPageSize,
  );

  void setSubgroupItemsPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: subgroupItemsPageNumber,
    value: value,
    setPageNumber: (v) => subgroupItemsPageNumber = v,
    syncPagination: _syncSubgroupItemsPagination,
  );

  void setSubgroupItemsPageSize(int value) => applyTablePageSize(
    currentPageSize: subgroupItemsPageSize,
    value: value,
    setPageNumber: (v) => subgroupItemsPageNumber = v,
    setPageSize: (v) => subgroupItemsPageSize = v,
    syncPagination: _syncSubgroupItemsPagination,
  );

  void setCapabilityAvailabilityPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: capabilityAvailabilityPageNumber,
    value: value,
    setPageNumber: (v) => capabilityAvailabilityPageNumber = v,
    syncPagination: _syncCapabilityAvailabilityPagination,
  );

  void setCapabilityAvailabilityPageSize(int value) => applyTablePageSize(
    currentPageSize: capabilityAvailabilityPageSize,
    value: value,
    setPageNumber: (v) => capabilityAvailabilityPageNumber = v,
    setPageSize: (v) => capabilityAvailabilityPageSize = v,
    syncPagination: _syncCapabilityAvailabilityPagination,
  );

  void _resetSubgroupState() {
    subgroup.clear();
    selectedGroup = null;
    _resetSubgroupItemsState();
  }

  void _resetSubgroupItemsState() {
    subgroupItems.clear();
    selectedSubgroup = null;
    isSubgroupItemsLoading = false;
    subgroupItemsError = null;
    subgroupItemsPageNumber = 1;
    subgroupItemsPageSize = _defaultSubgroupItemsPageSize;
    _syncSubgroupItemsPagination();
    _resetAvailabilityState();
  }

  void _resetAvailabilityState() {
    selectedCapability = null;
    isCapabilityAvailabilityLoading = false;
    capabilityAvailabilityError = null;
    availableByCapability.clear();
    capabilityAvailabilityPageNumber = 1;
    capabilityAvailabilityPageSize = _defaultCapabilityAvailabilityPageSize;
    _syncCapabilityAvailabilityPagination();
  }

  void _syncSubgroupItemsPagination() {
    syncTablePaginationValues(
      totalItems: subgroupItems.length,
      pageNumber: subgroupItemsPageNumber,
      pageSize: subgroupItemsPageSize,
      defaultPageSize: _defaultSubgroupItemsPageSize,
      setPageNumber: (v) => subgroupItemsPageNumber = v,
      setPageSize: (v) => subgroupItemsPageSize = v,
      onTotalItemsResolved: (value) => subgroupItemsTotalItems = value,
    );
    notifyListeners();
  }

  void _syncCapabilityAvailabilityPagination() {
    syncTablePaginationValues(
      totalItems: availableByCapability.length,
      pageNumber: capabilityAvailabilityPageNumber,
      pageSize: capabilityAvailabilityPageSize,
      defaultPageSize: _defaultCapabilityAvailabilityPageSize,
      setPageNumber: (v) => capabilityAvailabilityPageNumber = v,
      setPageSize: (v) => capabilityAvailabilityPageSize = v,
      onTotalItemsResolved: (value) => capabilityAvailabilityTotalItems = value,
    );
    notifyListeners();
  }
}
