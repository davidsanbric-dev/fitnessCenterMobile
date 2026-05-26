import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/domain/domain.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/logic/services/trainers_service.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';

class TrainersDirectoryRepositoryImpl implements TrainersDirectoryRepository {
  TrainersDirectoryRepositoryImpl({TrainersService? service})
    : _service = service ?? TrainersService();

  final TrainersService _service;

  @override
  Future<TrainersDirectoryFilterData> fetchTrainersFilterData({
    required TrainersSearchMode mode,
  }) async {
    final data = await _service.fetchTrainersFilterData(mode: mode);
    return TrainersDirectoryFilterData(
      disciplines: data.disciplines,
      memberships: data.memberships,
      options: data.options,
    );
  }

  @override
  Future<List<TrainerDirectoryDto>> fetchTrainersByDiscipline({
    required String filterLabel,
    required int locationId,
    required Iterable<DisciplineDto> disciplines,
  }) {
    return _service.fetchTrainersByDiscipline(
      filterLabel: filterLabel,
      locationId: locationId,
      disciplines: disciplines,
    );
  }

  @override
  Future<List<TrainerDirectoryDto>> fetchTrainersByMembership({
    required String filterLabel,
    required int locationId,
    required Iterable<MembershipDto> memberships,
  }) {
    return _service.fetchTrainersByMembership(
      filterLabel: filterLabel,
      locationId: locationId,
      memberships: memberships,
    );
  }

  @override
  Future<List<AvailableSlotDto>> fetchTrainerAvailability({
    required String trainerId,
    required int disciplineId,
    required int locationId,
  }) {
    return _service.fetchTrainerAvailability(
      trainerId: trainerId,
      disciplineId: disciplineId,
      locationId: locationId,
    );
  }
}
