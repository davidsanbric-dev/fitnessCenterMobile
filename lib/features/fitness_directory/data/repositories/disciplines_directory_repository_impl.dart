import 'package:fitnesscenter_mobile/app/core/api/shared/types.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/services/disciplines_service.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';

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
  }) {
    return _service.fetchAvailableBookingsByDiscipline(
      disciplineId: disciplineId,
    );
  }
}
