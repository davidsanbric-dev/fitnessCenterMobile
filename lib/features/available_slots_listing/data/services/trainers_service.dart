import 'package:fitnesscenter_mobile/app/core/api/trainers_api.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainer_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/trainer/trainers_request.dart';
import 'package:fitnesscenter_mobile/app/core/utils/lookup.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';

class TrainersDirectory {
  const TrainersDirectory({
    required this.trainers,
    required Map<String, String> trainerNameToId,
    required Map<String, int> trainerNameToDisciplineId,
    required Map<String, String> trainerNameToDisciplineLabel,
  }) : _trainerNameToId = trainerNameToId,
       _trainerNameToDisciplineId = trainerNameToDisciplineId,
       _trainerNameToDisciplineLabel = trainerNameToDisciplineLabel;

  const TrainersDirectory.empty()
    : trainers = const <String>[],
      _trainerNameToId = const <String, String>{},
      _trainerNameToDisciplineId = const <String, int>{},
      _trainerNameToDisciplineLabel = const <String, String>{};

  final List<String> trainers;
  final Map<String, String> _trainerNameToId;
  final Map<String, int> _trainerNameToDisciplineId;
  final Map<String, String> _trainerNameToDisciplineLabel;

  bool get isEmpty => trainers.isEmpty;

  String? resolveTrainerId(String label) =>
      _trainerNameToId[normalizeKey(label)];

  int? resolveTrainerDisciplineId(String label) =>
      _trainerNameToDisciplineId[normalizeKey(label)];

  String? resolveTrainerDisciplineLabel(String label) =>
      _trainerNameToDisciplineLabel[normalizeKey(label)];
}

class TrainersService {
  TrainersService({TrainersApi? trainersApi})
    : _trainersApi = trainersApi ?? TrainersApi();

  final TrainersApi _trainersApi;

  Future<TrainersDirectory> loadAllTrainers() async {
    final trainersData = await _trainersApi.getTrainers(
      const TrainersRequest(),
    );

    final validTrainers = trainersData
        .where(
          (item) =>
              item.trainerId.trim().isNotEmpty &&
              item.trainerName.trim().isNotEmpty,
        )
        .toList(growable: false);

    return TrainersDirectory(
      trainers: normalizeStringList(
        validTrainers.map((item) => item.trainerName).toList(),
      ),
      trainerNameToId: _buildTrainerIdLookup(validTrainers),
      trainerNameToDisciplineId: _buildDisciplineIdLookup(validTrainers),
      trainerNameToDisciplineLabel: _buildDisciplineLabelLookup(validTrainers),
    );
  }

  Map<String, String> _buildTrainerIdLookup(List<TrainerDto> trainersData) {
    return buildNormalizedLookupMap<TrainerDto, String>(
      data: trainersData,
      labelSelector: (item) => item.trainerName,
      valueSelector: (item) {
        final value = item.trainerId.trim();
        return value.isEmpty ? null : value;
      },
    );
  }

  Map<String, int> _buildDisciplineIdLookup(List<TrainerDto> trainersData) {
    return buildNormalizedLookupMap<TrainerDto, int>(
      data: trainersData,
      labelSelector: (item) => item.trainerName,
      valueSelector: (item) => item.disciplineId,
      isValueValid: (value) => value != 0,
    );
  }

  Map<String, String> _buildDisciplineLabelLookup(
    List<TrainerDto> trainersData,
  ) {
    return buildNormalizedLookupMap<TrainerDto, String>(
      data: trainersData,
      labelSelector: (item) => item.trainerName,
      valueSelector: (item) {
        final value = item.disciplineName.trim();
        return value.isEmpty ? null : value;
      },
    );
  }
}
