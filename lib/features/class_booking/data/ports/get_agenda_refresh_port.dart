import 'package:fitnesscenter_mobile/features/bookings/feature.dart';
import 'package:fitnesscenter_mobile/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:get/get.dart';

class GetAgendaRefreshPort implements AgendaRefreshPort {
  @override
  Future<void> refreshAgenda() async {
    if (Get.isRegistered<BookingsViewModel>()) {
      await Get.find<BookingsViewModel>().reload();
    }
  }
}
