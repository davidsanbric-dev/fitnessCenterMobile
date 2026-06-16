import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/features/bookings/logic/services/bookings_service.dart';
import 'package:get/get.dart';

/// Drives the Assessment Results sub-page: completed bookings that carry a
/// trainer feedback note, sorted most-recent first. The full list is held in
/// memory so the view can filter/display without extra fetches.
class AssessmentResultsController extends ControllerBase {
  AssessmentResultsController({BookingsService? bookingsService})
    : _bookingsService = bookingsService ?? BookingsService();

  final BookingsService _bookingsService;

  final _completed = <BookingDto>[].obs;

  /// Only sessions where the trainer left a note.
  List<BookingDto> get assessments => _completed
      .where((b) => (b.notes ?? '').trim().isNotEmpty)
      .toList(growable: false);

  @override
  void onReady() {
    super.onReady();
    load();
  }

  Future<void> load() async {
    if (isLoading.value) return;

    await runLoading(
      action: () => _bookingsService.fetchBookings(
        bookingStatus: 'COMPLETED',
        // Completed sessions are past-dated; opt out of the default upcoming
        // date window so they aren't filtered out server-side, and fetch the
        // full set (page_size 0) so no assessment note is capped off.
        includeAllDates: true,
        pageSize: 0,
      ),
      errorMessage: 'Unexpected error while loading assessment results',
      onSuccess: (items) => _completed.assignAll(items),
      onError: () => _completed.clear(),
    );
  }

  Future<void> reload() => load();
}
