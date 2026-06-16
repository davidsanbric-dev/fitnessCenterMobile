import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';
import 'package:get/get.dart';

class CapabilitiesController extends ControllerBase {
  static const int _defaultSubgroupItemsPageSize = 6;
  static const int _defaultCapabilityAvailabilityPageSize = 6;

  CapabilitiesController({
    CapabilitiesDirectoryRepository? repository,
    this.locationId = 1,
  }) : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  final CapabilitiesDirectoryRepository _repository;
  final int locationId;

  // Resolved from the selected group; the subgroup/items/availability steps are
  // scoped to the club that owns the chosen group (mirrors the booking flow).
  int? _selectedGroupLocationId;

  int? _resolveLocationIdForGroup(CapabilityDto group) {
    if (group.locationId > 0) {
      return group.locationId;
    }
    return locationId > 0 ? locationId : null;
  }

  int? _resolveLocationIdForCapability(CapabilityDto capability) {
    if (capability.locationId > 0) {
      return capability.locationId;
    }
    return _selectedGroupLocationId ?? (locationId > 0 ? locationId : null);
  }

  final stage = CapabilitiesViewStage.groupSelection.obs;
  final RxList<CapabilityDto> groups = <CapabilityDto>[].obs;
  final RxList<CapabilityDto> subgroup = <CapabilityDto>[].obs;
  final RxList<CapabilityDto> subgroupItems = <CapabilityDto>[].obs;
  final selectedGroup = Rxn<CapabilityDto>();
  final selectedSubgroup = Rxn<CapabilityDto>();
  final selectedCapability = Rxn<CapabilityDto>();
  final RxList<AvailableSlotByCapabilityDto> availableByCapability =
      <AvailableSlotByCapabilityDto>[].obs;
  final isSubgroupItemsLoading = false.obs;
  final subgroupItemsError = RxnString();
  final subgroupItemsPageNumber = 1.obs;
  final subgroupItemsPageSize = _defaultSubgroupItemsPageSize.obs;
  final subgroupItemsTotalItems = 0.obs;
  final isCapabilityAvailabilityLoading = false.obs;
  final capabilityAvailabilityError = RxnString();
  final capabilityAvailabilityPageNumber = 1.obs;
  final capabilityAvailabilityPageSize =
      _defaultCapabilityAvailabilityPageSize.obs;
  final capabilityAvailabilityTotalItems = 0.obs;

  Future<void> ensureGroupsLoaded() async {
    if (groups.isNotEmpty || isLoading.value) return;

    await loadGroups();
  }

