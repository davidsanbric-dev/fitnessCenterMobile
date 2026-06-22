import 'package:fitnesscenter_mobile/app/core/shared/schemas/bookings/booking_dto.dart';
import 'package:fitnesscenter_mobile/app/core/shared/widgets/table/table_pagination.dart';
import 'package:fitnesscenter_mobile/app/core/viewmodel/view_model_base.dart';
import 'package:fitnesscenter_mobile/features/profile/domain/domain.dart';

/// Drives the read-only "Training History" sub-page: the member's COMPLETED
/// bookings, refreshed on open / pull-to-refresh so a session the trainer just
/// marked completed (in the web panel) surfaces here. The full list is held in
/// memory and paginated client-side.
class TrainingHistoryViewModel extends ViewModelBase {
  TrainingHistoryViewModel({MemberBookingsRepository? repository})
    : _repository = repository ?? (throw ArgumentError.notNull('repository'));

  static const int _defaultPageSize = 6;

  final MemberBookingsRepository _repository;

  final List<BookingDto> bookings = <BookingDto>[];
  bool isLoading = false;
  String? error;
  int pageNumber = 1;
  int pageSize = _defaultPageSize;
  int totalItems = 0;

  bool _hasLoaded = false;
  bool get hasLoaded => _hasLoaded;

  List<BookingDto> get pageRows => sliceTablePage(
    bookings.toList(growable: false),
    pageNumber: pageNumber,
    pageSize: pageSize,
    defaultPageSize: _defaultPageSize,
  );

  Future<void> loadHistory() async {
    if (isLoading) return;

    await runLoad<List<BookingDto>>(
      setLoading: (value) => isLoading = value,
      setError: (message) => error = message,
      loader: () => _repository.fetchCompletedBookings(),
      onSuccess: (items) {
        bookings
          ..clear()
          ..addAll(items);
        _syncPagination();
        _hasLoaded = true;
      },
      onError: () {
        bookings.clear();
        _syncPagination();
      },
      unexpectedErrorMessage: 'Unexpected error while loading training history',
    );
  }

  Future<void> reload() => loadHistory();

  void setPageNumber(int value) => applyTablePageNumber(
    currentPageNumber: pageNumber,
    value: value,
    setPageNumber: (v) => pageNumber = v,
    syncPagination: _syncPagination,
  );

  /// Fetches the full detail payload for a row's booking. Throws
  /// [ApiException] on failure so the widget-facing layer can present it.
  Future<BookingDto> fetchBookingDetails({required String bookingId}) {
    return _repository.fetchBookingDetails(bookingId: bookingId);
  }

  void _syncPagination() {
    syncTablePaginationValues(
      totalItems: bookings.length,
      pageNumber: pageNumber,
      pageSize: pageSize,
      defaultPageSize: _defaultPageSize,
      setPageNumber: (v) => pageNumber = v,
      setPageSize: (v) => pageSize = v,
      onTotalItemsResolved: (value) => totalItems = value,
    );
    notifyListeners();
  }
}
