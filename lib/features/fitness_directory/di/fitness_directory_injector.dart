import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/fitness_directory/feature.dart';

class FitnessDirectoryInjector {
  static FitnessDirectoryViewModel getFitnessDirectoryViewModel() => getOrPut(
    () => FitnessDirectoryViewModel(
      repository: MembershipsDirectoryRepositoryImpl(),
    ),
  );

  static DisciplinesDirectoryViewModel getDisciplinesDirectoryViewModel() =>
      getOrPut(
        () => DisciplinesDirectoryViewModel(
          repository: DisciplinesDirectoryRepositoryImpl(),
        ),
      );

  static TrainersViewModel getTrainersViewModel() => getOrPut(
    () => TrainersViewModel(repository: TrainersDirectoryRepositoryImpl()),
  );

  static CapabilitiesViewModel getCapabilitiesViewModel() => getOrPut(
    () => CapabilitiesViewModel(
      repository: CapabilitiesDirectoryRepositoryImpl(),
    ),
  );
}
