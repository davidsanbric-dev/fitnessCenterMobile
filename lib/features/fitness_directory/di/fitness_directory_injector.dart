import 'package:portfolio_mobile_app/features/fitness_directory/feature.dart';
import 'package:get/get.dart';

class FitnessDirectoryInjector {
  static FitnessDirectoryController getFitnessDirectoryController() {
    if (!Get.isRegistered<FitnessDirectoryController>()) {
      Get.put(
        FitnessDirectoryController(
          repository: MembershipsDirectoryRepositoryImpl(),
        ),
      );
    }
    return Get.find<FitnessDirectoryController>();
  }

  static DisciplinesDirectoryController getDisciplinesDirectoryController() {
    if (!Get.isRegistered<DisciplinesDirectoryController>()) {
      Get.put(
        DisciplinesDirectoryController(
          repository: DisciplinesDirectoryRepositoryImpl(),
        ),
      );
    }
    return Get.find<DisciplinesDirectoryController>();
  }

  static TrainersController getTrainersController() {
    if (!Get.isRegistered<TrainersController>()) {
      Get.put(
        TrainersController(repository: TrainersDirectoryRepositoryImpl()),
      );
    }
    return Get.find<TrainersController>();
  }

  static CapabilitiesController getCapabilitiesController() {
    if (!Get.isRegistered<CapabilitiesController>()) {
      Get.put(
        CapabilitiesController(
          repository: CapabilitiesDirectoryRepositoryImpl(),
        ),
      );
    }
    return Get.find<CapabilitiesController>();
  }
}
