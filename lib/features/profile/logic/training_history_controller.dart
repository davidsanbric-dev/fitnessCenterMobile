import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/booking_service.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:portfolio_mobile_app/features/bookings/logic/services/bookings_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Drives the read-only "Training History" sub-page: the member's COMPLETED
/// bookings, refreshed on open / pull-to-refresh so a session the trainer just
/// marked completed (in the web panel) surfaces here.
class TrainingHistoryController extends ControllerBase {
  static const String _completedStatus = 'COMPLETED';
  static const int _defaultPageSize = 6;

  TrainingHistoryController({
    BookingsService? bookingsService,
    BookingService? bookingService,
  }) : _bookingsService = bookingsService ?? BookingsService(),
       _bookingService = bookingService ?? BookingService();

  final BookingsService _bookingsService;
  final BookingService _bookingService;

  final bookings = <BookingDto>[].obs;
  final pageNumber = 1.obs;
  final pageSize = _defaultPageSize.obs;
  final totalItems = 0.obs;

  @override
  void onReady() {
    super.onReady();
    loadHistory();
  }

  Future<void> loadHistory() async {
    if (isLoading.value) return;

    await runLoading(
      action: () => _bookingsService.fetchBookings(
        bookingStatus: _completedStatus,
        // History is past-dated; opt out of the default upcoming date window
        // so completed sessions aren't filtered out server-side.
        includeAllDates: true,
        // Fetch every completed session (page_size 0 = no server cap); the list
        // is then paginated client-side, so a member with a long history isn't
        // capped at the backend's default page size.
        pageSize: 0,
      ),
      errorMessage: 'Unexpected error while loading training history',
      onSuccess: (items) {
        bookings.assignAll(items);
        _syncPagination();
      },
      onError: () {
        bookings.clear();
        _syncPagination();
      },
    );
  }

  Future<void> reload() => loadHistory();

  List<BookingDto> get pageRows => sliceTablePage(
    bookings.toList(growable: false),
    pageNumber: pageNumber.value,
    pageSize: pageSize.value,
    defaultPageSize: _defaultPageSize,
  );

  void setPageNumber(int value) => setTablePageNumber(
    pageNumber: pageNumber,
    value: value,
    syncPagination: _syncPagination,
  );

  Future<void> showBookingDetails(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    try {
      final detail = await _bookingService.fetchBookingDetails(
        bookingId: normReqString(row['bookingId']),
      );

      if (!context.mounted) return;
      await BookingDetailsCardDialog.show(context, booking: detail);
    } on ApiException catch (error) {
      Get.snackbar('Could not load details', error.message);
    } catch (error) {
      Get.snackbar(
        'Unexpected error',
        'Could not show booking details: $error',
      );
    }
  }

  void _syncPagination() {
    syncTablePaginationState(
      totalItems: bookings.length,
      pageNumber: pageNumber,
      pageSize: pageSize,
      defaultPageSize: _defaultPageSize,
      onTotalItemsResolved: (value) => totalItems.value = value,
    );
  }
}
