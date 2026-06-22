import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/class_booking/feature.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:flutter/material.dart';

class CapabilitiesViewModel extends ViewModelBase {
  CapabilitiesViewModel({
    CapabilitiesCatalogRepository? catalogRepository,
    AvailabilityListingRepository? availabilityRepository,
    ClassBookingViewModel? bookingViewModel,
  }) : _catalogRepository =
           catalogRepository ??
           (throw ArgumentError.notNull('catalogRepository')),
       _availabilityRepository =
           availabilityRepository ??
           (throw ArgumentError.notNull('availabilityRepository')),
       _bookingViewModel =
           bookingViewModel ??
           ClassBookingInjector.getSharedClassBookingViewModel();

  final CapabilitiesCatalogRepository _catalogRepository;
  final AvailabilityListingRepository _availabilityRepository;
  final ClassBookingViewModel _bookingViewModel;
  static const int _defaultCapabilityAvailabilityPageSize = 6;
  static const int _defaultCapabilitySubgroupItemsPageSize = 6;

  final List<FilterBoxOptionData> capabilityOptions = <FilterBoxOptionData>[];
  final List<CapabilityDto> capabilityGroups = <CapabilityDto>[];
  final List<CapabilityDto> capabilitySubgroup = <CapabilityDto>[];
  final List<CapabilityDto> capabilitySubgroupItems = <CapabilityDto>[];
  final List<AvailableSlotByCapabilityDto> availableByCapability =
      <AvailableSlotByCapabilityDto>[];
  CapabilityDto? selectedCapability;
  bool isCapabilitySubgroupItemsLoading = false;
  String? capabilitySubgroupItemsError;
  int capabilitySubgroupItemsPageNumber = 1;
  int capabilitySubgroupItemsPageSize = _defaultCapabilitySubgroupItemsPageSize;
  int capabilitySubgroupItemsTotalItems = 0;
  bool isCapabilityAvailabilityLoading = false;
  String? capabilityAvailabilityError;
  int capabilityAvailabilityPageNumber = 1;
  int capabilityAvailabilityPageSize = _defaultCapabilityAvailabilityPageSize;
  int capabilityAvailabilityTotalItems = 0;

  Future<void> loadCapabilities() async {
    final capabilitiesData = await _catalogRepository.fetchCapabilities();
    _applyCapabilities(capabilitiesData);
  }

  void resetSubgroup() {
    capabilitySubgroup.clear();
    resetSubgroupItems();
  }

  void resetSubgroupItems() {
    isCapabilitySubgroupItemsLoading = false;
    capabilitySubgroupItemsError = null;
    capabilitySubgroupItems.clear();
    capabilitySubgroupItemsPageNumber = 1;
    capabilitySubgroupItemsPageSize = _defaultCapabilitySubgroupItemsPageSize;
    _syncCapabilitySubgroupItemsPagination();
  }

