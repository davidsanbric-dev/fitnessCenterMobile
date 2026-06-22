import 'package:fitnesscenter_mobile/app/core/di/locator.dart';
import 'package:fitnesscenter_mobile/features/class_booking/data/ports/get_agenda_refresh_port.dart';
import 'package:fitnesscenter_mobile/features/class_booking/data/repositories/repositories.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/class_booking_repository.dart';
import 'package:fitnesscenter_mobile/features/class_booking/presentation/viewmodels/class_booking_view_model.dart';
import 'package:get/get.dart';

class ClassBookingInjector {
  static void ensureRegistered() {
    final repository = getOrPut<ClassBookingRepository>(
      ClassBookingRepositoryImpl.new,
      permanent: true,
    );
    final agendaRefreshPort = getOrPut<AgendaRefreshPort>(
      GetAgendaRefreshPort.new,
      permanent: true,
    );
    getOrPut<ClassBookingViewModel>(
      () => ClassBookingViewModel(
        repository: repository,
        agendaRefreshPort: agendaRefreshPort,
      ),
      permanent: true,
    );
  }

  static ClassBookingViewModel getSharedClassBookingViewModel() {
    ensureRegistered();
    return Get.find<ClassBookingViewModel>();
  }
}
