import 'package:fitnesscenter_mobile/app/core/exceptions/api_exception.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/schemas/booking/booking_state_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/dialogs/assign_row_value_dialog.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/utils/normalize.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/bookings/domain/domain.dart';

/// Outcome of a booking-status intent, carrying the snackbar title/message the
/// widget-facing layer surfaces. Keeps the view-model free of UI dependencies.
class BookingActionResult {
  const BookingActionResult({required this.title, required this.message});

  final String title;
  final String message;
}

class BookingsViewModel extends ViewModelBase {
  BookingsViewModel({required BookingsRepository repository})
    : _repository = repository;

  static const String _confirmReservationAction = '1';
  static const String _cancelReservationAction = '2';
  static const String _reservedState = 'RESERVADA';
  static const String _confirmedState = 'CONFIRMADA';
  static const String _canceledState = 'ANULADA';

  // Statuses members are not allowed to set from the generic picker. "Completed"
  // is an operational/admin outcome, not a member-driven transition.
  static const Set<String> _memberHiddenStatusCodes = {
    'completed',
    'completada',
  };
  static const int _defaultBookingsPageSize = 6;

  final BookingsRepository _repository;

  final List<BookingDto> bookings = <BookingDto>[];
  final List<BookingStateDto> states = <BookingStateDto>[];
  bool isLoading = false;
  String? error;
  int bookingsPageNumber = 1;
  int bookingsPageSize = _defaultBookingsPageSize;
  int bookingsTotalItems = 0;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  List<BookingDto> get bookingsPageRows => sliceTablePage(
    bookings.toList(growable: false),
    pageNumber: bookingsPageNumber,
    pageSize: bookingsPageSize,
    defaultPageSize: _defaultBookingsPageSize,
  );

  Future<void> loadBookings() async {
    if (isLoading) return;

    await runLoad<List<BookingDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () => _repository.fetchBookings(),
      onSuccess: (items) {
        bookings
          ..clear()
          ..addAll(items);
        _syncBookingsPagination();
        _hasLoaded = true;
      },
      onError: () {
        bookings.clear();
        _syncBookingsPagination();
      },
      unexpectedErrorMessage: 'Unexpected error while loading bookings',
    );
  }

  Future<void> reload() => loadBookings();

  void setBookingsPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: bookingsPageNumber,
    value: value,
    setPageNumber: (v) => bookingsPageNumber = v,
    syncPagination: _syncBookingsPagination,
  );

  void setBookingsPageSize(int value) => applyTablePageSize(
    currentPageSize: bookingsPageSize,
    value: value,
    setPageNumber: (v) => bookingsPageNumber = v,
    setPageSize: (v) => bookingsPageSize = v,
    syncPagination: _syncBookingsPagination,
  );

  /// Fetches the full detail payload for a row's booking. Throws
  /// [ApiException] on failure so the widget-facing layer can present it.
  Future<BookingDto> fetchBookingDetails({required String bookingId}) {
    return _repository.fetchBookingDetails(bookingId: bookingId);
  }

  Future<BookingActionResult> confirmReservation(Map<String, dynamic> row) {
    return _updateBookingStatusAction(
      row: row,
      actionCode: _confirmReservationAction,
      expectedStates: const <String>{_reservedState, _canceledState},
      fallbackState: _confirmedState,
      successStateLabel: 'confirmed',
      unavailableMessage:
          'Only reserved or canceled bookings can be confirmed.',
    );
  }

  Future<BookingActionResult> cancelReservation(Map<String, dynamic> row) {
    return _updateBookingStatusAction(
      row: row,
      actionCode: _cancelReservationAction,
      expectedStates: const <String>{_reservedState, _confirmedState},
      fallbackState: _canceledState,
      successStateLabel: 'canceled',
      unavailableMessage:
          'Only reserved or confirmed bookings can be canceled.',
    );
  }

  /// Loads the backend status catalog once, so the generic picker can offer the
  /// full set of member-selectable statuses. Non-fatal on failure.
  Future<void> ensureBookingStatesLoaded() async {
    if (states.isNotEmpty) return;
    try {
      final data = await _repository.fetchBookingStates();
      states
        ..clear()
        ..addAll(data);
    } catch (_) {
      // Non-fatal: fall back to statuses derived from the loaded bookings.
    }
  }

  /// Builds the member-selectable status options for the generic picker,
  /// hiding operational/admin-only outcomes.
  List<AssignRowValueOption> buildStateOptions() {
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

  /// Resolves which option should be pre-selected for [row]'s current status.
  String resolveStateOptionIdForRow(
    List<AssignRowValueOption> options,
    Map<String, dynamic> row,
  ) {
    return _resolveStateOptionId(
      options,
      _normalizeState(row['bookingStatus'] ?? row['state']),
    );
  }

  /// Applies a member-picked status to a booking and refreshes the list.
  /// Returns `null` on success or an error message describing the failure.
  Future<String?> applyBookingStatus({
    required String bookingId,
    required String state,
  }) async {
    try {
      await _repository.updateBookingStatus(bookingId: bookingId, state: state);
      await _refreshBookingsAfterStatusUpdate(
        bookingId: bookingId,
        fallbackState: state,
      );
      return null;
    } on ApiException catch (error) {
      return error.message;
    } catch (error) {
      return 'Could not update status: $error';
    }
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

  Future<BookingActionResult> _updateBookingStatusAction({
    required Map<String, dynamic> row,
    required String actionCode,
    required Set<String> expectedStates,
    required String fallbackState,
    required String successStateLabel,
    required String unavailableMessage,
  }) async {
    final currentState = _normalizeState(row['bookingStatus'] ?? row['state']);
    if (currentState.isEmpty || !expectedStates.contains(currentState)) {
      return BookingActionResult(
        title: 'Action unavailable',
        message: unavailableMessage,
      );
    }

    try {
      final bookingId = _bookingIdOf(row);

      await _repository.updateBookingStatus(
        bookingId: bookingId,
        state: actionCode,
      );

      await _refreshBookingsAfterStatusUpdate(
        bookingId: bookingId,
        fallbackState: fallbackState,
      );
      return BookingActionResult(
        title: 'Status updated',
        message: 'Booking changed to $successStateLabel.',
      );
    } on ApiException catch (error) {
      return BookingActionResult(
        title: 'Could not update booking',
        message: error.message,
      );
    } catch (error) {
      return BookingActionResult(
        title: 'Unexpected error',
        message: 'Could not update booking status: $error',
      );
    }
  }

  String _bookingIdOf(Map<String, dynamic> row) =>
      normReqString(row['bookingId']);

  String _normalizeState(dynamic value) {
    return value?.toString().trim().toUpperCase() ?? '';
  }

  Future<void> _refreshBookingsAfterStatusUpdate({
    required String bookingId,
    required String fallbackState,
  }) async {
    try {
      final latestBookings = await _repository.fetchBookings();
      bookings
        ..clear()
        ..addAll(latestBookings);
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
    notifyListeners();
  }

  void _syncBookingsPagination() {
    syncTablePaginationValues(
      totalItems: bookings.length,
      pageNumber: bookingsPageNumber,
      pageSize: bookingsPageSize,
      defaultPageSize: _defaultBookingsPageSize,
      setPageNumber: (v) => bookingsPageNumber = v,
      setPageSize: (v) => bookingsPageSize = v,
      onTotalItemsResolved: (value) => bookingsTotalItems = value,
    );
    notifyListeners();
  }
}
