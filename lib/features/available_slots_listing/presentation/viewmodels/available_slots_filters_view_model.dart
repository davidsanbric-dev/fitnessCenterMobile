import 'package:fitnesscenter_mobile/app/core/exceptions/error_message.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_by_capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/capabilities/capability_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/filter_boxes/filter_box.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/presentation/viewmodels/capabilities_view_model.dart';
import 'package:fitnesscenter_mobile/features/available_slots_listing/types.dart';

class AvailableSlotsFiltersViewModel extends ViewModelBase {
  AvailableSlotsFiltersViewModel({
    CapabilitiesViewModel? capabilitiesViewModel,
    MemberFiltersRepository? memberFiltersRepository,
  }) : capabilitiesViewModel =
           capabilitiesViewModel ??
           (throw ArgumentError.notNull('capabilitiesViewModel')),
       _memberFiltersRepository =
           memberFiltersRepository ??
           (throw ArgumentError.notNull('memberFiltersRepository'));

  final CapabilitiesViewModel capabilitiesViewModel;
  final MemberFiltersRepository _memberFiltersRepository;

  final List<String> disciplines = <String>[];

  bool isFiltersLoading = false;
  bool hasLoadedFilters = false;
  bool hasLoadedCapabilityFilters = false;
  String? filtersError;

  final Map<String, int> _disciplineNameToId = {};

  List<FilterBoxOptionData> get capabilityOptions =>
      capabilitiesViewModel.capabilityOptions;
  List<CapabilityDto> get capabilityGroups =>
      capabilitiesViewModel.capabilityGroups;
  List<CapabilityDto> get capabilitySubgroup =>
      capabilitiesViewModel.capabilitySubgroup;
  List<CapabilityDto> get capabilitySubgroupItems =>
      capabilitiesViewModel.capabilitySubgroupItems;
  List<CapabilityDto> get capabilitySubgroupItemsPageRows =>
      capabilitiesViewModel.capabilitySubgroupItemsPageRows;
  CapabilityDto? get selectedCapability =>
      capabilitiesViewModel.selectedCapability;
  bool get isCapabilitySubgroupItemsLoading =>
      capabilitiesViewModel.isCapabilitySubgroupItemsLoading;
  String? get capabilitySubgroupItemsError =>
      capabilitiesViewModel.capabilitySubgroupItemsError;
  int get capabilitySubgroupItemsPageNumber =>
      capabilitiesViewModel.capabilitySubgroupItemsPageNumber;
  int get capabilitySubgroupItemsPageSize =>
      capabilitiesViewModel.capabilitySubgroupItemsPageSize;
  int get capabilitySubgroupItemsTotalItems =>
      capabilitiesViewModel.capabilitySubgroupItemsTotalItems;
  bool get isCapabilityAvailabilityLoading =>
      capabilitiesViewModel.isCapabilityAvailabilityLoading;
  String? get capabilityAvailabilityError =>
      capabilitiesViewModel.capabilityAvailabilityError;
  int get capabilityAvailabilityPageNumber =>
      capabilitiesViewModel.capabilityAvailabilityPageNumber;
  int get capabilityAvailabilityPageSize =>
      capabilitiesViewModel.capabilityAvailabilityPageSize;
  int get capabilityAvailabilityTotalItems =>
      capabilitiesViewModel.capabilityAvailabilityTotalItems;
  List<Map<String, dynamic>> get capabilityBookingsTableRows =>
      capabilitiesViewModel.capabilityBookingsTableRows;

  Future<void> ensureFiltersLoaded() async {
    if ((hasLoadedFilters && hasLoadedCapabilityFilters) || isFiltersLoading) {
      return;
    }

    await loadMemberFilters();
  }

  Future<void> loadMemberFilters() async {
    isFiltersLoading = true;
    filtersError = null;
    notifyListeners();

    try {
      final disciplinesData = await _memberFiltersRepository
          .fetchDisciplinesFilterData();

      disciplines
        ..clear()
        ..addAll(disciplinesData.disciplines);
      _cacheDisciplines(disciplinesData.disciplineNameToId);
      hasLoadedFilters = true;
      await capabilitiesViewModel.loadCapabilities();
      hasLoadedCapabilityFilters = true;
    } catch (err) {
      hasLoadedFilters = true;
      hasLoadedCapabilityFilters =
          capabilitiesViewModel.capabilityGroups.isNotEmpty;
      filtersError = err.userErrorMessageWith(
        'No se pudieron cargar los filtros',
      );
    } finally {
      isFiltersLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCapabilitySubgroupFor(CapabilityDto group) =>
      capabilitiesViewModel.loadSubgroupFor(
        group: group,
        setLoading: _setFiltersLoading,
        setError: _setFiltersError,
      );

  void resetCapabilitySubgroup() => capabilitiesViewModel.resetSubgroup();

  Future<void> loadCapabilitySubgroupItemsFor({
    required CapabilityDto group,
    required CapabilityDto subgroup,
  }) => capabilitiesViewModel.loadSubgroupItemsFor(
    group: group,
    subgroup: subgroup,
  );

  void resetCapabilitySubgroupItems() =>
      capabilitiesViewModel.resetSubgroupItems();

  void setCapabilitySubgroupItemsPageNumber(int value) =>
      capabilitiesViewModel.setCapabilitySubgroupItemsPageNumber(value);

  void setCapabilitySubgroupItemsPageSize(int value) =>
      capabilitiesViewModel.setCapabilitySubgroupItemsPageSize(value);

  Future<void> loadBookingsByCapability(CapabilityDto capability) =>
      capabilitiesViewModel.loadBookingsByCapability(capability);

  void removeBookedCapabilitySlot(AvailableSlotByCapabilityDto slot) =>
      capabilitiesViewModel.removeBookedCapabilitySlot(slot);

  void resetCapabilityAvailability() =>
      capabilitiesViewModel.resetAvailability();

  void setCapabilityAvailabilityPageNumber(int value) =>
      capabilitiesViewModel.setCapabilityAvailabilityPageNumber(value);

  void setCapabilityAvailabilityPageSize(int value) =>
      capabilitiesViewModel.setCapabilityAvailabilityPageSize(value);

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

  void _setFiltersLoading(bool value) {
    isFiltersLoading = value;
    notifyListeners();
  }

  void _setFiltersError(String? message) {
    filtersError = message;
    notifyListeners();
  }

  void _cacheDisciplines(Map<String, int> disciplineNameToId) {
    _disciplineNameToId
      ..clear()
      ..addAll(disciplineNameToId);
  }
}
