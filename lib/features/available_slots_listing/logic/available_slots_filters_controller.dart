import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/domain/domain.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/logic/capabilities_controller.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/types.dart';
import 'package:get/get.dart';

class AvailableSlotsFiltersController extends ControllerBase {
  AvailableSlotsFiltersController({
    CapabilitiesController? capabilitiesController,
    MemberFiltersRepository? memberFiltersRepository,
  }) : capabilitiesController =
           capabilitiesController ??
           (throw ArgumentError.notNull('capabilitiesController')),
       _memberFiltersRepository =
           memberFiltersRepository ??
           (throw ArgumentError.notNull('memberFiltersRepository'));

  final CapabilitiesController capabilitiesController;
  final MemberFiltersRepository _memberFiltersRepository;

  final RxList<String> disciplines = <String>[].obs;

  final isFiltersLoading = false.obs;
  final hasLoadedFilters = false.obs;
  final hasLoadedCapabilityFilters = false.obs;
  final filtersError = RxnString();

  final Map<String, int> _disciplineNameToId = {};

  RxList<FilterBoxOptionData> get capabilityOptions =>
      capabilitiesController.capabilityOptions;
  RxList<CapabilityDto> get capabilityGroups =>
      capabilitiesController.capabilityGroups;
  RxList<CapabilityDto> get capabilitySubgroup =>
      capabilitiesController.capabilitySubgroup;
  RxList<CapabilityDto> get capabilitySubgroupItems =>
      capabilitiesController.capabilitySubgroupItems;
  List<CapabilityDto> get capabilitySubgroupItemsPageRows =>
      capabilitiesController.capabilitySubgroupItemsPageRows;
  Rxn<CapabilityDto> get selectedCapability =>
      capabilitiesController.selectedCapability;
  RxBool get isCapabilitySubgroupItemsLoading =>
      capabilitiesController.isCapabilitySubgroupItemsLoading;
  RxnString get capabilitySubgroupItemsError =>
      capabilitiesController.capabilitySubgroupItemsError;
  RxInt get capabilitySubgroupItemsPageNumber =>
      capabilitiesController.capabilitySubgroupItemsPageNumber;
  RxInt get capabilitySubgroupItemsPageSize =>
      capabilitiesController.capabilitySubgroupItemsPageSize;
  RxInt get capabilitySubgroupItemsTotalItems =>
      capabilitiesController.capabilitySubgroupItemsTotalItems;
  RxBool get isCapabilityAvailabilityLoading =>
      capabilitiesController.isCapabilityAvailabilityLoading;
  RxnString get capabilityAvailabilityError =>
      capabilitiesController.capabilityAvailabilityError;
  RxInt get capabilityAvailabilityPageNumber =>
      capabilitiesController.capabilityAvailabilityPageNumber;
  RxInt get capabilityAvailabilityPageSize =>
      capabilitiesController.capabilityAvailabilityPageSize;
  RxInt get capabilityAvailabilityTotalItems =>
      capabilitiesController.capabilityAvailabilityTotalItems;
  List<Map<String, dynamic>> get capabilityBookingsTableRows =>
      capabilitiesController.capabilityBookingsTableRows;

  Future<void> ensureFiltersLoaded() async {
    if ((hasLoadedFilters.value && hasLoadedCapabilityFilters.value) ||
        isFiltersLoading.value) {
      return;
    }

    await loadMemberFilters();
  }

  Future<void> loadMemberFilters() async {
    isFiltersLoading.value = true;
    filtersError.value = null;

    try {
      final disciplinesData = await _memberFiltersRepository
          .fetchDisciplinesFilterData();

      disciplines.assignAll(disciplinesData.disciplines);
      _cacheDisciplines(disciplinesData.disciplineNameToId);
      hasLoadedFilters.value = true;
      await capabilitiesController.loadCapabilities();
      hasLoadedCapabilityFilters.value = true;
    } catch (err) {
      hasLoadedFilters.value = true;
      hasLoadedCapabilityFilters.value =
          capabilitiesController.capabilityGroups.isNotEmpty;
      filtersError.value = err.userErrorMessageWith(
        'No se pudieron cargar los filtros',
      );
    } finally {
      isFiltersLoading.value = false;
    }
  }

  Future<void> loadCapabilitySubgroupFor(CapabilityDto group) =>
      capabilitiesController.loadSubgroupFor(
        group: group,
        isLoading: isFiltersLoading,
        error: filtersError,
      );

  void resetCapabilitySubgroup() => capabilitiesController.resetSubgroup();

  Future<void> loadCapabilitySubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) => capabilitiesController.loadSubgroupItemsFor(
    group: group,
    subgroup: subgroup,
  );

  void resetCapabilitySubgroupItems() =>
      capabilitiesController.resetSubgroupItems();

  void setCapabilitySubgroupItemsPageNumber(int value) =>
      capabilitiesController.setCapabilitySubgroupItemsPageNumber(value);

  void setCapabilitySubgroupItemsPageSize(int value) =>
      capabilitiesController.setCapabilitySubgroupItemsPageSize(value);

  Future<void> loadBookingsByCapability(CapabilityDto capability) =>
      capabilitiesController.loadBookingsByCapability(capability);

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) =>
      capabilitiesController.removeBookedCapabilitySlot(slot);

  void resetCapabilityAvailability() =>
      capabilitiesController.resetAvailability();

  void setCapabilityAvailabilityPageNumber(int value) =>
      capabilitiesController.setCapabilityAvailabilityPageNumber(value);

  void setCapabilityAvailabilityPageSize(int value) =>
      capabilitiesController.setCapabilityAvailabilityPageSize(value);

  MemberAvailabilityFilters? buildAvailabilityFilters(
    MemberAvailabilityParams params,
  ) {
    final normalizedService = params.serviceLabel.trim();
    final trimmedPrimarySelection = params.primarySelectionLabel.trim();

    int disciplineId = 0;
    String? trainerId;
    String? disciplineLabel;
    String? trainerLabel;

    if (params.searchMode == DisciplineSearchMode.discipline) {
      final resolvedDisciplineId =
          _disciplineNameToId[normalizeKey(trimmedPrimarySelection)];
      disciplineLabel = trimmedPrimarySelection;

      if (resolvedDisciplineId == null) {
        return null;
      }
      disciplineId = resolvedDisciplineId;
    } else {
      final resolvedTrainerId = params.trainerId?.trim() ?? '';
      trainerId = resolvedTrainerId.isEmpty ? null : resolvedTrainerId;
      trainerLabel = trimmedPrimarySelection;
      disciplineId = 0;
      disciplineLabel = null;
    }

    return MemberAvailabilityFilters(
      serviceLabel: normalizedService,
      disciplineId: disciplineId,
      disciplineLabel: disciplineLabel,
      trainerId: trainerId,
      trainerLabel: trainerLabel,
      searchMode: params.searchMode,
    );
  }

  void _cacheDisciplines(Map<String, int> disciplineNameToId) {
    _disciplineNameToId
      ..clear()
      ..addAll(disciplineNameToId);
  }
}
