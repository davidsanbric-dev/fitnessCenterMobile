import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:fitnesscenter_mobile/app/core/services/push_notification_service.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/data/repositories/repositories.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/viewmodels/available_slots_availability_view_model.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/viewmodels/available_slots_filters_view_model.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/viewmodels/capabilities_view_model.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Facade view-model aggregating the capabilities/filters/availability
/// view-models behind a single [Listenable], so a `ListenableBuilder` bound to
/// it rebuilds when any sub view-model changes.
class AvailableSlotsViewModel extends ChangeNotifier {
  factory AvailableSlotsViewModel({
    CapabilitiesViewModel? capabilitiesViewModel,
  }) {
    final availabilityRepository = AvailabilityListingRepositoryImpl();
    final memberFiltersRepository = MemberFiltersRepositoryImpl();
    final capabilitiesCatalogRepository = CapabilitiesCatalogRepositoryImpl();
    final CapabilitiesViewModel resolvedCapabilitiesViewModel =
        capabilitiesViewModel ??
        CapabilitiesViewModel(
          catalogRepository: capabilitiesCatalogRepository,
          availabilityRepository: availabilityRepository,
        );
    final filtersViewModel = AvailableSlotsFiltersViewModel(
      capabilitiesViewModel: resolvedCapabilitiesViewModel,
      memberFiltersRepository: memberFiltersRepository,
    );
    final availabilityViewModel = AvailableSlotsAvailabilityViewModel(
      filtersViewModel: filtersViewModel,
      repository: availabilityRepository,
    );

    return AvailableSlotsViewModel._(
      capabilitiesViewModel: resolvedCapabilitiesViewModel,
      filtersViewModel: filtersViewModel,
      availabilityViewModel: availabilityViewModel,
    );
  }

