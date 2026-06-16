import 'package:portfolio_mobile_app/app/core/controller/controller_base.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:portfolio_mobile_app/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:portfolio_mobile_app/app/core/exceptions/api_exception.dart';
import 'package:portfolio_mobile_app/app/core/shared/services/booking_service.dart';
import 'package:portfolio_mobile_app/app/core/utils/normalize.dart';
import 'package:portfolio_mobile_app/app/core/utils/parse.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/dialogs/assign_row_value_dialog.dart';
import 'package:portfolio_mobile_app/app/core/shared/widgets/table/table_pagination.dart';
import 'package:portfolio_mobile_app/features/bookings/logic/services/bookings_service.dart';
import 'package:portfolio_mobile_app/features/available_slots_listing/presentation/widgets/booking_details_card_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingsController extends ControllerBase {
  static const String _confirmReservationAction = '1';
  static const String _cancelReservationAction = '2';
  static const String _reservedState = 'RESERVADA';
  static const String _confirmedState = 'CONFIRMADA';
  static const String _canceledState = 'ANULADA';

  // Statuses members are not allowed to set from the generic picker. "Completed"
  // is an operational/admin outcome, not a member-driven transition.
  static const Set<String> _memberHiddenStatusCodes = {'completed', 'completada'};
  static const int _defaultBookingsPageSize = 6;

  BookingsController({
    BookingsService? bookingsService,
    BookingService? bookingService,
  }) : _bookingsService = bookingsService ?? BookingsService(),
       _bookingService = bookingService ?? BookingService();

  final BookingsService _bookingsService;
  final BookingService _bookingService;

  final bookings = <BookingDto>[].obs;
  final states = <BookingStateDto>[].obs;
  final bookingsPageNumber = 1.obs;
  final bookingsPageSize = _defaultBookingsPageSize.obs;
  final bookingsTotalItems = 0.obs;

  bool _hasLoaded = false;

  @override
  void onReady() {
    super.onReady();
    loadBookings();
  }

  Future<void> loadBookings() async {
    if (isLoading.value) return;

    await runLoading(
      action: () => _bookingsService.fetchBookings(),
      errorMessage: 'Unexpected error while loading bookings',
      onSuccess: (items) {
        bookings.assignAll(items);
        _syncBookingsPagination();
        _hasLoaded = true;
      },
      onError: () {
        bookings.clear();
        _syncBookingsPagination();
      },
    );
  }

  Future<void> reload() => loadBookings();

  bool get hasLoaded => _hasLoaded;
  List<BookingDto> get bookingsPageRows => sliceTablePage(
    bookings.toList(growable: false),
    pageNumber: bookingsPageNumber.value,
    pageSize: bookingsPageSize.value,
    defaultPageSize: _defaultBookingsPageSize,
  );

  void setBookingsPageNumber(int value) => setTablePageNumber(
    pageNumber: bookingsPageNumber,
    value: value,
    syncPagination: _syncBookingsPagination,
  );

  void setBookingsPageSize(int value) => setTablePageSize(
    pageNumber: bookingsPageNumber,
    pageSize: bookingsPageSize,
    value: value,
    syncPagination: _syncBookingsPagination,
  );

  Future<void> showBookingDetails(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    try {
      final detail = await _bookingService.fetchBookingDetails(
        bookingId: normReqString(row['bookingId']),
        locationCode: _resolveLocationArg(row),
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

  Future<void> confirmReservation(
    BuildContext _,
    Map<String, dynamic> row,
  ) async {
    await _updateBookingStatusAction(
      row: row,
      actionCode: _confirmReservationAction,
      expectedStates: const <String>{_reservedState, _canceledState},
      fallbackState: _confirmedState,
      successStateLabel: 'confirmed',
      unavailableMessage:
          'Only reserved or canceled bookings can be confirmed.',
    );
  }

  Future<void> cancelReservation(
    BuildContext _,
    Map<String, dynamic> row,
  ) async {
    await _updateBookingStatusAction(
      row: row,
      actionCode: _cancelReservationAction,
      expectedStates: const <String>{_reservedState, _confirmedState},
      fallbackState: _canceledState,
      successStateLabel: 'canceled',
      unavailableMessage:
          'Only reserved or confirmed bookings can be canceled.',
    );
  }

  /// Generic status picker: lets the member pick any backend-supported booking
  /// status and apply it, mirroring the available-slots / web-admin flow.
  Future<void> updateBookingStatus(
    BuildContext context,
    Map<String, dynamic> row,
  ) async {
    await _ensureBookingStatesLoaded();

    final options = _buildStateOptions();
    if (options.isEmpty) {
      Get.snackbar(
        'Action unavailable',
        'No booking statuses are available to apply.',
      );
      return;
    }

    final initialValue = _resolveStateOptionId(
      options,
      _normalizeState(row['bookingStatus'] ?? row['state']),
    );

    if (!context.mounted) return;
    final updatedState = await showAssignRowValueDialog(
      context: context,
      title: 'Update Status',
      fieldLabel: 'Status',
      emptySelectionMessage: 'Select a status',
      confirmLabel: 'Update',
      initialValue: initialValue,
      options: options,
      onSubmit: (value) async {
        try {
          final bookingId = normReqString(row['bookingId']);
          await _bookingService.updateBookingStatus(
            bookingId: bookingId,
            state: value,
            locationCode: _resolveLocationArg(row),
          );
          await _refreshBookingsAfterStatusUpdate(
            bookingId: bookingId,
            fallbackState: value,
          );
          return null;
        } on ApiException catch (error) {
          return error.message;
        } catch (error) {
          return 'Could not update status: $error';
        }
      },
    );

    if (updatedState != null) {
      Get.snackbar('Status updated', 'Booking changed to $updatedState.');
    }
  }

  Future<void> _ensureBookingStatesLoaded() async {
    if (states.isNotEmpty) return;
    try {
      final data = await _bookingService.fetchBookingStates();
      states.assignAll(data);
    } catch (_) {
      // Non-fatal: fall back to statuses derived from the loaded bookings.
    }
  }

  List<AssignRowValueOption> _buildStateOptions() {
    final source = states.isNotEmpty
        ? states.toList(growable: false)
        : bookings
              .map(
                (booking) =>
                    BookingStateDto(code: booking.state, label: booking.state),
              )
              .toList(growable: false);

    final selectable = source
        .where(
          (state) =>
              !_memberHiddenStatusCodes.contains(
                state.code.trim().toLowerCase(),
              ) &&
              !_memberHiddenStatusCodes.contains(
                state.label.trim().toLowerCase(),
              ),
        )
        .toList(growable: false);

    return buildOptions<BookingStateDto>(
      source: selectable,
      idSelector: (state) => state.code,
      labelSelector: (state) => state.label,
      normalizeId: (value) => value.toLowerCase(),
    );
  }

  String _resolveStateOptionId(
    List<AssignRowValueOption> options,
    String currentValue,
  ) {
    final normalized = currentValue.trim().toLowerCase();
    if (normalized.isNotEmpty) {
      for (final option in options) {
        final optionId = option.id.trim().toLowerCase();
        final optionLabel = option.label.trim().toLowerCase();
        if (optionId == normalized || optionLabel == normalized) {
          return option.id;
        }
      }
    }
    return options.first.id;
  }

  Future<void> _updateBookingStatusAction({
    required Map<String, dynamic> row,
    required String actionCode,
    required Set<String> expectedStates,
    required String fallbackState,
    required String successStateLabel,
    required String unavailableMessage,
  }) async {
    final currentState = _normalizeState(row['bookingStatus'] ?? row['state']);
    if (currentState.isEmpty || !expectedStates.contains(currentState)) {
      Get.snackbar('Action unavailable', unavailableMessage);
      return;
    }

    try {
      final bookingId = normReqString(row['bookingId']);

      await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        state: actionCode,
        locationCode: _resolveLocationArg(row),
      );

      await _refreshBookingsAfterStatusUpdate(
        bookingId: bookingId,
        fallbackState: fallbackState,
      );
      Get.snackbar('Status updated', 'Booking changed to $successStateLabel.');
    } on ApiException catch (error) {
      Get.snackbar('Could not update booking', error.message);
    } catch (error) {
      Get.snackbar(
        'Unexpected error',
        'Could not update booking status: $error',
      );
    }
  }

  String _normalizeState(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  /// Location argument for booking requests. Prefers the real `/statics`
  /// location code carried by the booking (e.g. `LOC001`); only falls back to
  /// the numeric id when the code is missing. The booking's `locationId` is a
  /// DB primary key, not the synthetic id the LocationCodeRegistry knows, so
  /// sending it would resolve to the wrong code and 404.
  Object _resolveLocationArg(Map<String, dynamic> row) {
    final code = normOptString(row['locationCode']);
    if (code != null && code.isNotEmpty) {
      return code;
    }
    return parseReqInt(row['locationId']);
  }

  Future<void> _refreshBookingsAfterStatusUpdate({
    required String bookingId,
    required String fallbackState,
  }) async {
    try {
      final latestBookings = await _bookingsService.fetchBookings();
      bookings.assignAll(latestBookings);
      _syncBookingsPagination();
      _hasLoaded = true;
    } catch (_) {
      // Keep UI responsive even if the follow-up refresh fails.
      _applyBookingState(bookingId: bookingId, state: fallbackState);
    }
  }

  void _applyBookingState({required String bookingId, required String state}) {
    final trimmedId = bookingId.trim();
    final trimmedState = state.trim();
    if (trimmedId.isEmpty || trimmedState.isEmpty) return;

    final index = bookings.indexWhere((item) => item.bookingId == trimmedId);
    if (index < 0) return;

    bookings[index] = bookings[index].copyWith(state: trimmedState);
    bookings.refresh();
  }

  void _syncBookingsPagination() {
    syncTablePaginationState(
      totalItems: bookings.length,
      pageNumber: bookingsPageNumber,
      pageSize: bookingsPageSize,
      defaultPageSize: _defaultBookingsPageSize,
      onTotalItemsResolved: (value) => bookingsTotalItems.value = value,
    );
  }
}
