import 'package:portfolio_mobile_app/features/bookings/logic/bookings_controller.dart';
import 'package:portfolio_mobile_app/features/class_booking/domain/agenda_refresh_port.dart';
import 'package:get/get.dart';

class GetAgendaRefreshPort implements AgendaRefreshPort {
  @override
  Future<void> refreshAgenda() async {
    if (Get.isRegistered<BookingsController>()) {
      await Get.find<BookingsController>().reload();
    }
  }
}