  AvailableSlotsViewModel._({
    required this.capabilitiesViewModel,
    required this.filtersViewModel,
    required this.availabilityViewModel,
  }) {
    capabilitiesViewModel.addListener(notifyListeners);
    filtersViewModel.addListener(notifyListeners);
    availabilityViewModel.addListener(notifyListeners);
    // Refresh the visible availability when a trainer changes a slot (push), so
    // the member's listing stays in sync without re-applying filters by hand.
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().setOnSlotsUpdated(
        availabilityViewModel.refreshAvailability,
      );
    }
  }

  final CapabilitiesViewModel capabilitiesViewModel;
  final AvailableSlotsFiltersViewModel filtersViewModel;
  final AvailableSlotsAvailabilityViewModel availabilityViewModel;

  @override
  void dispose() {
    capabilitiesViewModel.removeListener(notifyListeners);
    filtersViewModel.removeListener(notifyListeners);
    availabilityViewModel.removeListener(notifyListeners);
    super.dispose();
  }

  List<String> get disciplines => filtersViewModel.disciplines;

  bool get isFiltersLoading => filtersViewModel.isFiltersLoading;
  bool get hasLoadedFilters => filtersViewModel.hasLoadedFilters;
  bool get hasLoadedCapabilityFilters =>
      filtersViewModel.hasLoadedCapabilityFilters;
  String? get filtersError => filtersViewModel.filtersError;

  bool get hasSubmittedAvailabilityRequest =>
      availabilityViewModel.hasSubmittedAvailabilityRequest;
  bool get isAvailabilityLoading => availabilityViewModel.isAvailabilityLoading;
  String? get availabilityError => availabilityViewModel.availabilityError;
  bool get isReservingBooking => availabilityViewModel.isReservingBooking;
  String? get reserveBookingError => availabilityViewModel.reserveBookingError;
  List<AvailableSlotDto> get availableSlots =>
      availabilityViewModel.availableSlots;
  MemberAvailabilityFilters? get lastSubmittedFilters =>
      availabilityViewModel.lastSubmittedFilters;
  int get availabilityPageNumber =>
      availabilityViewModel.availabilityPageNumber;
  int get availabilityPageSize => availabilityViewModel.availabilityPageSize;
  int get availabilityTotalItems =>
      availabilityViewModel.availabilityTotalItems;

  List<FilterBoxOptionData> get capabilityOptions =>
      filtersViewModel.capabilityOptions;
  List<CapabilityDto> get capabilityGroups => filtersViewModel.capabilityGroups;
  List<CapabilityDto> get capabilitySubgroup =>
      filtersViewModel.capabilitySubgroup;
  List<CapabilityDto> get capabilitySubgroupItems =>
      filtersViewModel.capabilitySubgroupItems;
  List<CapabilityDto> get capabilitySubgroupItemsPageRows =>
      filtersViewModel.capabilitySubgroupItemsPageRows;
  CapabilityDto? get selectedCapability => filtersViewModel.selectedCapability;
  bool get isCapabilitySubgroupItemsLoading =>
      filtersViewModel.isCapabilitySubgroupItemsLoading;
  String? get capabilitySubgroupItemsError =>
      filtersViewModel.capabilitySubgroupItemsError;
  int get capabilitySubgroupItemsPageNumber =>
      filtersViewModel.capabilitySubgroupItemsPageNumber;
  int get capabilitySubgroupItemsPageSize =>
      filtersViewModel.capabilitySubgroupItemsPageSize;
  int get capabilitySubgroupItemsTotalItems =>
      filtersViewModel.capabilitySubgroupItemsTotalItems;
  bool get isCapabilityAvailabilityLoading =>
      filtersViewModel.isCapabilityAvailabilityLoading;
  String? get capabilityAvailabilityError =>
      filtersViewModel.capabilityAvailabilityError;
  int get capabilityAvailabilityPageNumber =>
      filtersViewModel.capabilityAvailabilityPageNumber;
  int get capabilityAvailabilityPageSize =>
      filtersViewModel.capabilityAvailabilityPageSize;
  int get capabilityAvailabilityTotalItems =>
      filtersViewModel.capabilityAvailabilityTotalItems;
  List<Map<String, dynamic>> get capabilityBookingsTableRows =>
      filtersViewModel.capabilityBookingsTableRows;
  List<Map<String, dynamic>> get availableSlotsTableRows =>
      availabilityViewModel.availableSlotsTableRows;

  Future<void> ensureFiltersLoaded() => filtersViewModel.ensureFiltersLoaded();

  Future<void> loadMemberFilters() => filtersViewModel.loadMemberFilters();

  Future<void> consultAvailability(MemberAvailabilityParams params) =>
      availabilityViewModel.consultAvailability(params);

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) =>
      availabilityViewModel.removeBookedAvailabilitySlot(slot);

  Future<void> loadCapabilitySubgroupFor(CapabilityDto group) =>
      filtersViewModel.loadCapabilitySubgroupFor(group);

  void resetCapabilitySubgroup() => filtersViewModel.resetCapabilitySubgroup();

  Future<void> loadCapabilitySubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) => filtersViewModel.loadCapabilitySubgroupItemsFor(
    group: group,
    subgroup: subgroup,
  );

  void resetCapabilitySubgroupItems() =>
      filtersViewModel.resetCapabilitySubgroupItems();

  void setCapabilitySubgroupItemsPageNumber(int value) =>
      filtersViewModel.setCapabilitySubgroupItemsPageNumber(value);

  void setCapabilitySubgroupItemsPageSize(int value) =>
      filtersViewModel.setCapabilitySubgroupItemsPageSize(value);

  void resetAvailabilityView() => availabilityViewModel.resetAvailabilityView();

  Future<void> loadBookingsByCapability(CapabilityDto capability) =>
      filtersViewModel.loadBookingsByCapability(capability);

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) =>
      filtersViewModel.removeBookedCapabilitySlot(slot);

  void resetCapabilityAvailability() =>
      filtersViewModel.resetCapabilityAvailability();

  void setCapabilityAvailabilityPageNumber(int value) =>
      filtersViewModel.setCapabilityAvailabilityPageNumber(value);

  void setCapabilityAvailabilityPageSize(int value) =>
      filtersViewModel.setCapabilityAvailabilityPageSize(value);

  void setAvailabilityPageNumber(int value) =>
      availabilityViewModel.setAvailabilityPageNumber(value);

  void setAvailabilityPageSize(int value) =>
      availabilityViewModel.setAvailabilityPageSize(value);
}
