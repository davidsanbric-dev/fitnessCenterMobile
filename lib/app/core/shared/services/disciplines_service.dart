import 'package:fitnesscenter_mobile/app/core/api/available_slots_api.dart';
import 'package:fitnesscenter_mobile/app/core/api/shared/types.dart';
import 'package:fitnesscenter_mobile/app/core/api/disciplines_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slots_request.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/utils/lookup.dart';

class DisciplinesService {
  DisciplinesService({
    DisciplinesApi? disciplinesApi,
    AvailableSlotsApi? availableSlotsApi,
  }) : _disciplinesApi = disciplinesApi ?? DisciplinesApi(),
       _availableSlotsApi = availableSlotsApi ?? AvailableSlotsApi();

  final DisciplinesApi _disciplinesApi;
  final AvailableSlotsApi _availableSlotsApi;

  Future<DisciplinesFilterData> fetchDisciplinesFilterData() async {
    final disciplinesResult = await _disciplinesApi.getDisciplines();
    final validDisciplines = disciplinesResult.items
        .where(
          (item) =>
              item.disciplineId != 0 && item.disciplineName.trim().isNotEmpty,
        )
        .toList(growable: false);

    return DisciplinesFilterData(
      disciplines: validDisciplines
          .map((item) => item.disciplineName)
          .toList(growable: false),
      disciplineNameToId: buildNormalizedLookupMap<DisciplineDto, int>(
        data: validDisciplines,
        labelSelector: (item) => item.disciplineName,
        valueSelector: (item) => item.disciplineId,
        isValueValid: (value) => value != 0,
      ),
    );
  }

  Future<PaginatedResult<DisciplineDto>> fetchDisciplines({
    int? pageNumber,
    int? pageSize,
  }) {
    return _disciplinesApi.getDisciplines(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  Future<List<AvailableSlotDto>> fetchAvailableBookingsByDiscipline({
    required int disciplineId,
  }) {
    return _availableSlotsApi.getAvailableBookings(
      AvailableSlotsRequest(disciplineId: disciplineId),
    );
  }
}

class DisciplinesFilterData {
  const DisciplinesFilterData({
    required this.disciplines,
    required this.disciplineNameToId,
  });

  final List<String> disciplines;
  final Map<String, int> disciplineNameToId;
}