  Future<void> loadGroups({bool forceRefresh = false}) async {
    if (!forceRefresh && groups.isNotEmpty && error.value == null) {
      stage.value = CapabilitiesViewStage.groupSelection;
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      // Unscoped so every club's groups show, like the booking flow.
      final items = await _repository.fetchGroups();
      groups.assignAll(items);
      _resetSubgroupState();
      stage.value = CapabilitiesViewStage.groupSelection;
    } catch (err) {
      groups.clear();
      _resetSubgroupState();
      stage.value = CapabilitiesViewStage.groupSelection;
      error.value = err.userErrorMessageWith('Could not load class options');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubgroupFor(CapabilityDto group) async {
    if (group.id == 0) {
      error.value = 'Select a valid group.';
      return;
    }

    final groupLocationId = _resolveLocationIdForGroup(group);
    if (groupLocationId == null) {
      error.value = 'Could not determine the club.';
      return;
    }
    _selectedGroupLocationId = groupLocationId;

    isLoading.value = true;
    error.value = null;

    try {
      final items = await _repository.fetchSubgroup(
        locationId: groupLocationId,
        groupId: group.id,
      );
      selectedGroup.value = group;
      subgroup.assignAll(items);
      _resetSubgroupItemsState();
      stage.value = CapabilitiesViewStage.subgroupSelection;
    } catch (err) {
      subgroup.clear();
      selectedGroup.value = group;
      _resetSubgroupItemsState();
      stage.value = CapabilitiesViewStage.subgroupSelection;
      error.value = err.userErrorMessageWith('Could not load subgroup options');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubgroupItemsFor(CapabilityDto subgroup) async {
    if (subgroup.id == 0) {
      subgroupItemsError.value = 'Select a valid subgroup.';
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      return;
    }

    final groupId = selectedGroup.value?.id;
    if (groupId == null || groupId <= 0) {
      subgroupItemsError.value = 'Select a valid group.';
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      return;
    }

    error.value = null;
    selectedSubgroup.value = subgroup;
    selectedCapability.value = null;
    _resetAvailabilityState();
    isSubgroupItemsLoading.value = true;
    subgroupItemsError.value = null;
    subgroupItemsPageNumber.value = 1;
    subgroupItems.clear();
    _syncSubgroupItemsPagination();
    stage.value = CapabilitiesViewStage.subgroupItemsSelection;

    try {
      final items = await _repository.fetchSubgroupItems(
        locationId: _selectedGroupLocationId ?? locationId,
        groupId: groupId,
        subgroupId: subgroup.id,
      );
      subgroupItems.assignAll(items);
      _syncSubgroupItemsPagination();
    } catch (err) {
      subgroupItems.clear();
      _syncSubgroupItemsPagination();
      subgroupItemsError.value = err.userErrorMessageWith(
        'Could not load class options for this subgroup',
      );
    } finally {
      isSubgroupItemsLoading.value = false;
    }
  }

  Future<void> loadBookingsForCapability(CapabilityDto capability) async {
    if (capability.id == 0) {
      capabilityAvailabilityError.value = 'Select a valid class option.';
      return;
    }

    final capabilityLocationId = _resolveLocationIdForCapability(capability);
    if (capabilityLocationId == null) {
      capabilityAvailabilityError.value = 'Could not determine the club.';
      return;
    }

    error.value = null;
    isCapabilityAvailabilityLoading.value = true;
    capabilityAvailabilityError.value = null;
    capabilityAvailabilityPageNumber.value = 1;
    stage.value = CapabilitiesViewStage.capabilityAvailability;
    selectedCapability.value = capability;
    availableByCapability.clear();
    _syncCapabilityAvailabilityPagination();

    try {
      final items = await _repository.fetchAvailableBookingsByCapability(
        locationId: capabilityLocationId,
        capability: capability,
      );
      availableByCapability.assignAll(items);
      _syncCapabilityAvailabilityPagination();
      stage.value = CapabilitiesViewStage.capabilityAvailability;
    } catch (err) {
      availableByCapability.clear();
      _syncCapabilityAvailabilityPagination();
      stage.value = CapabilitiesViewStage.capabilityAvailability;
      capabilityAvailabilityError.value = err.userErrorMessageWith(
        'Could not load availability for this class option',
      );
    } finally {
      isCapabilityAvailabilityLoading.value = false;
    }
  }

  void backToGroups() {
    error.value = null;
    _resetSubgroupState();
    stage.value = CapabilitiesViewStage.groupSelection;
  }

  void backToSubgroup() {
    error.value = null;
    _resetSubgroupItemsState();
    stage.value = CapabilitiesViewStage.subgroupSelection;
  }

  void backToSubgroupItems() {
    error.value = null;
    isCapabilityAvailabilityLoading.value = false;
    capabilityAvailabilityError.value = null;
    selectedCapability.value = null;
    availableByCapability.clear();
    stage.value = CapabilitiesViewStage.subgroupItemsSelection;
  }

  void removeBookedAvailabilitySlot(AvailableSlotByCapabilityDto slot) {
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  List<Map<String, dynamic>> get capabilityBookingsTableRows => sliceTablePage(
    availableByCapability
        .map((item) => item.toTableRow())
        .toList(growable: false),
    pageNumber: capabilityAvailabilityPageNumber.value,
    pageSize: capabilityAvailabilityPageSize.value,
    defaultPageSize: _defaultCapabilityAvailabilityPageSize,
  );

  List<CapabilityDto> get subgroupItemsPageRows => sliceTablePage(
    subgroupItems.toList(growable: false),
    pageNumber: subgroupItemsPageNumber.value,
    pageSize: subgroupItemsPageSize.value,
    defaultPageSize: _defaultSubgroupItemsPageSize,
  );

  void setSubgroupItemsPageNumber(int value) => setTablePageNumber(
    pageNumber: subgroupItemsPageNumber,
    value: value,
    syncPagination: _syncSubgroupItemsPagination,
  );

  void setSubgroupItemsPageSize(int value) => setTablePageSize(
    pageNumber: subgroupItemsPageNumber,
    pageSize: subgroupItemsPageSize,
    value: value,
    syncPagination: _syncSubgroupItemsPagination,
  );

  void setCapabilityAvailabilityPageNumber(int value) => setTablePageNumber(
    pageNumber: capabilityAvailabilityPageNumber,
    value: value,
    syncPagination: _syncCapabilityAvailabilityPagination,
  );

  void setCapabilityAvailabilityPageSize(int value) => setTablePageSize(
    pageNumber: capabilityAvailabilityPageNumber,
    pageSize: capabilityAvailabilityPageSize,
    value: value,
    syncPagination: _syncCapabilityAvailabilityPagination,
  );

  void _resetSubgroupState() {
    subgroup.clear();
    selectedGroup.value = null;
    _selectedGroupLocationId = null;
    _resetSubgroupItemsState();
  }

  void _resetSubgroupItemsState() {
    subgroupItems.clear();
    selectedSubgroup.value = null;
    isSubgroupItemsLoading.value = false;
    subgroupItemsError.value = null;
    subgroupItemsPageNumber.value = 1;
    subgroupItemsPageSize.value = _defaultSubgroupItemsPageSize;
    _syncSubgroupItemsPagination();
    _resetAvailabilityState();
  }

  void _resetAvailabilityState() {
    selectedCapability.value = null;
    isCapabilityAvailabilityLoading.value = false;
    capabilityAvailabilityError.value = null;
    availableByCapability.clear();
    capabilityAvailabilityPageNumber.value = 1;
    capabilityAvailabilityPageSize.value =
        _defaultCapabilityAvailabilityPageSize;
    _syncCapabilityAvailabilityPagination();
  }

  void _syncSubgroupItemsPagination() {
    syncTablePaginationState(
      totalItems: subgroupItems.length,
      pageNumber: subgroupItemsPageNumber,
      pageSize: subgroupItemsPageSize,
      defaultPageSize: _defaultSubgroupItemsPageSize,
      onTotalItemsResolved: (value) => subgroupItemsTotalItems.value = value,
    );
  }

  void _syncCapabilityAvailabilityPagination() {
    syncTablePaginationState(
      totalItems: availableByCapability.length,
      pageNumber: capabilityAvailabilityPageNumber,
      pageSize: capabilityAvailabilityPageSize,
      defaultPageSize: _defaultCapabilityAvailabilityPageSize,
      onTotalItemsResolved: (value) =>
          capabilityAvailabilityTotalItems.value = value,
    );
  }
}
