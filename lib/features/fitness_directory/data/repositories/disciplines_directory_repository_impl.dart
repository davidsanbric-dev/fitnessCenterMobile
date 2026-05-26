import 'package:portfolio_mobile_app/app/core/api/shared/types.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/disciplines_service.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';

class DisciplinesDirectoryRepositoryImpl
    implements DisciplinesDirectoryRepository {
  DisciplinesDirectoryRepositoryImpl({DisciplinesService? service})
    : _service = service ?? DisciplinesService();

  final DisciplinesService _service;

  @override
  Future<PaginatedResult<DisciplineDto>> fetchDisciplines({
    int? pageNumber,
    int? pageSize,
  }) {
    return _service.fetchDisciplines(
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<List<AvailableSlotDto>> fetchAvailableBookingsByDiscipline({
    required int disciplineId,
    required int locationId,
  }) {
    return _service.fetchAvailableBookingsByDiscipline(
      disciplineId: disciplineId,
      locationId: locationId,
    );
  }
}