  Future<void> loadSubgroupFor({
    required CapabilityDto group,
    required void Function(bool isLoading) setLoading,
    required void Function(String? message) setError,
  }) async {
    if (group.id == 0) {
      setError('Select a valid group.');
      capabilitySubgroup.clear();
      notifyListeners();
      return;
    }

    setLoading(true);
    setError(null);
    capabilitySubgroup.clear();
    notifyListeners();

    try {
      final items = await _catalogRepository.fetchSubgroup(groupId: group.id);
      capabilitySubgroup
        ..clear()
        ..addAll(items);
    } catch (err) {
      capabilitySubgroup.clear();
      setError(err.userErrorMessageWith('Could not load subgroup options'));
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> loadSubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) async {
    if (subgroup.id == 0) {
      capabilitySubgroupItemsError = 'Select a valid subgroup option.';
      capabilitySubgroupItems.clear();
      notifyListeners();
      return;
    }
    if (group.id == 0) {
      capabilitySubgroupItemsError = 'Select a valid group.';
      capabilitySubgroupItems.clear();
      notifyListeners();
      return;
    }

    selectedCapability = null;
    isCapabilitySubgroupItemsLoading = true;
    capabilitySubgroupItemsError = null;
    capabilitySubgroupItemsPageNumber = 1;
    capabilitySubgroupItems.clear();
    _syncCapabilitySubgroupItemsPagination();

    try {
      final items = await _catalogRepository.fetchSubgroupItems(
        groupId: group.id,
        subgroupId: subgroup.id,
      );
      capabilitySubgroupItems
        ..clear()
        ..addAll(items);
      _syncCapabilitySubgroupItemsPagination();
    } catch (err) {
      capabilitySubgroupItems.clear();
      _syncCapabilitySubgroupItemsPagination();
      capabilitySubgroupItemsError = err.userErrorMessageWith(
        'Could not load class options for this subgroup',
      );
    } finally {
      isCapabilitySubgroupItemsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookingsByCapability(CapabilityDto capability) async {
    if (capability.id == 0) {
      capabilityAvailabilityError = 'Select a valid class option.';
      notifyListeners();
      return;
    }

    selectedCapability = capability;
    isCapabilityAvailabilityLoading = true;
    capabilityAvailabilityError = null;
    capabilityAvailabilityPageNumber = 1;
    availableByCapability.clear();
    _syncCapabilityAvailabilityPagination();

    try {
      final items = await _availabilityRepository
          .fetchAvailableBookingsByCapability(capability: capability);
      availableByCapability
        ..clear()
        ..addAll(items);
      _syncCapabilityAvailabilityPagination();
    } catch (err) {
      availableByCapability.clear();
      _syncCapabilityAvailabilityPagination();
      capabilityAvailabilityError = err.userErrorMessageWith(
        'Could not load availability for this class option',
      );
    } finally {
      isCapabilityAvailabilityLoading = false;
      notifyListeners();
    }
  }

  Future<void> reserveCapabilitySlot(AvailableSlotByCapabilityDto slot) async {
    await _bookingViewModel.bookByClassType(slot: slot);
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) {
    availableByCapability.remove(slot);
    _syncCapabilityAvailabilityPagination();
  }

  void resetAvailability() {
    isCapabilityAvailabilityLoading = false;
    capabilityAvailabilityError = null;
    availableByCapability.clear();
    selectedCapability = null;
    capabilityAvailabilityPageNumber = 1;
    capabilityAvailabilityPageSize = _defaultCapabilityAvailabilityPageSize;
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

  List<CapabilityDto> get capabilitySubgroupItemsPageRows => sliceTablePage(
    capabilitySubgroupItems.toList(growable: false),
    pageNumber: capabilitySubgroupItemsPageNumber,
    pageSize: capabilitySubgroupItemsPageSize,
    defaultPageSize: _defaultCapabilitySubgroupItemsPageSize,
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

  void setCapabilitySubgroupItemsPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: capabilitySubgroupItemsPageNumber,
    value: value,
    setPageNumber: (v) => capabilitySubgroupItemsPageNumber = v,
    syncPagination: _syncCapabilitySubgroupItemsPagination,
  );

  void setCapabilitySubgroupItemsPageSize(int value) => applyTablePageSize(
    currentPageSize: capabilitySubgroupItemsPageSize,
    value: value,
    setPageNumber: (v) => capabilitySubgroupItemsPageNumber = v,
    setPageSize: (v) => capabilitySubgroupItemsPageSize = v,
    syncPagination: _syncCapabilitySubgroupItemsPagination,
  );

  void _applyCapabilities(List<CapabilityDto> capabilities) {
    capabilityGroups
      ..clear()
      ..addAll(capabilities);
    capabilitySubgroup.clear();
    resetSubgroupItems();
    capabilityOptions
      ..clear()
      ..addAll(_buildCapabilitiesOptions(capabilities));
    notifyListeners();
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

  void _syncCapabilitySubgroupItemsPagination() {
    syncTablePaginationValues(
      totalItems: capabilitySubgroupItems.length,
      pageNumber: capabilitySubgroupItemsPageNumber,
      pageSize: capabilitySubgroupItemsPageSize,
      defaultPageSize: _defaultCapabilitySubgroupItemsPageSize,
      setPageNumber: (v) => capabilitySubgroupItemsPageNumber = v,
      setPageSize: (v) => capabilitySubgroupItemsPageSize = v,
      onTotalItemsResolved: (value) =>
          capabilitySubgroupItemsTotalItems = value,
    );
    notifyListeners();
  }
}
