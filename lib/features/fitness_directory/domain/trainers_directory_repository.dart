import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';

class TrainersDirectoryFilterData {
  const TrainersDirectoryFilterData({
    this.disciplines = const <DisciplineDto>[],
    this.memberships = const <MembershipDto>[],
    required this.options,
  });

  final List<DisciplineDto> disciplines;
  final List<MembershipDto> memberships;
  final List<String> options;
}

abstract interface class TrainersDirectoryRepository {
  Future<TrainersDirectoryFilterData> fetchTrainersFilterData({
    required TrainersSearchMode mode,
  });

  Future<List<TrainerDirectoryDto>> fetchAllTrainers();

  Future<List<TrainerDirectoryDto>> fetchTrainersByDiscipline({
    required String filterLabel,
    required int locationId,
    required Iterable<DisciplineDto> disciplines,
  });

  Future<List<TrainerDirectoryDto>> fetchTrainersByMembership({
    required String filterLabel,
    required int locationId,
    required Iterable<MembershipDto> memberships,
  });

  Future<List<AvailableSlotDto>> fetchTrainerAvailability({
    required String trainerId,
    required int disciplineId,
    required int locationId,
  });
}
