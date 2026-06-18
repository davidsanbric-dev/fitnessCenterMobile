import 'package:portfolio_mobile_app/app/core/api/available_slots_api.dart';
import 'package:portfolio_mobile_app/app/core/api/memberships_api.dart';
import 'package:portfolio_mobile_app/app/core/api/trainers_api.dart';
import 'package:portfolio_mobile_app/app/core/api/disciplines_api.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slot_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/available_slots/available_slots_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/memberships/membership_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainer_directory_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainers_by_membership_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/trainer/trainers_request.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/disciplines/discipline_dto.dart';
import 'package:portfolio_mobile_app/features/fitness_directory/types.dart';

class TrainersService {
  TrainersService({
    AvailableSlotsApi? availableSlotsApi,
    MembershipsApi? membershipsApi,
    TrainersApi? trainersApi,
    DisciplinesApi? disciplinesApi,
  }) : _availableSlotsApi = availableSlotsApi ?? AvailableSlotsApi(),
       _membershipsApi = membershipsApi ?? MembershipsApi(),
       _trainersApi = trainersApi ?? TrainersApi(),
       _disciplinesApi = disciplinesApi ?? DisciplinesApi();

  static const Duration trainersLoadTimeout = Duration(seconds: 20);

  final AvailableSlotsApi _availableSlotsApi;
  final MembershipsApi _membershipsApi;
  final TrainersApi _trainersApi;
  final DisciplinesApi _disciplinesApi;

  Future<TrainersFilterData> fetchTrainersFilterData({
    required TrainersSearchMode mode,
  }) async {
    if (mode == TrainersSearchMode.discipline) {
      final response = await _disciplinesApi.getDisciplines().timeout(
        trainersLoadTimeout,
        onTimeout: () => throw const ApiException(
          'Timed out while loading discipline filters.',
        ),
      );
      return TrainersFilterData(
        disciplines: response.items,
        options: response.items
            .map((item) => item.disciplineName)
            .toList(growable: false),
      );
    }

    final response = await _membershipsApi.getMemberships().timeout(
      trainersLoadTimeout,
      onTimeout: () => throw const ApiException(
        'Timed out while loading membership plan filters.',
      ),
    );
    return TrainersFilterData(
      memberships: response,
      options: response
          .map((item) => item.membershipName)
          .toList(growable: false),
    );
  }

  Future<List<TrainerDirectoryDto>> fetchAllTrainers() async {
    // No discipline filter: the API returns every active trainer when
    // ``discipline_id`` is omitted. Each trainer carries its own discipline in
    // the response, so we map them straight through.
    final response = await _trainersApi
        .getTrainers(const TrainersRequest())
        .timeout(
          trainersLoadTimeout,
          onTimeout: () =>
              throw const ApiException('Timed out while loading trainers.'),
        );

    final mapped = response
        .map(
          (trainer) => TrainerDirectoryDto(
            membershipId: '',
            membershipName: '',
            trainerId: trainer.trainerId,
            trainerName: trainer.trainerName,
            disciplineId: trainer.disciplineId,
            disciplineName: trainer.disciplineName,
            bio: trainer.bio,
            photoUrl: trainer.photoUrl,
          ),
        )
        .toList(growable: false);

    if (mapped.isEmpty) {
      throw const ApiException('No trainers were found.');
    }

    return mapped;
  }

  Future<List<TrainerDirectoryDto>> fetchTrainersByDiscipline({
    required String filterLabel,
    required Iterable<DisciplineDto> disciplines,
  }) async {
    final discipline = _findDisciplineByLabel(
      disciplines: disciplines,
      filterLabel: filterLabel,
    );

    final response = await _trainersApi
        .getTrainers(
          TrainersRequest(
            disciplineCode: discipline.disciplineId,
          ),
        )
        .timeout(
          trainersLoadTimeout,
          onTimeout: () => throw const ApiException(
            'Timed out while loading trainers by discipline.',
          ),
        );

    final mapped = response
        .map(
          (trainer) => TrainerDirectoryDto(
            membershipId: '',
            membershipName: '',
            trainerId: trainer.trainerId,
            trainerName: trainer.trainerName,
            disciplineId: discipline.disciplineId,
            disciplineName: discipline.disciplineName,
            bio: trainer.bio,
            photoUrl: trainer.photoUrl,
          ),
        )
        .toList(growable: false);

    if (mapped.isEmpty) {
      throw ApiException('No trainers were found for "$filterLabel".');
    }

    return mapped;
  }

  Future<List<TrainerDirectoryDto>> fetchTrainersByMembership({
    required String filterLabel,
    required Iterable<MembershipDto> memberships,
  }) async {
    final membership = _findMembershipByLabel(
      memberships: memberships,
      filterLabel: filterLabel,
    );

    final response = await _trainersApi
        .getTrainersByMembership(
          TrainersByMembershipRequest(
            membershipId: membership.membershipId,
            disciplineCode: 0,
          ),
        )
        .timeout(
          trainersLoadTimeout,
          onTimeout: () => throw const ApiException(
            'Timed out while loading trainers by membership plan.',
          ),
        );

    final mapped = response
        .map(
          (trainer) => TrainerDirectoryDto(
            membershipId: membership.membershipId,
            membershipName: membership.membershipName,
            trainerId: trainer.trainerId,
            trainerName: trainer.trainerName,
            disciplineId: 0,
            disciplineName: '',
            bio: trainer.bio,
            photoUrl: trainer.photoUrl,
          ),
        )
        .toList(growable: false);

    if (mapped.isEmpty) {
      throw ApiException('No trainers were found for "$filterLabel".');
    }

    return mapped;
  }

  Future<List<AvailableSlotDto>> fetchTrainerAvailability({
    required String trainerId,
    required int disciplineId,
  }) {
    return _availableSlotsApi.getAvailableBookings(
      AvailableSlotsRequest(
        disciplineId: disciplineId,
        trainerId: trainerId,
      ),
    );
  }

  DisciplineDto _findDisciplineByLabel({
    required Iterable<DisciplineDto> disciplines,
    required String filterLabel,
  }) {
    final normalizedLabel = filterLabel.trim().toLowerCase();
    for (final discipline in disciplines) {
      if (discipline.disciplineName.trim().toLowerCase() == normalizedLabel) {
        return discipline;
      }
    }
    throw ApiException('Discipline "$filterLabel" was not found.');
  }

  MembershipDto _findMembershipByLabel({
    required Iterable<MembershipDto> memberships,
    required String filterLabel,
  }) {
    final normalizedLabel = filterLabel.trim().toLowerCase();
    for (final membership in memberships) {
      if (membership.membershipName.trim().toLowerCase() == normalizedLabel) {
        return membership;
      }
    }
    throw ApiException('Membership plan "$filterLabel" was not found.');
  }
}

class TrainersFilterData {
  const TrainersFilterData({
    this.disciplines = const <DisciplineDto>[],
    this.memberships = const <MembershipDto>[],
    required this.options,
  });

  final List<DisciplineDto> disciplines;
  final List<MembershipDto> memberships;
  final List<String> options;
}
