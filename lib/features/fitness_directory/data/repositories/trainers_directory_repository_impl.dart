import 'package:fitnesscenter_mobile/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/domain/domain.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/data/services/trainers_service.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/types.dart';

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
  Future<List<TrainerDirectoryDto>> fetchAllTrainers() {
    return _service.fetchAllTrainers();
  }

  @override
  Future<List<TrainerDirectoryDto>> fetchTrainersByDiscipline({
    required String filterLabel,
    required Iterable<DisciplineDto> disciplines,
  }) {
    return _service.fetchTrainersByDiscipline(
      filterLabel: filterLabel,
      disciplines: disciplines,
    );
  }

  @override
  Future<List<TrainerDirectoryDto>> fetchTrainersByMembership({
    required String filterLabel,
    required Iterable<MembershipDto> memberships,
  }) {
    return _service.fetchTrainersByMembership(
      filterLabel: filterLabel,
      memberships: memberships,
    );
  }

  @override
  Future<List<AvailableSlotDto>> fetchTrainerAvailability({
    required String trainerId,
    required int disciplineId,
  }) {
    return _service.fetchTrainerAvailability(
      trainerId: trainerId,
      disciplineId: disciplineId,
    );
  }
}
