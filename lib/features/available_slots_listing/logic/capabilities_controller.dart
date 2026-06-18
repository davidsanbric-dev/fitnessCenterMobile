import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/domain/domain.dart';
import 'package:portfolio_mobile_app/features/class_booking/class_booking.dart';
import 'package:get/get.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';

class CapabilitiesController extends ControllerBase {
  CapabilitiesController({
    CapabilitiesCatalogRepository? catalogRepository,
    AvailabilityListingRepository? availabilityRepository,
    ClassBookingController? bookingController,
  }) : _catalogRepository =
           catalogRepository ??
           (throw ArgumentError.notNull('catalogRepository')),
       _availabilityRepository =
           availabilityRepository ??
           (throw ArgumentError.notNull('availabilityRepository')),
       _bookingController =
           bookingController ??
           ClassBookingInjector.getSharedClassBookingController();

  final CapabilitiesCatalogRepository _catalogRepository;
  final AvailabilityListingRepository _availabilityRepository;
  final ClassBookingController _bookingController;
  static const int _defaultCapabilityAvailabilityPageSize = 6;
  static const int _defaultCapabilitySubgroupItemsPageSize = 6;

  final RxList<FilterBoxOptionData> capabilityOptions =
      <FilterBoxOptionData>[].obs;
  final RxList<CapabilityDto> capabilityGroups = <CapabilityDto>[].obs;
  final RxList<CapabilityDto> capabilitySubgroup = <CapabilityDto>[].obs;
  final RxList<CapabilityDto> capabilitySubgroupItems = <CapabilityDto>[].obs;
  final RxList<AvailableSlotByCapabilityDto> availableByCapability =
      <AvailableSlotByCapabilityDto>[].obs;
  final selectedCapability = Rxn<CapabilityDto>();
  final isCapabilitySubgroupItemsLoading = false.obs;
  final capabilitySubgroupItemsError = RxnString();
  final capabilitySubgroupItemsPageNumber = 1.obs;
  final capabilitySubgroupItemsPageSize =
      _defaultCapabilitySubgroupItemsPageSize.obs;
  final capabilitySubgroupItemsTotalItems = 0.obs;
  final isCapabilityAvailabilityLoading = false.obs;
  final capabilityAvailabilityError = RxnString();
  final capabilityAvailabilityPageNumber = 1.obs;
  final capabilityAvailabilityPageSize =
      _defaultCapabilityAvailabilityPageSize.obs;
  final capabilityAvailabilityTotalItems = 0.obs;

  Future<void> loadCapabilities() async {
    final capabilitiesData = await _catalogRepository.fetchCapabilities();
    _applyCapabilities(capabilitiesData);
  }

  void resetSubgroup() {
    capabilitySubgroup.clear();
    resetSubgroupItems();
  }

  void resetSubgroupItems() {
    isCapabilitySubgroupItemsLoading.value = false;
    capabilitySubgroupItemsError.value = null;
    capabilitySubgroupItems.clear();
    capabilitySubgroupItemsPageNumber.value = 1;
    capabilitySubgroupItemsPageSize.value =
        _defaultCapabilitySubgroupItemsPageSize;
    _syncCapabilitySubgroupItemsPagination();
  }

