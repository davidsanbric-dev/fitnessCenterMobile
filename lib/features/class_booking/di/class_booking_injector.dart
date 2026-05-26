import 'package:portfolio_mobile_app/features/class_booking/data/repositories/repositories.dart';
import 'package:portfolio_mobile_app/features/class_booking/logic/class_booking_controller.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/class_booking_repository.dart';
import 'package:portfolio_mobile_app/features/class_booking/logic/get_agenda_refresh_port.dart';
import 'package:get/get.dart';

class ClassBookingInjector {
  static void ensureRegistered() {
    if (!Get.isRegistered<ClassBookingRepository>()) {
      Get.put<ClassBookingRepository>(
        ClassBookingRepositoryImpl(),
        permanent: true,
      );
    }
    if (!Get.isRegistered<AgendaRefreshPort>()) {
      Get.put<AgendaRefreshPort>(GetAgendaRefreshPort(), permanent: true);
    }
    if (!Get.isRegistered<ClassBookingController>()) {
      Get.put(
        ClassBookingController(
          repository: Get.find<ClassBookingRepository>(),
          agendaRefreshPort: Get.find<AgendaRefreshPort>(),
        ),
        permanent: true,
      );
    }
  }

  static ClassBookingController createClassBookingController() {
    return ClassBookingController(repository: ClassBookingRepositoryImpl());
  }

  static ClassBookingController getSharedClassBookingController() {
    ensureRegistered();
    return Get.find<ClassBookingController>();
  }
}
