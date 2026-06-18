import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/data/repositories/repositories.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/available_slots_availability_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/available_slots_filters_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/capabilities_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:portfolio_mobile_app/app/core/services/push_notification_service.dart';
import 'package:get/get.dart';

class AvailableSlotsController extends ControllerBase {
  factory AvailableSlotsController({
    CapabilitiesController? capabilitiesController,
  }) {
    final availabilityRepository = AvailabilityListingRepositoryImpl();
    final memberFiltersRepository = MemberFiltersRepositoryImpl();
    final capabilitiesCatalogRepository = CapabilitiesCatalogRepositoryImpl();
    final CapabilitiesController resolvedCapabilitiesController =
        capabilitiesController ??
        CapabilitiesController(
          catalogRepository: capabilitiesCatalogRepository,
          availabilityRepository: availabilityRepository,
        );
    final filtersController = AvailableSlotsFiltersController(
      capabilitiesController: resolvedCapabilitiesController,
      memberFiltersRepository: memberFiltersRepository,
    );
    final availabilityController = AvailableSlotsAvailabilityController(
      filtersController: filtersController,
      repository: availabilityRepository,
    );

    return AvailableSlotsController._(
      capabilitiesController: resolvedCapabilitiesController,
      filtersController: filtersController,
      availabilityController: availabilityController,
    );
  }

  AvailableSlotsController._({
    required this.capabilitiesController,
    required this.filtersController,
    required this.availabilityController,
  });

  final CapabilitiesController capabilitiesController;
  final AvailableSlotsFiltersController filtersController;
  final AvailableSlotsAvailabilityController availabilityController;

  @override
  void onInit() {
    super.onInit();
    // Refresh the visible availability when a trainer changes a slot (push), so
    // the member's listing stays in sync without re-applying filters by hand.
    if (Get.isRegistered<PushNotificationService>()) {
      Get.find<PushNotificationService>().setOnSlotsUpdated(
        availabilityController.refreshAvailability,
      );
    }
  }

  RxList<String> get disciplines => filtersController.disciplines;

  RxBool get isFiltersLoading => filtersController.isFiltersLoading;
  RxBool get hasLoadedFilters => filtersController.hasLoadedFilters;
  RxBool get hasLoadedCapabilityFilters =>
      filtersController.hasLoadedCapabilityFilters;
  RxnString get filtersError => filtersController.filtersError;

  RxBool get hasSubmittedAvailabilityRequest =>
      availabilityController.hasSubmittedAvailabilityRequest;
  RxBool get isAvailabilityLoading =>
      availabilityController.isAvailabilityLoading;
  RxnString get availabilityError => availabilityController.availabilityError;
  RxBool get isReservingBooking => availabilityController.isReservingBooking;
  RxnString get reserveBookingError =>
      availabilityController.reserveBookingError;
  RxList<AvailableSlotDto> get availableSlots =>
      availabilityController.availableSlots;
  Rxn<MemberAvailabilityFilters> get lastSubmittedFilters =>
      availabilityController.lastSubmittedFilters;
  RxInt get availabilityPageNumber =>
      availabilityController.availabilityPageNumber;
  RxInt get availabilityPageSize => availabilityController.availabilityPageSize;
  RxInt get availabilityTotalItems =>
      availabilityController.availabilityTotalItems;

  RxList<FilterBoxOptionData> get capabilityOptions =>
      filtersController.capabilityOptions;
  RxList<CapabilityDto> get capabilityGroups =>
      filtersController.capabilityGroups;
  RxList<CapabilityDto> get capabilitySubgroup =>
      filtersController.capabilitySubgroup;
  RxList<CapabilityDto> get capabilitySubgroupItems =>
      filtersController.capabilitySubgroupItems;
  List<CapabilityDto> get capabilitySubgroupItemsPageRows =>
      filtersController.capabilitySubgroupItemsPageRows;
  Rxn<CapabilityDto> get selectedCapability =>
      filtersController.selectedCapability;
  RxBool get isCapabilitySubgroupItemsLoading =>
      filtersController.isCapabilitySubgroupItemsLoading;
  RxnString get capabilitySubgroupItemsError =>
      filtersController.capabilitySubgroupItemsError;
  RxInt get capabilitySubgroupItemsPageNumber =>
      filtersController.capabilitySubgroupItemsPageNumber;
  RxInt get capabilitySubgroupItemsPageSize =>
      filtersController.capabilitySubgroupItemsPageSize;
  RxInt get capabilitySubgroupItemsTotalItems =>
      filtersController.capabilitySubgroupItemsTotalItems;
  RxBool get isCapabilityAvailabilityLoading =>
      filtersController.isCapabilityAvailabilityLoading;
  RxnString get capabilityAvailabilityError =>
      filtersController.capabilityAvailabilityError;
  RxInt get capabilityAvailabilityPageNumber =>
      filtersController.capabilityAvailabilityPageNumber;
  RxInt get capabilityAvailabilityPageSize =>
      filtersController.capabilityAvailabilityPageSize;
  RxInt get capabilityAvailabilityTotalItems =>
      filtersController.capabilityAvailabilityTotalItems;
  List<Map<String, dynamic>> get capabilityBookingsTableRows =>
      filtersController.capabilityBookingsTableRows;
  List<Map<String, dynamic>> get availableSlotsTableRows =>
      availabilityController.availableSlotsTableRows;

  Future<void> ensureFiltersLoaded() => filtersController.ensureFiltersLoaded();

  Future<void> loadMemberFilters() => filtersController.loadMemberFilters();

  Future<void> consultAvailability(MemberAvailabilityParams params) =>
      availabilityController.consultAvailability(params);

  void removeBookedAvailabilitySlot(AvailableSlotDto slot) =>
      availabilityController.removeBookedAvailabilitySlot(slot);

  Future<void> loadCapabilitySubgroupFor(CapabilityDto group) =>
      filtersController.loadCapabilitySubgroupFor(group);

  void resetCapabilitySubgroup() => filtersController.resetCapabilitySubgroup();

  Future<void> loadCapabilitySubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) => filtersController.loadCapabilitySubgroupItemsFor(
    group: group,
    subgroup: subgroup,
  );

  void resetCapabilitySubgroupItems() =>
      filtersController.resetCapabilitySubgroupItems();

  void setCapabilitySubgroupItemsPageNumber(int value) =>
      filtersController.setCapabilitySubgroupItemsPageNumber(value);

  void setCapabilitySubgroupItemsPageSize(int value) =>
      filtersController.setCapabilitySubgroupItemsPageSize(value);

  void resetAvailabilityView() =>
      availabilityController.resetAvailabilityView();

  Future<void> loadBookingsByCapability(CapabilityDto capability) =>
      filtersController.loadBookingsByCapability(capability);

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) =>
      filtersController.removeBookedCapabilitySlot(slot);

  void resetCapabilityAvailability() =>
      filtersController.resetCapabilityAvailability();

  void setCapabilityAvailabilityPageNumber(int value) =>
      filtersController.setCapabilityAvailabilityPageNumber(value);

  void setCapabilityAvailabilityPageSize(int value) =>
      filtersController.setCapabilityAvailabilityPageSize(value);

  void setAvailabilityPageNumber(int value) =>
      availabilityController.setAvailabilityPageNumber(value);

  void setAvailabilityPageSize(int value) =>
      availabilityController.setAvailabilityPageSize(value);
}