  Future<void> loadSubgroupFor({
    required CapabilityDto group,
    required RxBool isLoading,
    required RxnString error,
  }) async {
    if (group.id == 0) {
      error.value = 'Select a valid group.';
      capabilitySubgroup.clear();
      return;
    }

    isLoading.value = true;
    error.value = null;
    capabilitySubgroup.clear();

    try {
      final items = await _catalogRepository.fetchSubgroup(
        groupId: group.id,
      );
      capabilitySubgroup.assignAll(items);
    } catch (err) {
      capabilitySubgroup.clear();
      error.value = err.userErrorMessageWith('Could not load subgroup options');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) async {
    if (subgroup.id == 0) {
      capabilitySubgroupItemsError.value = 'Select a valid subgroup option.';
      capabilitySubgroupItems.clear();
      return;
    }
    if (group.id == 0) {
      capabilitySubgroupItemsError.value = 'Select a valid group.';
      capabilitySubgroupItems.clear();
      return;
    }

    selectedCapability.value = null;
    isCapabilitySubgroupItemsLoading.value = true;
    capabilitySubgroupItemsError.value = null;
    capabilitySubgroupItemsPageNumber.value = 1;
    capabilitySubgroupItems.clear();
    _syncCapabilitySubgroupItemsPagination();

    try {
      final items = await _catalogRepository.fetchSubgroupItems(
        groupId: group.id,
        subgroupId: subgroup.id,
      );
      capabilitySubgroupItems.assignAll(items);
      _syncCapabilitySubgroupItemsPagination();
    } catch (err) {
      capabilitySubgroupItems.clear();
      _syncCapabilitySubgroupItemsPagination();
      capabilitySubgroupItemsError.value = err.userErrorMessageWith(
        'Could not load class options for this subgroup',
      );
    } finally {
      isCapabilitySubgroupItemsLoading.value = false;
    }
  }

  Future<void> loadBookingsByCapability(CapabilityDto capability) async {
    if (capability.id == 0) {
      capabilityAvailabilityError.value = 'Select a valid class option.';
      return;
    }

    selectedCapability.value = capability;
    isCapabilityAvailabilityLoading.value = true;
    capabilityAvailabilityError.value = null;
    capabilityAvailabilityPageNumber.value = 1;
    availableByCapability.clear();
    _syncCapabilityAvailabilityPagination();

    try {
      final items = await _availabilityRepository
          .fetchAvailableBookingsByCapability(
            capability: capability,
          );
      availableByCapability.assignAll(items);
      _syncCapabilityAvailabilityPagination();
    } catch (err) {
      availableByCapability.clear();
      _syncCapabilityAvailabilityPagination();
      capabilityAvailabilityError.value = err.userErrorMessageWith(
        'Could not load availability for this class option',
      );
    } finally {
      isCapabilityAvailabilityLoading.value = false;
    }
  }

  Future<void> reserveCapabilitySlot(AvailableSlotByCapabilityDto slot) async {
    await _bookingController.bookByClassType(slot: slot);
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) {
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  void resetAvailability() {
    isCapabilityAvailabilityLoading.value = false;
    capabilityAvailabilityError.value = null;
    availableByCapability.clear();
    selectedCapability.value = null;
    capabilityAvailabilityPageNumber.value = 1;
    capabilityAvailabilityPageSize.value =
        _defaultCapabilityAvailabilityPageSize;
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

  List<CapabilityDto> get capabilitySubgroupItemsPageRows => sliceTablePage(
    capabilitySubgroupItems.toList(growable: false),
    pageNumber: capabilitySubgroupItemsPageNumber.value,
    pageSize: capabilitySubgroupItemsPageSize.value,
    defaultPageSize: _defaultCapabilitySubgroupItemsPageSize,
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

  void setCapabilitySubgroupItemsPageNumber(int value) => setTablePageNumber(
    pageNumber: capabilitySubgroupItemsPageNumber,
    value: value,
    syncPagination: _syncCapabilitySubgroupItemsPagination,
  );

  void setCapabilitySubgroupItemsPageSize(int value) => setTablePageSize(
    pageNumber: capabilitySubgroupItemsPageNumber,
    pageSize: capabilitySubgroupItemsPageSize,
    value: value,
    syncPagination: _syncCapabilitySubgroupItemsPagination,
  );

  void _applyCapabilities(List<CapabilityDto> capabilities) {
    capabilityGroups.assignAll(capabilities);
    capabilitySubgroup.clear();
    resetSubgroupItems();
    capabilityOptions.assignAll(_buildCapabilitiesOptions(capabilities));
  }

  List<FilterBoxOptionData> _buildCapabilitiesOptions(
    List<CapabilityDto> capabilities,
  ) {
    final options = capabilities
        .map(
          (capability) => FilterBoxOptionData(
            label: capability.description,
            iconData: _resolveServiceIcon(capability.description),
          ),
        )
        .toList(growable: true);

    options.sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
    return options.toList(growable: false);
  }

  IconData _resolveServiceIcon(String name) {
    if (name.trim().isEmpty) {
      return LucideIcons.dumbbell;
    }
    return LucideIcons.dumbbell;
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

  void _syncCapabilitySubgroupItemsPagination() {
    syncTablePaginationState(
      totalItems: capabilitySubgroupItems.length,
      pageNumber: capabilitySubgroupItemsPageNumber,
      pageSize: capabilitySubgroupItemsPageSize,
      defaultPageSize: _defaultCapabilitySubgroupItemsPageSize,
      onTotalItemsResolved: (value) =>
          capabilitySubgroupItemsTotalItems.value = value,
    );
  }
}
