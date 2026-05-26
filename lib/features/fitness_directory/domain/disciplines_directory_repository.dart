import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';

abstract interface class DisciplinesDirectoryRepository {
  Future<PaginatedResult<DisciplineDto>> fetchDisciplines({
    int? pageNumber,
    int? pageSize,
  });

  Future<List<AvailableSlotDto>> fetchAvailableBookingsByDiscipline({
    required int disciplineId,
    required int locationId,
  });
}
