import 'package:fitnesscenter_mobile/app/core/api/shared/types.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';

abstract interface class DisciplinesDirectoryRepository {
  Future<PaginatedResult<DisciplineDto>> fetchDisciplines({
    int? pageNumber,
    int? pageSize,
  });

  Future<List<AvailableSlotDto>> fetchAvailableBookingsByDiscipline({
    required int disciplineId,
  });
}
